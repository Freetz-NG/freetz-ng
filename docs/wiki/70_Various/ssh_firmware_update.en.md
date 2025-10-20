# ssh_firmware_update.py

**ssh_firmware_update.py** is a modern, user-friendly utility for upgrading Freetz-NG to the
**FRITZ!Box firmware** and **external packages** over SSH, fully emulating the classic *Freetz-NG* update workflow.

It supports both **interactive** and **batch** command-line modes, offering a guided experience
with sensible defaults - most users can simply press *Enter* to perform a standard upgrade.

### Key Features

* **Interactive & Batch Modes** – Choose between guided prompts or fully automated operation via CLI arguments.
* **Flexible Directory Selection** – Accept suggested installation paths or specify custom locations for external packages.
* **Upgrade Summary** – Displays a clear overview of selected options and actions before execution.
* **Selective Updates** – Flash only the firmware, update only external storage, or perform both in one run.
* **SSH-Based Operation** – Works entirely over SSH; no web interface required.
* **Flexible Password Handling** – Accepts credentials via `--password`, the `ROUTER_PASSWORD` environment variable, or an interactive prompt.
* **Progress Monitoring** – Real-time progress bars for uploads and extraction, with step-by-step verification.
* **Large Archive Support** – Efficient handling of large external archives during upload and extraction.
* **Dry-Run Mode** – Simulate the full upgrade process safely without applying any changes.
* **Extended Configuration** – Provides more control and customization than the legacy web interface.
* **Robust Error Handling** – All operations include validation, logging, and detailed error reporting.
* **Toolchain Integration** – Designed to run directly from the *Freetz-NG* toolchain shell, e.g.:

```
tools/ssh_firmware_update.py --host 192.168.178.1 --password mypassword
```

If you don't have python3 installed:
```
make python3-host-precompiled
PATH="$PATH:$(realpath tools/path/)"
tools/ssh_firmware_update.py ...
```

