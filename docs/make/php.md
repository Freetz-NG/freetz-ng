# PHP 8.4.1 (binary only)
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
- **CURL** - Enable cURL support
- **EXIF** - Enable EXIF support
- **FILEINFO** - Enable file information support
- **FILTER** - Enable filter extension
- **FTP** - Enable FTP support
- **GD** - Enable GD image library (if available)
- **GETTEXT** - Enable gettext support
- **ICONV** - Enable iconv character conversion
- **LIBICONV** - Use GNU libiconv instead of uClibc iconv
- **LIBXML** - Enable libXML support (required for DOM, SimpleXML, etc.)
- **MBSTRING** - Enable multi-byte string support
- **MYSQLI** - Enable MySQLi support (requires MySQL)
- **OPCACHE** - Enable OPcache bytecode cache
- **OPENSSL** - Enable OpenSSL support
- **PCNTL** - Enable process control functions
- **PDO** - Enable PHP Data Objects
- **PDO_SQLITE** - Enable PDO SQLite driver
- **SESSION** - Enable session handling
- **SIMPLEXML** - Enable SimpleXML
- **SOCKETS** - Enable socket functions
- **SQLITE3** - Enable SQLite3 support
- **SYSVIPC** - Enable System V IPC support (semaphores, shared memory, messages)
- **TOKENIZER** - Enable tokenizer
- **ZLIB** - Enable zlib compression

## Build Notes

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
