# Download failures during build (sources/tools)

<!-- See also: custom mirror configuration in menuconfig/.config -->

This page explains what to do when, during `make`, Freetz-NG stops with a download error (e.g. `ERROR 404`, `Download failed`, timeouts, etc.).

## First things first: don't panic

If you are **not a developer** and you have simply:

- cloned the https://github.com/Freetz-NG/freetz-ng repository locally,
- done the "normal" configuration with `make menuconfig`,
- started `make`,
- and then you hit a download error,

then in most cases it is **not a problem with your PC or the repository**. It is often a **temporary** issue (network, DNS, firewall, mirror overload, GitHub/SourceForge maintenance, etc.).

In these cases just try running `make` again (even multiple times, or at a different time). Besides,

- if you are a developer, please avoid changing settings if it used to work before.
- if you are running a GitHub Actions workflow and a job fails because a download did not succeed, it can be useful to use the option that reruns the failed job.

## How downloads work in Freetz-NG (in short)

During the build, Freetz-NG downloads source packages/archives **only when they are missing locally**.

- Downloaded files are stored in the `dl/` directory (in the repository root).
- If the required file is already present in `dl/` with the **exact expected name**, the download is skipped.

Practical consequence:

- if you copy (or manually download) the correct file into `dl/`, the error is often bypassed immediately.

## Special case: `tools-YYYY-MM-DD.tar.xz` (precompiled host-tools)

If the missing file looks like:

- `tools-2025-12-09.tar.xz`

then it is related to **precompiled host-tools**.

Common causes:

- you are building an older commit/branch that refers to a tarball that is no longer present on mirrors;
- a mirror/release has not published that asset yet (or it was removed).

What to do: rebuild the requested version with:

```sh
tools/dl-hosttools own
```

This creates a `dl/tools-YYYY-MM-DD.tar.xz` file matching the required date/version.

⚠️ **Warning**: This script **overwrites `.config`** with a minimal configuration. Any custom settings will be lost.

**Recommendation**: Before running `tools/dl-hosttools own`, save your configuration:

```sh
cp .config .config.backup
tools/dl-hosttools own
cp .config.backup .config  # Restore afterwards
```

Or use git:

```sh
git stash
tools/dl-hosttools own
git stash pop
```

## If you are a developer and the error is about the package you are introducing

If you are adding or modifying a package and the download error is about *that* package, the cause is often in the `*.mk` file:

- wrong or non-existing source URL
- wrong file name
- wrong checksum hash
- incorrect use of alias/macros (`@MIRROR`, `@SF`, `@GNU`, ...)

In that case:

- carefully re-check `$(PKG)_SITE`, `$(PKG)_SOURCE`, `$(PKG)_HASH`, and the download logic;
- avoid adding aliases unless they are really needed: simpler is usually more reliable.

## When it might be a "real" problem (not temporary)

Sometimes Freetz-NG may refer to a package that has become **obsolete** over time and whose source was removed or moved.

Typical signs:

- it fails consistently for days;
- it fails on all mirrors;
- other users report the same problem.

If after several attempts (`make` repeated at different times) the problem does not go away:

- open an issue at https://github.com/Freetz-NG/freetz-ng
- include:
  - the name of the missing file,
  - the full failure output,
  - the commit/branch you are using,
  - your operating system and version.

Temporary workaround:

- if you find the correct file version on the Internet (or on an alternative mirror), put it into `dl/` with the exact expected name.

## Developer notes: understanding the attempt order

The download script typically tries:

1. user-defined mirrors/URLs from the configuration (if present),
2. "official" package-specific URLs (and their possible aliases),
3. public mirrors (`@MIRROR` and similar) in an order that may include randomization.

Before adding new aliases or special logic in a makefile, it is useful to understand this flow well: often nothing "exotic" is required to get robust downloads.

## How to specify custom mirrors/URLs

You can add one or more custom mirrors via `make menuconfig`:

- `Download options` -> `Additional user-defined download site`

This option populates the `FREETZ_DL_SITE_USER` variable.

Format:

- if you want to specify multiple mirrors, **separate them with spaces** (not commas);
- each entry must be a base URL (without the file name), for example `https://my.server.tld/freetz`.

Example (as it appears in `.config`):

```sh
FREETZ_DL_SITE_USER="https://mirror1.example.org/freetz https://mirror2.example.org/freetz"
```

Note: the `main-url,mirror1,mirror2,...` syntax (comma-separated) is used for some URL lists internal to makefiles, not for user-defined mirrors in `FREETZ_DL_SITE_USER`.
