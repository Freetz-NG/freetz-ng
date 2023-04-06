/*

FIXME

---> tools/pseudo-host ... 
building ...
gcc [...] pseudo_wrappers.c
In file included from pseudo_ports.h:13,
                 from pseudo.h:160,
                 from pseudo_wrappers.c:30:
ports/linux/nostatx/portdefs.h:8:8: error: redefinition of ‘struct statx_timestamp’

*/

{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "freetz-env";
  targetPkgs = pkgs: (with pkgs; [
gnumake bison flex which pkg-config ncurses ncurses.dev perl autoconf automake
cmake gettext libtool openssl subversion sqlite sqlite.dev acl acl.dev libcap libcap.dev git unzip zlib zlib.dev zstd libelf
glibc_multi glibc_multi.dev # include/gnu/stubs-32.h
    ]) ++ (with pkgs.xorg; [
      /*
      libX11
      libXcursor
      libXrandr
      */
    ]);
  multiPkgs = pkgs: (with pkgs; [
      gcc
      /*
      udev
      alsa-lib
      */
    ]);
  runScript = "bash";


profile = ''
# disable hardening flags to fix busybox build
# archival/libarchive/decompress_lunzip.c:475:38: error: format not a string literal and no format arguments 
# disable all hardening flags
export NIX_HARDENING_ENABLE=""
# default hardening flags
#export NIX_HARDENING_ENABLE="pie pic format stackprotector fortify strictoverflow""
# disable some hardening flags: format
#export NIX_HARDENING_ENABLE="pie pic stackprotector fortify strictoverflow"
'';

}).env
