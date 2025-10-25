talvolta# PHP 8.4.1 (binary only)
  - Package: [master/make/pkgs/php/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/php/)
  - Maintainer: -

"*PHP is a widely-used general-purpose scripting language that is
especially suited for Web development and can be embedded into HTML.*"

## Available Binaries

The package provides:

| Binary | Location | Size | Description |
|--------|----------|------|-------------|
| **php** | `/usr/bin/php` | ~18 MB | PHP CLI (Command Line Interface) |
| **php-cgi** | `/usr/bin/php-cgi` | ~18 MB | PHP CGI for web servers |
| **php-fpm** | `/usr/sbin/php-fpm` | ~18 MB | PHP FastCGI Process Manager |

All binaries are stripped and dynamically linked against uClibc.

## Configuration Files

- `/etc/default.php/php.cfg` - Freetz-NG package configuration
- `/etc/default.php/php.ini` - PHP runtime configuration
- `/etc/default.php/php_config.def` - Default configuration template
- `/etc/init.d/rc.php` - Init script

## Available Extensions

The package includes the following compiled-in extensions: Core, curl, dom, fileinfo, ftp, hash, iconv, json, libxml, mbstring, opcache, pcre, pdo, session, simplexml, sockets, spl, sqlite3, standard, xml, xmlreader, xmlwriter, zlib

### Core Extensions
- **Core** - PHP core functionality
- **date** - Date and time functions
- **pcre** - Perl Compatible Regular Expressions (PCRE2)
- **reflection** - Reflection API
- **spl** - Standard PHP Library
- **standard** - Standard PHP functions

### String & Data Processing
- **ctype** - Character type checking
- **filter** - Data filtering and validation
- **hash** - Hashing functions (MD5, SHA, etc.)
- **iconv** - Character set conversion (GNU libiconv)
- **json** - JSON encoding/decoding
- **mbstring** - Multi-byte string functions

### XML Processing
- **libxml** - libXML2 support with HTML5 parser
- **dom** - DOM XML manipulation with RelaxNG support
- **simplexml** - SimpleXML interface
- **xml** - XML parser
- **xmlreader** - XMLReader streaming parser
- **xmlwriter** - XMLWriter streaming writer

### Web & Network
- **curl** - Client URL library
- **ftp** - FTP protocol support
- **session** - Session handling
- **sockets** - Low-level socket functions

### Database
- **pdo** - PHP Data Objects (PDO)
- **pdo_sqlite** - PDO driver for SQLite 3.x
- **sqlite3** - SQLite3 extension

### File & System
- **fileinfo** - File information (magic number detection)
- **posix** - POSIX functions
- **exif** - EXIF image metadata

### Process Control
- **pcntl** - Process Control functions
- **sysvsem** - System V semaphores
- **sysvshm** - System V shared memory
- **sysvmsg** - System V message queues

### Performance
- **opcache** - Zend OPcache for bytecode caching
- **zlib** - Compression functions

### Other
- **random** - Random number generation (CSPRNG)
- **tokenizer** - PHP tokenizer

## Configuration Options

When building PHP, you can enable/disable the following options via `make menuconfig`:

### Binary Selection
- **CLI** - Command-line interpreter (php)
- **CGI** - CGI binary (php-cgi)
- **FPM** - FastCGI Process Manager (php-fpm)

### Extension Options
- **CURL** - Enables HTTP/HTTPS/FTP client functionality (libcurl.so.4)
- **EXIF** - Enable EXIF support
- **FILEINFO** - Enable file information support
- **FILTER** - Enable filter extension
- **FTP** - Enable FTP support
- **GD** - Enables image manipulation and creation (libgd.so.3, requires libpng, libjpeg, libfreetype)
- **GETTEXT** - Enables internationalization and localization (libintl.so.8)
- **ICONV** - Enables character set conversion (uses uClibc built-in or libiconv.so.2)
- **LIBICONV** - Use GNU libiconv instead of uClibc iconv
- **LIBXML** - Enables XML parsing and manipulation (libxml2.so.16, required for DOM, SimpleXML, etc.)
- **MBSTRING** - Enables multi-byte string functions (libonig.so.5 for regex support)
- **MYSQLI** - Enables MySQL/MariaDB database access (libmysqlclient.so or libmariadb.so)
- **OPCACHE** - Enable OPcache bytecode cache
- **OPENSSL** - Enables cryptography and SSL/TLS (libssl.so.3, libcrypto.so.3)
- **PCNTL** - Enable process control functions
- **PDO** - Enable PHP Data Objects
- **PDO_SQLITE** - Enables SQLite database access via PDO (libsqlite3.so.3)
- **SESSION** - Enable session handling
- **SIMPLEXML** - Enables simplified XML parsing (requires libxml2.so.16)
- **SOCKETS** - Enable socket functions
- **SQLITE3** - Enables SQLite3 database access (libsqlite3.so.3)
- **SYSVIPC** - Enable System V IPC support (semaphores, shared memory, messages)
- **TOKENIZER** - Enable tokenizer
- **ZLIB** - Enables zlib compression/decompression (libz.so.1)
- **ZIP** - Enables ZIP archive handling (built-in with zlib support)

## Build Notes

### Library Dependencies

PHP 8.4.1 has the following library dependencies:

**Core Libraries (always required):**
- `libxml2.so.16` - XML parsing (with HTML5 support)
- `libpcre2-8.so` - Perl Compatible Regular Expressions
- `libonig.so.5` - Oniguruma regex library (for mbstring)
- `libintl.so.8` - Gettext internationalization
- `libz.so.1` - Zlib compression ⚠️ **Warning**: Required by Dropbear SSH. If externalized, Dropbear must be added to `/mod/etc/external.pkg` to prevent boot issues.

**Optional Libraries (enabled via menuconfig):**
- `libcurl.so.4` - HTTP/HTTPS/FTP client (CURL extension)
- `libgd.so.3` - Image manipulation (GD extension)
  - Requires: `libpng.so`, `libjpeg.so`, `libfreetype.so`
- `libiconv.so.2` - Character set conversion (ICONV extension, alternative to uClibc)
- `libsqlite3.so.3` - SQLite database (SQLite3 and PDO_SQLITE extensions)
- `libssl.so.3` & `libcrypto.so.3` - Cryptography and SSL/TLS (OpenSSL extension)
- `libmysqlclient.so` or `libmariadb.so` - MySQL/MariaDB (MySQLi extension)

All libraries can be externalized to save space in the main firmware image. See the "External processing" section in `make menuconfig`.

### libxml2 Dependency

PHP 8.4.1 requires a **full-featured libxml2** build with the following changes:

1. **HTML5 Parser Support**: The `FREETZ_LIB_libxml2_WITH_HTML` option is automatically selected when PHP is enabled.

2. **RelaxNG Support**: The libxml2 package has been rebuilt with `--with-minimum=no` instead of `--with-minimum=yes` to enable:
   - RelaxNG validation (`xmlRelaxNGValidateDoc`)
   - Schema validation support
   - Full XML feature set

This increases libxml2 size slightly but provides full XML/HTML processing capabilities required by PHP 8.4's DOM extension.

### GNU libiconv

When using the **LIBICONV** option, the package depends on GNU libiconv for character conversion instead of uClibc's built-in iconv. This provides better compatibility and more character set support.

### External Processing

PHP and its dependency libraries can be externalized to save flash space (approximately 20-25 MB for binaries + 4 MB for libraries).

**Configuration**: `make menuconfig` → Advanced options → External processing → External files → php

#### Library Externalization Options

By default, **PHP binaries are externalized** but **libraries remain in firmware** (`/usr/lib/freetz/`). You can optionally externalize libraries individually or all at once:

1. **No library externalization** (Default, Recommended):
   - PHP binaries → `/mod/external/usr/bin/php*`
   - Libraries → `/usr/lib/freetz/` (in firmware flash)
   - **Advantage**: All services (including Dropbear SSH) start immediately at boot
   - **Space cost**: ~4 MB in firmware flash

2. **Selective library externalization**:
   - Choose specific libraries to externalize
   - Useful for targeting large libraries (libxml2 ~1.5 MB, libiconv ~1.2 MB)
   
3. **Full library externalization**:
   - Enable "Externalize all PHP dependency libraries"
   - All libraries → `/mod/external/usr/lib/freetz/`
   - **Space saved**: ~4 MB in firmware flash
   - **⚠️ Important**: See warning below

#### ⚠️ Critical Warning: libz and Boot Dependencies

**`libz.so.1` is required by Dropbear SSH server** for compression support. If you externalize libz:

1. Dropbear will **fail to start at boot** (segmentation fault) because `/mod/external/` is not yet mounted
2. You will **lose SSH access** until external storage is mounted manually
3. **Solution**: Add dropbear to `/mod/etc/external.pkg`:
   ```bash
   echo "dropbear" >> /mod/etc/external.pkg
   ```
   This ensures dropbear starts AFTER external storage is mounted.

#### Boot Order and External Services

Services listed in `/mod/etc/external.pkg` are started **after** external storage is mounted:

- **Normal boot order**: 
  1. Mount filesystems
  2. Start core services (including Dropbear) ← Needs libraries in `/usr/lib/freetz/`
  3. Mount `/mod/external/` (if available)
  4. Start external services (from `/mod/etc/external.pkg`)

- **If libraries externalized without updating external.pkg**:
  - Services depending on externalized libraries will crash at boot
  - Example: Dropbear crashes if libz externalized but not in external.pkg
  - SSH access lost until manual intervention

**Best Practice**: Only externalize libraries if you understand the boot dependencies, or keep the default configuration (libraries in firmware, binaries externalized).

## Build Information

- **Toolchain**: GCC 13.4.0
- **C Library**: uClibc 1.0.55 (NPTL)
- **Interpreter**: `/usr/lib/freetz/ld-uClibc.so.1`
- **Linking**: Dynamic (requires shared libraries)

## Links

- [PHP Official Site](https://www.php.net/)
- [PHP 8.4 Release Notes](https://www.php.net/releases/8.4/en.php)
- [PHP 8.4 Documentation](https://www.php.net/manual/en/)
- [PHP 8 Migration Guide](https://www.php.net/manual/en/migration80.php)
