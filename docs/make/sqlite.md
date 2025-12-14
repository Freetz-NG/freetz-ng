# SQLite 3.50.4 (binary and library)
  - Homepage: [https://www.sqlite.org](https://www.sqlite.org)
  - Manpage: [https://www.sqlite.org/docs.html](https://www.sqlite.org/docs.html)
  - Changelog: [https://www.sqlite.org/changes.html](https://www.sqlite.org/changes.html)
  - Repository: [https://www.sqlite.org/src/timeline](https://www.sqlite.org/src/timeline)
  - Package: [master/make/pkgs/sqlite/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/sqlite/)
  - Maintainer: -

## Source
- Version: 3.50.4
- Source URL: https://www.sqlite.org/2025/sqlite-autoconf-3500400.tar.gz
- Hash: a3db587a1b92ee5ddac2f66b3edb41b26f9c867275782d46c3a088977d6a5b18

## Build Notes
SQLite 3.50.4 uses autosetup (Tcl-based) instead of GNU autotools for configuration. This affects the available configure options:
- Unsupported options like `--cache-file`, `--target`, `--disable-nls` are ignored or cause errors.
- The build system creates files directly in the source directory (e.g., `sqlite3`, `libsqlite3.so`) rather than in `.libs/`. The `make install` then copies them to the staging directory, from where Freetz installs them to the target root filesystem.
- Installation uses `/usr/local` prefix by default, requiring adjustments in `sqlite.mk` for staging paths.

## Externalization
Both the SQLite CLI (`sqlite3`) and the library (`libsqlite3.so`) can be externalized:
- Binary: `/usr/bin/sqlite3` (~328 KB)
- Library: `/usr/lib/freetz/libsqlite3.so.0` (symlink to `libsqlite3.so.3.50.4`, ~1.3 MB)
