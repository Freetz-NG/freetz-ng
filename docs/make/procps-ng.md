# procps-ng 4.0.5 (binaries only)
  - Homepage: [https://gitlab.com/procps-ng/procps](https://gitlab.com/procps-ng/procps)
  - Manpage: [https://linux.die.net/man/1/ps](https://linux.die.net/man/1/ps)
  - Changelog: [https://gitlab.com/procps-ng/procps/-/tags](https://gitlab.com/procps-ng/procps/-/tags)
  - Repository: [https://gitlab.com/procps-ng/procps](https://gitlab.com/procps-ng/procps)
  - Package: [master/make/pkgs/procps-ng/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/procps-ng/)
  - Maintainer: [@Ircama](https://github.com/Ircama)

## Overview

The **procps-full** package provides the complete versions of procps-ng utilities for process monitoring and system information. All binaries are installed with the suffix **"full"** to avoid conflicts with BusyBox versions.

This package is useful when you need the full feature set of procps utilities that may not be available in BusyBox implementations.

All commands are installed with the suffix full (e.g., psfull, topfull) to avoid conflicts with BusyBox versions.

## Features

- **18 utilities** for process and system monitoring
- All binaries compiled **statically** for minimal dependencies
- **Suffix "full"** added to each command to prevent conflicts with BusyBox
- Can be **externalized** to USB storage to save flash memory
- Total package size: **~1.3 MB** (all binaries)

## Binaries Included

### Process Information
- **psfull** (203 KB) - Report snapshot of current processes
  - Full featured `ps` command with all options
  - Supports BSD and UNIX syntax
  - Example: `psfull aux`, `psfull -ef`

- **topfull** (213 KB) - Display Linux processes in real-time
  - Interactive process viewer
  - CPU and memory usage monitoring
  - Process sorting and filtering

- **htop alternative** - More feature-rich than busybox top

### Memory and System Information
- **freefull** (37 KB) - Display memory usage
  - Shows total, used, free, shared, buffer, and cache memory
  - Example: `freefull -h` (human-readable)

- **uptimefull** (19 KB) - System uptime and load average
  - Shows how long the system has been running
  - Displays load averages

- **vmstatfull** (97 KB) - Virtual memory statistics
  - Report virtual memory, processes, CPU activity
  - Example: `vmstatfull 1` (update every second)

- **wfull** (82 KB) - Show who is logged on
  - Display logged-in users and their activity
  - Shows login time and current command

### Process Management
- **pgrepfull** (88 KB) - Lookup processes by name
  - Find processes based on name and attributes
  - Example: `pgrepfull sshd`

- **pkillfull** (88 KB) - Signal processes by name
  - Send signals to processes by name
  - Example: `pkillfull -9 process_name`

- **pidoffull** (75 KB) - Find process ID of running program
  - Alternative to `pidof` command
  - Example: `pidoffull sshd`

- **killfull** (17 KB) - Terminate processes by PID
  - Send signals to processes by PID
  - Example: `killfull -9 1234`

- **skillfull** (83 KB) - Send signal or report process status
  - Advanced process signaling utility

- **snicefull** (83 KB) - Renice running processes
  - Change process priority
  - Example: `snicefull +10 1234`

### Process Inspection
- **pmapfull** (88 KB) - Report memory map of a process
  - Display detailed memory map of a process
  - Example: `pmapfull 1234`

- **pwdxfull** (6.8 KB) - Report current working directory
  - Display current directory of a process
  - Example: `pwdxfull 1234`

### System Utilities
- **sysctlfull** (20 KB) - Configure kernel parameters at runtime
  - Read and write kernel parameters
  - Example: `sysctlfull -a` (show all)

- **slabtopfull** (30 KB) - Display kernel slab cache information
  - Real-time kernel slab cache monitoring
  - Useful for kernel debugging

- **tloadfull** (19 KB) - Graphical load average display
  - ASCII graph of system load average

- **watchfull** (26 KB) - Execute program periodically
  - Run a command repeatedly at intervals
  - Example: `watchfull -n 1 'psfull aux'`

## Installation

1. Enable the package in menuconfig:
   ```
   make menuconfig
   ```
   Navigate to: `Packages > Process utilities > procps-ng (full binaries)`

2. Select individual binaries you want to include (or select all)

3. Compile the firmware:
   ```
   make
   ```

## Usage Examples

### Basic Process Monitoring
```bash
# Show all processes with full details
psfull aux

# Show process tree
psfull -ejH

# Monitor processes in real-time
topfull

# Find process by name
pgrepfull nginx

# Kill process by name
pkillfull nginx
```

### Memory and System Info
```bash
# Display memory usage in human-readable format
freefull -h

# Show system uptime
uptimefull

# Monitor virtual memory statistics every second
vmstatfull 1

# Show who is logged in
wfull
```

### Advanced Process Analysis
```bash
# Show memory map of a process
pmapfull $(pidoffull sshd)

# Show current directory of a process
pwdxfull 1234

# Watch process list updates
watchfull -n 2 'psfull aux | head -20'

# Display kernel slab cache
slabtopfull
```

### System Configuration
```bash
# Show all kernel parameters
sysctlfull -a

# Set a kernel parameter
sysctlfull -w net.ipv4.ip_forward=1

# Read a specific parameter
sysctlfull net.ipv4.ip_forward
```

## Differences from BusyBox

The procps-full versions provide many more options and features compared to BusyBox:

| Feature | BusyBox | procps-full |
|---------|---------|-------------|
| `ps` options | Limited | Full BSD/UNIX syntax |
| `top` features | Basic | Advanced sorting, filtering |
| Memory details | Basic | Detailed breakdown |
| Process tree | Limited | Full hierarchy |
| Signal handling | Basic | All signals supported |
| Kernel parameters | - | Full sysctl support |

## Externalization

To save flash memory, you can externalize these binaries to USB storage:

1. Enable externalization in menuconfig:
   ```
   Advanced options > External > Freetz-NG packages
   ```

2. Select: `procps-ng (full binaries) - externalization`

3. The binaries will be stored on USB and symlinked to `/usr/bin/`

## Size Considerations

Individual binary sizes (stripped):
- Minimal set (ps, top, free): ~457 KB
- Common utilities (add vmstat, w, pgrep, pkill): ~846 KB  
- All binaries: ~1.3 MB

Choose only the binaries you need to minimize flash usage.

## Technical Details

### Build Configuration
- Compiled with `--enable-static --disable-shared`
- NLS (internationalization) disabled for smaller size
- Statically linked to avoid runtime dependencies
- Stripped to remove debug symbols

### Known Limitations
- **pidwait** is not included (requires kernel >= 5.3 with `pidfd_open` syscall)
- Static linking increases binary sizes compared to shared libraries
- Some features may not work on older kernels

## Troubleshooting

### Command not found
Make sure the binary is selected in menuconfig and the firmware was rebuilt.

### Permission denied
Ensure binaries have execute permissions:
```bash
chmod +x /usr/bin/*full
```

### Externalization not working
Check that USB storage is properly mounted and external directory is configured.

## See Also

- [htop](htop.md) - Interactive process viewer (alternative to topfull)
- [lsof](lsof.md) - List open files
- [strace](strace.md) - Trace system calls

## Version History

- **4.0.4** (Current)
  - Initial Freetz-NG integration
  - 18 binaries with "full" suffix
  - Externalization support

## Contributing

Report issues or improvements to the [Freetz-NG repository](https://github.com/Ircama/freetz-ng).

## License

procps-ng is licensed under GPL-2.0 and LGPL-2.1.
See the [official repository](https://gitlab.com/procps-ng/procps) for details.
