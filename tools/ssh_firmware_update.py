#!/usr/bin/env python3
"""
ssh_firmware_update.py — Freetz-NG FRITZ!Box Update via SSH/SCP

Emulates the web interface update process with interactive/batch modes, 
progress bars, dry-run, debug capabilities, and advanced UX.

Usage:
  tools/ssh_firmware_update.py --host 192.168.178.1 --password <pwd>
  ROUTER_PASSWORD=<pwd> ssh_firmware_update.py --host 192.168.178.1
  
If you don't have python3 installed:
  make python3-host-precompiled
  tools/path/python3 tools/ssh_firmware_update.py ...
"""
import os, sys, argparse, time, subprocess, threading, pty, select, errno, re, getpass
from glob import glob
from datetime import datetime
import re
import tty

# --- CONSTANTS ---
DEFAULT_USER = 'root'
DEFAULT_TARGET_DIR = '/var/tmp'
DEFAULT_EXTERNAL_BASE = '/var/media/ftp/external'
FREETZ_PATH = '/mod/sbin:/mod/bin:/mod/usr/sbin:/mod/usr/bin:/mod/etc/init.d:/sbin:/bin:/usr/sbin:/usr/bin'
PING_TIMEOUT = 1
BOOT_WAIT_MAX_TRIES = 450  # one try every two seconds; 15 minutes
SSH_TEST_CMD = 'pwd'
SSH_LOG_FILE = '/tmp/ssh_firmware_update.log'
REBOOT_CMD = (
    "nohup sh -c 'prepare_fwupgrade end; "
    "/etc/inittab.shutdown; "
    "sync; "
    "sleep 2; "
    "sync; "
    "reboot -d 2 -f' & >/dev/null 2>&1 < /dev/null"
)

# --- COLORS AND EMOJIS ---
COLORS = {
    'reset': '\033[0m', 'red': '\033[91m', 'green': '\033[92m', 
    'yellow': '\033[93m', 'blue': '\033[94m', 'cyan': '\033[96m',
    'bold': '\033[1m', 'dim': '\033[2m'
}
EMOJI = {
    'ok': '✅', 'fail': '❌', 'wait': '⏳', 'copy': '📤', 'install': '🛠️', 
    'reboot': '🔄', 'ping': '📡', 'external': '📦', 'prompt': '👉',
    'warning': '⚠️', 'info': 'ℹ️', 'rocket': '🚀', 'check': '✓', 'lamp': '💡'
}

# --- UTILITY FUNCTIONS ---
def cprint(msg, color=None, emoji=None, end='\n', file=sys.stdout):
    """Print colored message with optional emoji prefix"""
    prefix = COLORS.get(color, '')
    suffix = COLORS['reset'] if color else ''
    emj = EMOJI.get(emoji, '') + ' ' if emoji else ''
    print(f"{prefix}{emj}{msg}{suffix}", end=end, file=file, flush=True)

def cerror(msg):
    """Print error message"""
    cprint(f"ERROR: {msg}", 'red', 'fail', file=sys.stderr)

def cwarning(msg):
    """Print warning message"""
    cprint(f"WARNING: {msg}", 'yellow', 'warning')

def cinfo(msg):
    """Print info message"""
    cprint(msg, 'cyan', 'info')

def cdebug(msg, debug=False):
    """Print debug message if debug mode enabled"""
    if debug:
        cprint(f"[DEBUG] {msg}", 'dim')

def progress_bar(current, total, prefix='', width=40):
    """Display a progress bar"""
    if total == 0:
        total = 1
    percent = int(100 * current / total)
    filled = int(width * current / total)
    bar = '█' * filled + '-' * (width - filled)
    print(f"\r{prefix}[{bar}] {percent}% ({current}/{total})", end='', flush=True)
    if current >= total:
        print()

def confirm(prompt, default=True):
    """Ask user for confirmation"""
    options = '[Y/n]' if default else '[y/N]'
    response = input(f"{EMOJI['prompt']} {prompt} {options}: ").strip().lower()
    if not response:
        return default
    return response in ('y', 'yes')

def get_file_size(filepath):
    """Get file size in bytes"""
    try:
        return os.path.getsize(filepath)
    except:
        return 0

def format_size(size_bytes):
    """Format bytes to human readable string"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f} TB"

def log_ssh_command(command, output="", debug=False):
    """Log SSH/SCP commands to file for debugging"""
    if not debug:
        return
    try:
        with open(SSH_LOG_FILE, 'a', encoding='utf-8') as f:
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            f.write(f"\n{'='*60}\n")
            f.write(f"[{timestamp}] COMMAND: {command}\n")
            if output:
                f.write(f"OUTPUT:\n{output}\n")
            f.write(f"{'='*60}\n")
        cdebug(f"Logged SSH command to {SSH_LOG_FILE}", True)
    except Exception as e:
        cdebug(f"Failed to log SSH command: {e}", True)


# --- NETWORK UTILITY FUNCTIONS ---
def ping_router(host, timeout=PING_TIMEOUT):
    """Check if FRITZ!Box responds to ping"""
    return os.system(f"ping -c 1 -W {timeout} {host} > /dev/null 2>&1") == 0

def wait_router_boot(host, password, user=DEFAULT_USER, max_tries=BOOT_WAIT_MAX_TRIES, debug=False):
    """Wait for FRITZ!Box to boot and become accessible via SSH"""
    cinfo(f"Waiting for FRITZ!Box {host} to boot...")
    time.sleep(25)  # time for the device to shutdown
    start_time = time.time()
    
    # Phase 1: Wait for ping response
    cprint("Phase 1: Waiting for network connectivity...", 'blue', 'ping')
    for i in range(max_tries):
        if ping_router(host):
            cprint("")
            cprint(f"{EMOJI['ok']} FRITZ!Box is pingable!", 'green')
            break
        print('.', end='', flush=True)
        time.sleep(2)
    else:
        cprint("")
        cerror(f"Timeout waiting for FRITZ!Box to respond to ping ({max_tries * 2}s)")
        return False
    
    # Phase 2: Wait for SSH availability
    cprint("Phase 2: Waiting for SSH service...", 'blue', 'wait')
    time.sleep(5)  # Give SSH daemon time to start
    for i in range(max_tries):
        try:
            result = ssh_run(host, user, password, SSH_TEST_CMD, debug=debug, capture_output=True)
            if result and not 'connection refused' in result.lower():
                elapsed = int(time.time() - start_time)
                cprint("")
                cprint(f"{EMOJI['ok']} FRITZ!Box is fully operational! (took {elapsed}s)", 'green')
                return True
        except:
            pass
        print('.', end='', flush=True)
        time.sleep(2)

    cerror("Timeout waiting for SSH service to start")
    return False

def count_tar_files(tarfile):
    """Count total files in tar archive"""
    try:
        output = subprocess.getoutput(f"tar -tf '{tarfile}' 2>/dev/null")
        return len([l for l in output.splitlines() if l.strip() and not l.endswith('/')])  # only count files
    except:
        return 0

def get_password(args):
    """
    Get password from multiple sources (priority order):
    1. Command line argument (--password)
    2. Environment variable (ROUTER_PASSWORD)
    3. Interactive prompt (if not in batch mode)
    """
    if args.password:
        return args.password
    
    if 'ROUTER_PASSWORD' in os.environ:
        cdebug("Using password from ROUTER_PASSWORD environment variable", args.debug)
        return os.environ['ROUTER_PASSWORD']
    
    if args.batch:
        cerror("Password required in batch mode! Use --password or set ROUTER_PASSWORD environment variable")
        sys.exit(1)
    
    # Interactive password prompt
    try:
        password = getpass.getpass(f"{EMOJI['prompt']} Enter SSH password for {args.user}@{args.host}: ")
        if not password:
            cerror("Password cannot be empty!")
            sys.exit(1)
        return password
    except KeyboardInterrupt:
        cwarning("\nPassword input cancelled")
        sys.exit(130)

# --- FILE SELECTION FUNCTIONS ---
def find_images():
    """Find all .image and .external files in images/ directory"""
    images = sorted(glob('images/*.image'), key=os.path.getmtime, reverse=True)
    externals = sorted(glob('images/*.external'), key=os.path.getmtime, reverse=True)
    return images, externals

def select_file_interactive(files, file_type):
    """Interactive file selection from list"""
    if not files:
        cwarning(f"No {file_type} files found in images/ directory")
        path = input(f"{EMOJI['prompt']} Enter a {file_type} file path (outside images/),\n   or press Enter to skip: ").strip()
        if path:
            if os.path.exists(path):
                cprint(f"Selected archive: '{path}'.", 'green', 'check')
                return path
            else:
                cwarning(f"File not found: '{path}'. Skipping {file_type} update.")
                return None
        else:
            cinfo(f"Skipping {file_type} update.")
            return None
    
    cinfo(f"Available {file_type} files:")
    for i, f in enumerate(files[:5], 1):  # Show max 5 recent files
        size = format_size(get_file_size(f))
        mtime = datetime.fromtimestamp(os.path.getmtime(f)).strftime('%Y-%m-%d %H:%M')
        cprint(f"  {i}. {os.path.basename(f)} ({size}, {mtime})", 'cyan')
    
    cprint("")
    cprint(f"Latest {file_type}: {os.path.basename(files[0])}", 'green', 'check')
    
    if confirm(f"Use this {file_type}?", default=True):
        return files[0]
    
    choice = input(f"Enter number (1-{min(5, len(files))}) or path: ").strip()
    if choice.isdigit() and 1 <= int(choice) <= min(5, len(files)):
        cprint(f"Selected archive: '{files[int(choice) - 1]}'.", 'green', 'check')
        return files[int(choice) - 1]
    elif os.path.exists(choice):
        cprint(f"Selected archive: '{choice}'.", 'green', 'check')
        return choice
    else:
        cwarning(f"Invalid selection. Using latest {file_type}")
        return files[0]


# --- SSH/SCP WRAPPER ---
def sshpass_exec(cmd, password, verbose=False, retries=2, capture_output=False, silent=False, stdin_stream=None):
    """
    Execute SSH/SCP command with automatic password authentication.
    Uses PTY to interact with SSH password prompts.
    
    Args:
        cmd: List of command arguments (e.g., ['ssh', 'root@host', 'ls'])
        password: SSH password
        verbose: Enable debug output
        retries: Number of password retry attempts
        capture_output: Return output as string instead of printing
        silent: Suppress all output (for SCP uploads)
    
    Returns:
        Output string if capture_output=True, empty string otherwise
    """
    pid, master = pty.fork()
    if pid == 0:
        # Child process: force PTY slave (stdin) to raw mode for binary data transfer
        try:
            tty.setraw(sys.stdin.fileno())
        except Exception:
            cerror("Cannot set tty in raw mode")
            pass  # continue anyway
        # Child process: execute the command
        try:
            os.execvp(cmd[0], cmd)
        except Exception as e:
            print(f"Exec failed: {e}", file=sys.stderr)
            os._exit(127)

    # Parent process: handle password prompts and output
    rolling = bytearray()
    sent_count = 0
    hostkey_answered = False
    max_retries = max(0, retries)
    output = b''

    authenticated = False
    first_write = True
    try:
        while True:
            r, _, _ = select.select([master] + ([stdin_stream.fileno()] if stdin_stream else [sys.stdin.fileno()]), [], [], 0.1)
            # Handle command output
            if master in r:  # Here is the data received from the remote command
                try:
                    data = os.read(master, 4096)
                except OSError as e:
                    if e.errno == errno.EIO:
                        break
                    raise
                if not data:
                    break
                filtered = data
                # For SCP, also filter progress lines (lines starting with filename and containing %)
                if b'scp' in cmd[0].encode():
                    lines = data.split(b'\n')
                    filtered_lines = []
                    for line in lines:
                        if b'%' in line and (b'ETA' in line or b'KB/s' in line or b'MB/s' in line):
                            continue
                        filtered_lines.append(line)
                    filtered = b'\n'.join(filtered_lines)
                # Intercept password only if not yet authenticated
                if not authenticated:
                    for p in [b'password:', b"'s password:", b'root password:', b'root@']:
                        idx = filtered.lower().find(p)
                        while idx != -1:
                            end = filtered.find(b'\n', idx)
                            start = filtered.rfind(b'\n', 0, idx)
                            next_nl = end
                            while next_nl != -1 and next_nl+1 < len(filtered) and filtered[next_nl+1:next_nl+2] == b'\n':
                                next_nl += 1
                            if start != -1 and end != -1:
                                filtered = filtered[:start] + filtered[(next_nl+1) if next_nl != -1 else (end+1):]
                            elif end != -1:
                                filtered = filtered[:idx] + filtered[(next_nl+1) if next_nl != -1 else (end+1):]
                            elif start != -1:
                                filtered = filtered[:start]
                            else:
                                filtered = filtered[:idx]
                            idx = filtered.lower().find(p)
                    # Detect and respond to password prompts
                    if sent_count <= max_retries:
                        prompts = [b'password:', b"'s password:", b'root password:', b'root@']
                        for p in prompts:
                            if p in data.lower():
                                os.write(master, password.encode() + b"\n")
                                sent_count += 1
                                if verbose:
                                    sys.stderr.write(f"[debug] Sent password (attempt {sent_count}) for prompt {p.decode(errors='ignore')}\n")
                                    sys.stderr.flush()
                                rolling = bytearray()
                                break
                        else:
                            idx = data.lower().find(b'password')
                            if idx != -1:
                                window = data.lower()[idx: idx + 64]
                                if b':' in window:
                                    os.write(master, password.encode() + b"\n")
                                    sent_count += 1
                                    if verbose:
                                        sys.stderr.write(f"[debug] Sent password (attempt {sent_count})\n")
                                        sys.stderr.flush()
                                    rolling = bytearray()
                                    continue
                    # Detect authentication failures
                    fails = [b'permission denied', b'authentication failed', b'authentication error', b'login incorrect', b'access denied']
                    if any(p in data.lower() for p in fails):
                        if verbose:
                            sys.stderr.write("[debug] Detected authentication failure, aborting\n")
                            sys.stderr.flush()
                        time.sleep(0.05)
                        break
                    # No password prompt and no error: autheticated
                    if sent_count > 0 and not any(p in data.lower() for p in prompts + fails):
                        authenticated = True
                        time.sleep(1)
                # Remove leading whitespace/newlines
                while filtered and filtered[:1] in (b'\n', b'\r', b' ', b'\t'):
                    filtered = filtered[1:]
                output += filtered
                if not capture_output and not silent and filtered:
                    os.write(sys.stdout.fileno(), filtered)
                if verbose:
                    sys.stderr.write("[recv hex] " + ' '.join(f'{x:02x}' for x in data) + "\n")
                    sys.stderr.flush()
                rolling += data
                if len(rolling) > 4096:
                    rolling = rolling[-4096:]
                low = rolling.lower()
                if (not hostkey_answered) and b"are you sure you want to continue connecting" in low:
                    os.write(master, b"yes\n")
                    hostkey_answered = True
                    rolling = bytearray()
                    continue
                if (not hostkey_answered) and b"(yes/no)?" in low:
                    os.write(master, b"yes\n")
                    hostkey_answered = True
                    rolling = bytearray()
                    continue
            # Handle stdin input (pipe data after authentication)
            if authenticated:
                if stdin_stream and stdin_stream.fileno() in r:  # read from INPUT (stdin_stream)
                    try:
                        data = stdin_stream.read(4096)
                    except Exception:
                        data = b''
                    if not data:
                        # EOF reached: close master to send EOF to slave
                        try:
                            while True:
                                r, _, _ = select.select([master], [], [], 0)
                                if not r:
                                    # nessun dato da leggere, esco dal loop
                                    break
                                time.sleep(1)
                            time.sleep(5)
                            os.close(master)
                        except Exception as e:
                            cerror("Write error: {e}")
                        break
                    else:
                        if first_write:
                            first_write = False
                        os.write(master, data)
                elif not stdin_stream and sys.stdin.fileno() in r:  # read from INPUT (stdin)
                    try:
                        data = os.read(sys.stdin.fileno(), 4096)
                    except OSError:
                        data = b''
                    if not data:
                        # EOF reached: close master to send EOF to slave
                        try:
                            while True:
                                r, _, _ = select.select([master], [], [], 0)
                                if not r:
                                    # nessun dato da leggere, esco dal loop
                                    break
                                time.sleep(1)
                            time.sleep(5)
                            os.close(master)
                        except Exception as e:
                            cerror("Write error: {e}")
                        break
                    else:
                        os.write(master, data)
    
    except KeyboardInterrupt:
        pass
    finally:
        try:
            _, status = os.waitpid(pid, 0)
        except ChildProcessError:
            pass
    
    return output.decode(errors='ignore') if capture_output else ''

def ssh_run(host, user, password, command, debug=False, capture_output=True, stdin_stream=None):
    """Execute command on remote host via SSH, optionally passing a file-like stdin_stream"""
    # Prepend PATH export to ensure Freetz-NG commands are found
    # Use 'export PATH=...; command' to set PATH for the entire command execution
    full_command = f"export PATH='{FREETZ_PATH}'; {command}"
    cmd = ['ssh', '-o', 'StrictHostKeyChecking=no', f'{user}@{host}', full_command]
    cmd_str = ' '.join(cmd)
    cdebug(f"SSH: {cmd_str}", debug)
    output = sshpass_exec(cmd, password, verbose=debug, capture_output=capture_output, stdin_stream=stdin_stream)
    # Log command and output only in debug mode
    if debug:
        log_ssh_command(cmd_str, output if capture_output else "[output not captured]", debug)
    return output

def scp_send(host, user, password, local, remote, debug=False, dry_run=False):
    """Copy file to remote host via SCP"""
    # Use quiet mode and redirect all output to /dev/null to prevent progress display
    cmd = ['scp', '-o', 'StrictHostKeyChecking=no', '-o', 'LogLevel=ERROR', '-q', local, f'{user}@{host}:{remote}']
    cmd_str = ' '.join(cmd)
    cdebug(f"SCP: {cmd_str}", debug)
    
    # Log SCP command only in debug mode
    if debug:
        log_ssh_command(cmd_str, f"Uploading {local} to {remote}", debug)
    
    # Execute SCP with silent=True to suppress all output
    try:
        # Check if remote file already exists and warn user in interactive mode
        remote_exists = ssh_run(host, user, password, f"test -f '{remote}' && echo exists || echo notfound", debug=debug, capture_output=True).strip()
        if remote_exists == "exists":
            if not dry_run:
                if sys.stdin.isatty():  # Interactive mode
                    cwarning(f"Remote file already exists: {remote}")
                    if not confirm(f"Overwrite remote file\n '{remote}'?\n This will delete the existing file and it is needed to continue.", default=False):
                        cerror("Upload cancelled by user.")
                        return None
                # Delete remote file before upload
                ssh_run(host, user, password, f"rm -f '{remote}'", debug=debug)
            else:
                cwarning(f"[DRY-RUN] Remote file '{remote}' already exists. Would delete before upload.")

        output = sshpass_exec(cmd, password, verbose=False, capture_output=True, silent=True)
        # Check if there were any error messages in output
        if output and ('error' in output.lower() or 'failed' in output.lower() or 'permission denied' in output.lower()):
            cdebug(f"SCP error detected in output: {output}", debug)
            return False
        return True
    except Exception as e:
        cdebug(f"SCP exception: {e}", debug)
        return False


# --- FRITZ!Box CONFIGURATION FUNCTIONS ---
class RouterConfig:
    """FRITZ!Box configuration container"""
    def __init__(self):
        self.external_dir = DEFAULT_EXTERNAL_BASE
        self.external_freetz_services = 'yes'
        self.lang = 'en'
        self.has_ubi = False
        self.ubi_size = 0
        self.ubi_available = 0
        self.storage_devices = []
        
    def __repr__(self):
        return (f"RouterConfig(external_dir={self.external_dir}, "
                f"has_ubi={self.has_ubi}, storage_devices={len(self.storage_devices)})")

def parse_mod_config(config_text):
    """Parse /mod/etc/conf/mod.cfg content"""
    config = {}
    for line in config_text.splitlines():
        line = line.strip()
        if line.startswith('export '):
            # Remove 'export ' prefix
            line = line[7:]
            if '=' in line:
                key, value = line.split('=', 1)
                # Remove quotes from value
                value = value.strip("'\"")
                config[key] = value
    return config

def parse_df_output(df_text):
    """Parse df -h output to detect storage devices and UBI"""
    storage = []
    ubi_info = None
    
    for line in df_text.splitlines()[1:]:  # Skip header
        parts = line.split()
        if len(parts) >= 6:
            filesystem = parts[0]
            size = parts[1]
            used = parts[2]
            available = parts[3]
            use_percent = parts[4]
            mountpoint = ' '.join(parts[5:])
            
            # Detect UBI (internal flash storage)
            # UBI devices are mounted at /var/media/ftp or subdirectories
            if '/dev/ubi' in filesystem and '/var/media/ftp' in mountpoint:
                # Prefer the root UBI mount point (/var/media/ftp)
                # If we already have a UBI but this one is shorter path, replace it
                if ubi_info is None or len(mountpoint) < len(ubi_info['mountpoint']):
                    ubi_info = {
                        'filesystem': filesystem,
                        'size': size,
                        'available': available,
                        'mountpoint': mountpoint
                    }
            
            # Detect external storage (USB, SD card, etc.)
            # Only count devices that are NOT the UBI itself
            elif filesystem.startswith('/dev/sd') or filesystem.startswith('/dev/mmc'):
                storage.append({
                    'device': filesystem,
                    'size': size,
                    'available': available,
                    'use_percent': use_percent,
                    'mountpoint': mountpoint
                })
    
    return ubi_info, storage

def read_device_config(host, user, password, debug=False, summary=False):
    """Read and parse FRITZ!Box configuration"""
    config = RouterConfig()
    
    if not summary:
        # Step 1: Read mod.cfg
        cinfo("Step 1: Reading Freetz-NG configuration (/mod/etc/conf/mod.cfg)")

        # Try to connect, retrying every 2 seconds if 'No route to host' is detected
        start_time = time.time()
        no_route_first = True
        while True:
            mod_cfg_output = ssh_run(host, user, password, 
                                    "cat /mod/etc/conf/mod.cfg 2>/dev/null",
                                    debug=debug, capture_output=True)
            if (
                mod_cfg_output and "Connection refused" in mod_cfg_output
            ) or (
                mod_cfg_output and "Connection reset by peer" in mod_cfg_output
            ):
                cerror("Freetz-NG may not be properly installed.")
                return None
            if (
                mod_cfg_output and "ssh:" in mod_cfg_output and "No route to host" in mod_cfg_output
            ) or (
                mod_cfg_output and "Connection timed out" in mod_cfg_output
            ):
                elapsed = time.time() - start_time
                if no_route_first:
                    cerror(f"No connection to {host} (port 22: No route to host)")
                    no_route_first = False
                else:
                    print(".", end='', flush=True)
                if elapsed > BOOT_WAIT_MAX_TRIES * 2:
                    cerror(f"Could not connect to {host} after {BOOT_WAIT_MAX_TRIES * 2 / 60} minutes. Aborting.")
                    return None
                time.sleep(2)
                continue
            if not mod_cfg_output or 'No such file' in mod_cfg_output:
                cerror("Freetz-NG configuration file not found!")
                cerror("File /mod/etc/conf/mod.cfg is missing. Freetz-NG may not be properly installed.")
                return None
            break
        
        # Parse /mod/etc/conf/mod.cfg
        mod_config = parse_mod_config(mod_cfg_output)
        
        # Set external_dir with fallback
        if 'MOD_EXTERNAL_DIRECTORY' in mod_config:
            config.external_dir = mod_config['MOD_EXTERNAL_DIRECTORY']
        else:
            config.external_dir = '/var/media/ftp/external'
            cwarning("MOD_EXTERNAL_DIRECTORY not found in config, using default: /var/media/ftp/external")
        
        config.external_freetz_services = 'no'
        if 'MOD_EXTERNAL_FREETZ_SERVICES' in mod_config:
            config.external_freetz_services = mod_config['MOD_EXTERNAL_FREETZ_SERVICES']
        config.lang = 'en'
        if 'MOD_LANG' in mod_config:
            config.lang = mod_config['MOD_LANG']
        config.port = '81'
        if 'MOD_HTTPD_PORT' in mod_config:
            config.port = mod_config['MOD_HTTPD_PORT']
        config.user = 'unknown'
        if 'MOD_HTTPD_USER' in mod_config:
            config.user = mod_config['MOD_HTTPD_USER']
        config.stor = 'unknown'
        if 'MOD_STOR_PREFIX' in mod_config:
            config.stor = mod_config['MOD_STOR_PREFIX']

        cprint(f"{EMOJI['ok']} Configuration loaded successfully. Current settings:", 'green')
        cprint(f"  External directory: {config.external_dir}", 'cyan')
        cprint(f"  External services:  {config.external_freetz_services}", 'cyan')
        cprint(f"  Language:           {config.lang}", 'cyan')
        cprint(f"  HTTP port:          {config.port}", 'cyan')
        cprint(f"  User:               {config.user}", 'cyan')
        cprint(f"  Storage prefix:     {config.stor}", 'cyan')

        # Step 2: Read storage information (df -h)
        cprint("")
        cinfo("Step 2: Detecting storage devices")
        df_output = ssh_run(host, user, password, "df -h", debug=debug, capture_output=True)

        if df_output:
            ubi_info, storage_devices = parse_df_output(df_output)
            
            # UBI information
            if ubi_info:
                config.has_ubi = True
                config.ubi_size = ubi_info['size']
                config.ubi_available = ubi_info['available']
                cprint(f"\n{EMOJI['ok']} Internal UBI storage detected:", 'green')
                cprint(f"  Device:     {ubi_info['filesystem']}", 'cyan')
                cprint(f"  Size:       {ubi_info['size']}", 'cyan')
                cprint(f"  Available:  {ubi_info['available']}", 'cyan')
                cprint(f"  Mount:      {ubi_info['mountpoint']}", 'cyan')
            else:
                cwarning("No UBI storage detected (FRITZ!Box may have limited internal storage)")
            
            # External storage devices
            if storage_devices:
                config.storage_devices = storage_devices
                cprint(f"\n{EMOJI['ok']} External storage devices detected: {len(storage_devices)}", 'green')
                for i, dev in enumerate(storage_devices, 1):
                    cprint(f"  Device {i}:  {dev['device']}", 'cyan')
                    cprint(f"    Size:       {dev['size']}", 'cyan')
                    cprint(f"    Available:  {dev['available']}", 'cyan')
                    cprint(f"    Used:       {dev['use_percent']}", 'cyan')
                    cprint(f"    Mount:      {dev['mountpoint']}", 'cyan')
            else:
                cwarning("No external storage devices detected")

        # Step 3: Additional FRITZ!Box information
        cprint("")
        cinfo("Step 3: Gathering additional current system information (/etc/freetz_info.cfg):")

    # Get Freetz data
    freetz_data = ssh_run(host, user, password, 
                            "cat /etc/freetz_info.cfg 2>/dev/null || echo 'Unknown'",
                            debug=debug, capture_output=True).strip()

    # Extract variables from freetz_data
    config.freetz_info_boxtype = 'Unknown'
    config.freetz_info_firmwareversion = 'Unknown'
    config.freetz_info_version = 'Unknown'
    config.freetz_info_makedate = 'Unknown'
    config.freetz_info_image_name = 'Unknown'
    if freetz_data != 'Unknown':
        def extract_var(varname):
            match = re.search(rf"export {varname}='([^']*)'", freetz_data)
            return match.group(1) if match else 'Unknown'
        config.freetz_info_boxtype = extract_var('FREETZ_INFO_BOXTYPE')
        config.freetz_info_firmwareversion = extract_var('FREETZ_INFO_FIRMWAREVERSION')
        config.freetz_info_version = extract_var('FREETZ_INFO_VERSION')
        config.freetz_info_makedate = extract_var('FREETZ_INFO_MAKEDATE')
        config.freetz_info_image_name = extract_var('FREETZ_INFO_IMAGE_NAME')
        cprint(f"  Box type:     {config.freetz_info_boxtype}", 'cyan')
        cprint(f"  AVM Firmware: {config.freetz_info_firmwareversion}", 'cyan')
        cprint(f"  Make Version: {config.freetz_info_version}", 'cyan')
        cprint(f"  Make date:    {config.freetz_info_makedate}", 'cyan')
        cprint(f"  Image name:   {config.freetz_info_image_name}", 'cyan')

    # Get Freetz version
    kernel_version = ssh_run(host, user, password, 
                            "uname -r 2>/dev/null || echo 'Unknown'",
                            debug=debug, capture_output=True).strip()
    
    # Get urlader environment variables
    urlader_env = ssh_run(host, user, password,
                         "cat /proc/sys/urlader/environment 2>/dev/null || echo 'Unknown'",
                         debug=debug, capture_output=True).strip()
    
    # Parse urlader environment
    if urlader_env != 'Unknown':
        urlader_vars = {}
        for line in urlader_env.splitlines():
            line = line.strip()
            if '\t' in line:
                key, value = line.split('\t', 1)
                urlader_vars[key.strip()] = value.strip()
        
        # Store variables in config
        config.hw_revision = urlader_vars.get('HWRevision', 'Unknown')
        config.hw_subrevision = urlader_vars.get('HWSubRevision', 'Unknown')
        config.product_id = urlader_vars.get('ProductID', 'Unknown')
        config.serial_number = urlader_vars.get('SerialNumber', 'Unknown')
        config.annex = urlader_vars.get('annex', 'Unknown')
        config.autoload = urlader_vars.get('autoload', 'Unknown')
        config.bootloader_version = urlader_vars.get('bootloaderVersion', 'Unknown')
        config.country = urlader_vars.get('country', 'Unknown')
        config.firmware_info = urlader_vars.get('firmware_info', 'Unknown')
        config.firmware_version = urlader_vars.get('firmware_version', 'Unknown')
        config.flashsize = urlader_vars.get('flashsize', 'Unknown')
        
        # Display selected information
        if config.hw_revision != 'Unknown':
            cprint(f"  HW Revision:  {config.hw_revision}", 'cyan')
        if config.hw_subrevision != 'Unknown':
            cprint(f"  HW SubRev:    {config.hw_subrevision}", 'cyan')
        if config.product_id != 'Unknown':
            cprint(f"  Product ID:   {config.product_id}", 'cyan')
        if config.serial_number != 'Unknown':
            cprint(f"  Serial:       {config.serial_number}", 'cyan')
        if config.annex != 'Unknown':
            cprint(f"  Annex:        {config.annex}", 'cyan')
        if config.bootloader_version != 'Unknown':
            cprint(f"  Bootloader:   {config.bootloader_version}", 'cyan')
        if config.country != 'Unknown':
            cprint(f"  Country:      {config.country}", 'cyan')
        if config.firmware_info != 'Unknown':
            cprint(f"  FW Info:      {config.firmware_info}", 'cyan')
        if config.flashsize != 'Unknown':
            cprint(f"  Flash:        {config.flashsize}", 'cyan')
    else:
        config.hw_revision = 'Unknown'
        config.hw_subrevision = 'Unknown'
        config.product_id = 'Unknown'
        config.serial_number = 'Unknown'
        config.annex = 'Unknown'
        config.autoload = 'Unknown'
        config.bootloader_version = 'Unknown'
        config.country = 'Unknown'
        config.firmware_info = 'Unknown'
        config.firmware_version = 'Unknown'
        config.flashsize = 'Unknown'
    
    if kernel_version != 'Unknown':
        cprint(f"  Kernel:       {kernel_version}", 'cyan')

    # Get RAM info
    ram_output = ssh_run(host, user, password, "free", debug=debug, capture_output=True)
    ram_line = None
    config.ram_total = None
    for line in ram_output.splitlines():
        if line.lower().startswith("mem:"):
            ram_line = line
            parts = line.split()
            if len(parts) >= 2 and parts[1].isdigit():
                config.ram_total = int(parts[1])
    if config.ram_total:
        cprint(f"  RAM:          {config.ram_total // 1024} MB", 'cyan')
    else:
        cprint("FRITZ!Box RAM info not available", 'yellow', 'warning')
    # Get JFFS2 info
    config.jffs2_output = ssh_run(host, user, password, "grep jffs2 /proc/mtd", debug=debug, capture_output=True)
    if config.jffs2_output.strip():
        cprint("  JFFS2 partition detected:", 'cyan')
        for line in config.jffs2_output.splitlines():
            cprint(f"  {line}", 'cyan')
    else:
        cprint("  No JFFS2 partition detected", 'cyan')

    return config

# --- UPDATE PROCESS FUNCTIONS ---
def detect_external_dir(host, user, password, debug=False):
    """Detect current external directory from FRITZ!Box configuration"""
    cdebug("Detecting external directory from FRITZ!Box config", debug)
    # Try to read mod config
    output = ssh_run(host, user, password, 
                     "cat /mod/etc/conf/mod.cfg 2>/dev/null | grep EXTERNAL_DIRECTORY || echo '/var/media/ftp/FRITZBOX/external'",
                     debug=debug)
    if output and '/var' in output:
        match = re.search(r'(/var[^\s]+)', output)
        if match:
            return match.group(1)
    return DEFAULT_EXTERNAL_BASE

def upload_file_with_progress(host, user, password, local_file, remote_dir, debug=False, dry_run=False):
    """Upload file to FRITZ!Box with progress indication"""
    filename = os.path.basename(local_file)
    filesize = get_file_size(local_file)
    remote_path = f"{remote_dir}/{filename}"
    
    cprint(f"Uploading file name: '{filename}' ({format_size(filesize)})", 'yellow', 'copy')
    # Count number of files in tar archive
    nfiles = count_tar_files(local_file)
    cprint(f"Archive contains {nfiles} files.", 'yellow', 'info')
    cprint(f"Stage filename: {remote_path}", 'yellow', 'copy')
    
    if dry_run:
        cwarning("[DRY-RUN] Skipping file upload")
        return remote_path
    
    # Check if remote file already exists and warn user in interactive mode
    remote_exists = ssh_run(host, user, password, f"test -f '{remote_path}' && echo exists || echo notfound", debug=debug, capture_output=True).strip()
    if remote_exists == "exists":
        if not dry_run:
            if sys.stdin.isatty():  # Interactive mode
                cwarning(f"Remote file already exists: {remote_path}")
                if not confirm(f"Overwrite remote file '{remote_path}'? This will delete the existing file.", default=False):
                    cerror("Upload cancelled by user.")
                    return None
            # Delete remote file before upload
            ssh_run(host, user, password, f"rm -f '{remote_path}'", debug=debug)
        else:
            cwarning(f"[DRY-RUN] Remote file '{remote_path}' already exists. Would delete before upload.")

    # For large files, show progress with monitoring thread
    if filesize > 10 * 1024 * 1024:  # > 10MB
        cinfo("Upload in progress (this may take several minutes)...")
        # Progress monitoring thread
        upload_done = threading.Event()
        start_time = time.time()
        def monitor_progress():
            """Monitor upload progress by checking remote file size"""
            last_size = 0
            shown_progress = False
            while not upload_done.is_set():
                try:
                    # Check remote file size
                    result = ssh_run(host, user, password, 
                                   f"ls -l {remote_path} 2>/dev/null | awk '{{print $5}}'",
                                   debug=False, capture_output=True)
                    if result and result.strip().isdigit():
                        current_size = int(result.strip())
                        if current_size > 0 and current_size > last_size:
                            last_size = current_size
                            elapsed = time.time() - start_time
                            speed = current_size / elapsed if elapsed > 0 else 0
                            percent = int(100 * current_size / filesize)
                            eta = int((filesize - current_size) / speed) if speed > 0 else 0
                            # Clear line and show progress
                            print(f"\r   Progress: {percent}% | {format_size(current_size)}/{format_size(filesize)} | "
                                  f"{format_size(speed)}/s | ETA: {eta}s     ", end='', flush=True)
                            shown_progress = True
                except:
                    pass
                time.sleep(1)  # Update every second
            # If we never showed progress, it means upload was too fast or failed
            if not shown_progress:
                time.sleep(0.1)  # Give SCP time to complete
        # Start monitoring thread
        monitor_thread = threading.Thread(target=monitor_progress, daemon=True)
        monitor_thread.start()
        # Perform upload
        success = scp_send(host, user, password, local_file, remote_path, debug=debug, dry_run=dry_run)
        upload_done.set()
        monitor_thread.join(timeout=1)
        # Verify upload completed successfully
        elapsed = time.time() - start_time
        verify_result = ssh_run(host, user, password,
                               f"ls -l {remote_path} 2>/dev/null | awk '{{print $5}}'",
                               debug=debug, capture_output=True)
        if verify_result and verify_result.strip().isdigit():
            uploaded_size = int(verify_result.strip())
            if uploaded_size == filesize:
                speed = filesize / elapsed if elapsed > 0 else 0
                print(f"\r   Progress: 100% | {format_size(filesize)}/{format_size(filesize)} | "
                      f"{format_size(speed)}/s | Completed in {int(elapsed)}s     ")
                success = True
            else:
                print(f"\r  Upload incomplete: {format_size(uploaded_size)}/{format_size(filesize)}     ")
                success = False
        else:
            # Could not verify - assume success if scp_send returned True
            if success:
                speed = filesize / elapsed if elapsed > 0 else 0
                print(f"\r   Progress: 100% | {format_size(filesize)}/{format_size(filesize)} | "
                      f"{format_size(speed)}/s | Completed in {int(elapsed)}s     ")
    else:
        # Small files: simple upload
        start_time = time.time()
        success = scp_send(host, user, password, local_file, remote_path, debug=debug, dry_run=dry_run)
        elapsed = time.time() - start_time
    
    if success:
        cprint(f"{EMOJI['ok']} Upload complete", 'green')
        return remote_path
    else:
        cerror("Upload failed!")
        return None

def extract_archive_with_progress(host, user, password, archive_file, target_dir, log_file, debug=False):
    """
    Extract a tar archive to a target directory on FRITZ!Box, showing progress.
    Used by both firmware_update_process and external_update_process.
    """
    ssh_run(host, user, password, f"rm -rf {log_file}", debug=debug)
    tar_count = count_tar_files(archive_file)
    extract_cmd = f"mkdir -p {target_dir} && tar -C {target_dir} -xvf - > {log_file} 2>&1; echo $? > /tmp/var-tar.code"
    cdebug(f"Extracting {tar_count} files to {target_dir}", debug)

    extract_done = threading.Event()
    start_time = time.time()

    def monitor_extraction():
        last_count = 0
        while not extract_done.is_set():
            try:
                result = ssh_run(host, user, password,
                                 f"grep -v '/$' {log_file} 2>/dev/null | wc -l || echo 0",  # only count files
                                 debug=False, capture_output=True)
                if result and result.strip().isdigit():
                    current_count = int(result.strip())
                    if current_count > last_count:
                        last_count = current_count
                        percent = min(99, int(100 * current_count / tar_count)) if tar_count > 0 else 0
                        print(f"\r   Extraction progress: {percent}% | {current_count}/{tar_count} files extracted     ",
                              end='', flush=True)
            except:
                pass
            time.sleep(1)

    monitor_thread = threading.Thread(target=monitor_extraction, daemon=True)
    monitor_thread.start()

    with open(archive_file, 'rb') as f:
        ssh_run(host, user, password, extract_cmd, debug=debug, capture_output=False, stdin_stream=f)
    extract_done.set()
    monitor_thread.join(timeout=1)

    elapsed = int(time.time() - start_time)

    # Check extraction return code
    ret_code = ssh_run(host, user, password, f"cat /tmp/var-tar.code", debug=debug, capture_output=True).strip()
    if not ret_code.isdigit() or int(ret_code) != 0:
        cprint("")
        cerror(f"Archive extraction failed with code {ret_code}")
        cprint(f"Last 10 lines of extraction log:", 'red', 'warning')
        log_tail = ssh_run(host, user, password, f"tail -n 10 {log_file}", debug=debug, capture_output=True)
        print(log_tail)
        return False

    print(f"\r   Extraction progress: 100% | {tar_count}/{tar_count} files extracted in {elapsed}s     ")
    cprint(f"{EMOJI['ok']} Extraction complete.", 'green')
    if target_dir != '/':
        ext_size = ssh_run(host, user, password, f"du -sh '{target_dir}' 2>/dev/null | awk '{{print $1}}'", debug=debug, capture_output=True).strip()
        cprint(f"   Size of the external directory: {ext_size}", 'cyan')

    return True

def firmware_update_process(host, user, password, image_file,
                           stop_services='semistop_avm', no_reboot=False,
                           reboot_at_the_end=False,
                           delete_jffs2=False, downgrade=False,
                           debug=False, dry_run=False):
    """Execute firmware update process (emulates do_update_handler.sh)"""
    cprint("\n" + "="*60, 'bold')
    cprint("FIRMWARE UPDATE PROCESS", 'bold', 'install')
    cprint("="*60 + "\n", 'bold')

    if dry_run:
        cwarning("[DRY-RUN] Skipping firmware extraction and installation")
        cprint("")
        return True
    
    # Step 0: Prepare downgrade (if requested)
    if downgrade:
        cinfo("Step 0: Preparing downgrade...")
        downgrade_output = ssh_run(host, user, password, "/usr/bin/prepare-downgrade", debug=debug, capture_output=True)
        if downgrade_output:
            cprint(downgrade_output)
        cprint(f"{EMOJI['ok']} Downgrade preparation complete.", 'green')
    
    # Step 1: Stop AVM services (if requested)
    if stop_services == 'noaction':
        cwarning(f"Firmware not installed ({stop_services})")
        return True
    if stop_services == 'stop_avm':
        cinfo(f"Step 1: Stopping AVM services ({stop_services}). Please wait...")
        ssh_run(host, user, password, "prepare_fwupgrade start", debug=debug)
        ssh_run(host, user, password, "prepare_fwupgrade end", debug=debug)
        cprint(f"{EMOJI['ok']} AVM services stopped.", 'green')
    elif stop_services == 'semistop_avm':
        cinfo(f"Step 1: Stopping AVM services ({stop_services}). Please wait...")
        ssh_run(host, user, password, "prepare_fwupgrade start_from_internet", debug=debug)
        cprint(f"{EMOJI['ok']} AVM services stopped.", 'green')
    elif stop_services == 'tr069':
        cinfo(f"Step 1: Stopping AVM services ({stop_services}). Please wait...")
        ssh_run(host, user, password, "prepare_fwupgrade start_tr069", debug=debug)
        cprint(f"{EMOJI['ok']} AVM services stopped.", 'green')
    else:
        cinfo("Step 1: Skipping AVM services stop (nostop_avm mode)")

    # Step 2: Extract FRITZ!Box firmware archive
    cinfo("Step 2: Extracting firmware archive to the tmpfs of FRITZ!Box. Please wait...")
    if not extract_archive_with_progress(
        host, user, password,
        archive_file=image_file,
        target_dir="/",
        log_file="/tmp/fw_extract.log",
        debug=debug
    ):
        return False
    
    # Step 3: Execute firmware installation script
    inst_exists = ssh_run(host, user, password, f"test -f /var/install -a -x /var/install && echo ok || echo notfound", debug=debug, capture_output=True).strip()
    if inst_exists != "ok":
        cerror("Installation file does not exist.")
        return False

    cinfo("Step 3: Flashing firmware, please wait... (see /tmp/var-install.out)")
    # Emulate install() function from do_update_handler.sh
    install_commands = [
        "rm -f /var/post_install",  # Remove no-op original from var.tar
    ]
    
    # Delete JFFS2 if requested
    if delete_jffs2:
        cwarning("Deleting JFFS2 partition (as requested)")
        install_commands.extend([
            # Set image size to max
            "sed -i -e 's|kernel_update_len=$Kernel_without_jffs2_size|kernel_update_len=$kernel_mtd_size|' /var/install",
            # Unset jffs2_size env var
            "echo jffs2_size > /proc/sys/urlader/environment"
        ])
    
    # Execute installation
    install_commands.extend([
        "cd /",
        "( set -o pipefail ; . /bin/env.mod.rcconf avm ; /var/install 2>&1 ; echo $? >/tmp/var-install.code ) > /tmp/var-install.out",
        "tail -n1 /tmp/var-install.code"
    ])
    install_output = ssh_run(
        host, user, password,
        " && ".join(install_commands),
        debug=debug
    )
    
    # Parse installation result
    exit_code = 6  # Default: OTHER_ERROR
    last_line = install_output.strip().splitlines()[-1] if install_output.strip() else ''
    if last_line.isnumeric():
        exit_code = int(last_line)
    
    result_codes = {
        0: ("INSTALL_SUCCESS_NO_REBOOT", "green"),
        1: ("INSTALL_SUCCESS_REBOOT", "green"),
        2: ("INSTALL_WRONG_HARDWARE", "red"),
        3: ("INSTALL_KERNEL_CHECKSUM", "red"),
        4: ("INSTALL_FILESYSTEM_CHECKSUM", "red"),
        5: ("INSTALL_URLADER_CHECKSUM", "red"),
        6: ("INSTALL_OTHER_ERROR", "red"),
        7: ("INSTALL_FIRMWARE_VERSION", "yellow"),
        8: ("INSTALL_DOWNGRADE_NEEDED", "yellow"),
    }
    
    result_txt, color = result_codes.get(exit_code, ("UNKNOWN_ERROR", "red"))
    cprint(f"Installation result: {exit_code} ({result_txt})", color, 'info' if color == 'green' else 'warning')
    
    # Step 4: Verify post_install if exists
    if exit_code == 1:
        cinfo("Step 4: Verifying post-installation script...")
        post_install_exists = ssh_run(
            host, user, password, 
            "test -f /var/post_install && echo exists || echo notfound",
            debug=debug, capture_output=True
        ).strip()
        if post_install_exists == "exists":
            cprint(f"{EMOJI['ok']} Post-installation script found: /var/post_install", 'green')
        else:
            error("No post-installation script found")
            return False
    
    # Step 5: Reboot if needed
    if exit_code == 1 and not no_reboot and reboot_at_the_end:
        cprint(f"{EMOJI['ok']} Firmware update complete.", 'green')
        cprint("Reboot is postponed after the installation of the external updates.", 'reboot', 'reboot')
        cprint("")
        cprint("="*60 + "\n", 'bold')
        return True
    if exit_code == 1 and not no_reboot:
        cprint("\n" + "="*60, 'bold')
        cprint("REBOOTING FRITZ!Box", 'bold', 'reboot')
        cprint("="*60 + "\n", 'bold')
        ssh_run(host, user, password, REBOOT_CMD, capture_output=False, debug=debug)

        if not wait_router_boot(host, password, user, debug=debug):
            cerror("Router did not come back online in time after reboot!")
            return False

        # Read again FRITZ!Box configuration
        cinfo("Gathering system information after reboot:")
        router_config = read_device_config(host, user, password, debug, summary=True)
        if router_config is None:
            cerror("Cannot read Freetz-NG configuration!")
            return False
        return True
    elif exit_code == 1 and no_reboot:
        cwarning("Reboot required but --no-reboot flag is set")
        return True
    elif exit_code <= 1:
        cprint(f"{EMOJI['ok']} Firmware update complete (no reboot required).", 'green')
        return True
    else:
        cerror("Firmware installation failed!")
        cprint(f"Last 10 lines of the installation log:", 'red', 'warning')
        log_tail = ssh_run(host, user, password, f"tail -n 10 /tmp/var-install.out", debug=debug, capture_output=True)
        print(log_tail)
        return False

def external_update_process(host, user, password, external_file, external_dir,
                            preserve_old=False, restart_services=True,
                            reboot_at_the_end=False,
                            debug=False, dry_run=False):
    """Execute external update process (emulates do_external_handler.sh)"""
    cprint("\n" + "="*60, 'bold')
    cprint("EXTERNAL UPDATE PROCESS", 'bold', 'external')
    cprint("="*60 + "\n", 'bold')
    
    # Determine external directory from filename if not specified
    if not external_dir:
        basename = os.path.splitext(os.path.basename(external_file))[0]
        external_dir = f"{DEFAULT_EXTERNAL_BASE}/{basename}"
    
    cprint(f"Installation directory: {external_dir}", 'cyan', 'info')

    # Check if external_dir exists and contains .external marker
    dir_exists = ssh_run(host, user, password, f"test -d '{external_dir}' && echo exists || echo notfound", debug=debug, capture_output=True).strip()
    if dir_exists == "exists":
        marker_exists = ssh_run(host, user, password, f"test -e '{external_dir}/.external' && echo exists || echo notfound", debug=debug, capture_output=True).strip()
        if marker_exists != "exists":
            cerror(f"External directory '{external_dir}' exists but is missing the .external marker file!")
            return False
    
    if dry_run:
        cprint("")
        cwarning("[DRY-RUN] Skipping external extraction")
        return True
    
    # Step 1: Stop external services
    if restart_services:
        cinfo("Step 1: Stopping external services")
        status = ssh_run(host, user, password, "/mod/etc/init.d/rc.external status 2>/dev/null", debug=debug)
        if 'running' in status:
            ssh_run(host, user, password, "/mod/etc/init.d/rc.external stop", debug=debug)
            cprint(f"{EMOJI['ok']} External services stopped", 'green')
        else:
            cinfo("External services not running")
    else:
        if not reboot_at_the_end:
            cinfo("Step 1: External services not stopped as requested.")
    
    # Step 2: Delete or preserve old directory
    if preserve_old:
        cinfo("Step 2: Keeping old external directory and files")
    else:
        cinfo("Step 2: Removing old external directory and files")
        ssh_run(host, user, password, f"rm -rf {external_dir}", debug=debug)
        cprint(f"{EMOJI['ok']} Old external directory '{external_dir}' and files removed", 'green')
    
    # Step 3: Extract external archive
    cinfo("Step 3: Extracting external archive. Please wait...")
    if not extract_archive_with_progress(
        host, user, password,
        archive_file=external_file,
        target_dir=external_dir,
        log_file="/tmp/ext_extract.log",
        debug=debug
    ):
        return False
    
    # Step 4: Mark as external directory
    cinfo("Step 4: Mark external directory")
    ssh_run(host, user, password, f"touch {external_dir}/.external", debug=debug)
    
    # Step 5: Restart external services
    if restart_services:
        if reboot_at_the_end:
            cerror("Cannot restart external services if reboot is needed.")
        else:
            cinfo("Step 5: Starting external services...")
            ret = ssh_run(host, user, password, "/mod/etc/init.d/rc.external start", debug=debug)
            cprint(ret)
            cprint(f"{EMOJI['ok']} External services started", 'green')
    else:
        if not reboot_at_the_end:
            cinfo("Step 5: External not restarted as requested.")
    
    return True


# --- MAIN FUNCTION ---
def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Professional Freetz-NG FRITZ!Box Update Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Interactive mode (recommended for first-time users)
    %(prog)s --host 192.168.178.1 --password mypass

    # Batch mode with specific files
    %(prog)s --host 192.168.178.1 --password mypass --image fw.image --external fw.external --batch

    # Dry-run to test without making changes
    %(prog)s --host 192.168.178.1 --password mypass --dry-run

    # Update only firmware (no external)
    %(prog)s --host 192.168.178.1 --password mypass --image fw.image --batch --skip-external

    # Update only external (no firmware)
    %(prog)s --host 192.168.178.1 --password mypass --external fw.external --batch --skip-firmware
"""
    )
    
    # Connection arguments
    conn_group = parser.add_argument_group('Connection Options')
    conn_group.add_argument('--host', required=True,
                           help='FRITZ!Box IP address or hostname')
    conn_group.add_argument('--user', default=DEFAULT_USER,
                           help=f'SSH username (default: {DEFAULT_USER})')
    conn_group.add_argument('--password',
                           help='SSH password (or use ROUTER_PASSWORD env var, or interactive prompt)')
    
    # File selection arguments
    file_group = parser.add_argument_group('File Selection')
    file_group.add_argument('--image',
                           help='Firmware .image file path (or auto-detect from images/)')
    file_group.add_argument('--external',
                           help='External .external file path (or auto-detect from images/)')
    file_group.add_argument('--skip-firmware', action='store_true',
                           help='Skip firmware update (external only)')
    file_group.add_argument('--skip-external', action='store_true',
                           help='Skip external update (firmware only)')
    
    # Directory arguments
    dir_group = parser.add_argument_group('Directory Options')
    dir_group.add_argument('--external-dir',
                          help='External installation directory (default: auto-detect)')
    
    # Update behavior arguments
    update_group = parser.add_argument_group('Update Behavior')
    update_group.add_argument('--stop-services', 
                             choices=['stop_avm', 'semistop_avm', 'nostop_avm', 'tr069', 'noaction'],
                             default='semistop_avm',
                             help='AVM services stop strategy (default: stop_avm)')
    update_group.add_argument('--no-reboot', action='store_true',
                             help='Do not reboot FRITZ!Box after firmware update')
    update_group.add_argument('--reboot-at-the-end', action='store_true',
                             help='Move the reboot at the end, after the external storage update')
    update_group.add_argument('--delete-jffs2', action='store_true',
                             help='Delete JFFS2 partition during firmware update')
    update_group.add_argument('--downgrade', action='store_true',
                             help='Prepare for firmware downgrade (run prepare-downgrade)')
    update_group.add_argument('--no-delete-external', action='store_true',
                             help='Delete old external files before extraction')
    update_group.add_argument('--no-external-restart', action='store_true',
                             help='Do not restart external services after update')
    
    # Mode arguments
    mode_group = parser.add_argument_group('Execution Modes')
    mode_group.add_argument('--batch', action='store_true',
                           help='Batch mode: no interactive prompts, use only CLI arguments')
    mode_group.add_argument('--dry-run', action='store_true',
                           help='Dry-run: show what would be done without making changes')
    mode_group.add_argument('--debug', action='store_true',
                           help='Enable debug output')
    
    args = parser.parse_args()
    
    # Get password from args, env var, or prompt
    args.password = get_password(args)
    
    # Print header
    cprint("\n" + "="*70, 'bold')
    cprint("   Freetz-NG FRITZ!Box Update Tool", 'bold', 'rocket')
    cprint("="*70 + "\n", 'bold')
    
    # Initialize SSH log file only if debug mode is active
    if args.debug:
        try:
            with open(SSH_LOG_FILE, 'w', encoding='utf-8') as f:
                f.write(f"FRITZ!Box Update Session - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            cinfo(f"SSH commands will be logged to: {SSH_LOG_FILE}")
        except Exception as e:
            cwarning(f"Could not create SSH log file: {e}")
    
    if args.dry_run:
        cwarning("DRY-RUN MODE: No changes will be made to FRITZ!Box\n")
    
    # Read FRITZ!Box configuration (always read to show information and validate)
    router_config = read_device_config(args.host, args.user, args.password, args.debug)
    if router_config is None:
        cerror("Cannot proceed without valid Freetz-NG configuration!")
        return 1
    
    # Update defaults based on FRITZ!Box configuration
    if not args.external_dir:
        # Use configured external directory as default
        DEFAULT_EXTERNAL_BASE_OVERRIDE = router_config.external_dir
        cdebug(f"Using external directory from FRITZ!Box config: {DEFAULT_EXTERNAL_BASE_OVERRIDE}", args.debug)
    
    # Validate arguments
    if args.skip_firmware and args.skip_external:
        cerror("Cannot skip both firmware and external updates!")
        return 1
    
    # File selection (interactive or batch)
    images, externals = find_images()
    
    auto_selected_image = False
    if not args.skip_firmware and not args.image:
        if args.batch:
            if not images:
                cerror("No firmware images found and --batch mode requires --image")
                return 1
            args.image = images[0]
            cprint(f"Auto-selected latest firmware image: {os.path.basename(args.image)}", 'yellow', 'info')
            auto_selected_image = True
        else:
            # Interactive: ask if user wants to install firmware
            cprint("")
            if confirm("Install firmware image?", default=True):
                args.image = select_file_interactive(images, 'firmware image')
                if not args.image:
                    cwarning("No firmware image selected, skipping firmware update")
                    args.skip_firmware = True
            else:
                cinfo("Skipping firmware update")
                args.skip_firmware = True

    if not args.skip_firmware and args.image and os.path.islink(args.image):
        cprint(f"Image is a symlink of {os.path.basename(os.path.realpath(args.image))}", 'yellow', 'info')

    auto_selected_external = False
    if not args.skip_external and not args.external:
        if args.batch:
            if externals:
                args.external = externals[0]
                cprint(f"Auto-selected latest external: {os.path.basename(args.external)}", 'yellow', 'info')
                auto_selected_external = True
            else:
                cinfo("No external files found, skipping external update")
                args.skip_external = True
        else:
            # Interactive: ask if user wants to install external
            cprint("")  # Empty line for spacing
            if confirm("Install external package?", default=True):
                args.external = select_file_interactive(externals, 'external package')
                if not args.external:
                    cwarning("No external package selected, skipping external update")
                    args.skip_external = True
            else:
                cinfo("Skipping external update")
                args.skip_external = True
    
    # Re-validate that at least one operation is selected
    if args.skip_firmware and args.skip_external:
        cerror("No operations selected! Must install at least firmware or external.")
        return 1
    
    # Validate selected files exist
    if args.image and not os.path.exists(args.image):
        cerror(f"Firmware image not found: {args.image}")
        return 1
    if args.external and not os.path.exists(args.external):
        cerror(f"External package not found: {args.external}")
        return 1
    if not args.skip_external and not args.skip_firmware and args.image and args.external:
        # Here add a number of checks on the archives
        # If the firmware archive is a symlink, follow the link and get the file; compare this filename with external and check that the two filenames differ only in the suffix (image and external). If they differ, show a warning. Write everything in English.
        firmware_real_path = os.path.realpath(args.image)
        external_real_path = os.path.realpath(args.external)
        firmware_base = os.path.splitext(os.path.basename(firmware_real_path))[0]
        external_base = os.path.splitext(os.path.basename(external_real_path))[0]
        if firmware_base != external_base:
            if args.batch and (auto_selected_image or auto_selected_external):
                cerror(f"Auto-selected firmware and external package have different paths:\n  Firmware: {firmware_real_path}\n  External: {external_real_path}\nIn --batch mode, these paths must match.")
                return 1
            else:
                cwarning(f"Firmware and external package have different base names:\n  Firmware: {firmware_real_path}\n  External: {external_real_path}")
                if (
                    (auto_selected_image or auto_selected_external)
                    and not confirm("The base names differ. Do you want to proceed anyway?", default=False)
                ):
                    cprint("Update cancelled by user due to path name mismatch.", 'red')
                    return 1
        else:
            firmware_suffix = os.path.splitext(firmware_real_path)[1]
            external_suffix = os.path.splitext(external_real_path)[1]
            if firmware_suffix != '.image' or external_suffix != '.external':
                cwarning(f"Non standard firmware or external suffix:\n  Firmware: {firmware_real_path}\n  External: {external_real_path}")

    # Show storage information first
    if router_config and args.external:
        cprint("\n" + "-"*70, 'dim')  # Begin directory configuration
        cinfo(f"Available storage devices:")
        # Show UBI internal storage first if present
        if router_config.has_ubi and hasattr(router_config, 'ubi_available') and hasattr(router_config, 'ubi_size'):
            ubi_label = getattr(router_config, 'ubi_mount', None) or '/var/media/ftp'
            cprint(f"     [UBI] {ubi_label}: {router_config.ubi_available} free ({router_config.ubi_size} total)", 'yellow')
        # Show external devices
        if router_config.storage_devices:
            for dev in router_config.storage_devices:
                cprint(f"     {dev['mountpoint']}: {dev['available']} free ({dev['size']} total)", 'yellow')
        cprint("")  # Empty line for spacing

    # Ask for external directory if external update is selected
    if args.external and not args.skip_external:
        if not args.external_dir:
            # Use FRITZ!Box config external directory directly (without appending basename)
            if router_config:
                suggested_dir = router_config.external_dir
            else:
                suggested_dir = DEFAULT_EXTERNAL_BASE
            if args.batch:
                args.external_dir = suggested_dir
                cprint(f"Using suggested external directory in batch mode: {suggested_dir}.", 'yellow', 'info')
            else:
                cprint(f"  Suggested external directory: {suggested_dir}", 'cyan')
                # Show storage recommendations
                if router_config and router_config.storage_devices:
                    cprint(f"  💡 Available storage devices:", 'yellow')
                    # Show UBI internal storage first if present
                    if router_config.has_ubi and hasattr(router_config, 'ubi_available') and hasattr(router_config, 'ubi_size'):
                        ubi_label = getattr(router_config, 'ubi_mount', None) or '/var/media/ftp'
                        cprint(f"     [UBI] {ubi_label}: {router_config.ubi_available} free ({router_config.ubi_size} total)", 'yellow')
                    # Show external devices
                    if router_config.storage_devices:
                        for dev in router_config.storage_devices:
                            cprint(f"     {dev['mountpoint']}: {dev['available']} free", 'yellow')
                if confirm("Use suggested directory for external installation?", default=True):
                    args.external_dir = suggested_dir
                else:
                    custom_dir = input(f"{EMOJI['prompt']} Enter custom external directory path: ").strip()
                    args.external_dir = custom_dir if custom_dir else suggested_dir
                    cinfo(f"Using external directory: {args.external_dir}")

        # Show external directory size, check existence first
        ext_exists = ssh_run(args.host, args.user, args.password, f"test -d '{args.external_dir}' && echo exists || echo notfound", debug=args.debug, capture_output=True).strip()
        if ext_exists == "exists":
            ext_size = ssh_run(args.host, args.user, args.password, f"du -sh '{args.external_dir}' 2>/dev/null | awk '{{print $1}}'", debug=args.debug, capture_output=True).strip()
            cprint(f"   External directory '{args.external_dir}' already exists. Current size: {ext_size}", 'cyan')
        else:
            cwarning(f"Remote external directory '{args.external_dir}' does not exist.\n   It will be created during archive extraction.")
            ext_size = "0"

    # Ask for external directory if external update is selected
    if args.external and not args.skip_external:
        if not args.external_dir:
            # Use FRITZ!Box config external directory directly (without appending basename)
            if router_config:
                suggested_dir = router_config.external_dir
            else:
                suggested_dir = DEFAULT_EXTERNAL_BASE
            
            cprint(f"  Suggested external directory: {suggested_dir}", 'cyan')
            
            # Show storage recommendations
            if router_config and router_config.storage_devices:
                cprint(f"  💡 Available storage devices:", 'yellow')
                # Show UBI internal storage first if present
                if router_config.has_ubi and hasattr(router_config, 'ubi_available') and hasattr(router_config, 'ubi_size'):
                    ubi_label = getattr(router_config, 'ubi_mount', None) or '/var/media/ftp'
                    cprint(f"     [UBI] {ubi_label}: {router_config.ubi_available} free ({router_config.ubi_size} total)", 'yellow')
                # Show external devices
                if router_config.storage_devices:
                    for dev in router_config.storage_devices:
                        cprint(f"     {dev['mountpoint']}: {dev['available']} free", 'yellow')
            
            if confirm("Use suggested directory for external installation?", default=True):
                args.external_dir = suggested_dir
            else:
                custom_dir = input(f"{EMOJI['prompt']} Enter custom external directory path: ").strip()
                args.external_dir = custom_dir if custom_dir else suggested_dir
                cinfo(f"Using external directory: {args.external_dir}")
    
    cprint("-"*70 + "\n", 'dim')  # End of directory configuration
    
    # Process firmware image options
    if args.image and not args.skip_firmware:
        # Extract firmware metadata from the image archive
        cprint("\n" + "-"*70, 'dim')
        cinfo("Reading firmware archive metadata...")
        
        # Extract ./var/content
        try:
            fw_content_output = subprocess.getoutput(f"tar -xOf '{args.image}' ./var/content 2>/dev/null")
        except Exception as e:
            cerror(f"Could not extract ./var/content from firmware image: {e}")
            return 1
        
        if not fw_content_output or len(fw_content_output.strip()) == 0:
            cerror("Firmware image does not contain valid ./var/content metadata!")
            return 1
        
        # Parse ./var/content
        fw_content = {}
        for line in fw_content_output.splitlines():
            line = line.strip()
            if '=' in line:
                key, value = line.split('=', 1)
                fw_content[key.strip()] = value.strip()
        
        # Extract Product field
        fw_product = fw_content.get('Product', 'Unknown')
        fw_type = fw_content.get('Type', 'Unknown')
        fw_version = fw_content.get('Version', 'Unknown')
        fw_build = fw_content.get('Build', 'Unknown')
        fw_oems = fw_content.get('OEMs', 'Unknown')
        fw_countries = fw_content.get('Countries', 'Unknown')
        fw_languages = fw_content.get('Languages', 'Unknown')
        
        # Display firmware information
        cprint(f"\n{EMOJI['info']} Firmware archive information:", 'cyan')
        cprint(f"  Product:    {fw_product}", 'cyan')
        cprint(f"  Version:    {fw_version}", 'cyan')
        
        # Verify product compatibility
        if fw_product != 'Unknown' and hasattr(router_config, 'product_id') and router_config.product_id != 'Unknown':
            # Extract product ID from fw_product (format: "Fritz_Box_HW285 (FRITZ!Box 7690)")
            fw_product_id = fw_product.split()[0] if ' ' in fw_product else fw_product
            
            if router_config.product_id not in fw_product:
                cprint("")
                cwarning(f"COMPATIBILITY WARNING:")
                cwarning(f"  FRITZ!Box Product ID: {router_config.product_id}")
                cwarning(f"  Firmware Product:     {fw_product}")
                cprint("")
                
                if args.batch:
                    cerror("Product ID mismatch detected in batch mode! Cannot proceed.")
                    cerror("The firmware image is not compatible with this FRITZ!Box model.")
                    return 1
                else:
                    cwarning("The firmware image may not be compatible with this FRITZ!Box model!")
                    if not confirm("Do you want to proceed anyway? (NOT RECOMMENDED)", default=False):
                        cinfo("Update cancelled by user due to product mismatch.")
                        return 0
        else:
            cdebug("Could not verify product compatibility (missing product ID)", args.debug)

        # Extract ./var/.packages
        try:
            fw_packages = subprocess.getoutput(f"tar -xOf '{args.image}' ./var/.packages 2>/dev/null")
            if fw_packages and fw_packages.strip():
                package_lines = fw_packages.strip().splitlines()
                if len(package_lines) == 1:
                    cinfo(f"Packages:  {fw_packages.strip()}")
                else:
                    cprint("")
                    cinfo(f"Packages:  {len(package_lines)} packages included. List:")
                    # Show first few packages as preview
                    # Show packages two per line
                    for i in range(0, min(30, len(package_lines)), 2):
                        if i + 1 < len(package_lines):
                            cprint(f"              {package_lines[i]:<30} {package_lines[i+1]}", 'cyan')
                        else:
                            cprint(f"              {package_lines[i]}", 'cyan')
                    if len(package_lines) > 30:
                        cprint(f"              ... and {len(package_lines) - 30} more", 'cyan')
                cprint("")
            else:
                cdebug("No packages information found in firmware", args.debug)
        except Exception as e:
            cdebug(f"Could not extract ./var/.packages: {e}", args.debug)
            fw_packages = ""
        
        cinfo("Firmware Update Options:")
        # Propose to perform the reboot at the end
        if not args.skip_firmware and not args.skip_external and not args.no_reboot and not args.reboot_at_the_end:
            if args.batch:
               args.reboot_at_the_end = True
               cprint(f"In batch mode, reboot will be performed at the end of the update process.", 'yellow', 'info')
            else:
                if confirm("Would you like to move the reboot at the end, after the external storage update?", default=False):
                    args.reboot_at_the_end = True
        # --- Compute default as in firmware.cgi ---
        ram_mb = router_config.ram_total // 1024 if router_config.ram_total else 0
        has_jffs2 = bool(router_config.jffs2_output.strip())
        if ram_mb >= 128 and not has_jffs2:
            stop_default = 'stop_avm'
        else:
            stop_default = 'semistop_avm'
        #cprint(f"Valid action for your device: {'Full stop (stop_avm)' if stop_default == 'stop_avm' else 'Semi-stop (semistop_avm)'}", 'yellow', 'lamp')
        if args.stop_services != "noaction":
            if args.batch:
                cprint(f"In batch mode, using stop services mode '{args.stop_services}'.", 'yellow', 'info')
            else:
                if confirm("Stop AVM services before firmware update (stop is needed)?", default=True):
                    pass
                    """
                    if confirm("Use full stop (stop_avm) instead of semi-stop (semistop_avm)?", default=(stop_default == 'stop_avm')):
                        args.stop_services = 'stop_avm'
                    else:
                        args.stop_services = 'semistop_avm'
                    """
                else:
                    args.stop_services = 'nostop_avm'
                    cwarning("Warning: Not stopping AVM services during firmware upgrade may cause issues!")
        
        if not args.no_reboot and not args.reboot_at_the_end and not args.batch:
            args.no_reboot = not confirm("Reboot FRITZ!Box after firmware installation?", default=True)
        cprint("-"*70 + "\n", 'dim')
    
    if args.external and not args.skip_external:
        cprint("\n" + "-"*70, 'dim')
        if args.batch:
            if args.no_delete_external:
                cprint("Old external directory will be preserved", 'yellow', 'info')
            else:
                cprint("Old external directory will be deleted before extraction.", 'yellow', 'info')
            if args.stop_services != 'nostop_avm' and args.reboot_at_the_end:
                cinfo("External services will be stopped by the firmware update and restarted within the reboot.")
                args.no_external_restart = True
        else:
            cinfo("External Update Options:")

            if confirm("Delete any previously existing external directory after file upload and before extraction?", default=True):
                args.no_delete_external = False
            else:
                args.no_delete_external = True
                cwarning("Warning: Not deleting old external files may cause issues!")

            if args.stop_services != 'nostop_avm' and args.reboot_at_the_end:
                cinfo("Note: external services will be stopped by the firmware update and restarted within the reboot.")
                args.no_external_restart = True
            else:
                if not confirm("Stop/restart external services after the file extraction?", default=True):
                    args.no_external_restart = True
                    cwarning("Warning: Not restarting services may cause issues!")

        cprint("-"*70 + "\n", 'dim')

    # Show summary
    cprint("\n" + "-"*70, 'dim')
    cinfo("Summary of the selected options:")
    cprint(f"  FRITZ!Box:        {args.host}", 'yellow')
    cprint(f"  User:             {args.user}", 'yellow')
    if args.image:
        cprint(f"  Firmware:         {os.path.basename(args.image)} ({format_size(get_file_size(args.image))})", 'yellow')
    if args.external:
        cprint(f"  External archive: {os.path.basename(args.external)} ({format_size(get_file_size(args.external))})", 'yellow')
        if args.external_dir:
            ext_size = ssh_run(args.host, args.user, args.password, f"du -hs {args.external_dir} 2>/dev/null | awk '{{print $1}}'", debug=args.debug, capture_output=True).strip()
            ext_size_str = f" ({ext_size})" if ext_size else ""
            cprint(f"  External dir:     {args.external_dir}{ext_size_str}", 'yellow')
    if args.image and not args.skip_firmware:
        cprint(f"  Stop services:    {args.stop_services}", 'yellow')
        cprint(f"  Reboot:           {'No' if args.no_reboot else 'Yes'}", 'yellow')
    if not args.skip_firmware and not args.skip_external:
        cprint(f"  Reboot at end:    {'Yes' if args.reboot_at_the_end else 'No'}", 'yellow')
    cprint("-"*70 + "\n", 'dim')

    # Execute firmware update
    if args.image and not args.skip_firmware:
        if not args.batch:
            if not confirm("Proceed with firmware update?", default=False):
                cinfo("Update cancelled by user.")
                return 0
        success = firmware_update_process(
            args.host, args.user, args.password, args.image,
            stop_services=args.stop_services, no_reboot=args.no_reboot,
            reboot_at_the_end=args.reboot_at_the_end,
            delete_jffs2=args.delete_jffs2, downgrade=args.downgrade,
            debug=args.debug, dry_run=args.dry_run
        )
        if success and not args.skip_external:
            cprint("")
        if not success:
            cerror("Firmware update failed!")
            return 1
    
    # Execute external update
    if args.external and not args.skip_external:
        # Detect external dir if not provided
        if not args.external_dir:
            if router_config:
                # Use configuration from FRITZ!Box
                basename = os.path.splitext(os.path.basename(args.external))[0]
                args.external_dir = f"{router_config.external_dir}/{basename}"
                cdebug(f"Using external directory from FRITZ!Box config: {args.external_dir}", args.debug)
            elif not args.dry_run:
                # Fallback to detection
                args.external_dir = detect_external_dir(args.host, args.user, args.password, args.debug)
                cdebug(f"Detected external directory: {args.external_dir}", args.debug)

        if not args.batch:
            if not confirm("Proceed with external storage update?", default=False):
                cinfo("Update cancelled by user.")
                return 0
        
        success = external_update_process(
            args.host, args.user, args.password, args.external, args.external_dir,
            preserve_old=args.no_delete_external, 
            restart_services=not args.no_external_restart,
            reboot_at_the_end=args.reboot_at_the_end,
            debug=args.debug, dry_run=args.dry_run
        )
        if not success:
            cerror("External update failed!")
            return 1
    
    # Reboot if needed
    if not args.no_reboot and args.reboot_at_the_end:
        cprint("\n" + "="*60, 'bold')
        cprint("REBOOTING FRITZ!Box", 'bold', 'reboot')
        cprint("="*60 + "\n", 'bold')
        if args.dry_run:
            cwarning("[DRY-RUN] Skipping reboot command")
        else:
            ssh_run(args.host, args.user, args.password, REBOOT_CMD, capture_output=False, debug=args.debug)
            if not wait_router_boot(args.host, args.password, args.user, debug=args.debug):
                cerror("Router did not come back online in time after reboot!")
                return 1

        # Read again FRITZ!Box configuration
        cinfo("Gathering system information after reboot:")
        router_config = read_device_config(args.host, args.user, args.password, args.debug, summary=True)
        if router_config is None:
            cerror("Cannot read Freetz-NG configuration!")
            return 1

    # Final success message
    cprint("\n" + "="*60, 'bold')
    cprint("UPDATE COMPLETED SUCCESSFULLY!", 'green', 'ok')
    cprint("="*60 + "\n", 'bold')
    
    # Show log file location only in debug mode
    if args.debug and os.path.exists(SSH_LOG_FILE):
        cinfo(f"SSH command log saved to: {SSH_LOG_FILE}")
    
    return 0

if __name__ == "__main__":
    try:
        ret = main()
        cprint("")
        sys.exit(ret)
    except KeyboardInterrupt:
        cwarning("\n\nUpdate interrupted by user")
        sys.exit(130)
    except Exception as e:
        cerror(f"Unexpected error: {e}")
        if '--debug' in sys.argv:
            import traceback
            traceback.print_exc()
        sys.exit(1)
