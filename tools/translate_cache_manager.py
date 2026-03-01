#!/usr/bin/env python3
import argparse
import datetime as dt
import fnmatch
import json
import os
import re
import shlex
import subprocess
import sys
import threading
import urllib.request
import urllib.parse
import urllib.error
from pathlib import Path

try:
    import tkinter as tk
    from tkinter import messagebox, simpledialog, ttk
    TK_AVAILABLE = True
except ModuleNotFoundError:
    tk = None
    messagebox = None
    simpledialog = None
    ttk = None
    TK_AVAILABLE = False

try:
    from tkcalendar import DateEntry
    CALENDAR_AVAILABLE = True
except ModuleNotFoundError:
    DateEntry = None
    CALENDAR_AVAILABLE = False

DATE_FMT = "%Y-%m-%d"
TS_FMT = "%Y-%m-%dT%H:%M:%SZ"


class ToolTip:
    def __init__(self, widget, text, delay=500):
        self.widget = widget
        self.text = text
        self.delay = delay
        self.tip_window = None
        self._after_id = None

        self.widget.bind("<Enter>", self._on_enter, add="+")
        self.widget.bind("<Leave>", self._on_leave, add="+")
        self.widget.bind("<ButtonPress>", self._on_leave, add="+")

    def _on_enter(self, _event=None):
        self._schedule()

    def _on_leave(self, _event=None):
        self._unschedule()
        self._hide()

    def _schedule(self):
        self._unschedule()
        self._after_id = self.widget.after(self.delay, self._show)

    def _unschedule(self):
        if self._after_id is not None:
            self.widget.after_cancel(self._after_id)
            self._after_id = None

    def _show(self):
        if self.tip_window is not None:
            return
        x = self.widget.winfo_pointerx() + 14
        y = self.widget.winfo_pointery() + 14
        self.tip_window = tw = tk.Toplevel(self.widget)
        tw.wm_overrideredirect(True)
        tw.wm_geometry(f"+{x}+{y}")
        label = tk.Label(
            tw,
            text=self.text,
            justify="left",
            background="#ffffe0",
            relief="solid",
            borderwidth=1,
            wraplength=460,
            padx=6,
            pady=4,
        )
        label.pack()

    def _hide(self):
        if self.tip_window is not None:
            self.tip_window.destroy()
            self.tip_window = None


class CacheManagerApp:
    def __init__(self, root, cache_dir: Path):
        self.root = root
        self.cache_dir = cache_dir
        self.root.title("Freetz Translate Cache Manager")
        # Set reasonable initial size that fits on most screens (even 1366x768)
        self.root.geometry("1400x650")
        # Set minimum size to prevent UI breaking on too small windows
        self.root.minsize(1000, 500)
        # Center window on screen
        self.root.update_idletasks()
        x = (self.root.winfo_screenwidth() // 2) - (1400 // 2)
        y = (self.root.winfo_screenheight() // 2) - (650 // 2)
        self.root.geometry(f"1400x650+{x}+{y}")

        self.lang_data = {}  # Key: file_stem (e.g., "it", "it-rutorrent"), Value: JSON dict
        self.index = []
        self.filtered_ids = []
        self.row_by_id = {}
        self.dirty_langs = set()  # Track which file_stems have changes
        self.sort_column = None
        self.sort_reverse = False
        self.preferred_user = self._default_github_user()

        self._icons = {
            "add_entry": "➕",
            "save_all": "💾",
            "help": "ℹ",
            "search": "🔍",
            "reload": "⟳",
            "entry_editor": "📝",
            "bulk": "⚡",
            "test_translation": "🧪",
            "test_agent": "🔑",
            "shortcuts": "⌨",
            "use_editor": "📋",
            "play": "▶",
            "apply": "✓",
            "delete": "✗",
            "trash": "🗑",
            "next": "⬇",
            "prev": "⬆",
            "success": "✅",
            "error": "❌",
            "warn": "⚠",
            "info": "ℹ",
            "hint": "💡",
            "pending": "⏳",
            "theme": "◐",
        }
        if sys.platform.startswith("linux"):
            self._icons.update({
                "add_entry": "✚",
                "save_all": "◉",
                "help": "ℹ",
                "search": "⌕",
                "reload": "↻",
                "entry_editor": "✎",
                "test_translation": "⚗",
                "test_agent": "⚙",
                "shortcuts": "☰",
                "use_editor": "✍",
                "play": "▸",
                "apply": "✔",
                "delete": "✖",
                "trash": "⌦",
                "next": "➜",
                "prev": "⬅",
                "success": "✔",
                "error": "✖",
                "warn": "⚠",
                "info": "ℹ",
                "hint": "☞",
                "pending": "⌛",
                "theme": "◑",
            })
        
        # Search state
        self.search_query = ""
        self.search_results = []
        self.search_current_index = -1
        self.search_dialog = None
        
        # Selection anchor for Shift+arrow navigation
        self.selection_anchor = None

        # Live grammar/spellcheck state for Translation editor
        self._suspend_live_grammar = False
        self._live_grammar_after_id = None
        self._live_grammar_request_seq = 0
        self._live_grammar_issue_tags = []
        self._live_grammar_issue_tooltips = {}
        self._live_grammar_tooltip_window = None
        
        # Flag to prevent reloading values when restoring selection after "No" in unsaved changes dialog
        self._restoring_selection = False
        
        # Column visibility state
        self.column_widths = {
            "lang": 60, "file": 150, "package": 140, "agent": 90, "source": 280,
            "original": 280, "translation": 320,
            "timestamp": 155, "github_user": 120
        }
        self.column_visibility = {
            "lang": False, "file": False, "package": True, "agent": False, "source": False,
            "original": True, "translation": True,
            "timestamp": False, "github_user": False
        }

        self._build_ui()
        self._setup_keyboard_bindings()
        self._setup_tooltips()
        self._setup_notebook_tab_tooltips()
        self._load_all()
        self._refresh_filter_values()
        self.apply_filters()
        
        # Intercept window close to check for unsaved changes
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        
        # Set PanedWindow sash position to 65% after UI is fully rendered
        self.root.after(500, self._set_paned_position)

    def _label(self, icon_key, text):
        icon = self._icons.get(icon_key, "")
        return f"{icon} {text}".strip()

    def _configure_windows_tree_style(self, style_obj):
        style_obj.configure(
            "Entries.Treeview",
            rowheight=22,
            background="white",
            fieldbackground="white",
            borderwidth=1,
            relief="solid",
        )
        style_obj.configure(
            "Entries.Treeview.Heading",
            background="#d9d9d9",
            foreground="#000000",
            borderwidth=1,
            relief="raised",
            padding=(6, 3),
        )
        style_obj.map(
            "Entries.Treeview.Heading",
            background=[("active", "#c7c7c7"), ("pressed", "#b8b8b8")],
        )

    def _apply_theme(self, theme_name):
        style_obj = ttk.Style(self.root)
        current = style_obj.theme_use()
        if theme_name == current:
            return

        try:
            style_obj.theme_use(theme_name)
        except tk.TclError:
            return

        if sys.platform.startswith("win") and hasattr(self, "tree"):
            self._configure_windows_tree_style(style_obj)
            self.tree.configure(style="Entries.Treeview")

        self.update_status_bar(message=f"Theme changed to: {theme_name}")
        if hasattr(self, "_update_tree_column_separators"):
            self._update_tree_column_separators()

    def show_theme_menu(self):
        style_obj = ttk.Style(self.root)
        themes = sorted(style_obj.theme_names())
        current = style_obj.theme_use()

        menu = tk.Menu(self.root, tearoff=0)
        theme_var = tk.StringVar(value=current)
        for name in themes:
            menu.add_radiobutton(
                label=name,
                variable=theme_var,
                value=name,
                command=lambda n=name: self._apply_theme(n),
            )

        x = self.btn_theme.winfo_rootx()
        y = self.btn_theme.winfo_rooty() + self.btn_theme.winfo_height()
        try:
            menu.tk_popup(x, y)
        finally:
            menu.grab_release()

    def _build_ui(self):
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(2, weight=1)

        # Top toolbar
        toolbar = ttk.Frame(self.root, padding=8)
        toolbar.grid(row=0, column=0, sticky="ew")
        toolbar.columnconfigure(1, weight=1)

        self.lbl_cache_dir = ttk.Label(toolbar, text="Cache dir:")
        self.lbl_cache_dir.grid(row=0, column=0, sticky="w")
        self.cache_dir_var = tk.StringVar(value=str(self.cache_dir))
        self.entry_cache_dir = ttk.Entry(toolbar, textvariable=self.cache_dir_var, width=60)
        self.entry_cache_dir.grid(row=0, column=1, sticky="ew", padx=(4, 8))
        self.btn_reload = ttk.Button(toolbar, text=self._label("reload", "Reload"), command=self.reload_from_path)
        self.btn_reload.grid(row=0, column=2, padx=2)
        
        self.lbl_default_user = ttk.Label(toolbar, text="Default user:")
        self.lbl_default_user.grid(row=0, column=3, sticky="w", padx=(12, 4))
        self.preferred_user_var = tk.StringVar(value=self.preferred_user)
        self.entry_default_user = ttk.Entry(toolbar, textvariable=self.preferred_user_var, width=16)
        self.entry_default_user.grid(row=0, column=4, sticky="w", padx=(0, 8))
        
        self.btn_add_entry = ttk.Button(toolbar, text=self._label("add_entry", "Add entry"), command=self.add_new_entry)
        self.btn_add_entry.grid(row=0, column=5, padx=2)
        self.btn_save_all = ttk.Button(toolbar, text=self._label("save_all", "Save all"), command=self.save_all)
        self.btn_save_all.grid(row=0, column=6, padx=2)
        self.btn_help = ttk.Button(toolbar, text=self._label("help", "Help"), command=self.show_app_help)
        self.btn_help.grid(row=0, column=7, padx=(12, 2))
        self.btn_shortcuts = ttk.Button(toolbar, text=self._label("shortcuts", "Shortcuts"), command=self.show_shortcuts_help)
        self.btn_shortcuts.grid(row=0, column=8, padx=2)
        self.btn_theme = ttk.Button(toolbar, text=self._label("theme", "Theme"), command=self.show_theme_menu)
        self.btn_theme.grid(row=0, column=9, padx=2)

        # Filters panel
        filters = ttk.LabelFrame(self.root, text="Filters", padding=8)
        filters.grid(row=1, column=0, sticky="ew", padx=8, pady=(0, 8))
        filters.columnconfigure(10, weight=1)

        # Row 1: Basic filters
        ttk.Label(filters, text="Language").grid(row=0, column=0, sticky="w")
        self.lang_var = tk.StringVar(value="ALL")
        self.lang_combo = ttk.Combobox(filters, textvariable=self.lang_var, width=12, state="readonly")
        self.lang_combo.grid(row=0, column=1, sticky="w", padx=(4, 12))
        self.lang_combo.bind("<<ComboboxSelected>>", lambda e: self._update_file_filter())

        ttk.Label(filters, text="Package").grid(row=0, column=2, sticky="w")
        self.file_var = tk.StringVar(value="ALL")
        self.file_combo = ttk.Combobox(filters, textvariable=self.file_var, width=18, state="readonly")
        self.file_combo.grid(row=0, column=3, sticky="w", padx=(4, 12))

        ttk.Label(filters, text="Agent").grid(row=0, column=4, sticky="w")
        self.agent_var = tk.StringVar(value="ALL")
        self.agent_combo = ttk.Combobox(filters, textvariable=self.agent_var, width=12, state="readonly")
        self.agent_combo.grid(row=0, column=5, sticky="w", padx=(4, 12))

        ttk.Label(filters, text="User").grid(row=0, column=6, sticky="w")
        self.user_var = tk.StringVar(value="ALL")
        self.user_combo = ttk.Combobox(filters, textvariable=self.user_var, width=14, state="readonly")
        self.user_combo.grid(row=0, column=7, sticky="w", padx=(4, 12))

        self.only_no_meta = tk.BooleanVar(value=False)
        ttk.Checkbutton(filters, text="Only without metadata", variable=self.only_no_meta).grid(row=0, column=8, sticky="w", padx=(0, 12))

        self.btn_apply_filter = ttk.Button(filters, text="Apply filter", command=self.apply_filters)
        self.btn_apply_filter.grid(row=2, column=5, sticky="w", pady=(8, 0), padx=(12, 6))
        self.btn_reset_filter = ttk.Button(filters, text="Reset filter", command=self.reset_filters)
        self.btn_reset_filter.grid(row=2, column=6, sticky="w", pady=(8, 0), padx=(0, 6))

        # Row 2: Search
        ttk.Label(filters, text="Search").grid(row=1, column=0, sticky="w", pady=(8, 0))
        self.search_var = tk.StringVar()
        ttk.Entry(filters, textvariable=self.search_var, width=35).grid(row=1, column=1, columnspan=2, sticky="ew", pady=(8, 0), padx=(4, 12))

        self.search_mode_var = tk.StringVar(value="contains")
        ttk.Combobox(
            filters, textvariable=self.search_mode_var, state="readonly", width=10,
            values=["contains", "wildcard", "regex"]
        ).grid(row=1, column=3, sticky="w", pady=(8, 0), padx=(4, 12))

        self.case_sensitive = tk.BooleanVar(value=False)
        ttk.Checkbutton(filters, text="Case", variable=self.case_sensitive).grid(row=1, column=4, sticky="w", pady=(8, 0))

        self.in_key = tk.BooleanVar(value=True)
        self.in_original = tk.BooleanVar(value=True)
        self.in_translation = tk.BooleanVar(value=True)
        ttk.Label(filters, text="In:").grid(row=1, column=5, sticky="w", pady=(8, 0))
        search_fields = ttk.Frame(filters)
        search_fields.grid(row=1, column=6, columnspan=2, sticky="w", pady=(8, 0))
        ttk.Checkbutton(search_fields, text="key", variable=self.in_key).pack(side="left", padx=(0, 6))
        ttk.Checkbutton(search_fields, text="original", variable=self.in_original).pack(side="left", padx=(0, 6))
        ttk.Checkbutton(search_fields, text="translation", variable=self.in_translation).pack(side="left")

        # Row 3: Date filter
        self.date_enabled = tk.BooleanVar(value=False)
        ttk.Checkbutton(filters, text="Date period", variable=self.date_enabled).grid(row=2, column=0, sticky="w", pady=(8, 0))

        if CALENDAR_AVAILABLE:
            self.date_from_widget = DateEntry(filters, date_pattern="yyyy-mm-dd", width=12)
            self.date_from_widget.grid(row=2, column=1, sticky="w", pady=(8, 0), padx=(4, 12))
            self.date_to_widget = DateEntry(filters, date_pattern="yyyy-mm-dd", width=12)
            self.date_to_widget.grid(row=2, column=3, sticky="w", pady=(8, 0), padx=(4, 12))
            ttk.Label(filters, text="From").grid(row=2, column=2, sticky="e", pady=(8, 0), padx=(0, 4))
            ttk.Label(filters, text="To").grid(row=2, column=4, sticky="e", pady=(8, 0), padx=(0, 4))
        else:
            ttk.Label(filters, text="From (YYYY-MM-DD)").grid(row=2, column=1, sticky="w", pady=(8, 0), padx=(4, 4))
            self.date_from_var = tk.StringVar()
            ttk.Entry(filters, textvariable=self.date_from_var, width=12).grid(row=2, column=2, sticky="w", pady=(8, 0), padx=(0, 12))
            ttk.Label(filters, text="To (YYYY-MM-DD)").grid(row=2, column=3, sticky="w", pady=(8, 0), padx=(4, 4))
            self.date_to_var = tk.StringVar()
            ttk.Entry(filters, textvariable=self.date_to_var, width=12).grid(row=2, column=4, sticky="w", pady=(8, 0), padx=(0, 12))

        # Row 3 (right side): Filter status note next to filter action buttons
        self.filters_note_var = tk.StringVar(value="ℹ No active filters. Showing all entries.")
        self.lbl_filters_note = ttk.Label(filters, textvariable=self.filters_note_var, foreground="#1a5fb4")
        self.lbl_filters_note.configure(anchor="e", justify="right")
        self.lbl_filters_note.grid(row=2, column=7, columnspan=4, sticky="e", pady=(8, 0), padx=(8, 0))

        # Main content area
        body = ttk.Panedwindow(self.root, orient=tk.HORIZONTAL)
        body.grid(row=2, column=0, sticky="nsew", padx=8, pady=(0, 8))

        # Left: TreeView
        left = ttk.Frame(body)
        left.columnconfigure(0, weight=1)
        left.rowconfigure(1, weight=1)

        # Tree toolbar
        tree_toolbar = ttk.Frame(left)
        tree_toolbar.grid(row=0, column=0, columnspan=2, sticky="ew", pady=(0, 4))
        ttk.Label(tree_toolbar, text="Entries").pack(side="left")
        ttk.Button(tree_toolbar, text="Columns", command=self.show_column_menu).pack(side="left", padx=(12, 2))
        ttk.Button(tree_toolbar, text="Select visible", command=self.select_visible).pack(side="left", padx=2)
        ttk.Button(tree_toolbar, text="Clear selection", command=self.clear_selection).pack(side="left", padx=2)
        ttk.Button(tree_toolbar, text=self._label("search", "Search"), command=self.show_search_dialog).pack(side="left", padx=(12, 2))

        columns = ("lang", "file", "package", "agent", "source", "original", "translation", "timestamp", "github_user")
        tree_style_name = "Treeview"
        if sys.platform.startswith("win"):
            self._table_style = ttk.Style(self.root)
            try:
                # Windows native themes (vista/xpnative) may ignore heading background colors.
                # Use clam so custom heading style is actually applied.
                if "clam" in self._table_style.theme_names() and self._table_style.theme_use() != "clam":
                    self._table_style.theme_use("clam")
            except tk.TclError:
                pass

            self._configure_windows_tree_style(self._table_style)
            tree_style_name = "Entries.Treeview"

        self.tree = ttk.Treeview(left, columns=columns, show="headings", selectmode="extended", style=tree_style_name)
        
        self.column_headings = {
            "lang": "Lang", "file": "File", "package": "Package", "agent": "Agent", "source": "Source text",
            "original": "Original", "translation": "Translation",
            "timestamp": "Timestamp", "github_user": "GitHub user"
        }
        self.column_tooltips = {
            "lang": "Target language code of the entry (for example: it, de, fr).",
            "file": "Physical JSON file that contains this entry (base or package-specific cache).",
            "package": "Package label derived from file name (blank for base language cache).",
            "agent": "Translation service/provider used to generate the entry.",
            "source": "Internal source key used as unique identifier in the cache.",
            "original": "Original source text before translation.",
            "translation": "Current translated text stored in cache.",
            "timestamp": "Last creation/update timestamp saved in metadata.",
            "github_user": "GitHub username stored in metadata for authorship/tracking.",
        }
        
        for col in columns:
            self.tree.heading(col, text=self.column_headings[col], command=lambda c=col: self.sort_by_column(c))
            self.tree.column(col, width=self.column_widths[col], anchor="w")
        
        # Apply initial column visibility (hide columns with visibility=False)
        for col in columns:
            if not self.column_visibility[col]:
                self.tree.column(col, width=0)

        # Alternating row colors
        self.tree.tag_configure("oddrow", background="#f0f0f0")
        self.tree.tag_configure("evenrow", background="white")

        self._tree_separator_parent = left
        self._tree_separator_lines = []

        yscroll = ttk.Scrollbar(left, orient="vertical", command=self.tree.yview)
        xscroll = ttk.Scrollbar(left, orient="horizontal", command=self.tree.xview)

        def _on_tree_xscroll(*args):
            xscroll.set(*args)
            self._update_tree_column_separators()

        self.tree.configure(yscrollcommand=yscroll.set, xscrollcommand=_on_tree_xscroll)

        self.tree.grid(row=1, column=0, sticky="nsew")
        yscroll.grid(row=1, column=1, sticky="ns")
        xscroll.grid(row=2, column=0, sticky="ew")
        self.tree.bind("<Configure>", lambda _e: self._update_tree_column_separators(), add="+")
        self.tree.bind("<ButtonRelease-1>", lambda _e: self._update_tree_column_separators(), add="+")
        self.root.after(120, self._update_tree_column_separators)
        self.tree.bind("<Motion>", self._on_tree_heading_motion, add="+")
        self.tree.bind("<Leave>", self._hide_tree_heading_tooltip, add="+")
        self.tree.bind("<ButtonPress-1>", self._hide_tree_heading_tooltip, add="+")
        self.tree.bind("<<TreeviewSelect>>", self.on_tree_select)
        self.tree.bind("<<TreeviewSelect>>", self.update_status_bar, add="+")
        self.tree.bind("<Button-3>", self._on_tree_right_click)
        # Multi-selection with Shift+arrows - bind on tree to intercept before default behavior
        self.tree.bind("<Shift-Up>", lambda e: self._handle_shift_up_key())
        self.tree.bind("<Shift-Down>", lambda e: self._handle_shift_down_key())

        # Right: Notebook with tabs
        right = ttk.Frame(body)
        right.columnconfigure(0, weight=1)
        right.rowconfigure(0, weight=1)

        self.notebook = ttk.Notebook(right)
        self.notebook.grid(row=0, column=0, sticky="nsew", pady=(0, 0))

        # Tab 1: Single Entry Editor
        self._build_editor_tab()

        # Tab 2: Bulk Operations
        self._build_bulk_tab()

        # Tab 3: Test Translation
        self._build_test_tab()

        # Tab 4: Test Agent (with API key)
        self._build_agent_test_tab()

        body.add(left, weight=1)
        body.add(right, weight=1)
        
        # Store reference for later sash positioning
        self.paned_window = body
        self._init_paned_indicator()
        
        # Set initial sash position to 1170px (65% of 1800px default width)
        body.sashpos(0, 1170)
        self._update_paned_indicator()

        # Status bar (separated from main content)
        status_frame = ttk.Frame(self.root)
        status_frame.grid(row=3, column=0, sticky="ew")
        
        separator = ttk.Separator(status_frame, orient="horizontal")
        separator.pack(fill="x")
        
        bottom = ttk.Frame(status_frame, padding=(8, 4, 8, 4))
        bottom.pack(fill="x")
        self.status_var = tk.StringVar(value="Ready")
        ttk.Label(bottom, textvariable=self.status_var).pack(side="left")

    def _build_editor_tab(self):
        # Use canvas for tab content
        tab_container = ttk.Frame(self.notebook)
        self.notebook.add(tab_container, text=self._label("entry_editor", "Entry Editor"))
        
        canvas = tk.Canvas(tab_container)
        tab = ttk.Frame(canvas, padding=10)
        
        tab.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        tab_window = canvas.create_window((0, 0), window=tab, anchor="nw")
        canvas.bind("<Configure>", lambda e: canvas.itemconfigure(tab_window, width=e.width, height=e.height))
        
        canvas.grid(row=0, column=0, sticky="nsew")
        
        tab_container.grid_rowconfigure(0, weight=1)
        tab_container.grid_columnconfigure(0, weight=1)
        
        # Keep full-width layout and distribute vertical growth to text editors
        tab.columnconfigure(1, weight=1)
        tab.rowconfigure(2, weight=1)
        tab.rowconfigure(3, weight=2)

        self.id_var = tk.StringVar()
        self.lang_edit_var = tk.StringVar()
        self.agent_edit_var = tk.StringVar()
        self.ts_edit_var = tk.StringVar()
        self.user_edit_var = tk.StringVar()
        self.auto_update_ts_var = tk.BooleanVar(value=True)
        self.auto_update_user_var = tk.BooleanVar(value=True)
        
        # Track original values loaded to detect changes (for multi-selection partial update)
        self.original_loaded_values = {}
        self.currently_selected_ids = []
        self.pending_selection = None  # Track pending selection change for unsaved changes check

        ttk.Label(tab, text="Entry key").grid(row=0, column=0, sticky="nw", pady=(0, 6))
        ttk.Entry(tab, textvariable=self.id_var, state="readonly", width=38).grid(row=0, column=1, sticky="ew", pady=(0, 6))

        info_frame = ttk.Frame(tab)
        info_frame.grid(row=1, column=0, columnspan=2, sticky="ew", pady=(0, 6))
        ttk.Label(info_frame, text="Lang:").pack(side="left")
        ttk.Entry(info_frame, textvariable=self.lang_edit_var, width=8, state="readonly").pack(side="left", padx=(4, 12))
        ttk.Label(info_frame, text="Agent:").pack(side="left")
        ttk.Entry(info_frame, textvariable=self.agent_edit_var, width=12, state="readonly").pack(side="left", padx=(4, 0))

        ttk.Label(tab, text="Original text").grid(row=2, column=0, sticky="nw", pady=(0, 6))
        orig_frame = ttk.Frame(tab)
        orig_frame.grid(row=2, column=1, sticky="nsew", pady=(0, 6))
        orig_frame.columnconfigure(0, weight=1)
        orig_frame.rowconfigure(0, weight=1)
        self.original_txt = tk.Text(orig_frame, height=5, width=38, wrap="word")
        self.original_txt.grid(row=0, column=0, sticky="nsew")
        # Bind Tab key to move focus to next field instead of inserting tab character
        self.original_txt.bind("<Tab>", lambda e: self.translation_txt.focus() or "break")
        self.original_txt.bind("<Shift-Tab>", lambda e: self._focus_previous_widget(self.original_txt) or "break")
        orig_scroll = ttk.Scrollbar(orig_frame, orient="vertical", command=self.original_txt.yview)
        orig_scroll.grid(row=0, column=1, sticky="ns")
        self.original_txt.configure(yscrollcommand=orig_scroll.set)

        ttk.Label(tab, text="Translation").grid(row=3, column=0, sticky="nw", pady=(0, 6))
        trans_frame = ttk.Frame(tab)
        trans_frame.grid(row=3, column=1, sticky="nsew", pady=(0, 6))
        trans_frame.columnconfigure(0, weight=1)
        trans_frame.rowconfigure(0, weight=1)
        self.translation_txt = tk.Text(trans_frame, height=10, width=38, wrap="word")
        self.translation_txt.grid(row=0, column=0, sticky="nsew")
        # Bind Tab key to move focus to next field instead of inserting tab character
        self.translation_txt.bind("<Tab>", lambda e: self._focus_next_widget(self.translation_txt) or "break")
        self.translation_txt.bind("<Shift-Tab>", lambda e: self.original_txt.focus() or "break")
        self.translation_txt.bind("<<Modified>>", self._on_translation_text_modified, add="+")
        self.translation_txt.bind("<Motion>", self._on_translation_text_motion, add="+")
        self.translation_txt.bind("<Leave>", self._hide_translation_issue_tooltip, add="+")
        self.translation_txt.bind("<ButtonPress>", self._hide_translation_issue_tooltip, add="+")
        trans_scroll = ttk.Scrollbar(trans_frame, orient="vertical", command=self.translation_txt.yview)
        trans_scroll.grid(row=0, column=1, sticky="ns")
        self.translation_txt.configure(yscrollcommand=trans_scroll.set)
        self.translation_txt.tag_configure("grammar_issue_style", underline=True, foreground="#b00020")
        self.translation_txt.edit_modified(False)

        meta_frame = ttk.LabelFrame(tab, text="Metadata", padding=8)
        meta_frame.grid(row=4, column=0, columnspan=2, sticky="ew", pady=(6, 0))
        meta_frame.columnconfigure(1, weight=1)

        ttk.Label(meta_frame, text="Timestamp:").grid(row=0, column=0, sticky="w", pady=(0, 4))
        ts_frame = ttk.Frame(meta_frame)
        ts_frame.grid(row=0, column=1, sticky="ew", pady=(0, 4), padx=(4, 0))
        ttk.Entry(ts_frame, textvariable=self.ts_edit_var).pack(side="left", fill="x", expand=True)
        ttk.Button(ts_frame, text="Now", command=lambda: self.ts_edit_var.set(dt.datetime.now(dt.timezone.utc).strftime(TS_FMT)), width=8).pack(side="left", padx=(4, 0))
        ttk.Button(ts_frame, text="Clear", command=self.clear_timestamp, width=8).pack(side="left", padx=(4, 0))
        ttk.Checkbutton(meta_frame, text="Auto-update Timestamp", variable=self.auto_update_ts_var).grid(row=0, column=2, sticky="w", padx=(8, 0), pady=(0, 4))
        
        ttk.Label(meta_frame, text="GitHub user:").grid(row=1, column=0, sticky="w")
        user_frame = ttk.Frame(meta_frame)
        user_frame.grid(row=1, column=1, sticky="ew", padx=(4, 0))
        ttk.Entry(user_frame, textvariable=self.user_edit_var).pack(side="left", fill="x", expand=True)
        ttk.Button(user_frame, text="Default", command=lambda: self.user_edit_var.set(self.preferred_user_var.get()), width=8).pack(side="left", padx=(4, 0))
        ttk.Button(user_frame, text="Clear", command=self.clear_github_user, width=8).pack(side="left", padx=(4, 0))
        ttk.Checkbutton(meta_frame, text="Auto-update GitHub user", variable=self.auto_update_user_var).grid(row=1, column=2, sticky="w", padx=(8, 0))

        btn_frame = ttk.Frame(tab)
        btn_frame.grid(row=5, column=0, columnspan=2, sticky="ew", pady=(12, 0))
        ttk.Button(btn_frame, text=self._label("apply", "Apply to entry"), command=self.apply_entry_edit, width=18).pack(side="left", padx=(0, 8))
        ttk.Button(btn_frame, text=self._label("apply", "Check Grammar"), command=self.manual_grammar_check, width=18).pack(side="left", padx=(0, 8))
        ttk.Button(btn_frame, text=self._label("delete", "Delete selected"), command=self.delete_selected_entries, width=18).pack(side="left")

    def _build_bulk_tab(self):
        # Use canvas for tab content
        tab_container = ttk.Frame(self.notebook)
        self.notebook.add(tab_container, text=self._label("bulk", "Bulk Operations"))
        
        canvas = tk.Canvas(tab_container)
        tab = ttk.Frame(canvas, padding=10)
        
        tab.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        tab_window = canvas.create_window((0, 0), window=tab, anchor="nw")
        canvas.bind("<Configure>", lambda e: canvas.itemconfigure(tab_window, width=e.width, height=e.height))
        
        canvas.grid(row=0, column=0, sticky="nsew")
        tab_container.grid_rowconfigure(0, weight=1)
        tab_container.grid_columnconfigure(0, weight=1)
        
        tab.columnconfigure(0, weight=1)

        # Bulk replace section
        replace_frame = ttk.LabelFrame(tab, text="Text Replace on Selected Translations", padding=10)
        replace_frame.grid(row=0, column=0, sticky="ew", pady=(0, 10))
        replace_frame.columnconfigure(1, weight=1)

        ttk.Label(replace_frame, text="Find:").grid(row=0, column=0, sticky="w", pady=(0, 6))
        self.bulk_find_var = tk.StringVar()
        ttk.Entry(replace_frame, textvariable=self.bulk_find_var).grid(row=0, column=1, sticky="ew", pady=(0, 6), padx=(4, 0))

        ttk.Label(replace_frame, text="Replace:").grid(row=1, column=0, sticky="w", pady=(0, 6))
        self.bulk_replace_var = tk.StringVar()
        ttk.Entry(replace_frame, textvariable=self.bulk_replace_var).grid(row=1, column=1, sticky="ew", pady=(0, 6), padx=(4, 0))

        opts = ttk.Frame(replace_frame)
        opts.grid(row=2, column=0, columnspan=2, sticky="w", pady=(0, 6))
        self.bulk_regex = tk.BooleanVar(value=False)
        self.bulk_case = tk.BooleanVar(value=False)
        ttk.Checkbutton(opts, text="Regex mode", variable=self.bulk_regex).pack(side="left", padx=(0, 12))
        ttk.Checkbutton(opts, text="Case-sensitive", variable=self.bulk_case).pack(side="left")

        ttk.Button(replace_frame, text=self._label("play", "Apply bulk replace"), command=self.bulk_replace_selected).grid(row=3, column=0, columnspan=2, pady=(4, 0))

        # Bulk metadata update section
        meta_frame = ttk.LabelFrame(tab, text="Update Metadata on Selected Entries", padding=10)
        meta_frame.grid(row=1, column=0, sticky="ew", pady=(0, 10))
        meta_frame.columnconfigure(1, weight=1)

        ttk.Label(meta_frame, text="Timestamp:").grid(row=0, column=0, sticky="w", pady=(0, 6))
        self.bulk_ts_var = tk.StringVar()
        ts_frame = ttk.Frame(meta_frame)
        ts_frame.grid(row=0, column=1, sticky="ew", pady=(0, 6), padx=(4, 0))
        ttk.Entry(ts_frame, textvariable=self.bulk_ts_var).pack(side="left", fill="x", expand=True)
        ttk.Button(ts_frame, text="Now", command=lambda: self.bulk_ts_var.set(dt.datetime.now(dt.timezone.utc).strftime(TS_FMT))).pack(side="left", padx=(4, 0))

        ttk.Label(meta_frame, text="GitHub user:").grid(row=1, column=0, sticky="w", pady=(0, 6))
        self.bulk_user_var = tk.StringVar()
        user_frame = ttk.Frame(meta_frame)
        user_frame.grid(row=1, column=1, sticky="ew", pady=(0, 6), padx=(4, 0))
        ttk.Entry(user_frame, textvariable=self.bulk_user_var).pack(side="left", fill="x", expand=True)
        ttk.Button(user_frame, text="Default", command=lambda: self.bulk_user_var.set(self.preferred_user_var.get())).pack(side="left", padx=(4, 0))

        ttk.Button(meta_frame, text=self._label("play", "Apply metadata to selected"), command=self.bulk_update_metadata).grid(row=2, column=0, columnspan=2, pady=(4, 0))

        # Bulk delete section
        delete_frame = ttk.LabelFrame(tab, text="Danger Zone", padding=10)
        delete_frame.grid(row=2, column=0, sticky="ew")
        delete_frame.columnconfigure(0, weight=1)

        info = ttk.Label(delete_frame, text=f"{self._icons['warn']} Warning: Bulk delete removes selected entries permanently", foreground="red")
        info.grid(row=0, column=0, sticky="w", pady=(0, 6))
        ttk.Button(delete_frame, text=self._label("trash", "Delete selected entries"), command=self.delete_selected_entries).grid(row=1, column=0, sticky="w")

    def _build_test_tab(self):
        # Use canvas for tab content
        tab_container = ttk.Frame(self.notebook)
        self.notebook.add(tab_container, text=self._label("test_translation", "Test Translation"))
        
        canvas = tk.Canvas(tab_container)
        tab = ttk.Frame(canvas, padding=10)
        
        tab.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        tab_window = canvas.create_window((0, 0), window=tab, anchor="nw")
        canvas.bind("<Configure>", lambda e: canvas.itemconfigure(tab_window, width=e.width, height=e.height))
        
        canvas.grid(row=0, column=0, sticky="nsew")
        tab_container.grid_rowconfigure(0, weight=1)
        tab_container.grid_columnconfigure(0, weight=1)
        
        tab.columnconfigure(0, weight=1)
        tab.rowconfigure(3, weight=1)

        info = ttk.Label(tab, text="Test translation with different agents (calls freetz_translate)")
        info.grid(row=0, column=0, sticky="w", pady=(0, 10))

        input_frame = ttk.LabelFrame(tab, text="Input", padding=8)
        input_frame.grid(row=1, column=0, sticky="ew", pady=(0, 8))
        input_frame.columnconfigure(1, weight=1)

        ttk.Label(input_frame, text="Source lang:").grid(row=0, column=0, sticky="w", pady=(0, 4))
        self.test_src_var = tk.StringVar(value="en")
        ttk.Entry(input_frame, textvariable=self.test_src_var, width=8).grid(row=0, column=1, sticky="w", pady=(0, 4), padx=(4, 0))

        ttk.Label(input_frame, text="Target lang:").grid(row=1, column=0, sticky="w", pady=(0, 4))
        self.test_tgt_var = tk.StringVar(value="it")
        ttk.Entry(input_frame, textvariable=self.test_tgt_var, width=8).grid(row=1, column=1, sticky="w", pady=(0, 4), padx=(4, 0))

        ttk.Label(input_frame, text="Agent:").grid(row=2, column=0, sticky="w", pady=(0, 4))
        self.test_agent_var = tk.StringVar(value="deepl")
        agent_combo = ttk.Combobox(input_frame, textvariable=self.test_agent_var, width=14, 
                                     values=["deepl", "mymemory", "libretranslate", "apertium", "lingva", "openai"])
        agent_combo.grid(row=2, column=1, sticky="w", pady=(0, 4), padx=(4, 0))

        # Options frame with checkboxes
        ttk.Label(input_frame, text="Options:").grid(row=3, column=0, sticky="w", pady=(0, 4))
        options_frame = ttk.Frame(input_frame)
        options_frame.grid(row=3, column=1, sticky="w", pady=(0, 4), padx=(4, 0))
        
        self.test_debug_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(options_frame, text="Debug mode", variable=self.test_debug_var).pack(side="left", padx=(0, 12))
        
        self.test_cache_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(options_frame, text="Enable cache", variable=self.test_cache_var).pack(side="left")

        ttk.Label(input_frame, text="Text:").grid(row=4, column=0, sticky="nw")
        test_text_frame = ttk.Frame(input_frame)
        test_text_frame.grid(row=4, column=1, sticky="nsew", padx=(4, 0))
        test_text_frame.columnconfigure(0, weight=1)
        test_text_frame.rowconfigure(0, weight=1)

        self.test_input_txt = tk.Text(test_text_frame, height=4, width=38, wrap="word")
        self.test_input_txt.grid(row=0, column=0, sticky="nsew")
        self.test_input_scroll = ttk.Scrollbar(test_text_frame, orient="vertical", command=self.test_input_txt.yview)
        self.test_input_scroll.grid(row=0, column=1, sticky="ns")
        self.test_input_txt.configure(yscrollcommand=self.test_input_scroll.set)

        btn_frame = ttk.Frame(tab)
        btn_frame.grid(row=2, column=0, sticky="w", pady=(0, 8))
        ttk.Button(btn_frame, text=self._label("play", "Translate"), command=self.test_translate).pack(side="left", padx=(0, 4))
        ttk.Button(btn_frame, text=self._label("use_editor", "Use from editor"), command=self.test_use_from_editor).pack(side="left")

        result_frame = ttk.LabelFrame(tab, text="Result", padding=8)
        result_frame.grid(row=3, column=0, sticky="nsew")
        result_frame.columnconfigure(0, weight=1)
        result_frame.rowconfigure(0, weight=1)

        self.test_result_txt = tk.Text(result_frame, height=10, width=38, wrap="word", state="disabled")
        self.test_result_txt.grid(row=0, column=0, sticky="nsew")
        self.test_result_scroll = ttk.Scrollbar(result_frame, orient="vertical", command=self.test_result_txt.yview)
        self.test_result_scroll.grid(row=0, column=1, sticky="ns")
        self.test_result_txt.configure(yscrollcommand=self.test_result_scroll.set)
        self.test_result_txt.bind("<MouseWheel>", lambda e: self.test_result_txt.yview_scroll(int(-e.delta / 120), "units") or "break")
        self.test_result_txt.bind("<Button-4>", lambda _e: self.test_result_txt.yview_scroll(-1, "units") or "break")
        self.test_result_txt.bind("<Button-5>", lambda _e: self.test_result_txt.yview_scroll(1, "units") or "break")

    def _build_agent_test_tab(self):
        # Use canvas for tab content
        tab_container = ttk.Frame(self.notebook)
        self.notebook.add(tab_container, text=self._label("test_agent", "Test Agent"))
        
        canvas = tk.Canvas(tab_container)
        tab = ttk.Frame(canvas, padding=10)
        
        tab.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        tab_window = canvas.create_window((0, 0), window=tab, anchor="nw")
        canvas.bind("<Configure>", lambda e: canvas.itemconfigure(tab_window, width=e.width, height=e.height))
        
        canvas.grid(row=0, column=0, sticky="nsew")
        tab_container.grid_rowconfigure(0, weight=1)
        tab_container.grid_columnconfigure(0, weight=1)
        
        tab.columnconfigure(0, weight=1)
        tab.rowconfigure(4, weight=1)

        info = ttk.Label(tab, text="Test specific agent with API key (direct API call)")
        info.grid(row=0, column=0, sticky="w", pady=(0, 10))

        config_frame = ttk.LabelFrame(tab, text="Configuration", padding=8)
        config_frame.grid(row=1, column=0, sticky="ew", pady=(0, 8))
        config_frame.columnconfigure(1, weight=1)

        ttk.Label(config_frame, text="Agent:").grid(row=0, column=0, sticky="w", pady=(0, 4))
        self.agent_test_agent_var = tk.StringVar(value="deepl")
        agent_combo = ttk.Combobox(config_frame, textvariable=self.agent_test_agent_var, width=14, 
                                     values=["deepl", "mymemory", "libretranslate", "apertium", "lingva", "openai"], state="readonly")
        agent_combo.grid(row=0, column=1, sticky="w", pady=(0, 4), padx=(4, 0))
        agent_combo.bind("<<ComboboxSelected>>", lambda e: self._toggle_apikey_field())

        ttk.Label(config_frame, text="API Key:").grid(row=1, column=0, sticky="w", pady=(0, 4))
        self.agent_test_apikey_var = tk.StringVar()
        self.agent_test_apikey_entry = ttk.Entry(config_frame, textvariable=self.agent_test_apikey_var, show="*", width=26)
        self.agent_test_apikey_entry.grid(row=1, column=1, sticky="w", pady=(0, 4), padx=(4, 0))
        self.agent_test_apikey_label = ttk.Label(config_frame, text="(not required for this agent)", foreground="gray")
        self.agent_test_apikey_label.grid(row=1, column=2, sticky="w", padx=(4, 0))
        self.agent_test_apikey_label.grid_remove()  # Hidden by default

        ttk.Label(config_frame, text="Source lang:").grid(row=2, column=0, sticky="w", pady=(0, 4))
        self.agent_test_src_var = tk.StringVar(value="en")
        ttk.Entry(config_frame, textvariable=self.agent_test_src_var, width=8).grid(row=2, column=1, sticky="w", pady=(0, 4), padx=(4, 0))

        ttk.Label(config_frame, text="Target lang:").grid(row=3, column=0, sticky="w", pady=(0, 4))
        self.agent_test_tgt_var = tk.StringVar(value="it")
        ttk.Entry(config_frame, textvariable=self.agent_test_tgt_var, width=8).grid(row=3, column=1, sticky="w", pady=(0, 4), padx=(4, 0))

        input_frame = ttk.LabelFrame(tab, text="Input Text", padding=8)
        input_frame.grid(row=2, column=0, sticky="ew", pady=(0, 8))
        input_frame.columnconfigure(0, weight=1)
        input_frame.rowconfigure(0, weight=1)

        self.agent_test_input_txt = tk.Text(input_frame, height=4, width=38, wrap="word")
        self.agent_test_input_txt.grid(row=0, column=0, sticky="nsew")
        input_scroll = ttk.Scrollbar(input_frame, orient="vertical", command=self.agent_test_input_txt.yview)
        input_scroll.grid(row=0, column=1, sticky="ns")
        self.agent_test_input_txt.configure(yscrollcommand=input_scroll.set)

        btn_frame = ttk.Frame(tab)
        btn_frame.grid(row=3, column=0, sticky="w", pady=(0, 8))
        ttk.Button(btn_frame, text=self._label("play", "Test API"), command=self.agent_test_api).pack(side="left", padx=(0, 4))
        ttk.Button(btn_frame, text=self._label("use_editor", "Use from editor"), command=self.agent_test_use_from_editor).pack(side="left")

        result_frame = ttk.LabelFrame(tab, text="Result", padding=8)
        result_frame.grid(row=4, column=0, sticky="nsew")
        result_frame.columnconfigure(0, weight=1)
        result_frame.rowconfigure(0, weight=1)

        self.agent_test_result_txt = tk.Text(result_frame, height=10, width=38, wrap="word", state="disabled")
        self.agent_test_result_txt.grid(row=0, column=0, sticky="nsew")
        self.agent_test_result_scroll = ttk.Scrollbar(result_frame, orient="vertical", command=self.agent_test_result_txt.yview)
        self.agent_test_result_scroll.grid(row=0, column=1, sticky="ns")
        self.agent_test_result_txt.configure(yscrollcommand=self.agent_test_result_scroll.set)
        self.agent_test_result_txt.bind("<MouseWheel>", lambda e: self.agent_test_result_txt.yview_scroll(int(-e.delta / 120), "units") or "break")
        self.agent_test_result_txt.bind("<Button-4>", lambda _e: self.agent_test_result_txt.yview_scroll(-1, "units") or "break")
        self.agent_test_result_txt.bind("<Button-5>", lambda _e: self.agent_test_result_txt.yview_scroll(1, "units") or "break")

    def _setup_keyboard_bindings(self):
        """Setup keyboard shortcuts"""
        self.root.bind("<Home>", lambda e: self._handle_home_key())
        self.root.bind("<End>", lambda e: self._handle_end_key())
        self.root.bind("<Insert>", lambda e: self.add_new_entry())
        self.root.bind("<Delete>", lambda e: self.delete_selected_entries())
        # Select all
        self.root.bind("<Control-a>", lambda e: self._select_all())
        self.root.bind("<Control-A>", lambda e: self._select_all())
        # Search shortcuts
        self.root.bind("<Control-f>", lambda e: self.show_search_dialog())
        self.root.bind("<Control-F>", lambda e: self.show_search_dialog())
        self.root.bind("<F4>", lambda e: self.show_search_dialog())
        self.root.bind("<F3>", lambda e: self.search_next())
        self.root.bind("<Shift-F3>", lambda e: self.search_prev())
        # Save shortcut
        self.root.bind("<Control-s>", lambda e: self.save_all())
        self.root.bind("<Control-S>", lambda e: self.save_all())
        # Apply to entry shortcut
        self.root.bind("<Control-w>", lambda e: self.apply_entry_edit())
        self.root.bind("<Control-W>", lambda e: self.apply_entry_edit())
        # Quick apply+save without popups
        self.root.bind("<F10>", lambda e: self.quick_apply_and_save())
        # Maximize/restore window
        self.root.bind("<F11>", lambda e: self._toggle_fullscreen())

    def quick_apply_and_save(self):
        """F10: Apply edits then save all, auto-confirming prompts and showing status summary."""
        actions = []

        before_dirty = set(self.dirty_langs)
        had_selection = bool(self.currently_selected_ids)
        self.apply_entry_edit(skip_prompts=True, skip_no_changes_popup=True)

        after_apply_dirty = set(self.dirty_langs)
        if had_selection:
            if after_apply_dirty != before_dirty:
                actions.append("entry changes applied")
            else:
                actions.append("no entry changes")
        else:
            actions.append("no selected entry")

        files_to_save = len(self.dirty_langs)
        if files_to_save > 0:
            self.save_all(confirm=False)
            actions.append(f"saved {files_to_save} file(s)")
        else:
            actions.append("no files to save")

        self.update_status_bar(message=f"F10 quick save: {', '.join(actions)}")
        return "break"

    def _handle_home_key(self):
        """Select first visible entry"""
        if self.filtered_ids:
            first_id = self.filtered_ids[0]
            self.tree.selection_set(first_id)
            self.tree.see(first_id)
            self.tree.focus(first_id)
            self.selection_anchor = first_id

    def _handle_end_key(self):
        """Select last visible entry"""
        if self.filtered_ids:
            last_id = self.filtered_ids[-1]
            self.tree.selection_set(last_id)
            self.tree.see(last_id)
            self.tree.focus(last_id)
            self.selection_anchor = last_id

    def _select_all(self):
        """Select all visible entries (Ctrl+A) only when table has focus"""
        if self.root.focus_get() is not self.tree:
            return

        if self.filtered_ids:
            # Select all filtered/visible entries
            self.tree.selection_set(self.filtered_ids)
            # Focus on first item
            if self.filtered_ids:
                self.tree.focus(self.filtered_ids[0])
                self.tree.see(self.filtered_ids[0])
                self.selection_anchor = self.filtered_ids[0]
        return "break"  # Prevent default Ctrl+A behavior

    def _handle_shift_up_key(self):
        """Extend selection upward (Shift+Up) - selects range from anchor to current"""
        if not self.filtered_ids:
            return
        
        # Get currently focused item
        focused = self.tree.focus()
        if not focused:
            return
        
        # Set anchor if not set
        if self.selection_anchor is None:
            self.selection_anchor = focused
        
        # Find both anchor and focus indices
        try:
            anchor_idx = self.filtered_ids.index(self.selection_anchor)
            current_idx = self.filtered_ids.index(focused)
        except ValueError:
            return
        
        # If not at the top, move focus up
        if current_idx > 0:
            new_focus_idx = current_idx - 1
            # Select range from anchor to new focus
            start_idx = min(anchor_idx, new_focus_idx)
            end_idx = max(anchor_idx, new_focus_idx)
            
            # Clear selection and select the range
            self.tree.selection_set()
            for idx in range(start_idx, end_idx + 1):
                self.tree.selection_add(self.filtered_ids[idx])
            
            # Set focus to new position
            new_focus = self.filtered_ids[new_focus_idx]
            self.tree.see(new_focus)
            self.tree.focus(new_focus)
        
        return "break"  # Prevent default handler

    def _handle_shift_down_key(self):
        """Extend selection downward (Shift+Down) - selects range from anchor to current"""
        if not self.filtered_ids:
            return
        
        # Get currently focused item
        focused = self.tree.focus()
        if not focused:
            return
        
        # Set anchor if not set
        if self.selection_anchor is None:
            self.selection_anchor = focused
        
        # Find both anchor and focus indices
        try:
            anchor_idx = self.filtered_ids.index(self.selection_anchor)
            current_idx = self.filtered_ids.index(focused)
        except ValueError:
            return
        
        # If not at the bottom, move focus down
        if current_idx < len(self.filtered_ids) - 1:
            new_focus_idx = current_idx + 1
            # Select range from anchor to new focus
            start_idx = min(anchor_idx, new_focus_idx)
            end_idx = max(anchor_idx, new_focus_idx)
            
            # Clear selection and select the range
            self.tree.selection_set()
            for idx in range(start_idx, end_idx + 1):
                self.tree.selection_add(self.filtered_ids[idx])
            
            # Set focus to new position
            new_focus = self.filtered_ids[new_focus_idx]
            self.tree.see(new_focus)
            self.tree.focus(new_focus)
        
        return "break"  # Prevent default handler

    def _set_paned_position(self):
        """Set PanedWindow sash to 65% of window width"""
        try:
            # Force update to ensure window is fully rendered
            self.root.update_idletasks()
            
            # Get current window width and set sash at 65%
            width = self.root.winfo_width()
            if width > 200:  # Only if window is properly sized
                target_pos = int(width * 0.65)
                self.paned_window.sashpos(0, target_pos)
                self._update_paned_indicator()
        except Exception:
            pass  # Ignore if paned window not ready yet

    def _init_paned_indicator(self):
        """Create a visible vertical cue over the paned sash to suggest drag-resize."""
        self._indicator_drag_active = False
        self.paned_indicator = tk.Frame(
            self.paned_window,
            bg="#9aa0a6",
            width=4,
            cursor="sb_h_double_arrow",
            highlightthickness=0,
            bd=0,
        )
        self.paned_window.bind("<Configure>", self._update_paned_indicator, add="+")
        self.paned_window.bind("<B1-Motion>", self._on_paned_drag_motion, add="+")
        self.paned_window.bind("<ButtonRelease-1>", self._on_paned_drag_release, add="+")
        self.paned_window.bind("<ButtonPress-1>", self._on_paned_drag_press, add="+")

        # Make the indicator itself draggable (same behavior as real sash)
        self.paned_indicator.bind("<ButtonPress-1>", self._on_indicator_press, add="+")
        self.paned_indicator.bind("<B1-Motion>", self._on_indicator_drag, add="+")
        self.paned_indicator.bind("<ButtonRelease-1>", self._on_indicator_release, add="+")

    def _update_paned_indicator(self, _event=None):
        try:
            sash_x = self.paned_window.sashpos(0)
            height = self.paned_window.winfo_height()
            if height <= 2:
                return
            self.paned_indicator.place(x=max(0, sash_x - 2), y=0, width=4, height=height)
            self.paned_indicator.lift()
        except Exception:
            pass

    def _on_paned_drag_press(self, _event=None):
        self.paned_indicator.configure(bg="#6e7681")
        self._update_paned_indicator()

    def _on_paned_drag_motion(self, _event=None):
        self.paned_indicator.configure(bg="#6e7681")
        self._update_paned_indicator()

    def _on_paned_drag_release(self, _event=None):
        self.paned_indicator.configure(bg="#9aa0a6")
        self._update_paned_indicator()

    def _drag_sash_to_pointer(self, event):
        try:
            # Convert pointer position to paned-window local x
            pointer_x = event.x_root - self.paned_window.winfo_rootx()

            # Clamp in a reasonable range to avoid collapsing panes
            width = self.paned_window.winfo_width()
            min_x = 120
            max_x = max(min_x, width - 120)
            pointer_x = max(min_x, min(pointer_x, max_x))

            self.paned_window.sashpos(0, pointer_x)
            self._update_paned_indicator()
        except Exception:
            pass

    def _on_indicator_press(self, event):
        self._indicator_drag_active = True
        self.paned_indicator.configure(bg="#6e7681")
        self._drag_sash_to_pointer(event)
        return "break"

    def _on_indicator_drag(self, event):
        if self._indicator_drag_active:
            self.paned_indicator.configure(bg="#6e7681")
            self._drag_sash_to_pointer(event)
        return "break"

    def _on_indicator_release(self, event):
        if self._indicator_drag_active:
            self._drag_sash_to_pointer(event)
        self._indicator_drag_active = False
        self.paned_indicator.configure(bg="#9aa0a6")
        self._update_paned_indicator()
        return "break"

    def _focus_next_widget(self, current_widget):
        """Move focus to the next widget in tab order"""
        current_widget.tk_focusNext().focus()
        return "break"
    
    def _focus_previous_widget(self, current_widget):
        """Move focus to the previous widget in tab order"""
        current_widget.tk_focusPrev().focus()
        return "break"
    
    def _toggle_fullscreen(self):
        """Toggle fullscreen/maximized window (F11)"""
        current_state = self.root.attributes("-fullscreen")
        self.root.attributes("-fullscreen", not current_state)
        return "break"

    def _widget_title(self, widget):
        try:
            text = widget.cget("text")
            if text:
                return str(text)
        except Exception:
            pass
        return widget.winfo_class()

    def _setup_tooltips(self):
        self._tooltips = []

        shortcut_map = {
            self._label("save_all", "Save all"): "Ctrl+S",
            self._label("apply", "Apply to entry"): "Ctrl+W",
            self._label("delete", "Delete selected"): "Delete",
            self._label("search", "Search"): "Ctrl+F / F4 / F3 / Shift+F3",
            self._label("add_entry", "Add entry"): "Insert",
            self._label("shortcuts", "Shortcuts"): "F10/F11/Ctrl shortcuts overview",
            self._label("help", "Help"): "Application help",
        }

        explicit = {
            # Top toolbar
            "Cache dir:": (
                "Path to the directory containing translation cache JSON files "
                "(e.g. tools/translate_cache). All *.json files in this folder are "
                "loaded at startup. Change the path and click Reload to work on a "
                "different cache folder."
            ),
            "Default user:": (
                "Default GitHub username auto-filled into the 'GitHub user' metadata "
                "field when creating or editing entries. Used by the 'Default' button "
                "in the Entry Editor and Bulk Operations tabs."
            ),
            self._label("reload", "Reload"): (
                "Discard all in-memory changes and reload every JSON cache file from "
                "the directory shown in 'Cache dir'. Unsaved edits will be lost."
            ),
            self._label("add_entry", "Add entry"): (
                "Open a dialog to create a new translation entry. You choose the "
                "target language, an optional package name, the source key, the "
                "original English text, and the translation. The entry is added to "
                "the appropriate cache file (base or package-specific). Shortcut: Insert."
            ),
            self._label("save_all", "Save all"): (
                "Write every modified cache file back to disk. A timestamped backup "
                "of each file is created automatically before overwriting. Only files "
                "that have been changed since the last save are written. Shortcut: Ctrl+S."
            ),
            self._label("help", "Help"): "Open a help dialog explaining the application's purpose, workflow, and safety features.",
            self._label("shortcuts", "Shortcuts"): "Open a reference dialog listing all keyboard shortcuts (navigation, editing, search, window).",
            self._label("theme", "Theme"): "Open a menu to switch the UI skin/theme at runtime (works on Linux and Windows).",

            # Filter row 1: dropdowns
            "Language": (
                "Show only entries whose target language code matches the selected "
                "value (e.g. 'it', 'de'). Set to 'ALL' to show entries for every language."
            ),
            "Package": (
                "Show only entries belonging to a specific package-level cache file "
                "(e.g. 'it-rutorrent' comes from it-rutorrent.json). Set to 'ALL' to "
                "show entries from all cache files, including the base language file."
            ),
            "Agent": (
                "Show only entries translated by a specific service (e.g. deepl, "
                "mymemory, openai). The agent is stored in each entry's metadata. "
                "Set to 'ALL' to show entries from every translation service."
            ),
            "User": (
                "Show only entries whose 'github_user' metadata matches the selected "
                "username. Set to 'ALL' to show entries from all users."
            ),
            "Only without metadata": (
                "When checked, hide all entries that already have complete metadata "
                "(timestamp, service, user) and show only those that are missing one "
                "or more metadata fields. Useful for finding entries that need review."
            ),
            "Apply filter": (
                "Apply all current filter and search criteria to refresh the table. "
                "Rows that don't match the selected Language, Package, Agent, User, "
                "search text, date range, or metadata filter are hidden."
            ),
            "Reset filter": (
                "Reset every filter dropdown to 'ALL', clear the search text, uncheck "
                "'Only without metadata' and 'Date period', and refresh the table to "
                "show all entries."
            ),

            # Filter row 2: search
            "Search": (
                "Type a text pattern to filter entries. Matching is performed against "
                "the fields selected in the 'In:' checkboxes (key, original, translation). "
                "Use the dropdown to the right to choose between plain substring match "
                "(contains), glob-style wildcards (wildcard), or regular expression (regex). "
                "Press 'Apply filter' or Enter to execute."
            ),
            "Case": (
                "When checked, the search is case-sensitive: 'Hello' will NOT match "
                "'hello'. When unchecked (default), the search ignores letter case: "
                "'Hello' matches 'hello', 'HELLO', etc."
            ),
            "In:": (
                "Select which entry fields are searched when filtering. 'key' is the "
                "internal cache key (source text identifier), 'original' is the English "
                "source text, 'translation' is the translated text. At least one field "
                "should be checked for search to match anything."
            ),
            "key": (
                "When checked, the search pattern is matched against the cache key "
                "(the internal source text identifier). Uncheck to exclude keys from search."
            ),
            "original": (
                "When checked, the search pattern is matched against the original "
                "English source text. Uncheck to exclude original text from search."
            ),
            "translation": (
                "When checked, the search pattern is matched against the translated "
                "text. Uncheck to exclude translations from search."
            ),

            # Filter row 3: date
            "Date period": (
                "When checked, enable date-range filtering: only entries whose timestamp "
                "falls between the 'From' and 'To' dates are shown. Entries without a "
                "timestamp are hidden. When unchecked, date filtering is ignored."
            ),

            # Tree toolbar
            "Columns": (
                "Open a menu to show or hide individual table columns. Each column can "
                "be toggled independently. You can also right-click any column header "
                "for the same menu."
            ),
            "Select visible": (
                "Select all rows currently visible in the table (after filtering). "
                "Useful before bulk operations to apply changes to all filtered entries."
            ),
            "Clear selection": "Deselect all currently selected rows in the table.",
            self._label("search", "Search"): (
                "Open a floating search dialog for incremental find within the table. "
                "Type a term and press Enter or F3 to jump to the next matching row; "
                "Shift+F3 jumps to the previous match. Shortcut: Ctrl+F / F4."
            ),
            "Entries": "Label showing the entries table area below.",

            # Entry Editor tab
            "Entry key": (
                "Read-only field showing the internal cache key for the selected entry. "
                "This is the dictionary key used in the JSON cache file."
            ),
            "Lang:": (
                "Read-only display of the target language code (e.g. 'it') for the "
                "selected entry."
            ),
            "Agent:": (
                "Read-only display of the translation service that produced this entry "
                "(e.g. 'deepl', 'mymemory')."
            ),
            "Original text": (
                "The original English source text of the selected entry. Editable: you "
                "can modify it and click 'Apply to entry' to update the cache. Use "
                "Tab to move to the Translation field."
            ),
            "Translation": (
                "The translated text for the selected entry. Edit this field to correct "
                "or improve the translation, then click 'Apply to entry' (Ctrl+W) to "
                "save changes to memory. Use Tab/Shift+Tab to navigate between fields."
            ),
            "Timestamp:": (
                "UTC timestamp recording when this translation was created or last "
                "modified. Format: YYYY-MM-DD HH:MM:SS. Stored in the JSON cache as "
                "metadata alongside the translation."
            ),
            "GitHub user:": (
                "GitHub username of the person who created or last edited this "
                "translation entry. Stored as metadata in the JSON cache file."
            ),
            "Now": (
                "Set the Timestamp field to the current date and time in UTC "
                "(e.g. 2026-02-16 12:34:56). Does not save automatically; click "
                "'Apply to entry' afterward."
            ),
            "Default": (
                "Set the GitHub user field to the default username configured in the "
                "'Default user' field at the top of the window."
            ),
            "Clear": (
                "Erase the content of this metadata field (Timestamp or GitHub user) "
                "for the selected entries. The change is applied to the editor only; "
                "click 'Apply to entry' to commit."
            ),
            self._label("apply", "Apply to entry"): (
                "Write the current editor values (original text, translation, timestamp, "
                "GitHub user) back into the selected cache entries in memory. When "
                "multiple rows are selected, only fields you actually changed are "
                "updated (partial update). Changes are not written to disk until you "
                "click 'Save all'. Shortcut: Ctrl+W."
            ),
            self._label("apply", "Check Grammar"): (
                "Send the current translation text to the LanguageTool API for grammar "
                "and spelling verification in the entry's target language. Results are "
                "shown in a dialog with specific suggestions. Does not modify the text."
            ),
            self._label("delete", "Delete selected"): (
                "Permanently remove all selected entries from the in-memory cache. "
                "The corresponding cache files are marked as modified. Changes are "
                "written to disk only when you click 'Save all'. Shortcut: Delete."
            ),

            # Bulk Operations tab
            "Find:": (
                "The text or pattern to search for inside the translation field of "
                "each selected entry during bulk replace."
            ),
            "Replace:": (
                "The replacement text that will be substituted wherever the Find "
                "pattern matches in the translation field."
            ),
            "Regex mode": (
                "When checked, the Find field is interpreted as a Python regular "
                "expression (e.g. '\\bfoo\\b' matches whole word 'foo'). When "
                "unchecked, the Find field is treated as a plain literal string."
            ),
            "Case-sensitive": (
                "When checked, bulk replace distinguishes uppercase from lowercase: "
                "'Hello' will NOT match 'hello'. When unchecked, matching ignores "
                "letter case."
            ),
            self._label("play", "Apply bulk replace"): (
                "Run the find-and-replace operation on the translation text of every "
                "selected row. A count of modified entries is shown in the status bar. "
                "Entries without a match are skipped."
            ),
            self._label("play", "Apply metadata to selected"): (
                "Overwrite the timestamp and/or GitHub user metadata of all selected "
                "entries with the values entered above. Leave a field empty to skip it."
            ),
            self._label("trash", "Delete selected entries"): (
                "Permanently remove all selected entries from the in-memory cache "
                f"(same as '{self._label('delete', 'Delete selected')}' in the Entry Editor). The deletion is "
                "committed to disk only after 'Save all'."
            ),

            # Test Translation tab
            "Source lang:": (
                "ISO language code of the source text (e.g. 'en' for English). "
                "Passed to freetz_translate as the source language argument."
            ),
            "Target lang:": (
                "ISO language code for the desired translation output (e.g. 'it' "
                "for Italian). Passed to freetz_translate as the target language."
            ),
            "Debug mode": (
                "When checked, sets FREETZ_TRANSLATE_DEBUG=y so freetz_translate "
                "prints detailed diagnostic output (API URLs, response headers, "
                "cache lookups) in the Result area below the translated text."
            ),
            "Enable cache": (
                "When checked, sets FREETZ_TRANSLATE_CACHE_ENABLED=y so the test "
                "call may read from or write to the translation cache. When unchecked, "
                "the cache is bypassed and a fresh API call is always made."
            ),
            "Text:": (
                "Enter the source text to translate. This is sent to "
                "tools/freetz_translate with the selected agent and language pair."
            ),
            self._label("play", "Translate"): (
                "Run tools/freetz_translate in a background thread with the configured "
                "source/target languages, agent, and options. The translation result "
                "(or error) appears in the Result area below. If the currently selected "
                "entry has a package name, it is passed as an extra argument."
            ),
            self._label("use_editor", "Use from editor"): (
                "Copy the 'Original text' from the Entry Editor tab into this test "
                "input field, and set the target language to match the selected entry. "
                "Convenient for re-translating an existing entry with different settings."
            ),

            # Test Agent tab
            "API Key:": (
                "Authentication key for the selected translation provider. Required "
                "for DeepL, OpenAI, and LibreTranslate; not needed for Apertium, "
                "Lingva, or MyMemory (free tier). The key is masked with bullets."
            ),
            self._label("play", "Test API"): (
                "Call the selected translation provider's API directly (bypassing "
                "freetz_translate) with the configured API key, languages, and input "
                "text. Useful for verifying that an API key works or comparing raw "
                "API output."
            ),
            "Input Text": (
                "Enter the text to send directly to the translation provider API."
            ),

            # Date filter labels
            "From": (
                "Start date for the date-range filter. Only entries with a timestamp "
                "on or after this date are shown."
            ),
            "To": (
                "End date for the date-range filter. Only entries with a timestamp "
                "on or before this date are shown."
            ),
            "From (YYYY-MM-DD)": (
                "Start date for the date-range filter (format: YYYY-MM-DD). Only entries "
                "with a timestamp on or after this date are shown."
            ),
            "To (YYYY-MM-DD)": (
                "End date for the date-range filter (format: YYYY-MM-DD). Only entries "
                "with a timestamp on or before this date are shown."
            ),

            # LabelFrame titles (group containers)
            "Filters": (
                "Panel with all filtering controls: language, package, agent, user, "
                "text search, date range, and metadata presence."
            ),
            "Metadata": (
                "Metadata fields associated with the selected cache entry: timestamp "
                "and GitHub username. Updated when you click 'Apply to entry'."
            ),
            "Text Replace on Selected Translations": (
                "Bulk find-and-replace tool operating on the translation text of all "
                "selected rows. Supports plain text, regex, and case-sensitive modes."
            ),
            "Update Metadata on Selected Entries": (
                "Set the timestamp and/or GitHub user on all selected entries at once. "
                "Leave a field empty to skip updating that metadata."
            ),
            "Danger Zone": (
                "Destructive operations. Bulk delete permanently removes selected "
                "entries from memory. Use 'Save all' to commit deletions to disk."
            ),
            "Input": (
                "Configure the test translation request: source and target language "
                "codes, translation agent, debug/cache options, and the text to translate."
            ),
            "Result": (
                "Read-only area showing the translation output, error messages, or "
                "debug trace from the last test run."
            ),
            "Configuration": (
                "Configure the direct API test: select a translation agent, enter an "
                "API key (if required), and set source/target languages."
            ),
            "Options:": (
                "Additional flags for the test translation call: Debug mode shows "
                "verbose output; Enable cache allows reading/writing the translation cache."
            ),
            "Auto-update Timestamp": (
                "When enabled (default), updating Original/Translation also refreshes the Timestamp "
                "metadata automatically to current UTC time during Apply to entry."
            ),
            "Auto-update GitHub user": (
                "When enabled (default), updating Original/Translation also refreshes GitHub user "
                "metadata automatically using the value in 'Default user' (fallback: git user)."
            ),
        }

        for widget in self._iter_widgets(self.root):
            cls = widget.winfo_class()
            text = self._widget_title(widget)

            tip = None
            if text in explicit:
                tip = explicit[text]

            if tip and text in shortcut_map:
                tip = f"{tip} Shortcut: {shortcut_map[text]}."

            if tip:
                self._tooltips.append(ToolTip(widget, tip))

    def _iter_widgets(self, parent):
        for child in parent.winfo_children():
            yield child
            yield from self._iter_widgets(child)

    def _setup_notebook_tab_tooltips(self):
        self._tab_tooltip_window = None
        self._help_windows = {}
        self._tab_tooltip_text = {
            0: (
                "Entry Editor — Select one or more rows in the table, then inspect and edit "
                "the original text, translation, timestamp, and GitHub user. Click 'Apply to entry' "
                "(Ctrl+W) to commit changes to memory; use 'Save all' (Ctrl+S) to write to disk."
            ),
            1: (
                "Bulk Operations — Apply find-and-replace on the translation text of all selected "
                "entries, overwrite metadata (timestamp/user) in batch, or bulk-delete entries. "
                "Supports plain text, regex, and case-sensitive matching."
            ),
            2: (
                "Test Translation — Enter source text and call tools/freetz_translate with a chosen "
                "agent (deepl, mymemory, etc.), language pair, and debug/cache options. Shows the "
                "translated output and optional diagnostic trace. Runs in a background thread."
            ),
            3: (
                "Test Agent — Call a translation provider's HTTP API directly (bypassing freetz_translate) "
                "with an optional API key. Useful for verifying credentials, comparing raw API responses, "
                "or testing providers that require authentication."
            ),
        }
        self.notebook.bind("<Motion>", self._on_notebook_tab_motion, add="+")
        self.notebook.bind("<Leave>", self._hide_notebook_tab_tooltip, add="+")

    def _on_notebook_tab_motion(self, event):
        try:
            elem = self.notebook.identify(event.x, event.y)
            if "label" not in elem:
                self._hide_notebook_tab_tooltip()
                return
            index = self.notebook.index(f"@{event.x},{event.y}")
            text = self._tab_tooltip_text.get(index)
            if not text:
                self._hide_notebook_tab_tooltip()
                return
            self._show_notebook_tab_tooltip(text)
        except Exception:
            self._hide_notebook_tab_tooltip()

    def _show_notebook_tab_tooltip(self, text):
        x = self.root.winfo_pointerx() + 14
        y = self.root.winfo_pointery() + 14
        if self._tab_tooltip_window is not None:
            try:
                label = self._tab_tooltip_window.winfo_children()[0]
                label.configure(text=text)
                self._tab_tooltip_window.wm_geometry(f"+{x}+{y}")
                return
            except Exception:
                self._hide_notebook_tab_tooltip()

        tw = tk.Toplevel(self.root)
        tw.wm_overrideredirect(True)
        tw.wm_geometry(f"+{x}+{y}")
        label = tk.Label(
            tw,
            text=text,
            justify="left",
            background="#ffffe0",
            relief="solid",
            borderwidth=1,
            wraplength=420,
            padx=6,
            pady=4,
        )
        label.pack()
        self._tab_tooltip_window = tw

    def _hide_notebook_tab_tooltip(self, _event=None):
        if self._tab_tooltip_window is not None:
            self._tab_tooltip_window.destroy()
            self._tab_tooltip_window = None

    def _show_rich_text_dialog(self, key, title, subtitle, sections, icon_key=None, geometry="880x640"):
        existing = self._help_windows.get(key)
        if existing is not None:
            try:
                if existing.winfo_exists():
                    existing.deiconify()
                    existing.lift()
                    existing.focus_force()
                    return
            except Exception:
                pass

        win = tk.Toplevel(self.root)
        self._help_windows[key] = win
        win.title(title)
        win.geometry(geometry)
        win.transient(self.root)
        win.minsize(700, 420)

        container = ttk.Frame(win, padding=12)
        container.pack(fill="both", expand=True)
        container.columnconfigure(0, weight=1)
        container.rowconfigure(2, weight=1)

        title_text = title
        if icon_key:
            title_text = self._label(icon_key, title)

        ttk.Label(container, text=title_text, font=("TkDefaultFont", 14, "bold")).grid(
            row=0, column=0, sticky="w"
        )
        ttk.Label(container, text=subtitle, wraplength=820, justify="left").grid(
            row=1, column=0, sticky="w", pady=(4, 10)
        )

        notebook = ttk.Notebook(container)
        notebook.grid(row=2, column=0, sticky="nsew")

        for section_title, section_lines in sections:
            tab = ttk.Frame(notebook, padding=10)
            tab.columnconfigure(0, weight=1)
            tab.rowconfigure(0, weight=1)

            text_frame = ttk.Frame(tab)
            text_frame.grid(row=0, column=0, sticky="nsew")
            text_frame.columnconfigure(0, weight=1)
            text_frame.rowconfigure(0, weight=1)

            txt = tk.Text(text_frame, wrap="word", height=20)
            txt.grid(row=0, column=0, sticky="nsew")
            scroll = ttk.Scrollbar(text_frame, orient="vertical", command=txt.yview)
            scroll.grid(row=0, column=1, sticky="ns")
            txt.configure(yscrollcommand=scroll.set)

            content = "\n".join(section_lines)
            txt.insert("1.0", content)
            txt.configure(state="disabled")

            notebook.add(tab, text=section_title)

        footer = ttk.Frame(container)
        footer.grid(row=3, column=0, sticky="ew", pady=(10, 0))
        ttk.Button(footer, text="Close", command=win.destroy, width=12).pack(side="right")

        win.bind("<Escape>", lambda _e: win.destroy())
        win.protocol("WM_DELETE_WINDOW", win.destroy)

        win.update_idletasks()
        x = self.root.winfo_x() + max(0, (self.root.winfo_width() // 2) - (win.winfo_width() // 2))
        y = self.root.winfo_y() + max(0, (self.root.winfo_height() // 2) - (win.winfo_height() // 2))
        win.geometry(f"+{x}+{y}")

    def _show_shortcuts_dialog(self):
        key = "shortcuts"
        existing = self._help_windows.get(key)
        if existing is not None:
            try:
                if existing.winfo_exists():
                    existing.deiconify()
                    existing.lift()
                    existing.focus_force()
                    return
            except Exception:
                pass

        win = tk.Toplevel(self.root)
        self._help_windows[key] = win
        win.title("Keyboard Shortcuts")
        win.geometry("840x560")
        win.transient(self.root)
        win.minsize(700, 420)

        root_frame = ttk.Frame(win, padding=12)
        root_frame.pack(fill="both", expand=True)
        root_frame.columnconfigure(0, weight=1)
        root_frame.rowconfigure(1, weight=1)

        ttk.Label(
            root_frame,
            text=self._label("shortcuts", "Keyboard Shortcuts"),
            font=("TkDefaultFont", 14, "bold"),
        ).grid(row=0, column=0, sticky="w")

        notebook = ttk.Notebook(root_frame)
        notebook.grid(row=1, column=0, sticky="nsew", pady=(8, 0))

        categories = {
            "Navigation": [
                ("Home", "Select first visible row"),
                ("End", "Select last visible row"),
                ("Shift+Up / Shift+Down", "Extend multi-selection"),
                ("Ctrl+A", "Select all visible rows (when table has focus)"),
            ],
            "Editing": [
                ("Insert", "Add new entry"),
                ("Delete", "Delete selected entries"),
                ("Ctrl+W", "Apply changes to selected entry/entries"),
                ("Ctrl+S", "Save all modified files"),
                ("F10", "Quick apply + quick save (auto-confirm, no popups)"),
            ],
            "Search": [
                ("Ctrl+F / F4", "Open search dialog"),
                ("Enter", "Execute search in search dialog"),
                ("F3", "Jump to next result"),
                ("Shift+F3", "Jump to previous result"),
                ("Esc", "Close search/help dialogs"),
            ],
            "Window": [
                ("F11", "Toggle fullscreen"),
            ],
        }

        for category, rows in categories.items():
            tab = ttk.Frame(notebook, padding=10)
            tab.columnconfigure(0, weight=1)
            tab.rowconfigure(0, weight=1)

            tree = ttk.Treeview(tab, columns=("shortcut", "action"), show="headings", height=10)
            tree.heading("shortcut", text="Shortcut")
            tree.heading("action", text="Action")
            tree.column("shortcut", width=220, anchor="w")
            tree.column("action", width=540, anchor="w")

            for shortcut, action in rows:
                tree.insert("", "end", values=(shortcut, action))

            yscroll = ttk.Scrollbar(tab, orient="vertical", command=tree.yview)
            tree.configure(yscrollcommand=yscroll.set)

            tree.grid(row=0, column=0, sticky="nsew")
            yscroll.grid(row=0, column=1, sticky="ns")

            notebook.add(tab, text=category)

        footer = ttk.Frame(root_frame)
        footer.grid(row=2, column=0, sticky="ew", pady=(10, 0))
        ttk.Button(footer, text="Close", command=win.destroy, width=12).pack(side="right")

        win.bind("<Escape>", lambda _e: win.destroy())
        win.protocol("WM_DELETE_WINDOW", win.destroy)

        win.update_idletasks()
        x = self.root.winfo_x() + max(0, (self.root.winfo_width() // 2) - (win.winfo_width() // 2))
        y = self.root.winfo_y() + max(0, (self.root.winfo_height() // 2) - (win.winfo_height() // 2))
        win.geometry(f"+{x}+{y}")

    def show_app_help(self):
        sections = [
            (
                "Overview",
                [
                    "Translate Cache Manager",
                    "",
                    "Purpose:",
                    "• Load and maintain translation cache files (*.json) from a directory.",
                    "• Inspect and edit entries with metadata (service, timestamp, GitHub user).",
                    "• Work with base and package-aware caches (example: it.json, it-rutorrent.json).",
                    "",
                    "Main areas:",
                    "• Filters + entry table (left side)",
                    "• Tabs on the right: Entry Editor, Bulk Operations, Test Translation, Test Agent",
                ],
            ),
            (
                "Workflow",
                [
                    "Recommended workflow:",
                    "1. Set cache directory and click Reload.",
                    "2. Narrow scope with filters (language, package, user, metadata, date).",
                    "3. Search for specific entries with text search button, or press F4 or Control F; the search dialog will appear.",
                    "4. You can also select multiple rows in the table.",
                    "5. Edit in Entry Editor, then apply changes (Ctrl+W). The syntax checker underlines potential grammar issues in the translation; hover over the highlighted text to see suggestions.",
                    "6. Run Bulk Operations for repetitive changes.",
                    "7. Validate behavior in Test Translation / Test Agent.",
                    "8. Save all modified files (Ctrl+S).",
                    "",
                    "Tip:",
                    "• F10 performs a quick apply+save cycle without confirmation popups.",
                ],
            ),
            (
                "Filters & Search",
                [
                    "Filters:",
                    "• Language, Package, Agent, User",
                    "• Only without metadata",
                    "• Date period",
                    "",
                    "Text search modes:",
                    "• contains: plain substring",
                    "• wildcard: glob-style patterns",
                    "• regex: Python regular expressions",
                    "",
                    "Search scope note:",
                    "• Search works on currently visible (filtered) rows.",
                    "• Use Reset filter to search the full dataset.",
                ],
            ),
            (
                "Editing & Metadata",
                [
                    "Entry Editor capabilities:",
                    "• Edit Original text and Translation",
                    "• Set/clear Timestamp",
                    "• Set/clear GitHub user",
                    "• Partial update on multi-selection (only changed fields are propagated)",
                    "",
                    "Metadata conventions:",
                    "• Timestamp format: UTC / ISO-like string",
                    "• GitHub user defaults to the value in 'Default user'",
                ],
            ),
            (
                "Bulk/Test/Safety",
                [
                    "Bulk Operations:",
                    "• Replace text across selected translations",
                    "• Update metadata in batch",
                    "• Delete selected entries",
                    "",
                    "Test tabs:",
                    "• Test Translation: call freetz_translate with selected agent/options",
                    "• Test Agent: call provider APIs directly (with API key when needed)",
                    "",
                    "Safety features:",
                    "• Save all creates backup files before write",
                    "• Unsaved-state tracking in status bar",
                    "• Close protection when there are pending changes",
                ],
            ),
        ]
        self._show_rich_text_dialog(
            key="help",
            title="Application Help",
            subtitle="Reference guide for navigation, editing, bulk operations, testing, and safe save workflow.",
            sections=sections,
            icon_key="help",
            geometry="900x650",
        )

    def show_shortcuts_help(self):
        self._show_shortcuts_dialog()

    def _toggle_apikey_field(self):
        """Show/hide API key field based on selected agent"""
        agent = self.agent_test_agent_var.get()
        # deepl, openai, and libretranslate require API keys
        if agent in ["deepl", "openai", "libretranslate"]:
            self.agent_test_apikey_entry.configure(state="normal")
            self.agent_test_apikey_label.grid_remove()
        else:
            self.agent_test_apikey_entry.configure(state="disabled")
            self.agent_test_apikey_label.grid()

    def show_column_menu(self):
        """Show popup menu to toggle column visibility"""
        x = self.root.winfo_pointerx()
        y = self.root.winfo_pointery()
        self._show_column_menu_at(x, y)

    def _show_column_menu_at(self, x, y):
        """Show column visibility menu at absolute screen coordinates."""
        menu = tk.Menu(self.root, tearoff=0)
        
        for col in ["lang", "file", "package", "agent", "source", "original", "translation", "timestamp", "github_user"]:
            var = tk.BooleanVar(value=self.column_visibility[col])
            menu.add_checkbutton(
                label=self.column_headings[col],
                variable=var,
                command=lambda c=col, v=var: self.toggle_column_visibility(c, v)
            )
        
        # Position menu at given coordinates
        try:
            menu.tk_popup(x, y)
        finally:
            menu.grab_release()

    def _on_tree_right_click(self, event):
        """Show column visibility context menu when right-clicking table header."""
        region = self.tree.identify_region(event.x, event.y)
        if region == "heading":
            self._show_column_menu_at(event.x_root, event.y_root)
            return "break"

    def _on_tree_heading_motion(self, event):
        region = self.tree.identify_region(event.x, event.y)
        if region != "heading":
            self._hide_tree_heading_tooltip()
            return

        col_id = self.tree.identify_column(event.x)
        if not col_id:
            self._hide_tree_heading_tooltip()
            return

        try:
            idx = int(col_id.replace("#", "")) - 1
            columns = list(self.tree["columns"])
            if idx < 0 or idx >= len(columns):
                self._hide_tree_heading_tooltip()
                return
            col_name = columns[idx]
        except Exception:
            self._hide_tree_heading_tooltip()
            return

        text = self.column_tooltips.get(col_name)
        if not text:
            self._hide_tree_heading_tooltip()
            return

        self._show_tree_heading_tooltip(text)

    def _show_tree_heading_tooltip(self, text):
        x = self.root.winfo_pointerx() + 14
        y = self.root.winfo_pointery() + 14

        if hasattr(self, "_tree_heading_tooltip_window") and self._tree_heading_tooltip_window is not None:
            try:
                label = self._tree_heading_tooltip_window.winfo_children()[0]
                label.configure(text=text)
                self._tree_heading_tooltip_window.wm_geometry(f"+{x}+{y}")
                return
            except Exception:
                self._hide_tree_heading_tooltip()

        tw = tk.Toplevel(self.root)
        tw.wm_overrideredirect(True)
        tw.wm_geometry(f"+{x}+{y}")
        label = tk.Label(
            tw,
            text=text,
            justify="left",
            background="#ffffe0",
            relief="solid",
            borderwidth=1,
            wraplength=420,
            padx=6,
            pady=4,
        )
        label.pack()
        self._tree_heading_tooltip_window = tw

    def _hide_tree_heading_tooltip(self, _event=None):
        if hasattr(self, "_tree_heading_tooltip_window") and self._tree_heading_tooltip_window is not None:
            self._tree_heading_tooltip_window.destroy()
            self._tree_heading_tooltip_window = None

    def _update_tree_column_separators(self):
        if not hasattr(self, "tree") or not self.tree.winfo_exists():
            return
        if not hasattr(self, "_tree_separator_parent"):
            return

        columns = list(self.tree["columns"])
        visible_columns = [c for c in columns if int(self.tree.column(c, "width")) > 0]
        needed = max(0, len(visible_columns) - 1)

        while len(self._tree_separator_lines) < needed:
            line = tk.Frame(self._tree_separator_parent, bg="#c8c8c8", width=1, bd=0, highlightthickness=0)
            self._tree_separator_lines.append(line)
        while len(self._tree_separator_lines) > needed:
            self._tree_separator_lines.pop().destroy()

        if needed == 0:
            return

        total_width = sum(int(self.tree.column(c, "width")) for c in visible_columns)
        if total_width <= 0:
            for line in self._tree_separator_lines:
                line.place_forget()
            return

        try:
            xview_start = float(self.tree.xview()[0])
        except Exception:
            xview_start = 0.0
        x_offset = int(total_width * xview_start)

        tree_x = self.tree.winfo_x()
        tree_y = self.tree.winfo_y()
        tree_w = self.tree.winfo_width()
        tree_h = self.tree.winfo_height()

        cumulative = 0
        for index, col in enumerate(visible_columns[:-1]):
            cumulative += int(self.tree.column(col, "width"))
            sep_x = tree_x + cumulative - x_offset

            line = self._tree_separator_lines[index]
            if sep_x <= tree_x or sep_x >= tree_x + tree_w:
                line.place_forget()
            else:
                line.place(x=sep_x, y=tree_y, width=1, height=tree_h)
                line.lift()

    def toggle_column_visibility(self, column, var):
        """Toggle visibility of a column"""
        visible = var.get()
        self.column_visibility[column] = visible
        
        if visible:
            # Show column by restoring original width
            self.tree.column(column, width=self.column_widths[column])
        else:
            # Hide column by setting width to 0
            self.tree.column(column, width=0)

        self._update_tree_column_separators()

    def show_search_dialog(self):
        """Show search dialog with query input and Next/Previous buttons"""
        if self.search_dialog and tk.Toplevel.winfo_exists(self.search_dialog):
            # Dialog already open, focus it and select all text
            self.search_dialog.lift()
            self.search_dialog.focus()
            if hasattr(self, 'search_entry') and self.search_entry.winfo_exists():
                self.search_entry.focus()
                self.search_entry.select_range(0, tk.END)
                self.search_entry.icursor(tk.END)  # Cursor at end
            return
        
        # Create search dialog
        self.search_dialog = tk.Toplevel(self.root)
        self.search_dialog.title("Search Entries")
        self.search_dialog.geometry("500x150")
        self.search_dialog.transient(self.root)
        
        # Center dialog on parent
        self.search_dialog.update_idletasks()
        x = self.root.winfo_x() + (self.root.winfo_width() // 2) - 250
        y = self.root.winfo_y() + (self.root.winfo_height() // 3)
        self.search_dialog.geometry(f"+{x}+{y}")
        
        # Search query frame
        query_frame = ttk.Frame(self.search_dialog, padding=10)
        query_frame.pack(fill="x")
        
        ttk.Label(query_frame, text="Search for:").pack(side="left", padx=(0, 8))
        self.search_entry_var = tk.StringVar(value=self.search_query)
        self.search_entry = ttk.Entry(query_frame, textvariable=self.search_entry_var, width=40)
        self.search_entry.pack(side="left", fill="x", expand=True)
        self.search_entry.focus()
        self.search_entry.select_range(0, tk.END)  # Select all existing text
        self.search_entry.icursor(tk.END)  # Cursor at end
        
        # Bind Enter to start search
        self.search_entry.bind("<Return>", lambda e: self._perform_search())
        
        # Info label
        info_frame = ttk.Frame(self.search_dialog, padding=(10, 0, 10, 10))
        info_frame.pack(fill="x")
        self.search_info_var = tk.StringVar(value="Enter search term and press Enter or click Search")
        ttk.Label(info_frame, textvariable=self.search_info_var, foreground="blue").pack(side="left")

        # Explicit scope warning when filters are active
        scope_message = self._get_search_scope_message()
        if scope_message:
            scope_frame = ttk.Frame(self.search_dialog, padding=(10, 0, 10, 0))
            scope_frame.pack(fill="x")
            ttk.Label(
                scope_frame,
                text=scope_message,
                foreground="#b22222",
                wraplength=470,
                justify="left",
            ).pack(side="left", anchor="w")
        
        # Buttons
        button_frame = ttk.Frame(self.search_dialog, padding=10)
        button_frame.pack(fill="x")
        
        ttk.Button(button_frame, text=self._label("search", "Search"), command=self._perform_search, width=15).pack(side="left", padx=(0, 8))
        ttk.Button(button_frame, text=f"{self._icons['next']} Next (F3)", command=self.search_next, width=15).pack(side="left", padx=4)
        ttk.Button(button_frame, text=f"{self._icons['prev']} Previous (Shift+F3)", command=self.search_prev, width=20).pack(side="left", padx=4)
        ttk.Button(button_frame, text="Close", command=self.search_dialog.destroy, width=10).pack(side="right")
        
        # Bind ESC to close
        self.search_dialog.bind("<Escape>", lambda e: self.search_dialog.destroy())

    def _has_active_filters(self):
        """Return True if any filter (except dialog search) is currently restricting rows."""
        if self.lang_var.get() != "ALL":
            return True
        if self.file_var.get() != "ALL":
            return True
        if self.agent_var.get() != "ALL":
            return True
        if self.user_var.get() != "ALL":
            return True
        if self.only_no_meta.get():
            return True
        if self.date_enabled.get():
            return True
        if self.search_var.get().strip():
            return True
        return False

    def _get_search_scope_message(self):
        """Describe current search scope for the dialog when rows are filtered."""
        visible = len(self.filtered_ids)
        total = len(self.index)

        if not self._has_active_filters() and visible == total:
            return ""

        return (
            f"{self._icons['warn']} Search scope is limited to filtered rows only. "
            f"Currently visible: {visible} of {total} entries. "
            "Use 'Reset filter' to search the entire dataset."
        )

    def _update_filters_note(self):
        """Update visible note in Filters section about current filter state."""
        visible = len(self.filtered_ids)
        total = len(self.index)

        if self._has_active_filters() or visible != total:
            self.filters_note_var.set(
                f"{self._icons['warn']} Filters active: showing {visible} of {total} entries. "
                "Use 'Reset filter' to clear all filters."
            )
            self.lbl_filters_note.configure(foreground="#b22222")
        else:
            self.filters_note_var.set(
                f"ℹ No active filters. Showing all entries ({total})."
            )
            self.lbl_filters_note.configure(foreground="#1a5fb4")
    
    def _perform_search(self):
        """Execute search and find all matching entries"""
        query = self.search_entry_var.get().strip()
        if not query:
            self.search_info_var.set(f"{self._icons['warn']}  Please enter a search term")
            return
        
        self.search_query = query
        self.search_results = []
        self.search_current_index = -1
        
        # Search in visible filtered entries only
        query_lower = query.lower()
        for entry_id in self.filtered_ids:
            row = self.row_by_id.get(entry_id)
            if not row:
                continue
            
            # Search in all text fields
            searchable_text = " ".join([
                str(row.get("lang", "")),
                str(row.get("agent", "")),
                str(row.get("source", "")),
                str(row.get("original", "")),
                str(row.get("translation", "")),
                str(row.get("timestamp", "")),
                str(row.get("github_user", ""))
            ]).lower()
            
            if query_lower in searchable_text:
                self.search_results.append(entry_id)
        
        # Update info
        if self.search_results:
            self.search_info_var.set(f"{self._icons['success']} Found {len(self.search_results)} matches")
            
            # Jump to first result after current selection (if any)
            current_selection = self.tree.selection()
            start_index = 0
            
            if current_selection and current_selection[0] in self.filtered_ids:
                # Find position of current selection in filtered list
                try:
                    current_pos = self.filtered_ids.index(current_selection[0])
                    # Find first search result after current position
                    for i, result_id in enumerate(self.search_results):
                        if self.filtered_ids.index(result_id) > current_pos:
                            start_index = i
                            break
                except (ValueError, IndexError):
                    start_index = 0
            
            self.search_current_index = start_index
            self._highlight_search_result()
        else:
            self.search_info_var.set(f"{self._icons['error']} No matches found for '{query}'")
    
    def search_next(self):
        """Jump to next search result"""
        self._prune_search_results()

        if not self.search_results:
            if self.search_query:
                messagebox.showinfo("No results", f"No search results for '{self.search_query}'.\\nUse Ctrl+F to search.")
            else:
                messagebox.showinfo("No search", "No active search. Use Ctrl+F to start searching.")
            return
        
        # Move to next result (wrap around)
        self.search_current_index = (self.search_current_index + 1) % len(self.search_results)
        self._highlight_search_result()
    
    def search_prev(self):
        """Jump to previous search result"""
        self._prune_search_results()

        if not self.search_results:
            if self.search_query:
                messagebox.showinfo("No results", f"No search results for '{self.search_query}'.\\nUse Ctrl+F to search.")
            else:
                messagebox.showinfo("No search", "No active search. Use Ctrl+F to start searching.")
            return
        
        # Move to previous result (wrap around)
        self.search_current_index = (self.search_current_index - 1) % len(self.search_results)
        self._highlight_search_result()
    
    def _highlight_search_result(self):
        """Highlight and scroll to current search result"""
        self._prune_search_results()

        if self.search_current_index < 0 or self.search_current_index >= len(self.search_results):
            return
        
        entry_id = self.search_results[self.search_current_index]

        if not self.tree.exists(entry_id):
            return
        
        # Select and focus the row
        self.tree.selection_set(entry_id)
        self.tree.see(entry_id)
        self.tree.focus(entry_id)
        
        # Update search dialog info if open
        if self.search_dialog and tk.Toplevel.winfo_exists(self.search_dialog):
            self.search_info_var.set(
                f"{self._icons['success']} Match {self.search_current_index + 1} of {len(self.search_results)}"
            )

    def _prune_search_results(self):
        """Keep search results aligned with currently visible tree rows."""
        if not self.search_results:
            return

        self.search_results = [
            entry_id for entry_id in self.search_results
            if entry_id in self.filtered_ids and self.tree.exists(entry_id)
        ]

        if not self.search_results:
            self.search_current_index = -1
            return

        if self.search_current_index < 0:
            self.search_current_index = 0
        elif self.search_current_index >= len(self.search_results):
            self.search_current_index = 0

    def reload_from_path(self):
        path = Path(self.cache_dir_var.get()).expanduser().resolve()
        if not path.exists() or not path.is_dir():
            messagebox.showerror("Invalid directory", f"Directory not found: {path}")
            return
        self.cache_dir = path
        self._load_all()
        self._refresh_filter_values()
        self.apply_filters()

    def _load_all(self):
        self.lang_data.clear()
        self.index.clear()
        self.row_by_id.clear()
        self.filtered_ids.clear()
        self.dirty_langs.clear()

        files = sorted(
            file_path
            for file_path in self.cache_dir.iterdir()
            if file_path.is_file() and file_path.name.endswith(".json")
        )
        for file_path in files:
            file_stem = file_path.stem  # e.g., "it", "it-rutorrent", "de-transmission"
            
            # Extract base language code (part before first dash, if any)
            if "-" in file_stem:
                base_lang = file_stem.split("-", 1)[0]
                file_label = file_stem.split("-", 1)[1]
            else:
                base_lang = file_stem
                file_label = None
            
            try:
                payload = json.loads(file_path.read_text(encoding="utf-8"))
            except Exception as exc:
                messagebox.showwarning("Read error", f"Cannot parse {file_path.name}: {exc}")
                continue

            if not isinstance(payload, dict):
                continue

            # Store with file_stem as key (preserves file identity)
            self.lang_data[file_stem] = payload
            
            for key, entry in payload.items():
                if not isinstance(entry, dict):
                    continue
                agent, source = self._split_cache_key(key)
                row = {
                    "id": f"{file_stem}|{key}",  # Unique ID includes file_stem
                    "lang": base_lang,  # Base language for display/filtering ("it")
                    "file": f"{file_stem}.json",
                    "file_stem": file_stem,  # Original file name stem ("it-rutorrent")
                    "file_label": file_label,  # Label part ("rutorrent" or None)
                    "key": key,
                    "agent": agent,
                    "source": source,
                    "original": str(entry.get("original", "")),
                    "translation": str(entry.get("translation", "")),
                    "timestamp": str(entry.get("timestamp", "")),
                    "github_user": str(entry.get("github_user", "")),
                    "metadata_present": bool(entry.get("timestamp") or entry.get("service") or entry.get("github_user")),
                }
                self.index.append(row)
                self.row_by_id[row["id"]] = row

        self.update_status_bar(message=f"Loaded {len(self.index)} entries from {len(self.lang_data)} cache file(s)")

    @staticmethod
    def _split_cache_key(key: str):
        if ":" in key:
            service, source = key.split(":", 1)
            return service, source
        return "unknown", key

    def _refresh_filter_values(self):
        langs = sorted({r["lang"] for r in self.index})
        agents = sorted({r["agent"] for r in self.index})
        users = sorted({r["github_user"] for r in self.index if r["github_user"]})

        self.lang_combo["values"] = ["ALL"] + langs
        self.agent_combo["values"] = ["ALL"] + agents
        self.user_combo["values"] = ["ALL"] + users

        if self.lang_var.get() not in self.lang_combo["values"]:
            self.lang_var.set("ALL")
        if self.agent_var.get() not in self.agent_combo["values"]:
            self.agent_var.set("ALL")
        if self.user_var.get() not in self.user_combo["values"]:
            self.user_var.set("ALL")
        
        # Update file filter
        self._update_file_filter()
    
    def _update_file_filter(self):
        """Update file filter combobox based on selected language"""
        selected_lang = self.lang_var.get()
        
        if selected_lang == "ALL":
            # Show all file stems
            file_stems = sorted({r["file_stem"] for r in self.index})
        else:
            # Show only files for selected language
            file_stems = sorted({r["file_stem"] for r in self.index if r["lang"] == selected_lang})
        
        self.file_combo["values"] = ["ALL"] + file_stems
        
        # Reset file filter if current value not in list
        if self.file_var.get() not in self.file_combo["values"]:
            self.file_var.set("ALL")

    def _parse_date(self, value: str):
        value = value.strip()
        if not value:
            return None
        return dt.datetime.strptime(value, DATE_FMT).date()

    def _get_date_from_filter(self):
        """Get dates from filter widgets (handles both calendar and entry)"""
        if CALENDAR_AVAILABLE:
            d_from = self.date_from_widget.get_date() if self.date_enabled.get() else None
            d_to = self.date_to_widget.get_date() if self.date_enabled.get() else None
        else:
            try:
                d_from = self._parse_date(self.date_from_var.get()) if self.date_enabled.get() else None
                d_to = self._parse_date(self.date_to_var.get()) if self.date_enabled.get() else None
            except ValueError as exc:
                raise ValueError(f"Invalid date: {exc}")
        return d_from, d_to

    def _parse_timestamp_date(self, ts: str):
        ts = (ts or "").strip()
        if not ts:
            return None
        try:
            return dt.datetime.strptime(ts[:10], DATE_FMT).date()
        except Exception:
            return None

    def _search_match(self, row, pattern: str):
        fields = []
        if self.in_key.get():
            fields.append(row["source"])
        if self.in_original.get():
            fields.append(row["original"])
        if self.in_translation.get():
            fields.append(row["translation"])

        if not fields:
            return True

        mode = self.search_mode_var.get()
        case_sensitive = self.case_sensitive.get()

        if not case_sensitive:
            pattern_cmp = pattern.lower()
            fields_cmp = [f.lower() for f in fields]
        else:
            pattern_cmp = pattern
            fields_cmp = fields

        if mode == "contains":
            return any(pattern_cmp in f for f in fields_cmp)
        if mode == "wildcard":
            return any(fnmatch.fnmatch(f, pattern_cmp) for f in fields_cmp)

        flags = 0 if case_sensitive else re.IGNORECASE
        try:
            rx = re.compile(pattern, flags)
        except re.error as exc:
            raise ValueError(f"Invalid regex: {exc}")
        return any(rx.search(f) is not None for f in fields)

    def apply_filters(self):
        try:
            d_from, d_to = self._get_date_from_filter()
        except ValueError as exc:
            messagebox.showerror("Invalid date", str(exc))
            return

        if d_from and d_to and d_from > d_to:
            messagebox.showerror("Invalid period", "From date must be <= To date")
            return

        search = self.search_var.get().strip()

        for item in self.tree.get_children():
            self.tree.delete(item)

        self.filtered_ids.clear()
        filtered_rows = []
        
        for row in self.index:
            if self.lang_var.get() != "ALL" and row["lang"] != self.lang_var.get():
                continue
            if self.file_var.get() != "ALL" and row["file_stem"] != self.file_var.get():
                continue
            if self.agent_var.get() != "ALL" and row["agent"] != self.agent_var.get():
                continue
            if self.user_var.get() != "ALL" and row["github_user"] != self.user_var.get():
                continue
            if self.only_no_meta.get() and row["metadata_present"]:
                continue

            if self.date_enabled.get():
                r_date = self._parse_timestamp_date(row["timestamp"])
                if d_from and (r_date is None or r_date < d_from):
                    continue
                if d_to and (r_date is None or r_date > d_to):
                    continue

            if search:
                try:
                    if not self._search_match(row, search):
                        continue
                except ValueError as exc:
                    messagebox.showerror("Invalid search", str(exc))
                    return

            filtered_rows.append(row)

        # Apply sorting if column selected
        if self.sort_column:
            filtered_rows.sort(key=lambda r: r.get(self.sort_column, ""), reverse=self.sort_reverse)

        # Insert with alternating colors
        for idx, row in enumerate(filtered_rows):
            tag = "evenrow" if idx % 2 == 0 else "oddrow"
            self.tree.insert(
                "",
                "end",
                iid=row["id"],
                values=(
                    row["lang"],
                    row["file"],
                    row.get("file_label", "") or "",
                    row["agent"],
                    row["source"],
                    row["original"],
                    row["translation"],
                    row["timestamp"],
                    row["github_user"],
                ),
                tags=(tag,)
            )
            self.filtered_ids.append(row["id"])

        self._update_filters_note()
        self.update_status_bar()

    def sort_by_column(self, col):
        """Sort tree by column when header clicked"""
        if self.sort_column == col:
            self.sort_reverse = not self.sort_reverse
        else:
            self.sort_column = col
            self.sort_reverse = False
        
        self.apply_filters()  # Re-apply filters with new sort

    def reset_filters(self):
        self.lang_var.set("ALL")
        self.file_var.set("ALL")
        self.agent_var.set("ALL")
        self.user_var.set("ALL")
        self.search_var.set("")
        self.search_mode_var.set("contains")
        self.case_sensitive.set(False)
        self.in_key.set(True)
        self.in_original.set(True)
        self.in_translation.set(True)
        self.date_enabled.set(False)
        if not CALENDAR_AVAILABLE:
            self.date_from_var.set("")
            self.date_to_var.set("")
        self.only_no_meta.set(False)
        self.apply_filters()

    def add_new_entry(self):
        """Add a new translation entry"""
        dialog = tk.Toplevel(self.root)
        dialog.title("Add New Entry")
        dialog.geometry("600x500")
        dialog.transient(self.root)
        dialog.grab_set()
        
        # ESC to close dialog
        dialog.bind("<Escape>", lambda e: dialog.destroy())

        frame = ttk.Frame(dialog, padding=10)
        frame.pack(fill="both", expand=True)
        frame.columnconfigure(1, weight=1)

        ttk.Label(frame, text="Language:").grid(row=0, column=0, sticky="w", pady=(0, 6))
        lang_var = tk.StringVar(value="it")
        ttk.Entry(frame, textvariable=lang_var, width=8).grid(row=0, column=1, sticky="w", pady=(0, 6))

        ttk.Label(frame, text="Package (optional):").grid(row=1, column=0, sticky="w", pady=(0, 6))
        package_var = tk.StringVar(value="")
        package_entry = ttk.Entry(frame, textvariable=package_var, width=20)
        package_entry.grid(row=1, column=1, sticky="w", pady=(0, 6))
        # Hint label for package field
        hint_label = ttk.Label(frame, text="e.g., avm-rules, dropbear (leave empty for base cache file)", 
                               foreground="gray", font=("TkDefaultFont", 8))
        hint_label.grid(row=1, column=1, sticky="w", padx=(0, 0), pady=(28, 0))

        ttk.Label(frame, text="Agent:").grid(row=2, column=0, sticky="w", pady=(0, 6))
        agent_var = tk.StringVar(value="deepl")
        ttk.Combobox(frame, textvariable=agent_var, width=14,
                     values=["deepl", "mymemory", "libretranslate", "apertium", "lingva", "openai"]).grid(
            row=2, column=1, sticky="w", pady=(0, 6))

        ttk.Label(frame, text="Source text (key):").grid(row=3, column=0, sticky="nw", pady=(0, 6))
        source_txt = tk.Text(frame, height=3, wrap="word")
        source_txt.grid(row=3, column=1, sticky="ew", pady=(0, 6))

        ttk.Label(frame, text="Original (English):").grid(row=4, column=0, sticky="nw", pady=(0, 6))
        orig_txt = tk.Text(frame, height=4, wrap="word")
        orig_txt.grid(row=4, column=1, sticky="ew", pady=(0, 6))

        ttk.Label(frame, text="Translation:").grid(row=5, column=0, sticky="nw", pady=(0, 6))
        trans_txt = tk.Text(frame, height=6, wrap="word")
        trans_txt.grid(row=5, column=1, sticky="ew", pady=(0, 6))

        def do_add():
            lang = lang_var.get().strip()
            package = package_var.get().strip()
            agent = agent_var.get().strip()
            source = source_txt.get("1.0", "end-1c").strip()
            original = orig_txt.get("1.0", "end-1c").strip()
            translation = trans_txt.get("1.0", "end-1c").strip()

            if not all([lang, agent, source, original, translation]):
                messagebox.showwarning("Missing fields", "Language, Agent, Source, Original, and Translation are required")
                return

            # Calculate file_stem and file_label based on package
            if package:
                file_stem = f"{lang}-{package}"
                file_label = package
            else:
                file_stem = lang
                file_label = None

            key = f"{agent}:{source}"
            entry_id = f"{file_stem}|{key}"

            if entry_id in self.row_by_id:
                messagebox.showerror("Duplicate", f"Entry already exists: {entry_id}")
                return

            timestamp = dt.datetime.now(dt.timezone.utc).strftime(TS_FMT)
            github_user = self._default_github_user()

            # New entries go to package-specific file if package provided, otherwise base file
            row = {
                "id": entry_id,
                "lang": lang,  # Base language code (e.g., "it")
                "file": f"{file_stem}.json",
                "file_stem": file_stem,  # e.g., "it" or "it-avm-rules"
                "file_label": file_label,  # e.g., None or "avm-rules"
                "key": key,
                "agent": agent,
                "source": source,
                "original": original,
                "translation": translation,
                "timestamp": timestamp,
                "github_user": github_user,
                "metadata_present": True
            }

            # Store in lang_data using file_stem as key (matches save logic)
            if file_stem not in self.lang_data:
                self.lang_data[file_stem] = {}

            self.lang_data[file_stem][key] = {
                "original": original,
                "translation": translation,
                "timestamp": timestamp,
                "github_user": github_user,
                "service": agent
            }

            self.index.append(row)
            self.row_by_id[entry_id] = row
            self.dirty_langs.add(file_stem)  # Track file_stem, not lang

            self._refresh_filter_values()
            self._update_file_filter()  # Update file filter to include new file_stem
            self.apply_filters()
            self.update_status_bar(message=f"Added new entry to {file_stem}.json: {key}")
            dialog.destroy()

        btn_frame = ttk.Frame(frame)
        btn_frame.grid(row=6, column=0, columnspan=2, pady=(10, 0))
        ttk.Button(btn_frame, text=self._label("apply", "Add"), command=do_add).pack(side="left", padx=(0, 4))
        ttk.Button(btn_frame, text="Cancel", command=dialog.destroy).pack(side="left")

    def bulk_update_metadata(self):
        """Update timestamp and/or github_user for all selected entries"""
        selected = list(self.tree.selection())
        if not selected:
            messagebox.showwarning("No selection", "Select one or more entries")
            return

        timestamp = self.bulk_ts_var.get().strip()
        github_user = self.bulk_user_var.get().strip()

        if not timestamp and not github_user:
            messagebox.showwarning("No metadata", "Enter timestamp and/or github user")
            return

        changed = 0
        for entry_id in selected:
            row = self.row_by_id.get(entry_id)
            if not row:
                continue

            if timestamp:
                row["timestamp"] = timestamp
            if github_user:
                row["github_user"] = github_user
            row["metadata_present"] = True

            file_stem = row["file_stem"]
            key = row["key"]
            entry = self.lang_data[file_stem].setdefault(key, {})
            entry.setdefault("original", row["original"])
            entry.setdefault("translation", row["translation"])
            if timestamp:
                entry["timestamp"] = timestamp
            if github_user:
                entry["github_user"] = github_user
            entry.setdefault("service", row["agent"])
            self.dirty_langs.add(file_stem)
            changed += 1

            if self.tree.exists(entry_id):
                self.tree.item(entry_id, values=(
                    row["lang"], row["file"], row.get("file_label", "") or "", row["agent"], row["source"],
                    row["original"], row["translation"],
                    row["timestamp"], row["github_user"]
                ))

        self._refresh_filter_values()
        self.update_status_bar(message=f"Updated metadata for {changed} entries")

    def test_translate(self):
        """Test translation by calling freetz_translate"""
        src = self.test_src_var.get().strip()
        tgt = self.test_tgt_var.get().strip()
        agent = self.test_agent_var.get().strip()
        text = self.test_input_txt.get("1.0", "end-1c").strip()
        package_name = ""
        if self.currently_selected_ids:
            selected_row = self.row_by_id.get(self.currently_selected_ids[0])
            if selected_row:
                package_name = (selected_row.get("file_label") or "").strip()

        if not all([src, tgt, agent, text]):
            messagebox.showwarning("Missing input", "All fields are required")
            return

        self.test_result_txt.configure(state="normal")
        self.test_result_txt.delete("1.0", "end")
        self.test_result_txt.insert("1.0", f"{self._icons['pending']} Translating...")
        self.test_result_txt.configure(state="disabled")
        self.update_status_bar(message="Translation in progress...")

        def run_translation():
            script_path = self.cache_dir.parent / "freetz_translate"
            if not script_path.exists():
                self.root.after(0, lambda: self._show_test_result(
                    f"{self._icons['error']} Error: freetz_translate not found at {script_path}", "error"))
                return

            env = os.environ.copy()
            env["FREETZ_TRANSLATE_SERVICE"] = agent
            env["FREETZ_TRANSLATE_DEBUG"] = "y" if self.test_debug_var.get() else "n"
            env["FREETZ_TRANSLATE_CACHE_ENABLED"] = "y" if self.test_cache_var.get() else "n"

            try:
                cmd = [str(script_path), src, tgt, text]
                if package_name:
                    cmd.append(package_name)

                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    timeout=30,
                    env=env
                )

                if result.returncode == 0:
                    output = f"{self._icons['success']} Translation successful\n\n"
                    output += f"Service: {agent}\n"
                    output += f"Source ({src}): {text}\n\n"
                    output += f"Result ({tgt}):\n{result.stdout}"
                    if result.stderr:
                        output += f"\n\n--- Debug info ---\n{result.stderr}"
                    self.root.after(0, lambda: self._show_test_result(output, "success"))
                else:
                    output = f"{self._icons['error']} Translation failed (exit code {result.returncode})\n\n"
                    output += f"Error: {result.stderr or result.stdout}"
                    self.root.after(0, lambda: self._show_test_result(output, "error"))

            except subprocess.TimeoutExpired:
                self.root.after(0, lambda: self._show_test_result(
                    f"{self._icons['error']} Error: Translation timed out (30s)", "error"))
            except Exception as exc:
                error_msg = str(exc)
                
                # Windows-specific error: suggest Linux CLI command
                if "WinError 193" in error_msg or "is not a valid Win32 application" in error_msg:
                    debug_val = "y" if self.test_debug_var.get() else "n"
                    cache_val = "y" if self.test_cache_var.get() else "n"
                    package_arg = f" {shlex.quote(package_name)}" if package_name else ""
                    cli_cmd = f"FREETZ_TRANSLATE_DEBUG={debug_val} FREETZ_TRANSLATE_SERVICE={agent} FREETZ_TRANSLATE_CACHE_ENABLED={cache_val} tools/freetz_translate {shlex.quote(src)} {shlex.quote(tgt)} {shlex.quote(text)}{package_arg} && echo"
                    error_msg = (
                        f"{self._icons['error']} Windows Error: freetz_translate requires bash\n\n"
                        f"The translation script cannot run directly on Windows.\n\n"
                        f"{self._icons['use_editor']} Linux CLI command to test this:\n\n"
                        f"    {cli_cmd}\n\n"
                        f"Run this command in WSL, Git Bash, or a Linux environment."
                    )
                
                self.root.after(0, lambda: self._show_test_result(
                    f"{self._icons['error']} Error: {error_msg}", "error"))

        # Run in background thread
        thread = threading.Thread(target=run_translation, daemon=True)
        thread.start()

    def _show_test_result(self, text, status):
        """Update test result text box (called from GUI thread)"""
        self.test_result_txt.configure(state="normal")
        self.test_result_txt.delete("1.0", "end")
        self.test_result_txt.insert("1.0", text)
        self.test_result_txt.configure(state="disabled")
        self.update_status_bar(message=f"Translation {status}")

    def test_use_from_editor(self):
        """Copy text from editor tab to test tab"""
        self.notebook.select(2)  # Switch to test tab
        orig = self.original_txt.get("1.0", "end-1c").strip()
        if orig:
            self.test_input_txt.delete("1.0", "end")
            self.test_input_txt.insert("1.0", orig)
            lang = self.lang_edit_var.get()
            if lang:
                self.test_tgt_var.set(lang)

    def agent_test_use_from_editor(self):
        """Copy text from editor tab to agent test tab"""
        self.notebook.select(3)  # Switch to agent test tab
        orig = self.original_txt.get("1.0", "end-1c").strip()
        if orig:
            self.agent_test_input_txt.delete("1.0", "end")
            self.agent_test_input_txt.insert("1.0", orig)
            lang = self.lang_edit_var.get()
            if lang:
                self.agent_test_tgt_var.set(lang)

    def agent_test_api(self):
        """Test API directly with provided key using native Python (cross-platform)"""
        import urllib.request
        import urllib.parse
        import json as json_lib
        
        agent = self.agent_test_agent_var.get()
        api_key = self.agent_test_apikey_var.get().strip()
        src_lang = self.agent_test_src_var.get().strip()
        tgt_lang = self.agent_test_tgt_var.get().strip()
        text = self.agent_test_input_txt.get("1.0", "end-1c").strip()
        
        # Validate API key for agents that require it
        if agent in ["deepl", "openai", "libretranslate"] and not api_key:
            key_info = {
                "deepl": "Get one at: https://www.deepl.com/pro-api",
                "openai": "Get one at: https://platform.openai.com/api-keys",
                "libretranslate": "Get one at: https://portal.libretranslate.com"
            }
            messagebox.showwarning("Missing API Key", f"{agent} requires an API key\n\n{key_info.get(agent, '')}")
            return
        
        if not text:
            messagebox.showwarning("Missing text", "Please enter text to translate")
            return
        
        self.agent_test_result_txt.configure(state="normal")
        self.agent_test_result_txt.delete("1.0", "end")
        self.agent_test_result_txt.insert("1.0", "Testing API...\n")
        self.agent_test_result_txt.configure(state="disabled")
        self.update_status_bar(message="Testing API...")
        
        def run_test():
            try:
                result_text = ""
                
                if agent == "deepl":
                    # DeepL API - POST form-data
                    url = "https://api-free.deepl.com/v2/translate"
                    data = urllib.parse.urlencode({
                        'text': text,
                        'source_lang': src_lang.upper(),
                        'target_lang': tgt_lang.upper()
                    }).encode('utf-8')
                    
                    req = urllib.request.Request(url, data=data, method='POST')
                    req.add_header('Authorization', f'DeepL-Auth-Key {api_key}')
                    req.add_header('Content-Type', 'application/x-www-form-urlencoded')
                    req.add_header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
                    
                    with urllib.request.urlopen(req, timeout=30) as response:
                        result_text = response.read().decode('utf-8')
                
                elif agent == "openai":
                    # OpenAI API - POST JSON
                    url = "https://api.openai.com/v1/chat/completions"
                    prompt = f"Translate from {src_lang} to {tgt_lang}: {text}"
                    payload = {
                        "model": "gpt-3.5-turbo",
                        "messages": [{"role": "user", "content": prompt}],
                        "temperature": 0.3
                    }
                    
                    data = json_lib.dumps(payload).encode('utf-8')
                    req = urllib.request.Request(url, data=data, method='POST')
                    req.add_header('Authorization', f'Bearer {api_key}')
                    req.add_header('Content-Type', 'application/json')
                    req.add_header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
                    
                    with urllib.request.urlopen(req, timeout=30) as response:
                        result_text = response.read().decode('utf-8')
                
                elif agent == "mymemory":
                    # MyMemory API - GET
                    params = urllib.parse.urlencode({
                        'q': text,
                        'langpair': f'{src_lang}|{tgt_lang}'
                    })
                    url = f"https://api.mymemory.translated.net/get?{params}"
                    
                    req = urllib.request.Request(url)
                    req.add_header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
                    with urllib.request.urlopen(req, timeout=30) as response:
                        result_text = response.read().decode('utf-8')
                
                elif agent == "libretranslate":
                    # LibreTranslate API - POST JSON (requires API key since 2024)
                    url = "https://libretranslate.com/translate"
                    payload = {
                        "q": text,
                        "source": src_lang,
                        "target": tgt_lang,
                        "format": "text"
                    }
                    
                    # Add API key if provided
                    if api_key:
                        payload["api_key"] = api_key
                    
                    data = json_lib.dumps(payload).encode('utf-8')
                    req = urllib.request.Request(url, data=data, method='POST')
                    req.add_header('Content-Type', 'application/json')
                    req.add_header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
                    
                    with urllib.request.urlopen(req, timeout=30) as response:
                        result_text = response.read().decode('utf-8')
                
                elif agent == "apertium":
                    # Apertium API - GET
                    # NOTE: Apertium only supports specific language pairs (mainly Romance languages)
                    # Italian pairs: ita↔spa, ita→cat, ita→srd
                    # Other pairs: es↔fr, es↔pt, es↔ca, ca↔fr, pt↔es, etc.
                    # NOT supported: English↔Italian (en↔it)
                    # Check available pairs at: https://apertium.org/apy/listPairs
                    lang_pair = f'{src_lang}|{tgt_lang}'
                    params = urllib.parse.urlencode({
                        'q': text,
                        'langpair': lang_pair,
                        'markUnknown': 'no'
                    })
                    url = f"https://apertium.org/apy/translate?{params}"
                    
                    req = urllib.request.Request(url)
                    req.add_header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
                    with urllib.request.urlopen(req, timeout=30) as response:
                        result_text = response.read().decode('utf-8')
                
                elif agent == "lingva":
                    # Lingva API - GET
                    encoded_text = urllib.parse.quote(text)
                    url = f"https://lingva.ml/api/v1/{src_lang}/{tgt_lang}/{encoded_text}"
                    
                    req = urllib.request.Request(url)
                    req.add_header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
                    with urllib.request.urlopen(req, timeout=30) as response:
                        result_text = response.read().decode('utf-8')
                
                else:
                    self.root.after(0, lambda: self._show_agent_test_result(
                        f"{self._icons['error']} Agent '{agent}' not supported", "error"))
                    return
                
                # Success - show response (pretty-print JSON if possible)
                try:
                    parsed_json = json_lib.loads(result_text)
                    formatted_text = json_lib.dumps(parsed_json, indent=2, ensure_ascii=False)
                    output = f"{self._icons['success']} API Response:\n\n{formatted_text}\n"
                except (json_lib.JSONDecodeError, ValueError):
                    # Not JSON or parsing failed - show raw text
                    output = f"{self._icons['success']} API Response:\n\n{result_text}\n"
                
                self.root.after(0, lambda: self._show_agent_test_result(output, "success"))
            
            except urllib.error.HTTPError as exc:
                error_body = exc.read().decode('utf-8', errors='ignore')
                error_msg = f"HTTP {exc.code} {exc.reason}\n\n{error_body}"
                
                # Add helpful hints for common errors
                hint = ""
                if exc.code == 400 and agent == "apertium" and "pair" in error_body.lower():
                    # Apertium has limited language pair support - show relevant pairs
                    hint = f"\n\n{self._icons['hint']} Hint: Apertium doesn't support '{src_lang}→{tgt_lang}'.\n"
                    hint += "\nSupported pairs with Italian:\n"
                    hint += "  • ita↔spa (Italian↔Spanish)\n"
                    hint += "  • ita→cat (Italian→Catalan)\n"
                    hint += "  • ita→srd (Italian→Sardinian)\n"
                    hint += "\nOther Romance language pairs:\n"
                    hint += "  • es↔fr, es↔pt, es↔ca, es↔gl, es↔an\n"
                    hint += "  • ca↔es, ca↔fr, ca↔pt, ca→oc\n"
                    hint += "  • pt↔es, pt↔ca, pt↔gl\n"
                    hint += "  • fr↔es, fr↔ca, oc↔es, oc↔ca\n"
                    hint += f"\n{self._icons['warn']}  English↔Italian NOT supported by Apertium.\n"
                    hint += "Use DeepL, MyMemory, or LibreTranslate for English↔Italian.\n"
                    hint += "\nFull list: https://apertium.org/apy/listPairs"
                elif exc.code == 400 and agent == "libretranslate" and "API key" in error_body:
                    hint = f"\n\n{self._icons['hint']} Hint: Get a free API key at https://portal.libretranslate.com"
                elif exc.code == 403 and "Cloudflare" in error_body:
                    hint = f"\n\n{self._icons['hint']} Hint: Service may be blocking automated requests"
                
                self.root.after(0, lambda: self._show_agent_test_result(
                    f"{self._icons['error']} API Error:\n\n{error_msg}{hint}", "error"))
            except urllib.error.URLError as exc:
                error_msg = str(exc.reason)
                self.root.after(0, lambda: self._show_agent_test_result(
                    f"{self._icons['error']} Network Error: {error_msg}", "error"))
            except Exception as exc:
                error_msg = str(exc)
                self.root.after(0, lambda: self._show_agent_test_result(
                    f"{self._icons['error']} Error: {error_msg}", "error"))
        
        # Run in background thread
        thread = threading.Thread(target=run_test, daemon=True)
        thread.start()

    def _show_agent_test_result(self, text, status):
        """Update agent test result text box (called from GUI thread)"""
        self.agent_test_result_txt.configure(state="normal")
        self.agent_test_result_txt.delete("1.0", "end")
        self.agent_test_result_txt.insert("1.0", text)
        self.agent_test_result_txt.configure(state="disabled")
        self.update_status_bar(message=f"API test {status}")

    def select_visible(self):
        self.tree.selection_set(self.filtered_ids)
        self.update_status_bar(message=f"Selected {len(self.filtered_ids)} visible entries")

    def clear_selection(self):
        self.tree.selection_remove(self.tree.selection())
        self.update_status_bar(message="Selection cleared")

    def has_unsaved_changes(self):
        """Check if there are unsaved modifications in the right panel"""
        if not self.original_loaded_values:
            return False
        
        # Get current values
        current_original = self.original_txt.get("1.0", "end-1c")
        current_translation = self.translation_txt.get("1.0", "end-1c")
        current_ts = self.ts_edit_var.get().strip()
        current_user = self.user_edit_var.get().strip()
        
        # Compare with original values
        if self.original_loaded_values.get("original") != current_original:
            return True
        if self.original_loaded_values.get("translation") != current_translation:
            return True
        if self.original_loaded_values.get("timestamp") != current_ts:
            return True
        if self.original_loaded_values.get("github_user") != current_user:
            return True
        
        return False

    def on_tree_select(self, _event=None):
        # If we're restoring selection after user canceled change, don't reload values
        if self._restoring_selection:
            self._restoring_selection = False
            return
        
        selected = list(self.tree.selection())
        
        # Check for unsaved changes before switching selection
        if self.currently_selected_ids and selected != self.currently_selected_ids:
            if self.has_unsaved_changes():
                # Show confirmation dialog
                response = messagebox.askyesno(
                    "Unsaved Changes",
                    "You have unsaved modifications in the right panel.\n\nDiscard changes and continue?",
                    icon="warning",
                    default="no"
                )
                
                if not response:  # User chose "No" (cancel the selection change)
                    # Restore previous selection WITHOUT reloading values (keeps modifications)
                    self._restoring_selection = True
                    self.tree.selection_set(self.currently_selected_ids)
                    return
                # else: User chose "Yes" (discard changes), continue with new selection
        
        if not selected:
            self._cancel_live_grammar_timer()
            self._clear_live_grammar_marks()
            self.id_var.set("")
            self.lang_edit_var.set("")
            self.agent_edit_var.set("")
            self._suspend_live_grammar = True
            self.original_txt.delete("1.0", "end")
            self.translation_txt.delete("1.0", "end")
            self.translation_txt.edit_modified(False)
            self._suspend_live_grammar = False
            self.ts_edit_var.set("")
            self.user_edit_var.set("")
            self.original_loaded_values = {}
            self.currently_selected_ids = []
            self.selection_anchor = None
            self.update_status_bar()
            return

        self.currently_selected_ids = selected
        rows = [self.row_by_id.get(iid) for iid in selected if iid in self.row_by_id]
        
        if not rows:
            return
        
        # Update anchor when single selection (normal click)
        if len(selected) == 1:
            self.selection_anchor = selected[0]
        
        # For single selection, show all values (existing behavior)
        if len(rows) == 1:
            row = rows[0]
            self.id_var.set(row["id"])
            self.lang_edit_var.set(row["lang"])
            self.agent_edit_var.set(row.get("agent", "unknown"))
            self.ts_edit_var.set(row.get("timestamp", ""))
            self.user_edit_var.set(row.get("github_user", ""))
            self._suspend_live_grammar = True
            self.original_txt.delete("1.0", "end")
            self.original_txt.insert("1.0", row["original"])
            self.translation_txt.delete("1.0", "end")
            self.translation_txt.insert("1.0", row["translation"])
            self.translation_txt.edit_modified(False)
            self._suspend_live_grammar = False
            
            # Store original values
            self.original_loaded_values = {
                "id": row["id"],
                "lang": row["lang"],
                "agent": row.get("agent", "unknown"),
                "timestamp": row.get("timestamp", ""),
                "github_user": row.get("github_user", ""),
                "original": row["original"],
                "translation": row["translation"]
            }
        else:
            # Multi-selection: show only common values
            # Check if all IDs are the same
            ids = set(r["id"] for r in rows)
            if len(ids) == 1:
                self.id_var.set(rows[0]["id"])
            else:
                self.id_var.set(f"(multiple: {len(selected)} entries)")
            
            # Check common lang
            langs = set(r["lang"] for r in rows)
            if len(langs) == 1:
                self.lang_edit_var.set(rows[0]["lang"])
            else:
                self.lang_edit_var.set("(multiple)")
            
            # Check common agent
            agents = set(r.get("agent", "unknown") for r in rows)
            if len(agents) == 1:
                self.agent_edit_var.set(rows[0].get("agent", "unknown"))
            else:
                self.agent_edit_var.set("(multiple)")
            
            # Check common timestamp
            timestamps = set(r.get("timestamp", "") for r in rows)
            if len(timestamps) == 1:
                self.ts_edit_var.set(rows[0].get("timestamp", ""))
            else:
                self.ts_edit_var.set("(multiple)")
            
            # Check common github_user
            users = set(r.get("github_user", "") for r in rows)
            if len(users) == 1:
                self.user_edit_var.set(rows[0].get("github_user", ""))
            else:
                self.user_edit_var.set("(multiple)")
            
            # Check common original
            originals = set(r["original"] for r in rows)
            self._suspend_live_grammar = True
            self.original_txt.delete("1.0", "end")
            if len(originals) == 1:
                self.original_txt.insert("1.0", rows[0]["original"])
            else:
                self.original_txt.insert("1.0", "(multiple values)")
            
            # Check common translation
            translations = set(r["translation"] for r in rows)
            self.translation_txt.delete("1.0", "end")
            if len(translations) == 1:
                self.translation_txt.insert("1.0", rows[0]["translation"])
            else:
                self.translation_txt.insert("1.0", "(multiple values)")
            self.translation_txt.edit_modified(False)
            self._suspend_live_grammar = False
            
            # Store original common values for change detection
            self.original_loaded_values = {
                "id": rows[0]["id"] if len(ids) == 1 else "(multiple)",
                "lang": rows[0]["lang"] if len(langs) == 1 else "(multiple)",
                "agent": rows[0].get("agent", "unknown") if len(agents) == 1 else "(multiple)",
                "timestamp": rows[0].get("timestamp", "") if len(timestamps) == 1 else "(multiple)",
                "github_user": rows[0].get("github_user", "") if len(users) == 1 else "(multiple)",
                "original": rows[0]["original"] if len(originals) == 1 else "(multiple values)",
                "translation": rows[0]["translation"] if len(translations) == 1 else "(multiple values)"
            }

        self._schedule_live_grammar_check(delay_ms=250)
        
        self.update_status_bar()

    def _default_github_user(self):
        try:
            out = subprocess.check_output(["git", "config", "--get", "user.name"], stderr=subprocess.DEVNULL)
            user = out.decode("utf-8", errors="ignore").strip()
            return user or "unknown"
        except Exception:
            return "unknown"

    def update_status_bar(self, _event=None, message=None):
        """Update status bar with selection and visibility info"""
        selected_count = len(self.tree.selection())
        visible_count = len(self.filtered_ids)
        total_count = len(self.index)
        
        # Get current row number (position in filtered list)
        row_info = ""
        if selected_count > 0:
            selected = self.tree.selection()
            if selected and selected[0] in self.filtered_ids:
                row_num = self.filtered_ids.index(selected[0]) + 1  # 1-based
                row_info = f"Row: {row_num}/{visible_count} | "
        
        if message:
            status = f"{message} | {row_info}Selected: {selected_count} | Visible: {visible_count} | Total: {total_count}"
        else:
            status = f"{row_info}Selected: {selected_count} | Visible: {visible_count} | Total: {total_count}"
        
        if self.dirty_langs:
            status += f" | Unsaved: {', '.join(sorted(self.dirty_langs))}"
        
        self.status_var.set(status)

    def validate_translation(self, text):
        """Validate translation syntax and return (is_valid, error_message)"""
        if not text:
            return True, ""
        
        errors = []
        
        # Only check for malformed FREETZ placeholders (when present)
        if "__FREETZ_" in text:
            import re
            
            # Check LEADSP/TRAILSP format
            if "__FREETZ_LEADSP" in text or "__FREETZ_TRAILSP" in text:
                # Look for malformed placeholders (missing braces or numbers)
                malformed = re.findall(r'__FREETZ_(LEAD|TRAIL)SP(?!\{\d+\}__)', text)
                if malformed:
                    errors.append(f"{self._icons['warn']}  Malformed whitespace placeholder (expected format: __FREETZ_LEADSP{{N}}__ or __FREETZ_TRAILSP{{N}}__)")
            
            # Check CMD format
            if "__FREETZ_CMD" in text:
                # Look for malformed CMD placeholders (missing number)
                if re.search(r'__FREETZ_CMD(?!\d+__)', text):
                    errors.append(f"{self._icons['warn']}  Malformed command placeholder (expected format: __FREETZ_CMD0__, __FREETZ_CMD1__, etc.)")
            
            # Check for common typos in placeholders
            common_typos = [
                ("_FREETZ_", "__FREETZ__"),
                ("FREETZ__", "__FREETZ_"),
            ]
            for typo, correct in common_typos:
                if typo in text and correct not in text:
                    errors.append(f"{self._icons['warn']}  Possible typo: found '{typo}', did you mean '{correct}'?")
        
        if errors:
            return False, "\n".join(errors)
        
        return True, ""
    
    def check_grammar(self, text, lang_code):
        """Check grammar using LanguageTool API and return (has_issues, suggestions_list)"""
        try:
            issues = self._check_grammar_issues(text, lang_code, limit=10)
        except Exception:
            return False, []

        if not issues:
            return False, []

        suggestions = []
        for issue in issues:
            replacements = issue.get("replacements", [])
            problem_text = issue.get("problem_text", "")
            message = issue.get("message", "")
            if replacements:
                suggested = ", ".join(replacements[:3])
                suggestions.append(f"'{problem_text}' → {suggested}: {message}")
            else:
                suggestions.append(f"'{problem_text}': {message}")

        return len(suggestions) > 0, suggestions

    def _check_grammar_issues(self, text, lang_code, limit=50):
        """Return LanguageTool issues as list of dicts with absolute offsets."""
        if not text or not text.strip():
            return []

        if "__FREETZ_" in text:
            return []

        lang_map = {
            "it": "it",
            "de": "de-DE",
            "en": "en-US",
            "fr": "fr",
            "es": "es",
        }
        lt_lang = lang_map.get(lang_code)
        if not lt_lang:
            return []

        url = "https://api.languagetool.org/v2/check"
        data = urllib.parse.urlencode({
            "text": text,
            "language": lt_lang,
            "enabledOnly": "false",
        }).encode("utf-8")

        req = urllib.request.Request(url, data=data, method="POST")
        req.add_header("Content-Type", "application/x-www-form-urlencoded")
        req.add_header("User-Agent", "Freetz-NG-TranslateCacheManager/1.0")

        with urllib.request.urlopen(req, timeout=5) as response:
            result = json.loads(response.read().decode("utf-8"))

        matches = result.get("matches", []) or []
        issues = []
        for match in matches[:limit]:
            try:
                offset = int(match.get("offset", 0))
                length = int(match.get("length", 1))
            except Exception:
                continue

            if offset < 0:
                continue
            if length <= 0:
                length = 1

            problem_text = text[offset:offset + length] if offset < len(text) else ""
            replacements = [r.get("value", "") for r in (match.get("replacements", []) or []) if r.get("value")]

            issues.append({
                "offset": offset,
                "length": length,
                "message": match.get("message", ""),
                "problem_text": problem_text,
                "replacements": replacements,
            })

        return issues

    def _on_translation_text_modified(self, _event=None):
        if not hasattr(self, "translation_txt"):
            return

        if not self.translation_txt.edit_modified():
            return

        self.translation_txt.edit_modified(False)

        if self._suspend_live_grammar:
            return

        self._schedule_live_grammar_check(delay_ms=900)

    def _schedule_live_grammar_check(self, delay_ms=900):
        self._cancel_live_grammar_timer()
        self._live_grammar_after_id = self.root.after(delay_ms, self._start_live_grammar_check)

    def _cancel_live_grammar_timer(self):
        if self._live_grammar_after_id is not None:
            try:
                self.root.after_cancel(self._live_grammar_after_id)
            except Exception:
                pass
            self._live_grammar_after_id = None

    def _start_live_grammar_check(self):
        self._live_grammar_after_id = None

        if not self.currently_selected_ids:
            self._clear_live_grammar_marks()
            return

        lang_code = self.lang_edit_var.get().strip()
        if not lang_code or lang_code.startswith("("):
            self._clear_live_grammar_marks()
            return

        text = self.translation_txt.get("1.0", "end-1c")
        if not text.strip() or text.strip() == "(multiple values)" or "__FREETZ_" in text:
            self._clear_live_grammar_marks()
            return

        self._live_grammar_request_seq += 1
        request_seq = self._live_grammar_request_seq

        def worker(seq, snapshot_text, snapshot_lang):
            try:
                issues = self._check_grammar_issues(snapshot_text, snapshot_lang, limit=60)
                self.root.after(0, lambda: self._apply_live_grammar_issues(seq, snapshot_text, issues))
            except Exception:
                self.root.after(0, lambda: self._apply_live_grammar_issues(seq, snapshot_text, []))

        threading.Thread(
            target=worker,
            args=(request_seq, text, lang_code),
            daemon=True,
        ).start()

    def _apply_live_grammar_issues(self, seq, snapshot_text, issues):
        if seq != self._live_grammar_request_seq:
            return

        current_text = self.translation_txt.get("1.0", "end-1c")
        if current_text != snapshot_text:
            return

        self._clear_live_grammar_marks()
        if not issues:
            return

        for idx, issue in enumerate(issues):
            offset = issue.get("offset", 0)
            length = max(1, issue.get("length", 1))
            tag_name = f"grammar_issue_{idx}"

            start_index = f"1.0 + {offset} chars"
            end_index = f"1.0 + {offset + length} chars"

            try:
                self.translation_txt.tag_add(tag_name, start_index, end_index)
                self.translation_txt.tag_configure(tag_name, underline=True, foreground="#b00020")
                self._live_grammar_issue_tags.append(tag_name)
                self._live_grammar_issue_tooltips[tag_name] = self._format_live_grammar_tooltip(issue)
            except Exception:
                continue

    def _clear_live_grammar_marks(self):
        for tag_name in self._live_grammar_issue_tags:
            try:
                self.translation_txt.tag_remove(tag_name, "1.0", "end")
                self.translation_txt.tag_delete(tag_name)
            except Exception:
                pass
        self._live_grammar_issue_tags = []
        self._live_grammar_issue_tooltips = {}
        self._hide_translation_issue_tooltip()

    def _format_live_grammar_tooltip(self, issue):
        problem = issue.get("problem_text", "")
        message = issue.get("message", "")
        replacements = issue.get("replacements", [])

        if replacements:
            alternatives = ", ".join(replacements[:5])
            return f"{problem}\n{message}\nSuggerimenti: {alternatives}"
        return f"{problem}\n{message}"

    def _on_translation_text_motion(self, event):
        idx = self.translation_txt.index(f"@{event.x},{event.y}")
        tags = self.translation_txt.tag_names(idx)
        issue_tag = next((t for t in tags if t.startswith("grammar_issue_")), None)

        if not issue_tag:
            self._hide_translation_issue_tooltip()
            return

        tooltip_text = self._live_grammar_issue_tooltips.get(issue_tag)
        if not tooltip_text:
            self._hide_translation_issue_tooltip()
            return

        self._show_translation_issue_tooltip(tooltip_text)

    def _show_translation_issue_tooltip(self, text):
        x = self.root.winfo_pointerx() + 14
        y = self.root.winfo_pointery() + 14

        if self._live_grammar_tooltip_window is not None:
            try:
                label = self._live_grammar_tooltip_window.winfo_children()[0]
                label.configure(text=text)
                self._live_grammar_tooltip_window.wm_geometry(f"+{x}+{y}")
                return
            except Exception:
                self._hide_translation_issue_tooltip()

        tw = tk.Toplevel(self.root)
        tw.wm_overrideredirect(True)
        tw.wm_geometry(f"+{x}+{y}")
        label = tk.Label(
            tw,
            text=text,
            justify="left",
            background="#ffffe0",
            relief="solid",
            borderwidth=1,
            wraplength=460,
            padx=6,
            pady=4,
        )
        label.pack()
        self._live_grammar_tooltip_window = tw

    def _hide_translation_issue_tooltip(self, _event=None):
        if self._live_grammar_tooltip_window is not None:
            self._live_grammar_tooltip_window.destroy()
            self._live_grammar_tooltip_window = None
    
    def manual_grammar_check(self):
        """Manually check grammar of current translation without applying changes"""
        if not self.currently_selected_ids:
            messagebox.showwarning("No entry", "Select an entry first")
            return
        
        # Get current translation text
        translation_text = self.translation_txt.get("1.0", "end-1c").strip()
        
        if not translation_text:
            messagebox.showinfo("Empty Translation", "Translation field is empty, nothing to check")
            return
        
        # Get language from first selected entry
        first_entry_id = self.currently_selected_ids[0]
        row = self.row_by_id.get(first_entry_id)
        
        if not row:
            messagebox.showerror("Error", "Could not determine language")
            return
        
        lang_code = row["lang"]
        
        # Check if text contains technical content (skip grammar check)
        if "__FREETZ_" in translation_text:
            messagebox.showinfo(
                "Grammar Check Skipped",
                "Translation contains technical placeholders (__FREETZ_*). Grammar check is disabled for technical content."
            )
            return
        
        # Show "Checking..." status
        self.update_status_bar(message=f"Checking grammar with LanguageTool ({lang_code.upper()})...")
        self.root.update_idletasks()
        
        # Perform grammar check
        has_issues, suggestions = self.check_grammar(translation_text, lang_code)
        
        if has_issues:
            suggestions_text = "\n".join(f"  • {s}" for s in suggestions)
            messagebox.showinfo(
                "Grammar Check Results",
                f"LanguageTool found {len(suggestions)} potential issue(s) in {lang_code.upper()} translation:\n\n{suggestions_text}\n\nYou can edit the translation and check again, or click 'Apply to entry' when ready.",
                icon="info"
            )
            self.update_status_bar(message=f"Grammar check completed: {len(suggestions)} issue(s) found")
        else:
            messagebox.showinfo(
                "Grammar Check Results",
                f"{self._icons['success']} No grammar issues found in {lang_code.upper()} translation!\n\nLanguageTool did not detect any problems.",
                icon="info"
            )
            self.update_status_bar(message=f"Grammar check completed: No issues found {self._icons['success']}")
    
    def apply_entry_edit(self, skip_prompts=False, skip_no_changes_popup=False):
        # Get currently selected entries
        if not self.currently_selected_ids:
            messagebox.showwarning("No entry", "Select an entry first")
            return

        # Get current field values
        new_original = self.original_txt.get("1.0", "end-1c")
        new_translation = self.translation_txt.get("1.0", "end-1c")
        new_ts = self.ts_edit_var.get().strip()
        new_user = self.user_edit_var.get().strip()
        
        # Validate translation syntax
        is_valid, error_msg = self.validate_translation(new_translation)
        if not is_valid:
            if not skip_prompts:
                response = messagebox.askyesno(
                    "Validation Warning",
                    f"Translation has potential syntax issues:\n\n{error_msg}\n\nApply anyway?",
                    icon="warning"
                )
                if not response:
                    return
        
        # Grammar check for modified translations
        if self.original_loaded_values.get("translation") != new_translation:
            # Get the language from the first selected entry
            first_entry_id = self.currently_selected_ids[0]
            row = self.row_by_id.get(first_entry_id)
            if row:
                lang_code = row["lang"]
                has_issues, suggestions = self.check_grammar(new_translation, lang_code)
                
                if has_issues:
                    if not skip_prompts:
                        suggestions_text = "\n".join(f"  • {s}" for s in suggestions)
                        response = messagebox.askyesno(
                            "Grammar Check",
                            f"LanguageTool found {len(suggestions)} potential issue(s) in {lang_code.upper()} translation:\n\n{suggestions_text}\n\nApply anyway?",
                            icon="info"
                        )
                        if not response:
                            return

        # Determine which fields have been changed (for partial update in multi-selection)
        changed_fields = {}
        
        if self.original_loaded_values.get("original") != new_original:
            changed_fields["original"] = new_original
        
        if self.original_loaded_values.get("translation") != new_translation:
            changed_fields["translation"] = new_translation
        
        if self.original_loaded_values.get("timestamp") != new_ts:
            changed_fields["timestamp"] = new_ts
        
        if self.original_loaded_values.get("github_user") != new_user:
            changed_fields["github_user"] = new_user

        text_changed = ("original" in changed_fields) or ("translation" in changed_fields)
        if text_changed:
            if self.auto_update_ts_var.get():
                changed_fields["timestamp"] = dt.datetime.now(dt.timezone.utc).strftime(TS_FMT)
                new_ts = changed_fields["timestamp"]
                self.ts_edit_var.set(new_ts)

            if self.auto_update_user_var.get():
                default_user = (self.preferred_user_var.get() or "").strip() or self._default_github_user()
                changed_fields["github_user"] = default_user
                new_user = default_user
                self.user_edit_var.set(new_user)

        # Normalize metadata values to the effective values that will be saved
        if "timestamp" in changed_fields and not changed_fields["timestamp"]:
            changed_fields["timestamp"] = dt.datetime.now(dt.timezone.utc).strftime(TS_FMT)
            new_ts = changed_fields["timestamp"]
            self.ts_edit_var.set(new_ts)

        if "github_user" in changed_fields and not changed_fields["github_user"]:
            changed_fields["github_user"] = self._default_github_user()
            new_user = changed_fields["github_user"]
            self.user_edit_var.set(new_user)

        # If no fields changed, nothing to do
        if not changed_fields:
            if not skip_no_changes_popup:
                messagebox.showinfo("No changes", "No fields were modified")
            else:
                self.update_status_bar(message="No entry changes to apply")
            return

        # For multi-selection, apply only changed fields
        updated_count = 0
        updated_file_stems = set()
        
        for entry_id in self.currently_selected_ids:
            row = self.row_by_id.get(entry_id)
            if not row:
                continue
            
            file_stem = row["file_stem"]  # e.g., "it" or "it-rutorrent"
            key = row["key"]
            
            # Apply only the changed fields
            if "original" in changed_fields:
                row["original"] = changed_fields["original"]
            
            if "translation" in changed_fields:
                row["translation"] = changed_fields["translation"]
            
            if "timestamp" in changed_fields:
                row["timestamp"] = changed_fields["timestamp"]
            
            if "github_user" in changed_fields:
                row["github_user"] = changed_fields["github_user"]
            
            row["metadata_present"] = bool(row.get("timestamp") or row.get("github_user"))

            # Update cache (using file_stem to preserve file identity)
            cache_entry = self.lang_data[file_stem].setdefault(key, {})
            if "original" in changed_fields:
                cache_entry["original"] = row["original"]
            if "translation" in changed_fields:
                cache_entry["translation"] = row["translation"]
            if "timestamp" in changed_fields:
                cache_entry["timestamp"] = row["timestamp"]
            if "github_user" in changed_fields:
                cache_entry["github_user"] = row["github_user"]
            
            if "service" not in cache_entry and row["agent"] != "unknown":
                cache_entry["service"] = row["agent"]

            # Update tree display
            if self.tree.exists(entry_id):
                self.tree.item(
                    entry_id,
                    values=(
                        row["lang"],
                        row["file"],
                        row.get("file_label", "") or "",
                        row["agent"],
                        row["source"],
                        row["original"],
                        row["translation"],
                        row["timestamp"],
                        row["github_user"],
                    ),
                )
            
            updated_file_stems.add(file_stem)
            updated_count += 1

        # Mark file stems as dirty
        self.dirty_langs.update(updated_file_stems)
        
        # Update original loaded values to reflect applied changes (prevents unsaved changes warning)
        if "original" in changed_fields:
            self.original_loaded_values["original"] = changed_fields["original"]
        if "translation" in changed_fields:
            self.original_loaded_values["translation"] = changed_fields["translation"]
        if "timestamp" in changed_fields:
            self.original_loaded_values["timestamp"] = changed_fields["timestamp"]
        if "github_user" in changed_fields:
            self.original_loaded_values["github_user"] = changed_fields["github_user"]
        
        self._refresh_filter_values()
        
        # Show summary message
        changed_fields_list = list(changed_fields.keys())
        if len(self.currently_selected_ids) == 1:
            self.update_status_bar(message=f"Entry updated: {self.id_var.get()}")
        else:
            self.update_status_bar(message=f"Updated {updated_count} entries ({', '.join(changed_fields_list)} changed)")
        
        # Reload selection to show updated values
        self.on_tree_select()

    def clear_timestamp(self):
        """Clear timestamp field on all selected entries"""
        if not self.currently_selected_ids:
            messagebox.showwarning("No entry", "Select an entry first")
            return
        
        # Confirm if multiple items selected
        count = len(self.currently_selected_ids)
        if count > 1:
            if not messagebox.askyesno(
                "Confirm Clear",
                f"Clear timestamp on {count} selected entries?",
                icon="question"
            ):
                return
        
        updated_count = 0
        updated_file_stems = set()
        
        for entry_id in self.currently_selected_ids:
            row = self.row_by_id.get(entry_id)
            if not row:
                continue
            
            file_stem = row["file_stem"]
            key = row["key"]
            
            # Clear timestamp
            row["timestamp"] = ""
            row["metadata_present"] = bool(row.get("github_user"))
            
            # Update cache
            cache_entry = self.lang_data[file_stem].get(key, {})
            if cache_entry:
                cache_entry["timestamp"] = ""
            
            # Update tree display
            if self.tree.exists(entry_id):
                self.tree.item(
                    entry_id,
                    values=(
                        row["lang"],
                        row["file"],
                        row.get("file_label", "") or "",
                        row["agent"],
                        row["source"],
                        row["original"],
                        row["translation"],
                        row["timestamp"],
                        row["github_user"],
                    ),
                )
            
            updated_file_stems.add(file_stem)
            updated_count += 1
        
        # Mark file stems as dirty
        self.dirty_langs.update(updated_file_stems)
        
        # Clear the field in the editor
        self.ts_edit_var.set("")
        
        # Update status
        if len(self.currently_selected_ids) == 1:
            self.update_status_bar(message="Timestamp cleared")
        else:
            self.update_status_bar(message=f"Timestamp cleared on {updated_count} entries")
    
    def clear_github_user(self):
        """Clear github_user field on all selected entries"""
        if not self.currently_selected_ids:
            messagebox.showwarning("No entry", "Select an entry first")
            return
        
        # Confirm if multiple items selected
        count = len(self.currently_selected_ids)
        if count > 1:
            if not messagebox.askyesno(
                "Confirm Clear",
                f"Clear GitHub user on {count} selected entries?",
                icon="question"
            ):
                return
        
        updated_count = 0
        updated_file_stems = set()
        
        for entry_id in self.currently_selected_ids:
            row = self.row_by_id.get(entry_id)
            if not row:
                continue
            
            file_stem = row["file_stem"]
            key = row["key"]
            
            # Clear github_user
            row["github_user"] = ""
            row["metadata_present"] = bool(row.get("timestamp"))
            
            # Update cache
            cache_entry = self.lang_data[file_stem].get(key, {})
            if cache_entry:
                cache_entry["github_user"] = ""
            
            # Update tree display
            if self.tree.exists(entry_id):
                self.tree.item(
                    entry_id,
                    values=(
                        row["lang"],
                        row["file"],
                        row.get("file_label", "") or "",
                        row["agent"],
                        row["source"],
                        row["original"],
                        row["translation"],
                        row["timestamp"],
                        row["github_user"],
                    ),
                )
            
            updated_file_stems.add(file_stem)
            updated_count += 1
        
        # Mark file stems as dirty
        self.dirty_langs.update(updated_file_stems)
        
        # Clear the field in the editor
        self.user_edit_var.set("")
        
        # Update status
        if len(self.currently_selected_ids) == 1:
            self.update_status_bar(message="GitHub user cleared")
        else:
            self.update_status_bar(message=f"GitHub user cleared on {updated_count} entries")

    def bulk_replace_selected(self):
        selected = list(self.tree.selection())
        if not selected:
            messagebox.showwarning("No selection", "Select one or more entries in the table")
            return

        find = self.bulk_find_var.get()
        repl = self.bulk_replace_var.get()
        if not find:
            messagebox.showwarning("Missing find", "Insert Find text/pattern")
            return

        regex_mode = self.bulk_regex.get()
        case_sensitive = self.bulk_case.get()

        changed = 0
        for entry_id in selected:
            row = self.row_by_id.get(entry_id)
            if not row:
                continue

            text = row["translation"]
            if regex_mode:
                flags = 0 if case_sensitive else re.IGNORECASE
                try:
                    new_text, n = re.subn(find, repl, text, flags=flags)
                except re.error as exc:
                    messagebox.showerror("Regex error", str(exc))
                    return
            else:
                if case_sensitive:
                    n = text.count(find)
                    new_text = text.replace(find, repl)
                else:
                    pattern = re.compile(re.escape(find), re.IGNORECASE)
                    new_text, n = pattern.subn(repl, text)

            if n > 0:
                row["translation"] = new_text
                if not row["timestamp"]:
                    row["timestamp"] = dt.datetime.now(dt.timezone.utc).strftime(TS_FMT)
                if not row["github_user"]:
                    row["github_user"] = self._default_github_user()
                row["metadata_present"] = True

                file_stem = row["file_stem"]
                key = row["key"]
                entry = self.lang_data[file_stem].setdefault(key, {})
                entry["translation"] = row["translation"]
                entry.setdefault("original", row["original"])
                entry["timestamp"] = row["timestamp"]
                entry["github_user"] = row["github_user"]
                entry.setdefault("service", row["agent"])
                self.dirty_langs.add(file_stem)
                changed += 1

                if self.tree.exists(entry_id):
                    self.tree.item(
                        entry_id,
                        values=(
                            row["lang"],
                            row["file"],
                            row.get("file_label", "") or "",
                            row["agent"],
                            row["source"],
                            row["original"],
                            row["translation"],
                            row["timestamp"],
                            row["github_user"],
                        ),
                    )

        self._refresh_filter_values()
        self.update_status_bar(message=f"Bulk replace updated {changed} selected entries")

    def delete_selected_entries(self):
        selected = list(self.tree.selection())
        if not selected:
            messagebox.showwarning("No selection", "Select entries to delete")
            return

        if not messagebox.askyesno("Confirm delete", f"Delete {len(selected)} selected entries from cache?"):
            return

        for entry_id in selected:
            row = self.row_by_id.pop(entry_id, None)
            if not row:
                continue
            file_stem = row["file_stem"]
            key = row["key"]
            self.lang_data.get(file_stem, {}).pop(key, None)
            self.index = [r for r in self.index if r["id"] != entry_id]
            self.dirty_langs.add(file_stem)

        self.apply_filters()
        self.update_status_bar(message=f"Deleted {len(selected)} entries")

    def _backup_file(self, path: Path):
        stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d-%H%M%S")
        backup = path.with_name(f"{path.name}.backup-{stamp}")
        backup.write_text(path.read_text(encoding="utf-8"), encoding="utf-8")

    def save_all(self, confirm=True):
        if not self.dirty_langs:
            self.update_status_bar(message="No changes to save")
            return

        # Show confirmation dialog
        if confirm:
            langs_list = ", ".join(sorted(self.dirty_langs))
            confirmed = messagebox.askyesno(
                "Save Changes",
                f"Save changes to {len(self.dirty_langs)} cache file(s)?\n\nFiles: {langs_list}",
                icon="question"
            )
            
            if not confirmed:
                self.update_status_bar(message="Save cancelled")
                return

        saved = 0
        for file_stem in sorted(self.dirty_langs):
            # Save to original file name (e.g., it.json or it-rutorrent.json)
            target = self.cache_dir / f"{file_stem}.json"
            payload = self.lang_data.get(file_stem, {})

            if target.exists():
                try:
                    self._backup_file(target)
                except Exception as exc:
                    messagebox.showerror("Backup error", f"Failed backup for {target.name}: {exc}")
                    return

            try:
                target.write_text(
                    json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
                    encoding="utf-8",
                )
                saved += 1
            except Exception as exc:
                messagebox.showerror("Save error", f"Failed save for {target.name}: {exc}")
                return

        self.dirty_langs.clear()
        self.update_status_bar(message=f"Saved {saved} file(s) with backups")

    def on_closing(self):
        """Handle window close event - check for unsaved changes"""
        # Check for unapplied changes in right panel
        if self.has_unsaved_changes():
            response = messagebox.askyesnocancel(
                "Unsaved Entry Modifications",
                "You have unsaved modifications in the right panel.\n\nApply changes before closing?",
                icon="warning"
            )
            
            if response is None:  # Cancel - don't close
                return
            elif response:  # Yes - Apply changes
                self.apply_entry_edit()
            # else: No - Discard changes, continue to check file saves
        
        # Check for unsaved file changes
        if self.dirty_langs:
            langs_list = ", ".join(sorted(self.dirty_langs))
            response = messagebox.askyesnocancel(
                "Unsaved Changes",
                f"You have unsaved changes in {len(self.dirty_langs)} language file(s):\n\n{langs_list}\n\nSave before closing?",
                icon="warning"
            )
            
            if response is None:  # Cancel
                return
            elif response:  # Yes - Save
                self.save_all()
            # else: No - Don't save, just close
        
        self.root.destroy()


def default_cache_dir() -> Path:
    script = Path(__file__).resolve()
    return script.parent / "translate_cache"


def main():
    parser = argparse.ArgumentParser(description="Manage freetz translate cache JSON files")
    parser.add_argument("--cache-dir", type=Path, default=default_cache_dir(), help="Directory containing language cache JSON files")
    args = parser.parse_args()

    if not TK_AVAILABLE:
        raise SystemExit("tkinter is required to run this tool. Install python3-tk on your system.")

    cache_dir = args.cache_dir.expanduser().resolve()
    if not cache_dir.exists() or not cache_dir.is_dir():
        raise SystemExit(f"Cache directory does not exist: {cache_dir}")

    try:
        root = tk.Tk()
        app = CacheManagerApp(root, cache_dir)
        root.mainloop()
    except KeyboardInterrupt:
        # Handle Ctrl+C gracefully
        print("\n\nInterrupted by user (Ctrl+C). Exiting...")
        try:
            root.quit()
        except:
            pass
        raise SystemExit(0)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nExiting...")
        raise SystemExit(0)
