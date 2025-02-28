[//]: # ( Do not edit any section except DEVEL. )
# CHANGELOG
Latest changes

- Freetz-NG
  * [devel](#devel)
  * [ng24080](#ng24080)
  * [ng24040](#ng24040)
  * [ng23110](#ng23110)
  * [ng23080](#ng23080)
  * [ng23050](#ng23050)
  * [ng23030](#ng23030)
  * [ng22100](#ng22100)
  * [ng22070](#ng22070)
  * [ng22040](#ng22040)
  * [ng21090](#ng21090)
  * [ng21030](#ng21030)
  * [ng21010](#ng21010)
  * [ng20120](#ng20120)

- Freetz
  * [Freetz-2.0](#freetz-20)
  * [Freetz-1.2](#freetz-12)
  * [Freetz-1.1](#freetz-11)
  * [Freetz-1.1.4](#freetz-114)
  * [Freetz-1.1.3](#freetz-113)
  * [Freetz-1.1.2](#freetz-112)
  * [Freetz-1.1.1](#freetz-111)
  * [Freetz-1.1.0](#freetz-110)
  * [Freetz-1.0.1](#freetz-101)
  * [Freetz-1.0](#freetz-10)

- DS 2.6
  * [ds26-15.2](#ds26-152)
  * [ds26-15.1](#ds26-151)
  * [ds26-15.0](#ds26-150)
  * [ds26-14.4](#ds26-144)
  * [ds26-14.3](#ds26-143)

- DS 2.4
  * [ds-0.2.9_26-14.2](#ds-029_26-142)
  * [ds-0.2.9_26-14.1-p2](#ds-029_26-141-p2)
  * [ds-0.2.9_26-14.1-p1](#ds-029_26-141-p1)
  * [ds-0.2.9_26-14.1](#ds-029_26-141)
  * [ds-0.2.9_26-14.0](#ds-029_26-140)

<br>

### devel

 - Build system:
   * binutils (kernel) 2.18/2.22/2.23.2/2.24/2.25.1/2.26.1/2.31.1/2.36.1
   * binutils (target) 2.22/2.23.2/2.24/2.25.1/2.26.1/2.31.1/2.36.1/2.43.1
   * gcc (kernel) 3.4.6/4.6.4/4.7.4/4.8.5/5.5.0/8.3.0/8.4.0/9.3.0/9.4.0
   * gcc (target) 4.6.4/4.7.4/4.8.5/4.9.4/5.5.0/8.3.0/8.4.0/9.3.0/13.3.0/13.4.0/14.2.0
   * uClibc 0.9.28/0.9.29/0.9.32.1/0.9.33.2/1.0.14/1.0.51

 - Host tools:
   * busybox 1.37.0
   * ca-bundle 2024-12-31
   * Ccache 4.10.2
   * cmake 3.31.6
   * fakeroot 1.37
   * kconfig 6.13
   * lzma2 5.6.4
   * meson 1.7.0
   * openssl 3.0.16
   * precompiled host-tools 2025-02-19
   * precompiled toolchains r25112/r25157
   * prelink 20131005
   * python 3.12.9
   * u-boot 2025.01

 - AVM sources:
   * 3000 ax  7.41 - 4.4.271
   * 4040     8.00 - 4.4.271
   * 4050     7.58 - 4.4.271
   * 4050     8.02 - 4.4.271
   * 4060     8.02 - 4.4.271
   * 5530     8.00 - 4.9.276
   * 5590     8.00 - 4.4.271
   * 5690 pro 7.62 - 5.4.213
   * 5690 pro 8.01 - 5.4.213
   * 6591     8.00 - 5.15.153
   * 7510     7.30 - 4.4.60 (corrupt)
   * 7510     8.00 - 4.4.271
   * 7530     8.00 - 4.4.271
   * 7530 ax  8.03 - 4.19.183
   * 7590 ax  8.00 - 4.9.325
   * 7690     8.01 - 5.4.213

 - Patches:
   * Various Fritzos 8.0 related changes
   * New Patch: Hide unsecure settings from cockpit
   * New Patch: Hide internet visualisation from cockpit
   * New Patch: Hide internet details from cockpit
   * New Patch: Hide homenet details from cockpit
   * New Patch: Hide update check from cockpit

 - Packages:
   * Apache2 2.4.62
   * ACME.sh 3.1.0
   * Atop 2.11.0
   * AVM-rules 1.00
   * BIND 9.11.37/9.20.5
   * BusyBox 1.27.2/1.37.0
   * CA-bundle 2024-12-31
   * Curl 8.12.1
   * Dropbear 2024.86
   * Fontconfig 2.16.0
   * Git 2.47.0
   * htpdate 2.0.0
   * ImageMagick 7.1.1-44
   * iPerf3 3.3/3.18
   * Lighttpd 1.4.77
   * mc (Midnight Commander) 4.8.31/4.8.32
   * Mosquitto 2.0.20
   * Nano 8.3
   * OpenSSH 9.3p2/9.9p2
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1w/3.0.16
   * radvd 1.9.3/2.20
   * rsync 3.4.1
   * RPCBind 1.2.7
   * RRDtool 1.2.30/1.9.0
   * S-Lang 2.3.3
   * Screen 4.9.1/5.0.0
   * SQLite 3.40.1/3.47.1
   * sslh 2.1.4
   * strace 4.9/5.0/6.13
   * Stunnel 5.74
   * Subversion 1.9.12/1.14.5
   * tmux 3.5a
   * Tor 0.4.8.14
   * Tree 1.8.0/2.2.1
   * UltraVNC Repeater 014
   * uMurmur 0.2.20/0.3.0
   * Unbound 1.22.0
   * VLMCSD svn1113
   * xsltproc 1.1.42
   * XZ 5.6.4

 - Libraries:
   * cairo 1.18.2
   * expat 2.6.4
   * FreeType 2.13.3
   * fribidi 1.0.16
   * glib2 2.32.4/2.81.2
   * harfbuzz 10.3.0
   * libcap 2.49/2.73
   * libcap-ng 0.8.5
   * libdeflate 1.23
   * libexif 0.6.25
   * libffi 3.4.7
   * libmaxminddb-1.12.2
   * libnettle 3.10.1
   * libpng 1.6.46
   * libssh2 1.11.1
   * libtirpc 1.3.6
   * liburcu 0.15.0
   * libuv 1.44.2/1.50.0
   * libxml2 2.13.6
   * lz4 1.10.0
   * mbedTLS 2.7.19/2.28.9
   * pango 1.56.1
   * pcre2 10.45

 - Firmware updates:
   * Please see [FIRMWARES](FIRMWARES.md) for the list of currently supported devices and firmwares.

### ng24080

 - Build system:
   * uClibc 0.9.28/0.9.29/0.9.32.1/0.9.33.2/1.0.14/1.0.49
   * gcc 3.4.6/4.6.4/4.7.4/4.8.5/5.5.0/8.3.0//8.4.0/9.3.0/13.3.0/14.1.0

 - Host tools:
   * automake 1.17
   * ca-bundle 2024-07-02
   * cmake 3.30.1
   * cpio 2.15
   * fakeroot 1.35.1
   * kconfig 6.10
   * meson 1.5.1
   * ncurses 6.5
   * ninja 1.12.1
   * openssl 3.0.14
   * pkgconf 2.2.0
   * precompiled host-tools 2024-07-29
   * precompiled toolchains r23751
   * python 3.12.4
   * python3-packaging 24.1
   * u-boot 2024.07
   * wget 1.24.5
   * xz 5.6.2

 - AVM sources:
   * 7690 7.61 - 5.4.213

 - Patches:
   * Enforce /tmp/ permissions: Changes /var/tmp/ permissions back to 1777 after AVM sets 755.
   * Various Fritzos 8.0 related changes

 - Packages:
   * Apache2 2.4.62
   * Atop 2.10.0
   * AutoFS 5.0.5/5.1.9
   * BIND 9.11.37/9.18.28
   * BIRD 1.6.8/2.15.1
   * Bftpd 6.2
   * bvi 1.4.2
   * CA-bundle 2024-07-02
   * CCID 1.5.5
   * Curl 8.9.1
   * dtach 0.9
   * Dropbear 2024.85
   * endlessh 1.0
   * FFmpeg 5.1.4
   * Fontconfig 2.15.0
   * Git 2.45.2
   * HAProxy 2.6.17
   * ImageMagick 7.1.1-34
   * iPerf3 3.3/3.17.1
   * Lighttpd 1.4.76
   * Lynx 2.9.2
   * minisatip 1.0.4/1.3.6
   * Mosquitto 2.0.18
   * Nano 8.1
   * ncurses 6.5
   * ncursesw 6.5
   * Nmap 4.76/5.51/7.95
   * OpenSSH 9.3p2/9.8p1
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1w/3.0.14
   * OpenVPN 2.4.12/2.5.11/2.6.13
   * PCP client 1c783fb 
   * PCSC-lite 1.9.5/2.1.0
   * psl 0.21.5
   * socat 1.8.0.0
   * sslh 2.1.2
   * rsync 3.3.0
   * strace 4.9/5.0/6.10
   * Sudo 1.9.15p5
   * SQLite 3.45.3
   * Tinyproxy 1.11.2
   * Tor 0.4.8.12
   * Transmission 3.00/4.0.6
   * Unbound 1.20.0
   * UnRAR 6.1.7/7.0.9
   * usb.ids c70eea490a
   * Whois 5.5.23
   * xsltproc 1.1.41
   * XZ 5.6.2

 - Libraries:
   * attr 2.5.2
   * fribidi 1.0.15
   * glib2 2.32.4/2.81.0
   * harfbuzz 9.0.0
   * libidn 1.42
   * libmaxminddb 1.10.0
   * libpng 1.6.43
   * libtirpc 1.3.5
   * libxml2 2.13.3
   * pango 1.54.0
   * pcre2 10.44
   * pixman 0.43.4

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng24080/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng24040

 - Build system:
   * binutils 2.24.x/2.25.x/2.26.x/2.31.x/2.36.x/2.42.x
   * Ccache 4.9.1
   * uClibc 0.9.28/0.9.29/0.9.32.1/0.9.33.2/1.0.14/1.0.47

 - Host tools:
   * autoconf 2.72
   * cmake 3.29.0
   * dos2unix 7.5.2
   * fakeroot 1.34
   * kconfig 6.8
   * meson 1.4.0
   * ncftp 3.2.7
   * netkit-ftp 0.17-35
   * openssl 3.0.13
   * pkgconf 2.1.1
   * precompiled host-tools 2024-03-29
   * precompiled toolchains r23270
   * python 3.11.8
   * tar 1.35
   * u-boot 2024.01
   * xz 5.4.6

 - AVM sources:
   * 6670 7.61 - 5.15.111

 - Packages:
   * BIND 9.11.37/9.16.48
   * BIRD 1.6.8/2.15
   * CA-bundle 2024-03-11
   * CCID 1.5.4
   * Curl 8.8.0
   * Dnsmasq 2.80/2.90
   * Git 2.44.0
   * HAProxy 2.6.16
   * htop 1.0.3/3.3.0
   * iPerf3 3.3/3.16
   * iptables 1.4.11.1/1.4.21/1.6.2/1.8.10
   * jpeg 9f
   * jq 1.7.1
   * LCD4linux 3fce054e
   * Lighttpd 1.4.75
   * Lua 5.1.5/5.4.6
   * Lynx 2.9.0
   * mc (Midnight Commander) 4.8.31
   * minicom 2.9
   * minisatip 1.0.4/1.3.4
   * NcFTP 3.2.7
   * OpenSSH 9.3p2/9.7p1
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1w/3.0.13
   * OpenVPN 2.4.12/2.5.10/2.6.10
   * PCSC-lite 1.9.5/2.0.1
   * ProxyChains-NG 4.17
   * pyLoad 0.4.20/78162d75
   * socat 1.7.4.4
   * Stunnel 5.72
   * Subversion 1.9.12/1.14.3
   * SQLite 3.45.2
   * strace 4.9/5.0/6.8
   * tmux 3.4
   * Tor 0.4.8.10
   * Transmission 3.00/4.0.5
   * Unbound 1.19.3
   * UnRAR 6.1.7/7.0.7
   * vermagic D1W0U
   * Vim 9.1.0181
   * Wget 1.24.5
   * xsltproc 1.1.39
   * XZ Utils 5.4.6

 - Libraries:
   * cairo 1.18.0
   * expat 2.6.2
   * harfbuzz 8.4.0
   * libdeflate 1.20
   * libffi 3.4.6
   * libid3tag 0.16.3
   * libmaxminddb 1.9.1
   * libonig 6.9.9
   * libpng 1.6.42
   * libtirpc 1.3.4
   * libusb1 1.0.23/1.0.27
   * libuv 1.44.2/1.48.0
   * libxml2 2.12.6
   * mbedTLS 2.7.19/2.28.8
   * pango 1.52.1
   * pcre2 10.43
   * zlib 1.3.1

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng24040/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng23110

 - Build system:
   * Ccache 4.8.3

 - Host tools:
   * cmake 3.27.7
   * dtc 1.7.0
   * kconfig 6.6
   * meson 1.2.2
   * openssl 3.0.12
   * pkgconf 2.0.3
   * precompiled host-tools 2023-11-03
   * pseudo 1.9.0 oe-core cc1f616
   * python 3.11.6
   * u-boot 2023.10
   * xz 5.4.5

 - AVM sources:
   * 1240 ax 7.57 - 4.4.271

 - Packages:
   * ACME.sh 3.0.7 (letsencrypt)
   * Apache2 2.4.58
   * Atop 2.9.0
   * BIND 9.11.37/9.16.43
   * CA-bundle 2023-08-22
   * Curl 8.4.0
   * dtc 1.7.0
   * FFmpeg 5.1.3
   * ftdi1 1.5
   * Git 2.42.0
   * ImageMagick 7.1.1-20
   * iPerf3 3.3/3.15
   * Lighttpd 1.4.72
   * mc (Midnight Commander) 4.8.30
   * mysql-connector 8.0.21
   * Nmap 4.76/5.51/7.94
   * NZBGet 21.1/21.4-rc2
   * OpenSSH 9.3p2/9.5p1
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1w/3.0.12
   * PCSC-lite 2.0.0
   * ProxyChains-NG 4.16
   * Screen 4.9.1
   * SQLite 3.43.2
   * sslh 2.0.1
   * strace 4.9/5.0/6.6
   * Stunnel 5.71
   * Tor 0.4.8.7
   * Transmission 3.00/4.0.4
   * Unbound 1.18.0
   * UnRAR 6.1.7/6.2.12
   * Vim 9.0.1872
   * XZ Utils 5.4.5

 - Libraries:
   * apr 1.7.4
   * apr-util 1.6.3
   * FreeType 2.13.2
   * glib2 2.32.4/2.76.5
   * harfbuzz 8.2.2
   * libconfuse 3.3
   * fribidi 1.0.13
   * libxml2 2.11.5
   * mbedTLS 2.7.19/2.28.5
   * neon 0.30.2/0.32.5
   * pango 1.51.0
   * serf 1.3.10
   * uClibc++ 0.2.6-6687fc92

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng23110/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng23080

 - Build system:
   * binutils 2.24.x/2.25.x/2.26.x/2.31.x/2.36.x/2.41.x
   * Ccache 4.8.2
   * gcc 3.4.6/4.6.4/4.7.4/4.8.5/5.5.0/8.3.0/9.3.0/13.2.0
   * uClibc 0.9.28/0.9.29/0.9.32.1/0.9.33.2/1.0.14/1.0.44

 - Host tools:
   * autoconf 2.71
   * automake 1.16.5
   * cmake 3.27.3
   * fakeroot 1.32.1
   * kconfig 6.4
   * libtool 2.4.7
   * m4 1.4.19
   * meson 1.2.1
   * make 4.4.1
   * openssl 3.0.10
   * pkgconf 2.0.1
   * precompiled host-tools 2023-08-18
   * precompiled toolchains r22199
   * python 3.11.4
   * u-boot 2023.07.02
   * xz 5.4.4

 - AVM sources:
   * 1200 ac 7.50 - 4.4.271
   * 1200 ax 7.56 - 4.4.271
   * 2400    7.27 - 4.4.60
   * 2400    7.50 - 4.4.271
   * 4040    7.56 - 4.4.271
   * 4060    7.30 - 4.4.60
   * 4060    7.56 - 4.4.271
   * 6000    7.56 - 4.4.271
   * 6590    7.56 - 2.6.39.4
   * 6591    7.56 - 4.9.279 (delta 6591 7.50)
   * 6690    7.29 - 4.9.250
   * 6690    7.56 - 4.9.279
   * 6820    7.56 - 4.4.271
   * 7490    7.56 - 3.10.107
   * 7510    7.56 - 4.4.271
   * 7530 ac 7.56 - 4.4.271
   * 7530 ax 7.56 - 4.19.183 (corrupt)
   * 7590    7.56 - 4.9.325
   * Gateway 7.54 - 4.4.271

 - Packages:
   * ACME.sh 3.0.6 (letsencrypt)
   * Bftpd 6.1
   * BIND 9.11.37/9.16.42
   * CA-bundle 2023-05-30
   * Curl 8.2.1
   * Git 2.41.0
   * HAProxy 2.6.15
   * iPerf3 3.3/3.14
   * minidlna 1.3.3
   * Net-SNMP 5.9.4
   * NZBGet 21.1/21.4-rc1
   * OpenSSH 9.4p1
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1v/3.0.10
   * OpenVPN 2.4.12/2.5.9/2.6.6
   * pptp 1.10.0
   * psl 0.21.2
   * pyLoad 0.4.20/9b358adf
   * Smartmontools 7.4
   * SQLite 3.42.0
   * strace 4.9/5.0/6.4
   * Stunnel 5.70
   * Sudo 1.9.14p3
   * Tor 0.4.7.14
   * Transmission 3.00/4.0.3
   * Tree 1.8.0/2.1.1
   * UnRAR 6.1.7/6.2.8
   * vnstat 1.18
   * Wget GNU 1.21.4
   * wput 0.6.2
   * xsltproc 1.1.38
   * XZ Utils 5.4.4

 - Libraries:
   * FreeType 2.13.1
   * libdeflate 1.18
   * glib2 2.32.4/2.76.4
   * harfbuzz 8.1.1
   * libnettle 3.9.1
   * libpng 1.6.40
   * libssh2 1.11.0
   * libuv 1.44.2/1.46.0
   * mbedTLS 2.7.19/2.28.4
   * zlib 1.3

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng23080/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng23050

 - Build system:
   * Ccache 4.8.1
   * uClibc-ng 1.0.43

 - Host tools:
   * busybox 1.36.1
   * cmake 3.27.0
   * kconfig 6.3
   * meson 1.1.1
   * precompiled host-tools 2023-05-28
   * precompiled toolchains r21480
   * python 3.11.3
   * xz 5.4.3

 - AVM sources:
   * 5530 7.50 - 4.9.276
   * 5590 7.50 - 4.4.271

 - Patches:
   * patch VLAN: re-enables vlan config of voip in ata-mode

 - Packages:
   * BusyBox 1.36.1
   * CCID 1.5.2
   * Curl 8.1.1
   * davfs2 1.5.2/1.7.0
   * HAProxy 2.6.10
   * iPerf3 3.3/3.13
   * Lighttpd 1.4.71
   * OpenVPN 2.4.12/2.5.9/2.6.4
   * strace 4.9/5.0/6.3
   * tcpdump 4.1.1/4.99.4
   * XZ Utils 5.4.3

 - Libraries:
   * FreeType 2.13.0
   * glib2 2.32.4/2.76.2
   * harfbuzz 7.3.0
   * libcap 2.49/2.69
   * libgcrypt 1.10.2
   * libgpg-error 1.47
   * libnettle 3.9
   * libpcap 1.1.1/1.10.4
   * libuv 1.45.0
   * libxml2 2.11.4
   * pango 1.50.14
   * SQLite 3.41.2

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng23050/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng23030

 - Known problems:
   * Loading build kernel modules may work or do not. You'll notice.

 - Build system:
   * Ccache 4.7.4
   * Cmake support
   * Meson support

 - Host tools:
   * busybox 1.36.0
   * cmake 3.25.2
   * fakeroot 1.31
   * fastjar 0.98
   * genext2fs 1.5.0-3b99f4a4
   * gperf 3.1
   * kconfig 6.2
   * meson 1.0.0
   * mklibs 0.1.45
   * ncurses 6.4
   * ninja 1.11.1
   * patchelf 0.14.5/0.15.0
   * precompiled host-tools 2023-02-20
   * prelink 20130503
   * pseudo 1.9.0 oe-core c9670c2
   * python 3.11.2
   * sed 4.9
   * sfk 1.9.8.2
   * u-boot 2023.01
   * xz 5.4.1

 - Patches:
   * remove AVMCOUNTERD: collects some data for you
   * remove AVM-WireGuard: VPN even with IPv6 support!!1
   * Various Fritzos 7.5 related changes

 - Packages:
   * ACME.sh 3.0.5 (letsencrypt)
   * Apache2 2.4.57
   * BIND 9.11.37/9.16.38
   * BIRD 1.6.8
   * BusyBox 1.36.0
   * CA-bundle 2023-01-10
   * CCID 1.5.1
   * classpath 0.99
   * Curl 7.88.1
   * dehydrated 0.7.1 (letsencrypt)
   * DejaVu Fonts TTF 2.37
   * Dnsmasq 2.80/2.89
   * Dropbear 2022.83
   * Fontconfig 2.14.2
   * getdns 1.7.3
   * Git 2.40.0
   * HAProxy 2.6.9
   * htop 1.0.3/3.2.2
   * htpdate 1.3.7
   * IGMPproxy 0.4
   * ImageMagick 7.1.0-57
   * jamvm 2.0.0
   * Knock 0.8
   * libffi 3.4.4
   * libpcap 1.1.1/1.10.3
   * Lighttpd 1.4.69
   * Lua 5.1.5/5.4.4
   * Nano 7.2
   * ncurses 6.4
   * ncursesw 6.4
   * OpenSSH 9.3p1
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1t/3.0.8
   * OpenVPN 2.4.12/2.5.9/2.6.1
   * PCSC-lite 1.9.9
   * RPCBind 1.2.6
   * RRDtool 1.2.30/1.8.0
   * Swiss File Knife 1.9.8.2
   * strace 4.9/5.0/6.2
   * SQLite 3.41.1
   * Stunnel 5.69
   * Sudo 1.9.13p3
   * tcpdump 4.1.1/4.99.3
   * Tor 0.4.7.13
   * Unbound 1.17.1
   * UnRAR 6.1.7/6.2.6
   * xsltproc 1.1.37
   * XZ Utils 5.4.1

 - Libraries:
   * cairo 1.17.8
   * expat 2.5.0
   * fribidi 1.0.12
   * glib2 2.32.4/2.75.3
   * harfbuzz 7.0.0
   * libcap-ng 0.8.3
   * libctlmgr 1.0
   * libev 4.33
   * libidn 1.41
   * libgpg-error 1.46
   * libmultid 1.0
   * libpng 1.6.39
   * libusb-compat 0.1.8
   * libxml2 2.10.3
   * mbedTLS 2.7.19/2.28.3
   * neon 0.30.2/0.32.4
   * openjp2 2.5.0
   * pango 1.50.12
   * pcre2 10.42
   * pixman 0.42.2

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng23030/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng22100

 - Known problems:
   * Loading build kernel modules may work or do not. You'll notice.

 - Build system:
   * ccache 4.6.3

 - Host tools:
   * kconfig 6.0
   * precompiled host-tools 2022-10-12
   * xz 5.2.7

 - Packages & libs:
   * BIND 9.11.37/9.16.33
   * CA-bundle 2022-10-11
   * Cifsmount 7.0
   * Curl 7.85.0
   * Dnsmasq 2.80/2.87
   * expat 2.4.9
   * FFmpeg 5.1.2
   * FreeType 2.12.1
   * FUSE 2.9.9
   * gettext 0.21.1
   * Git 2.38.0
   * GnuTLS 3.7.8
   * HAProxy 2.6.6
   * htpdate 1.3.6
   * iPerf3 3.12
   * jpeg 9e
   * libattr 2.5.1
   * libcap 2.49/2.66
   * liblz4 1.9.4
   * libmaxminddb 1.7.1
   * libnettle 3.8.1
   * libpopt 1.19
   * libtasn1 4.19.0
   * libtirpc 1.3.3
   * libuv 1.44.2
   * Lighttpd 1.4.67
   * mbed TLS 2.7.19/2.28.1
   * minidlna 1.3.2
   * Nano 6.4
   * Net-SNMP 5.9.3
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1q/3.0.5
   * rsync 3.2.6
   * Screen 4.9.0
   * SQLite 3.39.4
   * strace 4.9/5.0/5.19
   * Stunnel 5.68
   * Tor 0.4.7.9
   * uClibc-ng 1.0.42
   * Unbound 1.16.6
   * UNFS3 0.9.23
   * usb.ids a5edeafb60
   * Vim 9.0.0049
   * XZ Utils 5.2.7
   * zlib 1.2.13

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng22100/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng22070

 - Known problems:
   * Replace kernel does not work for most latest firmware versions.
   * Loading build kernel modules may work or do not. You'll notice.

 - Build system:
   * binutils 2.24.x/2.25.x/2.26.x/2.31.x/2.36.x/2.38.x
   * ccache 4.6.1
   * gcc 3.4.6/4.6.4/4.7.4/4.8.5/5.5.0/8.3.0/9.3.0
   * precompiled host-tools 2022-06-27
   * precompiled toolchains r19900

 - Host tools:
   * fakeroot 1.29
   * Haserl 0.9.36
   * kconfig 5.18
   * patchelf 0.14.5
   * U-Boot 2022.04
   * yf-bootmanager 0.8.6 87ee8c3
   * yf-fit_tools 0.2 24011d3

 - Packages & libs:
   * ACME.sh 3.0.4 (letsencrypt)
   * Apache 2.4.54
   * atop 2.7.1
   * BIND 9.11.37/9.16.29
   * CA-bundle 2022-04-26
   * Curl 7.84.0
   * Dante 1.4.3
   * dtc 1.6.1
   * Git 2.37.0
   * HAProxy 2.6.1
   * htpdate 1.3.4
   * htop 1.0.3/3.2.1
   * juis_check 1.2
   * libcap 2.49/2.64
   * libgcrypt 1.10.1
   * libgpg-error 1.45
   * libneon 0.30.2/0.32.2
   * libpcap 1.1.1/1.10.1
   * libxml 2.9.14
   * LCD4linux 9d4e4b7-git
   * lighttpd 1.4.65
   * ltrace 0.7.3checkpoint1-git
   * mc (Midnight Commander) 4.8.29
   * mini-snmpd 1.6
   * MTR 0.80/0.95
   * Nano 6.3
   * Net-SNMP 5.9.1
   * NZBGet 21.1
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1q/3.0.5
   * OpenVPN 2.4.12/2.5.7
   * PCSC-lite 1.9.8
   * pcre2 10.40
   * Privoxy 3.0.34
   * radvd 1.9.3/2.19
   * ser2net 3.5.4
   * Smartmontools 7.3
   * strace 4.9/5.0/5.18
   * Stunnel 5.64
   * Sudo 1.9.13
   * SQLite 3.39.0
   * tcpdump 4.1.1/4.99.1
   * tmux 3.3a
   * Tinyproxy 1.11.0
   * Tor 0.4.7.8
   * uClibc-ng 1.0.41
   * Unbound 1.16.0
   * UnRAR 6.1.7
   * Vim 8.2.5052
   * Wget GNU 1.21.3

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng22070/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng22040

 - Known problems:
   * Replace kernel does not work for most latest firmware versions.
   * Loading build kernel modules may work or do not. You'll notice.

 - Build system:
   * binutils 2.24.x/2.25.x/2.26.x/2.31.x/2.37.x
   * ccache 4.6
   * precompiled host-tools 2022-04-17
   * precompiled toolchains r18095/r18877/r18922

 - Host tools:
   * BusyBox 1.34.1
   * fakeroot 1.28-1
   * fitimg 0.7.2
   * kconfig 5.17
   * ncurses 6.3
   * patchelf 0.13.1
   * pseudo 1.9.0 oe-core 0cda3ba
   * yf-bootmanager 0.8.5 dd1e066
   * yf-juis 0.5 049839b
   * yf-signimage 1.0.1 78a5689
   * yourfritz 5e33421

 - Patches:
   * remove smd-httpd: http server on port 81 without config (broadcom devices)
   * yf-bootmanager 0.8.3

 - Packages & libs:
   * ACME.sh 3.0.2 (letsencrypt)
   * Apache 2.4.53
   * AutoFS 5.0.5/5.1.8
   * BIND 9.16.27
   * Bip 0.9.2
   * BusyBox 1.34.1
   * BusyBox 1.35.0
   * CA-bundle 2022-03-29
   * CCID 1.5.0
   * cifs-utils 6.15
   * Curl 7.82.0
   * davfs2 1.5.2/1.6.1
   * dropbear 2022.82
   * expat 2.4.8
   * git 2.35.3
   * HAProxy 2.5.5
   * iksemel 3.1.1
   * libcap 2.63
   * libexif 0.6.24
   * libgsasl 1.10.0
   * libgcrypt 1.9.4
   * libgpg-error 1.43
   * libidn 1.38
   * libmaxminddb 1.6.0
   * libneon 0.32.1
   * libnfsidmap 0.27
   * libudns 0.4
   * libusb1 1.0.23/1.0.26
   * libuv 1.44.1
   * lighttpd 1.4.64
   * LCD4linux e2cfdc5-git
   * mbed TLS 2.7.19/2.28.0
   * minicom 2.8
   * Nano 6.0
   * ncurses 6.3
   * ncursesw 6.3
   * OpenSSH 9.0p1
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1n/3.0.2
   * OpenVPN 2.4.12/2.5.6
   * pcre 8.45
   * pcre2 10.39
   * PCSC-lite 1.9.5
   * socat 1.7.4.2
   * SQLite 3.38.2
   * sslh 1.22c
   * strace 4.9/5.0/5.17
   * Stunnel 5.60
   * Subversion 1.9.12/1.14.2
   * Sundtek DVB driver 130210.134617/170310.204343/210803.071224
   * tinc 1.0.36/1.1pre18
   * tinyproxy 1.11.0
   * Tor 0.4.6.10
   * uClibc-ng 1.0.40
   * Unbound 1.15.0
   * UnRAR 6.1.4
   * utf8proc 2.7.0
   * Wget GNU 1.21.2
   * wireguard-linux-compat 1.0.20220627
   * wireguard-tools 1.0.20210914
   * zlib 1.2.12

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng22040/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng21090

 - Known problems:
   * Replace kernel does not work for most latest firmware versions.
   * Loading build kernel modules may work or do not. You'll notice.

 - Build system:
   * binutils:
      + add support for binutils-2.24.x/2.25.x/2.26.x/2.31.x/2.36.x
   * ccache 4.4.1
   * precompiled host-tools 2021-09-21
   * precompiled kernel-/target-toolchains:
      + toolchains updated to x86_64 (only)

 - New packages and libs:
   * libldns 1.7.1
   * Unbound 1.13.2

 - Updated tools and hooks:
   * busybox 1.33.1
   * dtc 1.6.1
   * fakeroot 1.26
   * fitimg 0.6
   * kconfig 5.14
   * patchelf 0.13
   * pseudo 1.9.0 oe-core b988b0a
   * tar 1.34

 - BusyBox package:
   * Version 1.32.1 removed
   * Version 1.33.1 updated
   * Version 1.34.0 added

 - Updated packages and libs:
   * ACME.sh 3.0.0 (letsencrypt)
   * apache 2.4.48
   * AutoFS 5.0.5/5.1.7
   * BIND 9.11.32
   * ca-bundle 2021-07-05
   * curl 7.79.1
   * dbus 1.13.18
   * dnsmasq 2.80/2.86
   * expat 2.4.1
   * git 2.33.0
   * gnutls 3.6.16
   * haproxy 2.4.4
   * iperf 3.9
   * libgcrypt 1.9.3
   * libgd 2.3.3
   * libgpg-error 1.42
   * libtirpc 1.3.2
   * mbed TLS 2.7.19/2.27.0
   * mc (Midnight Commander) 4.8.27
   * minidlna 1.3.0
   * Mosquitto 1.6.15
   * OpenSSH 8.7p1
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1l/3.0.0
   * OpenVPN 2.4.11/2.5.3
   * Perl 5.32.1
   * stunnel 5.59
   * Tor 0.4.5.8
   * uMurmur 0.2.20
   * unrar 6.0.6
   * vsftpd 3.0.5
   * wireguard-linux-compat 1.0.20210606
   * wireguard-tools 1.0.20210424

 - Web interface:
   * Settings backup:
      + Check for identic device, AVM passwords are device specific encoded
      + Support of encrypted setting backup files (openssl is required)
   * Dnsmasq GUI:
      + Add page to display DHCP leases
      + Add page to configure DHCP-Hosts - works in addition to freetz hosts file
   * Mod-Info:
      + Display package versions
   * Package CGIs (index page):
      + Show package version in header

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng21090/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng21030

 - Known problems:
   * Replace kernel does not work for most latest firmware versions.
   * Loading build kernel modules may work or do not. You'll notice.

 - Build system:
   * ccache 4.2
   * kernel-/target-toolchain:
      + uClibc-ng 1.0.37

 - New packages, libs, modules:
   * juis_check 0.5

 - New tools and hooks:
   * pseudo 1.9.0 oe-core
   * yourfritz-decoder 0.4-git

 - Updated tools and hooks:
   * fakeroot 1.25.3
   * fitimg 0.5
   * kconfig 5.11
   * patchelf 0.12
   * xz 5.2.5

 - Updated packages and libs:
   * cifs-utils 6.12
   * curl 7.75.0
   * haproxy 2.2.9
   * libgd 2.3.1
   * lighttpd 1.4.59
   * mtr 0.80/0.94
   * OpenSSL 0.9.8zh/1.0.2u/1.1.1j/3.0.0-alpha12
   * OpenVPN 2.4.10/2.5.1
   * pcre 8.44
   * rsync 3.2.3
   * wireguard-linux-compat 1.0.20210124
   * lzma2 5.2.5

 - Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng21030/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng21010

- Known problems:
   * Replace kernel does not work for most latest firmware versions.
   * Loading build kernel modules may work or do not. You'll notice.

- Build system:
   * kconfig 5.10

- New packages, libs, modules:
   * RPCBind 1.2.5

- Updated packages and libs:
   * CA-bundle 2021-01-19
   * dnsmasq 2.80/2.84
   * jpeg 9d
   * lighttpd 1.4.58
   * shellinabox 2.21
   * smartmontools 7.2
   * socat 1.7.4.1
   * Wget 1.21.1

- BusyBox:
   * Removed version 1.31.1
   * Updated version 1.32.1
   * Added version 1.33.0

- New tools and hooks:
   * fitimg: tool to pack/unpack FIT firmware files

- Firmware updates:
   * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng21010/docs/FIRMWARES.md) for the list of supported devices and firmwares.

### ng20120

- Known problems:
  * Replace kernel does not work for most latest firmware versions.
  * Loading build kernel modules may work or do not. You'll notice.

- Build system:
  * addons: additional to addon/static.pkg, addon/*.pkg could be used to enable addons, since r15856/3dda64565e
  * binutils:
    + add support for binutils-2.24.x/2.25.x/2.26.x/2.31.x
  * ccache 3.7.12
  * kconfig 5.9
    + added olddefconfig target
    + removed oldnoconfig target
  * kernel-/target-toolchain:
    + update gcc-4.7.x version to 4.7.4
    + add support for gcc-4.8.x/4.9.x/5.x/8.x
    + add support for x86 target
    + add uClibc-1.0.36 support
  * support for a 3rd (auxiliary) firmware
  * fakeroot: bump version to 1.23
  * lzma SDK: bump lzma SDK version to 4.65
  * sfk: bump version to 1.9.7.2
  * squashfs* tools:
    + unify all host- and target-patches (i.e. use the same set of patches for both the host and the target packages)
    + switch to using a C only version of liblzma instead of the C++ version used so far
  * squashfs3 tools: revise LZMA related patches so that the resulting binaries support
                     both ZLIB and LZMA compression methods at the same time
  * sed: added version 4.8
  * tar: bump version to 1.32

- New tools and hooks:
  * fwdu: script to download (and unpack) all firmwares from ftp.avm.de
  * verify-dls.sh: script to validate download urls in Config.in
  * scons: python based software construction tool (s. http://www.scons.org/ for details)
  * genext2fs: a tool to generate an ext2 filesystem as a normal (non-root) user
  * mke2img: a script taken from the Buildroot project making it possible to create
             an ext2 filesystem image as a normal (non-root) user
  * squashfs-tools-4.3: a special version of squashfs-tools modified to support AVM-BE format
  * bzimage2eva / eva2bzimage: conversion tools for PUMA6 kernels
  * patchelf: small utility to modify the dynamic linker and RPATH of ELF executables
  * uimg: tool to pack/unpack PUMA7 .uimg files (Intel Unified Image v3)
  * image2inmemory: creates an in-memory image for nand/ram-boot devices, uses latest.image by default

- New patches (read online help for more info):
    * udevmount: extends storage mounting of udev
    * Add telnetd (FOS 6.50+): Telnetd is not added by default. If you need it, enable this patch.
    * Remove telnetd (FOS <6.50): Telnetd is removed by default. If you need it, disabled this patch.
    * Remove samba: Add support for Visuality Systems NQCS (Non-GPL closed source CIFS server with SMB3).
    * Remove plcd: The plcd scans the network for powerline devices and shows them on the mesh overview.
    * Remove public firmware key: You could remove AVM's public firmware "key1" from image. This prevents
      unrequest self-updates of the FritzBox.
    * Drop noexec on external storages: Newer FritzOS versions don't allow to execute files on storages.
      Enable the noexec patch to allow it.
    * Patch DSL modified message: The DSL main page does not show a warning anymore.
    * Extend DSL spectrum: Shows DSL spectrum page with min/man visible initialy.
    * Extend DSL settings:Extends the DSL settings page with "speed" settings (lower SNR-margin etc).
    * Extend online counter: AVM's online counter page could be modified by convert the hours in days and
      traffic MB in GB.

- New packages, libs, modules:
    * ACME.sh 2.88 (letsencrypt)
    * Addhole (for dnsmasq) 1.0
    * asterisk 11.25.3
    * asterisk-chan-capi post-1.1.6 with asterisk11 adjustments by Mihai Moldovan
    * asterisk-chan-dongle 1.1-git (asterisk11 branch)
    * asterisk-chan-sccp 4.1.0RC1
    * asterisk-gui 2.1.0RC1
    * atop 2.2.3
    * autossh 1.4g
    * avm-forwarding 0.0.1b
    * AVM-portfw 0.9
    * AVM-rules 0.9 (deprecated)
    * axTLS wrapper 1.4.9
    * bvi 1.4.0
    * CA-bundle 2020-12-08
    * cntlm 0.93beta5
    * CurlFtpFS 0.9.2
    * decrypt FRITZ!OS configs v0.2 (renamed version of PeterPawn's script decode_passwords)
    * dehydrated 0.7.0 (letsencrypt)
    * ISC dhcp 4.3.6-P1
    * E-MailRelay 1.9
    * getdns 1.5.2
    * gptfdisk 1.0.1
    * hdparm 9.58
    * iksemel 1.5-git
    * iperf 3.7
    * jansson 2.7
    * jq 1.6
    * LCD4linux 91cfbc2-git
    * libavmacl2 (taken from AVM's 7490.06.30 open-source package)
    * libcap 2.24
    * libdvbcsa 1.1.0
    * libgsm-1.0.13
    * libmnl 1.0.4
    * libnettle 3.6
    * liblz4 1.9.3
    * libonig 6.7.1
    * libsrtp-1.4.4+20100615
    * libssh2 1.10.0
    * libtirpc 1.2.6
    * libusb-compat 0.1.5
    * lzma1 4.65
    * mbed TLS 2.7.18/2.25.0
    * minisatip 1.0.4
    * Mosquitto 1.6.8
    * MySQL 6.0.11-alpha
    * nzbget 14.1
    * PJProject 2.2.1
    * Fritz!Box private key password framework v0.7-git (by PeterPawn)
    * ProxyChains-NG 4.14 (e895fb713a-git)
    * python-cheetah 2.4.4
    * python-mechanize 0.2.5
    * python-yEnc 0.4.0
    * serf 1.3.9
    * ScanButton 0.2.3.cvs20090713
    * speex 1.2rc1
    * spandsp 0.0.6pre21
    * squashfs-tools 3.4
    * squashfs-tools 4.3 (modified to support AVM-BE format)
    * vermagic 1ac45e08d4-git
    * wireguard-tools 1.0.20200827
    * wireguard-linux-compat 1.0.20201112
    * xz 5.2.4

- Documentation/Wiki:
    * Most files are move to docs/ directory.
    * Just point your brwoser to: https://freetz-ng.github.io/
    * Could also be opened by the [README.md](../README.md) in the main directory
       + on GitLab: https://gitlab.com/Freetz-NG/freetz-ng/blob/master/README.md
       + on GitHub: https://github.com/Freetz-NG/freetz-ng/blob/master/README.md
    * This works also offline with a checkout. You need a markdown (.md) viewer or browser with markdown-addon
    * Now the documentation is always in sync with the source code, for releases and tags

- Updated build system:
    * The ./dl directory is no more a directory, but a link to ~/freetz-dl. So all downloads are share between all
      checkouts. If you don't like it just create ./dl as a directory by yourself.
    * Firmware files are verifyed before unpacking by the signature of AVM. The public key is unique per device (and
      for some also by annex or language), but not by FritzOS version. The first FritzBox devices had no siganture
      and as fallback the checksum-check on download is used.
    * Downloads are verifyed by a checksum, the result is colored. Downloads from svn, git etc repositories have
      no checksum when they are not on the mirros.
    * Additionally to ./fwmod_custom the file ./.fwmod_custom is executed but the later is unversioned.
      Pro-Tipp: If you want to run commands depending on .config variables, source the .config file by ". ../../.config".
    * You could set a user defined mirror as known (menuconfig > Download options > user-defined site) or by
      config/custom.in: Set a string for FREETZ_DL_SITE_CUSTOM symbol. User defined mirrors are now always used first
    * The link ./images/latest.image points always to the latest successfully created firmware.

- Updated tools and hooks:
    * push_firmware: updated for uimg, ram-boot (nand) and dual-boot (docsis) devices. Use it by execute
     "make push-firmware" to flash the latest compiled image or use "./tools/push_firmware" for more options.

- Updated patches:
    * All selectable patches are expected to work. If a patch fails, report it! Disable the
      patch in menuconfig or remove the patches/scripts/*.sh file to build image anyway.

- Updated packages and libs:
    * apache 2.4.46
    * apr 1.7.0
    * apr-util 1.6.1
    * AutoFS 5.0.5/5.1.6
    * bash 3.2.57
    * BIND 9.11.22
    * Bip 0.8.9/0.9.0-rc4
    * bird 1.6.4
    * CCID driver 1.4.33
    * cifs-utils 6.10
    * cryptsetup 1.7.5
    * curl 7.74.0
    * davfs2 1.5.2/1.6.0
    * dbus 1.8.20
    * DigiTemp 3.7.2
    * dnsmasq 2.80/2.82
    * dosfstools 3.0.28
    * dropbear 2020.81
    * e2fsprogs 1.42.13
    * espeak 1.48.04
    * expat 2.2.10
    * ffmpeg 1.2.12
    * freetype 2.10.1
    * fuse 2.9.7
    * gdb 7.9.1
    * git 2.26.2
    * gmp 6.1.2
    * gnu-make 4.2.1
    * gnutls 3.6.15
    * haproxy 1.8.27
    * hplip 3.14.6
    * htop 1.0.3
    * httpry 0.1.8
    * ImageMagick 7.0.10-10
    * inadyn-mt 02.28.10
    * iodine 0.7.0
    * iptables 1.4.11.1/1.4.21/1.6.2
    * jpeg 9c
    * knock 0.7
    * lftp 4.8.4
    * libcapi avm-(7390/7270).05.50
    * libconfig 1.5
    * libctlmgr 0.6.9
    * libevent 2.1.12
    * libffi 3.2.1
    * libFLAC 1.3.2
    * libgcrypt 1.8.5
    * libgd 2.3.0
    * libgpg-error 1.37
    * liblzo 2.10
    * libneon 0.31.2
    * libogg 1.3.2
    * libopus 1.1.4
    * libpng 1.2.59
    * libpopt 1.16
    * libtasn1 4.13
    * libtiff 4.0.7
    * libusb1 1.0.23/1.0.24
    * libvorbis 1.3.5
    * libxml 2.9.9
    * libxslt/xsltproc 1.1.33
    * lighttpd 1.4.57
    * lsof 4.89
    * ltrace 0.7.91-git
    * lynx 2.8.9
    * mc (Midnight Commander) 4.8.25
    * minidlna 1.2.1
    * mpc 1.1.0
    * mpfr 3.1.6
    * nano 5.3
    * ncftp-3.2.6
    * ncurses 6.2
    * ncursesw 6.2
    * netatalk 2.2.5
    * ngircd 22
    * noip 2.1.9-1
    * ntfs-3g 2017.3.23
    * obexftp 0.23
    * openconnect 7.04
    * OpenSSH 8.4p1
    * OpenSSL 0.9.8zh/1.0.2u/1.1.1i/3.0.0-alpha9
    * OpenVPN 2.4.10/2.5.0
    * pcre 8.43
    * PCSC-lite (pcscd) 1.9.0
    * php 5.6.40
    * privoxy 3.0.28
    * polarssl 1.2.19/1.3.22
    * polipo 1.1.1
    * pppd 2.4.7
    * pptpd 1.4.0
    * protobuf-c 1.1.0
    * Python 2.7.18
    * python-bjoern 1.3.4
    * pycrypto 2.6.1
    * pycurl 7.43.0
    * pyOpenSSL 0.13.1
    * radvd 1.9.3
    * readline 6.3-p8
    * RRDstats 0.7.2: support for FRITZ!Box cable, SmartHome & local power consumption
    * rsync 3.1.2
    * samba 3.6.25
    * sane-backends 1.0.27
    * screen 4.8.0
    * slang 2.3.1a
    * smartmontools 7.1
    * sqlite 3.31.1
    * sslh 1.19c
    * strace 4.9 (kernel-2.6.13) / 5.0 (all other kernel versions)
    * stunnel 5.57
    * subversion 1.8.19/1.9.12
    * tinc 1.0.36/1.1pre17
    * tinyproxy 1.8.4
    * tmux 2.5
    * tor 0.4.4.6
    * transmission 3.00
    * tree 1.8.0
    * uClibc++ 0.2.5-git
    * udpxy 1.0.23-9
    * usbutils 007
    * umurmur 0.2.17
    * unrar 6.0.1
    * usbip 0.1.8
    * util-linux-ng 2.27.1
    * Vim 8.2.0769
    * vnstat 1.17
    * vsftpd 3.0.3
    * vtun 3.0.4
    * Wget 1.20.3
    * xpdf 3.04
    * Zabbix 2.4.6
    * zlib 1.2.11

- Removed packages, libs, modules, tools:
    * apache 1.x
    * aiccu
    * cyassl
    * dtmfbox/dtmfbox-cgi (unmaintained, doesn't work)
    * MatrixSSL/MatrixTunnel (outdated, unmaintained, probably unsafe)
    * openvpn 2.2.x
    * php 5.5.x
    * pjproject
    * ruby/ruby-fcgi
    * truecrypt
    * wxWidgets

- Firmware updates:
    * Please see [FIRMWARES](https://github.com/Freetz-NG/freetz-ng/blob/ng20120/docs/FIRMWARES.md) for the list of supported devices and firmwares.

- BusyBox:
    * Updated to version 1.27.2/1.31.1/1.32.0

- Web interface:
    * It shows the device's hostname (without domain) in the title and header. Set it by Heimnetz > FRITZ!Box-Name. If you want
      a FQDN set it in ar7.cfg directly.
    * The reboot button asks before rebooting.
    * The default button on package pages asks before applying.
    * Automatic refresh of wev pages added, just add a "refresh" parameter with the count of seconds, like ​http://fritz:81/?refresh=3
    * It could be set that the device reboots automatically after successfully flash.
    * New, dark skins called 'cuma' and 'prisrak' added. If you have selected (menuconfig > Web Interface Freetz skins) multiple, you
      could switch them (Webif > System > Weboberfläche).
    * On supported devices, the system page shows the 2 partition sets and the containing FritzOS versions.
    * A stop/start/restart action of a package redirects no longer to the services page.

- menuconfig:
    * menuconfig help: shows howtos/make_targets.txt
    * menuconfig push-firmware: flashes the latest build image ./images/latest.image Use ./tools/push_firmware for more options
    * sorting: The packages in menuconfig are sorted now alphabetical. For a faster navigation just type the character, or
      space for pre-assigned.
    * labor detection: Labor firmware URL is not hardcoded anymore in Freetz, the current URL is detected by using boxmatrix.
      The labor option is enabled for all devices without current FritzOS, but having previous FritzOS version.

- Other stuff:
    * motd: It could be changed and also be dynamic. You could put your own content into /tmp/flash/mod/motd. It will be
      generated 1 time at boot, to update it more often, run "/mod/etc/init.d/rc.mod motd", eg by cron .

### Freetz-2.0

- Build system:
  * binutils:
    + bump version to 2.22
    + add EXPERIMENTAL support for binutils-2.23.x
  * ccache:
    + Bump to version 3.1.9
    + Use external cache dir (~/.freetz-ccache)
  * fakeroot: bump version to 1.18.4
  * use host tar to unpack packages again as busybox' tar doesn't support pax
    (aka POSIX 1003.1-2001) tar format
  * Move each library-package into separate subdirectory (#1093)
  * Readd unsquashfs and mksquashfs without lzma support (needed for 3370)
  * stripping of kernel modules added
  * stripping of shell scripts added
  * kconfig 3.8
  * menu configuration cache (Config.in.cache)
  * kernel-toolchain:
    + remove gcc-4.4.x support
    + add gcc-4.6.x support
  * target-toolchain:
    + remove gcc-4.4.x and gcc-4.5.x support
    + update gcc-4.6.x version to 4.6.4
    + add gcc-4.7.x support
    + remove uClibc-0.9.30.x and uClibc-0.9.31.x support
    + update uClibc-0.9.32.x version to 0.9.32.1
    + add uClibc-0.9.33.x support
  * menuconfig: firmware packaging (fwmod) special options FREETZ_FWMOD_*
    + unpack, modify, pack can be freely combined now
    + AVM SDK firmware can be packed now, even if image is too big for flash
    + USB/NFS root can be packed into tar.gz image with correct user/group and
      special file flags for devices
    + NFS/USB root can be sudo-unpacked to user-specified target folder, ready
      to be mounted
  * fwmod: new parameters to support FREETZ_FWMOD_* menuconfig options (also
    works stand-alone)
    + -f         force pack even if image is too big for flash (AVM SDK)
    + -z         zip file system into archive for USB/NFS root
    + -c <dir>   copy file system to target directory for NFS/USB root (implies -z)
  * Makefile: obsolete variables FWMOD_OPTS, FWMOD_NOPACK because of
    FREETZ_FWMOD_* menuconfig options

- New tools and hooks:
  * fmake: wrapper script for "make", located in Freetz root directory,
    including sample code for a post-build hook sending an e-mail message with
    timing and build log data to a predefined recipient. This makes life easier
    for both users and developers in two ways:
      1) Get actively notified about long-running build processes instead of
         having to look after them (push vs. pull principle).
      2) Make life easier for Freetz developers supporting users who keep
         asking: "How do I create a build log?" Now we can just tell them to
         run "fmake" and then send/upload fmake.log (plus .config) afterwards.

- New patches (read online & menuconfig help for more info):
    * replace dtrace: execute a custom action by phone
    * disable console on serial port: do not start a console/shell on serial
      port
    * replace onlinechanged: execute AVM, Freetz and user-defined scripts
      whenever the external IP address changes. In opposite to AVM's original
      this version also works on boxes behind a NAT (e.g. IP clients using an
      existing internet connection) and on boxes where AVM onlinechanged is not
      called reliably.
    * modify umtsd: AVM's umtsd will only be started if a *known* umts modem is detected.
    * custom UDEV rules: You could use own rules for UDEV.
    * remove showdsldstat: Removes the showdsldstat utility which shows you the cpmac mode,
      connect time, external ip (has not to be the public ip!), route and dns servers.
      Also the state of IPv6, voip and tr069.
    * remove jffs2.ko: remove JFFS2 kernel module, saving 144-192 kB of
      uncompressed firmware space
    * disable multid services: dns, dhcp and llmnr could be remapped with libmultid
    * remove Multi-Annex firmware files: Newest images have 1 full Annex + some bsdiff
    * remove dsl_control
    * remove fat modules
    * remove eventsdump
    * remove socat
    * remove MyFritz
    * remove AHA
    * remove isofs.ko
    * remove ramzswap.ko
    * remove microvoip-dsl.bin
    * remove remove_qos

- New packages, libs, modules:
    * apache 2.4.4
    * avahi 0.6.31
    * CCID 1.4.9
    * dante 1.2.2
    * dbus 1.6.8
    * dvbsnoop 1.4.50
    * dvbstream 0.5
    * dvbtune 0.5
    * fowsr 1.0
    * Ghostscript fonts 8.11
    * gntp-send 0.3.2-git
    * haproxy 1.4.23
    * html2text 1.3.2a
    * ImageMagick 6.8.6-9
    * inadyn-opendns 1.99
    * libattr 2.4.44
    * libev 4.15
    * libleptonica 1.69
    * libmultid 0.5
    * libopus 1.0.2
    * libtiff 4.0.3
    * libusb1 1.0.9
    * libyaml 2.0.2
    * openssl 1.0.1e (as an alternative to the also available openssl 0.9.8)
    * pcscd 1.8.8
    * protobuf-c 0.15
    * pyLoad 0.4.20
    * Python 2.7.4
    * python-bjoern 1.3-git
    * pycrypto 2.6
    * pycurl 7.19.0
    * python imaging library (PIL) 1.1.7
    * pyOpenSSL 0.13
    * pyRRD 0.1.0
    * pyserial 2.6
    * RTMPDump 2.4-git
    * Rush 1.7
    * samba 3.6.13 (as an alternative to the 3.0.37, 3.0.37 is still the default one)
    * shellinabox 2.14
    * smartmontools 5.43
    * smstools3 3.1.21
    * smusbutil 1.1
    * sslh 1.14
    * Sundtek DVB driver 130210.134617
    * Tesseract OCR 3.02.02
    * unfs3 0.9.22
    * Zabbix 2.0.5

- Updated tools and hooks:
    * get_ip:
     + default method can be set via web interface
     + added new methods stun-ip (default) and route
     + removed obsolete methods ostat and extquery

- Updated patches:
    * Update freetzmount patch (by hermann, updated by cuma)

- Updated packages and libs:
    * apache 1.3.42
    * apr 1.4.6
    * apr-util 1.5.2
    * bind 9.8.3-P3
    * callmonitor 1.20.9
    * cifs-utils 5.8
    * cryptsetup 1.6.0
    * curl 7.30.0
    * cyassl 2.5.0
    * davfs2 1.4.7
    * dnsmasq 2.65
    * dosfstools 3.0.16
    * dropbear 2013.56
    * e2fsprogs 1.42.7
    * ffmpeg 1.2
    * freetype 2.4.10
    * gdb 7.3.1
    * git 1.8.2.1
    * glib 2.32.4
    * gmp 5.1.1
    * hplip 3.12.6
    * htop 1.0.2
    * httpry: 0.1.6 and webinterface added
    * iptables 1.4.11.1
    * lftp 4.4.5
    * libevent 2.0.21
    * libconfig 1.4.8
    * libctlmgr 0.6
    * libexif 0.6.21
    * libffi 3.0.13
    * libftdi 0.20
    * libgcrypt 1.5.0
    * libgd 2.0.36RC1
    * libintl (gettext) 0.18.1.1
    * liblzo 2.06
    * libogg 1.3.0
    * libopenjpeg 1.5.2
    * libosip2 3.5.0
    * libpng 1.2.50
    * libvorbis 1.3.3
    * libxml 2.9.0
    * libxslt/xsltproc 1.1.28
    * lighttpd 1.4.32
    * linux-atm 2.5.2
    * lsof 4.86
    * lua 5.1.5
    * mc 4.8.8
      + new: subshell support for BusyBox default shell (ash)
      + changed: bash subshell is still supported, but the dependency is gone
        (use bash login shell or call "SHELL=/bin/bash mc" to get bash subshell)
    * minidlna 1.0.25
    * mpc 1.0.1
    * mpfr 3.1.2
    * ncurses 5.9
    * netatalk 2.2.4
    * netpbm 10.35.85
    * Net-SNMP 5.8
    * ngircd 19.2
    * ntfs-3g 2013.1.13
    * openssh 6.2p1
    * openssl 0.9.8y
    * openvpn 2.2.2 & 2.3.1
    * pcre 8.32
    * php 5.3.24/5.4.14
    * Pingtunnel 0.72
    * privoxy 3.0.21
    * polarssl 1.2.7
    * radvd 1.8.3
    * readline 6.2-p4
    * RRDstats: Cisco EPC & Arris Touchstone TM support and cable segment load
    * rsync 3.0.9
    * sane-backends 1.0.23
    * ser2net 2.7
    * siproxd 0.8.1
    * sispmctl 3.1
    * slang 2.2.4
    * squid 3.0.STABLE26
    * sqlite 3.7.16.2
    * sshfs-fuse 2.4
    * stunnel 4.56
    * subversion 1.7.9
    * tinc 1.0.19
    * tmux 1.7
    * tor 0.2.3.25
    * transmission 2.77
    * tree 1.6.0
    * truecrypt 7.1a
    * umurmur 0.2.10
    * unrar 4.2.4 (=rar 4.20)
    * vnstat 1.11
    * vsftpd-3.0.2
    * wget 1.14
    * zlib 1.2.7

- Removed packages, libs, modules, tools:
    * Remove getcons patch (see #1026 for details)
    * glib-1.2 (unused, no package depends on it anymore)
    * libflex (unused, no package depends on it anymore)

- Firmware updates:
    * Please see FIRMWARES for the list of currently supported boxes and firmwares.

- BusyBox:
    * Updated to version 1.21.0
    * Enhanced blkid und findfs support for busybox (used in freetzmount)
    * New applet stun-ip (by ralf) determines the external IP address via STUN protocol
    * All options of busybox integrated into menuconfig

- Web interface:
    * Skin "newfreetz" added
    * Skins could be preselected via menuconfig

- Other stuff:

### Freetz-1.2

- Build system:
  * fakeroot: bump version to 1.15.1
  * kernel-toolchain:
   + Bump binutils version to 2.18
   + Add gcc version 4.4.6
   + Add binutils version 2.21.52.0.2
   + Use gcc-3.4.6 for kernel versions 2.6.13.1 and 2.6.19.2
   + Use gcc-4.4.6 for kernel versions 2.6.28 and 2.6.32.21
   + Update download toolchains
  * target-toolchain:
   + Add gcc-4.4.6(default), gcc-4.5.3, and gcc-4.6.1, delete outdated versions
   + Bump binutils version to 2.21.52.0.2
   + Add uClibc-0.9.30.3 and uClibc-0.9.31.1, 0.9.32
   + Add gdb-6.8 and gdb-7.2, delete outdated versions
   + Update download toolchains:
    + Use gcc-4.4.6 for uClibc versions 0.9.28/29/30
    + Use gcc-4.5.3 for uClibc-0.9.31.1/0.9.32 toolchain
    + Remove kernel headers from download toolchains
   + Add install target for kernel headers
   + Update sys/queue.h in uClibc-0.9.28 toolchains
   + Enable mips-plt optimizations for gcc versions >= 4.4. These optimizations
     allow gcc to create binaries which are significantly smaller in size.
   + Add option to build uClibc with a reduced set of locales (saves > 200 KB)
   + Remove many unused symbols from libgcc_s (saves ~ 100 KB)
  * Bump ccache version to 3.1.5
  * patch-system: use shell-fuction isFreetzType (by kriegaex)
  * replace tar with busybox tar
  * patch-system: use shell function modsed
  * move packages and libs source dir to source/target-$(arch)_uClibc-$(version)
   * move config.cache to this subdir too
  * move tools source dir to source/host-tools

- Toolchain:
  * Add support for the GNU libstdc++. From now on user can specify (he/she has
    a choice between uClibc++ and libstdc++) the library to be used as the
    implementation of the Standard C++ Library. uClibc++ is still the default one.
    The option affects all packages using C++ compiler to compile. In one of the
    next releases it will be possible to select the library on a per-package-basis.
    The reason we add support for libstdc++ is some performance deficiencies
    of uClibc++ causing us either to get stuck with old versions of the packages
    we already support (e.g. nmap) or making it impossible to add support for
    the new ones (e.g. truecrypt).

- New tools and hooks:
    * New hook to add files/directories to var.tar
     * Put desired files/directories into make/{package}/files/var.tar
    * modlibrc:
     * modlib_status now supports "inetd"
     * modlib_startdaemon takes care of the returnvalue, creates pid-file & writes "Starting..."
     * modlib_start checks if the daemon is yet started or disabled
     * modlib_reload & modlib_startdaemon executes "config"-function of parent rc-skript (if available)
     * modlib_stop kills daemon with "stop" of parent rc.$DAEMON (if available)
    * New feature for modpatch: choose patch file depending on md5sum of target file
        this is triggered if the 2nd parameter is a directory and not a (patch-) file

- New patches (read online help for more info):
    * Add support for multiple printers
    * add additional image-infopage and .config in firmware image (by herman72pb)
    * remove ntfs-support
    * remove umts-support
    * add 3rd alarm-clock (for 7150  7112 7141 7170  3070_V3  3270 7240 7270 7270_V3)
    * freetzmount (by hermann72pb)
    * reg SIP from outside (by MaxMuster)
    * remove AVM's NAS webinterface and internal memory file
    * remove (unneeded) piglet and isdn/pots bitfile(s)
    * remove AVM's webdav
    * remove AVM's printserv & usblp
    * remove AVM's lsof
    * remove AVM's strace
    * remove chronyd

- New packages, libs, modules:
    * aiccu 20070115
    * apr 1.4.5
    * apr-util 1.3.12
    * autofs 5.0.5
    * berkeley-db 4.8.30
    * bind 9.8.0-P2
    * bittwist 1.1
    * comgt 0.32
    * compcache 0.5.4 (kernel module)
    * cpmaccfg-cgi 1.0: Webinterface for cpmaccfg
    * digitemp 3.6.0
    * dnsd-cgi 1.0
    * dosfstools 3.0.11
    * dtmfbox-cgi 0.1
    * ffmpeg 0.5.4
    * flex (libflex) 2.5.35
    * fortune 1.2
    * git 1.7.5.4
    * gnutls 2.10.5
    * gocr 0.49
    * gw6 5.1
    * hol 0.1
    * hplip 3.11.1
    * hp-utils 0.3.2
    * htop 0.9
    * htpdate 1.0.4
    * httpry 0.1.5
    * ifstat 1.1
    * iftop 0.17
    * igmpproxy 0.1
    * iptraf 3.0.1
    * ipsec-tools 0.7.2
    * iputils s20071127
    * lftp 4.0.5
    * libconfig 1.4.5
    * libdaemon 0.14
    * libdnet 1.12
    * libexif 0.6.20
    * libFLAC 1.2.1
    * libfreetz 0.4
    * libgd 2.0.35
    * libjs 1.6.20070208
    * libnet 1.1.4
    * libogg 1.2.2
    * libopenjpeg 1.4.0
    * liboping 1.6.1
    * libosip2 3.3.0
    * libpolarssl 0.14.3
    * libstdc++ 6.0.x
    * libsynce 0.10.0
    * libtasn1 2.9
    * libusb1 1.0.8
    * libvorbis 1.3.2
    * libxml 2.7.8
    * libxslt/xsltproc 1.1.26
    * lighttpd 1.4.28
    * mdev 0.6.2: First try to replace AVM's hotplug chain
      depends on 7170, 7240 and 7270.
    * mediatomb 0.12.1
    * minicom-2.5
    * minidlna 1.0.20
    * mini-snmpd 1.2b
    * nc6
    * ncftp-3.2.5
    * netatalk 2.1.5
    * netpbm-10.35.79
    * ndas-1.1-22
    * nhipt iptables cgi 0.8.3a
    * ngircd 17.1
    * nmap 4.68
    * noip 2.1.9
    * oidentd 2.0.8
    * onlinechanged-cgi 0.1
    * openconnect 2.24
    * opendd 0.7.9
    * owfs 2.7p32
    * pcre 8.12
    * phpxmail 1.5
    * pkcs#11 v2.20
    * polipo 1.0.4.1
    * ppp-cgi 0.6.9
    * radvd 1.7
    * ripmime 1.2.16.21
    * rsync 3.0.8
    * ruby-fcgi 0.8.7
    * ser2net 2.5
    * siproxd 0.8.0
    * slang 2.2.3
    * slurm 0.3.3
    * spawn-fcgi 1.6.3
    * sqlite 3.7.6.3
    * sshfs-fuse 2.2
    * subversion 1.6.17
    * synce-dccm 0.9.1
    * synce-serial 0.10.0
    * taglib 1.6.3
    * tcpproxy 2.0.0-beta15
    * tmux 1.4
    * transmission-cgi 0.0.4
    * trickle 1.07
    * truecrypt 7.0a
    * udpxy 1.0-Chipmunk-16
    * umurmur 0.2.6
    * unrar 4.0.7
    * util-linux-ng 2.17.2
    * vnstat 1.10
    * vnstat-cgi 0.6.9
    * vtun 3.0.3
    * wxWidgets 2.8.12
    * xmail 1.27

- Updated tools and hooks:
    * external:
     * Move external files out of tools/external into separate files for each package
     * added automatic start/stop of services on (un)mount (now configurable via webinterface)

- Updated patches:
    * Update many patches to support actual firmwares (e.g. changed paths)

- Updated packages and libs:
    * avm-firewall 2.0.4_rc5
    * bash 3.2.51
    * bftpd 3.3
    * bip 0.8.8
    * bird 1.3.1
    * bridge-utils 1.4
    * callmonitor 1.19.1
    * checkmaild 0.4.7
    * classpath 0.98
    * collectd 4.10.3
    * cryptsetup 1.0.6
    * curl 7.21.7
    * cyassl 1.9.0
    * davfs2 1.4.6
    * debootstrap 1.0.56
    * dns2tcp 0.5.2
    * dnsmasq 2.57
    * e2fsprogs 1.41.14
    * freetype 2.3.12
    * fuse 2.7.6
    * glib 2.22.5
    * gmp 5.0.1
    * gnu-make 3.82
    * haserl 0.9.29
    * inadyn-mt-2.24.36
    * inetd 0.2 (multiple daemons/package)
    * inotify-tools 3.14
    * iptables 1.4.1.1
    * iptables-cgi 1.1
    * iodine 0.6.0-rc1
    * irssi 0.8.15
    * jamvm 1.5.4
    * libart_lgpl 2.3.21
    * libcapi
    * libelf 0.8.13
    * libevent 2.0.12
    * libftdi 0.18
    * libgcrypt 1.4.6
    * libgpg-error 1.10
    * libiconv 1.13.1
    * libpcap 1.1.1
    * libpng 1.2.44
    * libpopt 1.15
    * liblzo 2.05
    * libneon 0.29.6
    * linux-atm 2.5.0
    * lsof 4.84
    * ltrace 0.5.3
    * lua 5.1.4
    * lynx 2.8.7
    * mc 4.6.2
    * mcabber 0.9.10
    * mpfr 2.4.2
    * mtr 0.80
    * nano 2.2.5
    * net-snmp 5.4.3
    * nfs-utils 1.3.4
    * ntfs-3g 2011.4.12
    * openssh 5.6p1
    * openssl 0.9.8r
    * openvpn 2.2.0
    * pciutils 3.1.7
    * php 5.3.6
    * pingtunnel 0.71 (and webif added)
    * privoxy 3.0.17
    * quagga 0.99.17
    * readline 6.1
    * rrdstats 0.7.1 (inetd support for webservers)
    * samba 3.0.37 (inetd support for smbd)
    * sispmctl 3.0
    * socat 1.7.3.3
    * strace 4.6
    * streamripper 1.64.6
    * stunnel 4.35
    * tcpdump 4.1.1
    * tinc 1.0.14
    * tinyproxy 1.8.2
    * tor 0.2.1.30
    * transmission 2.32
    * uClibc++ 0.2.3pre (git snapshot)
    * usbutils 0.86
    * vim 7.3
    * vsftpd 2.3.4: add SSL support
    * zlib 1.2.5

- Remove packages, patches, libs, modules, tools:
    * removed xyssl (not maintained anymore, superseded by polarssl)
    * removed automount patch (superseded by freetzmount)

- Firmware updates:
    * Please see FIRMWARES for the list of currently supported boxes and firmwares.

- BusyBox:
    * updated to 1.18.5

- Web interface:
    * add additional information and possibility to mount/umount partitions (by herman72pb)
    * added favicon by atomphil (Freetz-Webinterface only)
    * buttons removed from mainpage, created new "system"-submenu
      + button "reconnect" from mainpage is replaced by rc.dsld (restartable by "daemons" submenu)
      + button "downgrade" from mainpage is now integrated into firmware-update page
      + other buttons from mainpage moved to "system"-submenu
      + backup & restore, firmware upgrade and Rudi-shell moved to "system"-submenu
      + added link to AVM-webinterface to "system"-submenu
    * create a support-file added
    * memory usage at services-page added

- Other stuff:
    * add reiserfs to automountable filesystems
    * add IPv6
    * Remove MOD_LIMIT variable
      + compressed size of freetz config file must not be greater than 32 KB
      + this is a tffs2 restriction

### Freetz-1.1

- Build system::
 * Fix buffer overflow in tar

See svn log for more details.

### Freetz-1.1.4

- Updated packages and libs:
    * callmonitor 1.15.2 (Adds features up to 1.18.5)
    * sane-backends 1.0.21
    * tor 0.2.1.26

- Firmware updates:
   * Please see FIRMWARES for the list of currently supported boxes and firmwares.

See svn log for more details.

### Freetz-1.1.3

- Web interface:
    * added favicon by atomphil (Freetz-Webinterface only)

- Updated packages and libs:
    * bip 0.8.4
    * php 5.2.10 (download for 5.2.9 was removed)
    * davfs 1.4.5 (older versions have problems with gmx)
    * dnsmasq 2.55
    * dropbear 0.53.1
    * openssl 0.9.8n (security issues)
    * openvpn 2.1.1
    * stunnel 4.33
    * tor 0.2.1.25
    * vsftpd 2.2.2
    * wget 1.12

- Firmware updates
    * Please see FIRMWARES for the list of currently supported boxes and firmwares.

### Freetz-1.1.2

- Updated packages and libs:
    * microperl 5.10.1

- Firmware updates
    * Please see FIRMWARES for the list of currently supported boxes and firmwares.

### Freetz-1.1.1

- Build system:
  * patch-system: use shell-fuction isFreetzType (by kriegaex)
  * patch-system: use shell function modsed

- New patches (read online help for more info):
    * split tr069-remove-patches

    * Update usbstorage patches
- Updated packages and libs:
    * callmonitor 1.15.1

- Firmware updates
    * Please see FIRMWARES for the list of currently supported boxes and firmwares.

### Freetz-1.1.0

- Build system:
    * fakeroot: bump version to 1.12.2
    * xdelta: Disable build because we don't make use of it
    * toolchains:
      - add menuconfig option to adjust HOSTCC variable
      - add ccache for download- and kernel-toolchain
      - add two patches for gcc-3.4.6
        + Fix failure with newer host gccs
        + Fix failure on some machines
    * uClibc-0.9.29: Add 2 patches from openwrt
    * kernel-toolchain: Add two patches for gcc-3.4.6
      + Fix failure with newer host gccs
      + Fix failure on some machines
    * Bump squashfs3 version to 3.4

- New tools and hooks:
    * external
    * new make targets:
      - check-downloads: checks all downloads for availability (also
        $(pkg)-check-downloads)
      - mirror: downloads all package downloads into dl/mirror (also
        $(pkg)-download-mirror). This makes hardlinks for dupes in dl/ and
        dl/mirror to save disk space.
    * Add patch that enhances posibilities of /bin/onlinechanged:
      Based on changes by AVM we execute 3 locations on a call to /bin/onlinechanged:
      1. /var/tmp/onlinechanged (compatibility to old behaviour)
      2. /etc/onlinechanged/*   (new AVM behaviour)
      3. /tmp/flash/onlinechanged/*
      If a package needs actions on changes of online status create a script
      make/$package/files/root/etc/onlinechanged/$action_$package.


- New patches (read online help for more info):
    * 7270:
      * Option to add Annex A firmware into image
      * Fix flashing of firmwares > 8 MB over webinterface
      * Add volume counter (7240, 7270)
      * AVM Plugins can be reintegrated into firmware
    * Fix wrong usb mounts status message in AVM webinterface (7170, 7270)
    * Add new status bar design (optional)


- New packages, libs, modules:
    * bfusb 3-18-39 (firmware for bluetooth stick)
    * br2684ctl 20040226
    * dtach 0.8
    * external 0.1
    * hd-idle 0.1
    * httptunnel 3.3
    * libtool 1.5.26
    * linux-atm 2.4.1
    * mcabber 0.9.9
    * microperl 5.10.0
    * nagios 2.11
    * nano 2.0.9
    * nfs-utils 1.1.3
    * nfsd-cgi 0.1
    * openssh 5.1p1
    * pciutils 3.0.0
    * portmap 6.0
    * sablevm-sdk
    * socat 1.6.0.1
    * squid 3.0.STABLE9
    * tcp_wrappers 7.6
    * tinc 1.0.8
    * tree 1.5.1.2
    * usbutils 0.73
    * wol 0.7.1
    * wput 0.6.1
    * xpdf 3.02
    * new kernel modules: bfusb, pppoe, pppox

- Updated tools and hooks:

- Updated patches:
    * add reiserfs to automountable filesystems
    * change nice names for USB devices (sdax > uStor0x, sdby > uStor1y, ...)
    * 3131: Remove "remove cdrom.iso" patch

- Updated packages and libs:
    * bash 3.2.48
    * bftpd 2.3
    * bip 0.8.0
    * callmonitor 1.13
    * classpath 0.97.2
    * curl 7.19.4
    * cyassl 0.9.9
    * devmapper 1.02.27
    * dropbear: fixed init script not to start dropbear a second time when already running
    * dns2tcp 0.4.3
    * dnsmasq 2.47
    * dtmfbox 0.5.0
    * e2fsprogs 1.41.3
    * espeak 1.40.02
    * expat 2.0.1
    * glib 2.18.2
    * haserl 0.9.25
    * iodine 0.5.0
    * jamvm 1.5.1
    * libpopt 1.14
    * lsof 4.81
    * ltrace 0.5 svn 81
    * mcabber 0.9.9
    * ntfs-3g 2009.4.4: adds UTF-8 support
    * openssl 0.9.8k
    * openvpn 2.1_rc15
    * php 5.2.9
    * pingtunnel 0.70
    * pjproject 1.0.1
    * popt 1.14
    * pptp 1.7.2
    * ruby 1.8.6-p368
    * rrdtool 1.2.30
    * strace 4.5.18
    * streamripper 1.64.0
    * Stunnel 4.26
    * tor 0.2.0.34
    * transmission 1.60
    * usbip 0.1.7
    * vpnc 0.5.3
    * vsftpd 2.0.7: add SSL support
    * tree 1.5.2.1

- Remove packages, libs, modules, tools:

- Firmware updates:
    * Please see FIRMWARES for the list of currently supported boxes and firmwares.

- BusyBox:
    * updated to 1.12.4

- Web interface:

- Other stuff:
    + fix strip library function for 3170
    + tune behaviour of freetz_download (retries: 3, timeout: 20s)
    + Integrate new AVM open source packages (04.70 and 7270_04.70)
    + rudishell:
      * show it only with security level 0
      * don't allow to execute any code by clicking on a wrong url

### Freetz-1.0.1

- Build system:

    * target toolchain:
        + AVM links against uClibc-0.9.29 in labor firmwares (actually all, dsl and gaming);
          we added an uClibc version flag so that correct version is used
        + added simple check for old or new uClibc; if you change
          uClibc version most stuff has to be rebuilt
        + Delete toolchain-distclean target for download toolchain
        + Add *-toolchain-{dir/dist}clean targets for download toolchain
        + fix some toolchain dependencies
        + adapt updates from buildroot

- New tools and hooks:

- New patches (read online help for more info):
    * remove tr069-stuff
    * remove dect-stuff from 7270
    * remove DECT-files and modules on W900V

- New packages, libs, modules:

- Updated tools and hooks:
    * push_firmware now supports flashing from complete firmware images (by unpacking to tempfile)

- Updated patches:
    * usbstorage: delete storage.sh patch and therefore add sed line to usbstorage.sh
    * remove tr069: remove tr069 stuff for 7170, 7270
    * remove_dect: don't remove dect firmware files otherwise boot process will hang

- Updated packages and libs:
    * avm-firewall 2.0.4_rc2
    * bip 0.7.4
    * callmonitor 1.12.3
    * ctorrent dnh3.3.2
    * curl 7.19.1
    * cyassl 0.9.8
    * devmapper 1.02.27
    * dns2tcp 0.4.1
    * dnsmasq 2.46
    * dropbear 0.52
    * e2fsprogs 1.41.1
    * espeak 1.39
    * fuse 2.7.4
    * inadyn-mt 02.12.24
    * iodine 0.4.2
    * libftdi 0.14
    * module-init-tools 3.12
    * nano 2.0.9
    * ntfs-3g 1.5012
    * ncurses 5.7
    * obexftp 0.22
    * openssl 0.9.8j
    * openvpn 2.1_rc13
    * php 5.2.6
    * pppd 2.4.5
    * privoxy 3.0.10
    * quagga 0.99.14
    * readline 6.0
    * rrdstats: add uptime statistics
    * ruby 1.8.6
    * sg3_utils 1.26
    * streamripper 1.63.4
    * stunnel 4.25
    * tor 0.2.0.31
    * transmission 1.40
    * wget 1.11.4
    * xrelayd 0.2.1pre2

- Remove packages, libs, modules, tools:

- Firmware updates:
    * Please see FIRMWARES for the list of currently supported boxes and firmwares.

- BusyBox:
    * updated to 1.11.3

- Web interface:

- Other stuff:
    * kernel:
        + support for new sources (04.57)
        + add patch for multiple ftdi devices
        + add squashfs-3.3 patch for 2.6.19.2
        + activate "replace kernel" for 7270
        + Add mppe-mppc.patch to 2.6.19.2
        + 2.6.19.2: use other net sched timer (AVM changed it)
        + Raise source version for 5050 to 04.33
        + Activate AVM_CPMAC_SWITCH (affects all 4MB Ohios switch boxes)
    * push_firmware: Add MacOSX support
    * subdirs for downloaded an generated firmware-images to keep dl- and rootdir clean
    * mtd char devices were created with wrong minors
    * disable iptables-cgi for 7270
    * add menuconfig option for 7270 with 16 MB flash
    * add option to disable Freetz version string
    * fix wrong PID in /var/run/httpd.pid after webcfg restart
    * fwmod_list: ignore case when searching for new firmwares

### Freetz-1.0

- Build system:
    * adapted all packages to new macro style
        + please read make/README.Makefile for further instructions
        + look at make/Makefile.in for implementation
        + use global config.cache (make/config.cache) for all configure scripts
        + use macro for replacing 'libdir=/usr/lib' in *.la files
    * toolchains: Add menuconfig option to build static toolchains
    * kernel toolchain:
        + don't use crosstool to build kernel toolchain
        + update kernel toolchain to version 3.4.6 (same version as AVM)
        + use Binutils 2.17.50.0.17 for kernel toolchain
    * target toolchain:
        + uclibc: disable UCLIBC_HAS_FOPEN_LARGEFILE_MODE even if LFS is enabled
        + add uClibc-0.9.29 (doesn't work realy good and will be revised for
          next release)
    * download toolchain:
        + update because of above changes
    * Add squashfs3 utils
        + use squashfs3 for 7270 squashfs and if "replace kernel" is selected
          We have a kernel patch that makes 2.6.13.1 squashfs3 aware. Main
          benefit of squashfs3 are blocksize larger than 64kb. But these
          doesn't work with AVM 7270 stock kernel.
    * fakeroot: bump version to 1.9.2, put archive on dsmod.magenbrot.net to
      avoid being forced to version bumps if version becomes unavailable

- New tools and hooks:

- New patches (read online help for more info):
    * multid wait
    * remove annex firmware files (only 7270)
    * remove dsld
    * remove mediasrv
    * remove telephony
    * remove getcons (don't redirect serial console output)

- New packages, libs, modules:
    * avm-firewall 2.0.3c
    * bash 3.2
    * bip 0.7.2
    * bluez-libs 1.0.25
    * bluez-utils 2.25
    * curl 7.18.1
    * cyassl 0.8.5
    * dns2tcp 0.4
    * e2fsprogs 1.40.8
    * fstyp 0.1
    * glib 1.2.10
    * iodine 0.4.1
    * iptables-cgi 1.0.4
    * irssi 0.8.12
    * ldd 0.1
    * libavmhmac 0.2
    * libftdi 0.7.0
    * madplay 0.15.2b
    * module-init-tools 3.3-pre11
    * nano-shell 0.1
    * nfsroot 0.1
    * rcapid 0.1
    * rrdstats 0.6.9
    * ruby 1.8.6
    * quagga 0.99.6
    * samba 3.0.24 from avm gpl package
    * usbip 0.1.7
    * usbroot 0.1
    * vim 7.1
    * vsftpd 2.0.6
    * wget 1.11.1
    * xrelayd 0.2
    * xyssl 0.8
    * new kernel modules: blk_dev_md, bnep, crypt_aes, crypto_algapi,
      crypto_blkcipher, crypto_cbc, crypto_manager, crypto_sha256, dm_crypt,
      nls_utf8, pl2303, udf, x_tables\
      Some of these are not available for all boxes and/or firmwares. See
      menuconfig to check this.

- Updated tools and hooks:

- Updated patches:
    * remove assistant
    * remove cdrom
    * remove ftpd
    * remove help
    * remove samba
    * remove vpn files
    * samba
    * webmenu signed
    * webmenu wol
    * usbstorage patch
        + enabled by default
        + use fstyp to automount ext2, ext3, vfat and ntfs filesystems

- Updated packages and libs:
    * apache 1.3.41
    * bftpd 2.1
    * busybox 1.9.2
    * callmonitor 1.11
    * checkmaild 0.4.4
    * cpmaccfg 0.5
    * collectd 4.0.7
    * cryptsetup 1.0.5
    * ctorrent dnh3.3
    * dnsmasq 2.41
    * downloader 0.2
    * dropbear 0.51
    * dtmfbox 0.4.1_rc4
    * freetype 2.3.5
    * fuse 2.7.2
    * glib3 2.12.13
    * haserl 0.9.24
    * inadyn 1.96.2
    * inotify-tools 3.13
    * libelf 0.8.10
    * libevent 1.3e
    * libdevmapper 1.02
    * libid3tag 0.15.1b
    * libobenobex 1.3
    * libpcap 0.9.8
    * libpopt 1.13
    * lua 5.1.3
    * mc 4.6.1
    * mtr 0.72
    * nano 2.0.7
    * ntfs-3g 1.2506
    * obexftp 0.22
    * openntpd 3.9p1
    * openssl 0.9.8g
    * openvpn 2.1_rc7
    * php 5.2.5
    * pjproject 0.8.0
    * rrdtool 1.2.27
    * screen 4.0.3
    * sispmctl 2.6
    * strace 4.5.16
    * streamripper 1.62.3
    * stunnel 4.24
    * tcpdump 3.9.8
    * tor 0.1.2.19
    * transmission 1.20
    * vpnc 0.5.1
    * zlib 1.2.3

- Remove packages, libs, modules, tools:
    * removed firewall-cgi
    * removed orange box
    * removed samba 2.0.10

- Firmware updates:
    * Nearly all firmware version were updated since the last release. Please
      see FIRMWARES for the list of currently supported boxes and firmwares.

- BusyBox:
    * updated to version 1.9.2
    * removed symlinks to non-existing applets
    * make some additional busybox features configurable in menuconfig

- Web interface:
    * Freetz
        + generally, the Freetz-webinterface was updated to be more standards-
          compliant, load faster, allows for larger amounts of input data, and
          looks better with different screen resolutions and settings
        + the width of the webinterface display is now configurable
        + status of mass storage devices can be displayed in webinterface
        + more pages are localized
        + some actions like saving package options are more verbose
        + implemented avm-firewall web interface
        + implemented webinterface for samba package
        + added simple web interface for mini_fo
        + added favicons by cuma and han-solo
    * AVM
        + orange box was removed because it is outdated

- Other stuff:
    * DSMod was completly renamed to Freetz
    * new unix-conform user management
    * help texts in menuconfig extended and clarified
    * autorun/autoend functionality for mass storage devices
    * use tmpfs instead of ramfs for /var
    * enabled more packages for inetd
    * recover-eva:
        + fix error that tools/tar wasn't found on some systems
        + fix booting kernel image directly from RAM
    * fwmod:
        + add FWMOD_PATCH_TEST and FWMOD_NOPACK environment variable
          By setting these to y the build process can be interrupted after
          patching the firmware respectively before packing the firmware.
        + use "-no-exports, -no-progress and -no-sparse" as additional
          parameters for squashfs3
        + optimise the way FILESYSTEM_BLOCKSIZE is determined
    * kernel:
        + activate EPOLL support (needed by AVM phone book daemon (pbd))
        + reactivate "replace kernel" for firmwares with up to date sources
        + add kernel patch for squashfs3
        + add kernel patch for ip_conntrack:
            + don't calculate hashsize, use 256 buckets
            + ip_conntrack_tcp_be_liberal=1
    * add extract-images, a little heuristic (and not very fast) tool which can
      extract bootloaders (urlader.image) as well as hidden root kernel +
      SquashFS images (kernel.image) from any type of compound file,
      e.g. recover-EXEs.
    * add hexgrep, an awk-driven tool for matching hex sequences in input files
      It shows decimal file offsets as well as the matched sequences, because
      the latter are regex-matched and can thus vary.
    * add shell script for unpacking LZMA-compressed Linux kernel to tools
    * Rename tools/push_firmware.sh to tools/push_firmware and
      tools/lib_report.sh to tools/lib_report in order to unify naming of shell
      scripts tools/*. For instance, tools/ds_* do not have '.sh' extensions
      either.
    * add 64-bit fix for TI-chksum

### ds26-15.2

- Build system:
    * Makefile: be more tolerant towards users of SUSE oder Mandriva
      distributions using inofficial GNU diffutils-2.8.7 package (official
      version is 2.8.1) by using '-U 0' instead of '-u0'.
    * push_firmware.sh: add heuristic check for 'kernel.image' magic bytes and
      for firmware tar image erroneously specified as parameter. Add required
      package 'util-linux' for 'hexdump' to cygwin prerequisite notes.
    * fwmod: include .config and addon/static.pkg into firmware image for
      further reference, e.g. user support
    * Menuconfig online help: more precisely describe that each firmware needs
      not only at least one branding, but that this branding must correspond
      to the one defined in the boot loader environment. The shell command for
      determining it is also provided in the help text.
    * GCC 4.2.1
    * Binutils 2.17.50.0.17
    * Add "replace kernel" capability to Speedport configurations by
      integrating T-Com GPL sources (r4884 for W701V & W900V, r7203 for W501V)
    * Move definition of VERBOSE variable from make/Makefile.in to Makefile,
      because it is not only used for packages, but also for tools and
      toolchain. I had errors during "make tools", because in my local
      environment, there was VERBOSE=no, and such effects should be avoided.
      Maybe we should think about a main Makefile.in.
    * Libmudflap not needed in toolchain (gcc.mk),
      cf. https://dev.openwrt.org/changeset/7531
    * uClibc: remove AVM_VERSION form config so there is only one config file
      for all versions, because there were no differences between versions
      except LFS.
    * Move 'modpatch' shell function to tools/ds_patch and dot-include it from
      there.
    * ds_patch works as usual and still reacts to DS_VERBOSITY_LEVEL and
      AUTO_FIX_PATCHES. Some improvements:
        + script can also be executed directly
        + check for valid number of paramaters
        + usage help
        + new optional 3rd parameter for 'patch -p' path level
        + react to "$VERBOSE"=="-v" with verbose output so as to be prepared
          for script calls from *.mk which are planned to replace direct
          'patch' calls. This should help leverage the auto-fix feature to
          tools, package and toolchain source code patches in the future.
        + handle case of empty original file
        + add unsupported, but practical little function 'strip_patch_level'
          which was used to unify 200+ patches.
    * Makefiles *.mk: replace all direct calls to 'patch' from *.mk by calls
      to newly defined variable 'PATCH_TOOL:=$(TOOLS_DIR)/ds_patch'.
    * Canonise all source code patches to patch level 0 (-p0). Auto-fix a lot
      of patches by calling all available *-source targets from tools,
      packages and toolchain. Statistics: 250+ patches checked, 70+ updated.
      200+ hunks did not fit perfectly and were auto-fixed, 34 of them with
      fuzz 1 (18) or fuzz 2 (16).

- New packages, libs, modules, tools, hooks:
    * Integrate Media Server from USB Labor (by derheimi) for boxes with USB
      host; needs testing
    * Rrdtool 1.2.23
    * Collectd 4.0.5
    * Libart 2.3.19
    * Libfreetype 2.1.10
    * Libpng 1.2.10
    * GLib 2.12.12 (lib version 0.1200.12)
    * Libiconv 1.9.1 (lib version 2.2.0)
    * Gettext (libintl) 0.16.1 (lib version 8.0.1)

- Updated packages, libs, modules, patches:
    * NetSNMP bugfix provided by derheimi
      (cf. http://www.ip-phone-forum.de/showpost.php?p=902808)
      and upgrade DS-Mod package version to 0.4b
    * NTFS-3G 1.710
    * Tor 0.1.2.16: critical security bugfix, see
      http://archives.seul.org/or/announce/Aug-2007/msg00000.html;
      major bugfixes as described in
      http://archives.seul.org/or/announce/Jul-2007/msg00000.html.
    * Ctorrent dnh3.2
    * Haserl 0.9.18 featuring FIFO (pipe) upload capability, so an uploaded
      archive ist not stored on the box twice (packed and extracted), but can
      be uncompressed on the fly. This is used by the new firmware update
      assistant (see below).

- Firmware updates:
    * 7170: Labor DSL 29.04.99-7995
    * 7170: Labor WLAN 29.04.98-8020
    * 7140: integrate international versions
        + English, annex A: 39.04.34
        + English, annex B: 30.04.34

- BusyBox:
    * wget patch provided by RalfFriedl: URL with user/password does not work.
      Uuencode needs string length, not buffer length. NOTE: fixed (in a
      different way) in upstream since rev. #18955, thus patch can be removed
      in the future.

- Other stuff:
    * DS-Mod web interface, part 1: layout and language
        + Change layout a little bit: Both graphical bars now show the
          percentage on the right hand side of the bar. Both bars show usage
          information in a common way ("x of y KB used").
        + Rearrange buttons on the bottom so they are all the same size,
          resulting in a cleaner layout. Also reorder them so as to make
          "reboot" the last one.
        + Update some de/en language strings (only on main screen, not on
          subscreens)
    * DS-Mod web interface, part 2: new firmware update button
        + The new update assistant lets the user select a FW image and choose
          if he wants to stop AVM services before flashing
          (prepare_fwupgrade).
        + After successful upload, the FW is extracted (tar) and /var/install
          is called.
        + Subsequently the output of all steps is shown to the user along with
          the content of /var/post_install, if it exists.
        + It is then up to the user if he wants to reboot ("real" FW update)
          by clicking the corresponding button on the main screen or continue
          working without a reboot (pseudo update for installing/activating
          some add-on not requiring FW flashing).
        + Even if /var/install has been executed successfully and
          /var/post_install has been created, the user may choose to manually
          delete post_install in order to interrupt the firmware update
          process, because if a reboot takes place later and post_install is
          not available, the firmware will not be flashed, even if
          /var/tmp/kernel.image still exists. This provides the user with
          maximum flexibility (and self-responsibility).
        + Talking about self-responsibility: The assistant does NOT stop any
          DS-Mod services. If and which ones should be stopped is up to the
          user who should make up his mind and act accordingly BEFORE clicking
          the update button.
    * Auto-select vfat.ko in order to overwrite AVM's buggy fat and vfat
      modules with our own versions, because they segfault. This auto-
      selection can be reverted as soon as AVM provides fixed firmwares.
    * NTFS-3G + FUSE: fix problems
    * Several NetSNMP makefile fixes
    * 2170: change kernel layout from ar7 to ohio
    * Bintuils: add patch by spambin + several other patches and enhancements
    * Mtr: forgotten dependency ncurses
    * Transmission: fix problem with ar and ranlib
    * W900V: 5 answering machines are better than one
    * Kernel patches: add + update several ones
    * Rcapid: because of ongoing download site access problems, rcapid.tgz was
      put on our mirrors, which is not a licence problem because of the GPL
      the package is under. Thus, the source package is now downloaded using
      tools/ds_download.
    * Inotify-tools: fix typo in makefile
    * W501V: fix firmware patches (don't replace multid, don't copy igdd and
      libs, use 7141 as tk-firmware)
    * Speedports: symlink '/usr/www/<oem>' should always point to
      '/usr/www/all', not just 'all', otherwise LCR Auto Updater cannot be
      initiated properly (mount -o bind failure)
    * 300IP as Fon: fix symlink (boot failure after factory reset)
    * Libelf was missing in make/libs/Makefile.in
    * W701V: fix kernel oops
    * W701V: update web interface by adapting patch to Speedport2Fritz
    * Kernel build: disable NTFS module, enable UnionFS module
    * Gdb for target: fix makefile; add GDB_STAGING_DIR and make it order-only
      prerequisite for gdb target binaries, so the directory is created on
      demand
    * Libffi-sable: fix download URL
    * OpenSSL: build with zlib-dynamic
    * tools/depmod.pl: dos2unix line feeds


### ds26-15.1

- Build system:
    * Add "SHELL:=/bin/bash" to Makefile because of this:
      http://www.ip-phone-forum.de/showpost.php?p=896043
      I.e. the build now explicitly requires bash instead of sh, so we can use
      extended file name expansion functionality.
    * New target 'push-firmware' runs tools/push_firmware.sh to conveniently
      flash a recently build firmware
    * New target 'config-clean-deps' automatically deselects all kernel
      modules, shared libraries and optional BusyBox applets which are not
      selected by packages explicitly requiring them.
    * Add sanity checks to Makefile:
        + Do not run make as root
        + Heuristic check for falsely unpacked mod archive
      kriegaex: Thanks to Ralf Friedl for this idea, even though I implemented
      the checks in a different way technically. :-)

- New packages, libs, modules, tools, hooks:
    * Mtr 0.69: mtr combines the functionality of 'traceroute' and 'ping'
    * Espeak 1.27
    * Downloader CGI 0.1 by hermann72pb (ip-phone-forum.de)
      See http://www.ip-phone-forum.de/showthread.php?t=134934

- Updated packages, libs, modules, patches:
    * Midnight Commander (MC) pimp-up without version bump:
        + Remove 143 KB of unnecessary syntax highlighting definitions in 22
          files, because MC 4.5.0 only supports hard-coded syntax highlighting.
          Thus, the additional files were never used. The fascinating thing is
          that nobody ever complained about this, so the other language types
          do not seem to have been missed. Still supported are unified diff,
          LSM, shell script, Perl, Python, nroff (man-page source), HTML,
          Pascal, LaTeX 2.09, C/C++, change-log, makefile. Others would have
          to added inline to the source code.
        + Update MC default settings, hopefully nobody will complain:
            + Editor tab width changed from 8 to 4
            + Learn keys set to values which putty sends with TERM=xterm in
              telnet and ssh sessions. The assumption here is that most users
              probably use Putty on WinXP as their preferred terminal client.
              Other users can still create their own ~/.mc/ini in debug.cfg or
              otherwise, assuming that if they are Linux users who need this,
              they probably are more geek-ish than Windows users.
            + A few other minor changes which I (kriegaex) had in my
              long-tested private ini-file
        + Online help is a separate menuconfig option now. If chosen, the file
          (115 KB) will be copied from the source to the package directory,
          otherwise the file will be removed.
        + Syntax highlighting is a separate menuconfig option now. If switched
          off, this saves  70 KB in the main binary.
          Known problem: If syntax highlighting is deativated, somehow mcview
          does not start the internal MC viewer directly anymore, but yields
          the normal MC user interface. Anyway, viewing files with F3 from
          within MC still works.
        + Internal editor mcedit (activated by F4) can be decativated in
          menuconfig. If you want to use vi or nano instead, F4 will still
          work. By default, vi is called on the box, but exporting EDITOR so
          it points to another editor of your choice will get you the
          combination of file manager and editor you desire. :-) Switching off
          this feature saves another 86 KB in the main binary.
        + The defaults for the new menuconfig options generate a binary with
          the feature set known from the last package version.
    * DTMFbox:
        + Fix scriptadmin.sh
        + Add espeak (see "new packages" above)
    * Callmonitor 1.9.7 tries to fix performance problems with too many
      parallel automatic reverse phone number lookup during start-up. This
      could freeze a box so it had to be recovered.
    * Libncurses 5.6
    * Checkmaild 0.4.2: fix segfaults
    * OpenVPN package fixed (one file in package without LZO was not
      executable)
    * Dnsmasq: make dnsmasq aware of possible igdd (UPnP server) absence, so
      it starts multid without UPnP. Furthermore, fix a few quoting problems
      possibly leading to errors during start-up. Hopefully, this fixes some
      of the recently reported problems (untested).
    * Vpnc: increase username maximum length to 40 characters
    * FUSE 2.7.0 plus fix: includes were not installed into toolchain
    * NTFS-3G: remove mknod and replace insmod with modprobe
    * Cpmaccfg 0.4
    * Netsnmp: fix package so defaults are applied correctly
    * Update and fix several firmware patches (also see "other stuff" below)

- Firmware updates:
    * 5050: firmware 08.04.34
    * 3020: firmware 09.04.34
    * 3030: firmware 21.04.34
    * 7170 Labor WLAN: firmware 29.04.35-7816
    * 5140 (NEW): firmware 43.04.37 - welcome to the ds26 family ;-)
    * 7170: firmware 29.04.37
    * 7141: firmware 40.04.37
    * W701V: set 29.04.37 as tk-firmware

- Other stuff:
    * Wrap /sbin/ar7login with shell script in order to achieve normal
      user/password logins with telnet, even if telnetd is started with
      explicit ar7login parameter by 'telefon' (hard-coded). Exception: If no
      root password has been defined yet, proceed to renamed ar7login.bin for
      web password login.
    * Extend editor wrapper script to support disabling of the "do you really
      want to save" question. How to: echo 0 > /tmp/flash/ask_save; modsave
    * AVM web menu: Once more change the way the host part of the target URLs
      is determined. The host name might not always be a good idea if there
      are multiple boxes with the same host name in one LAN, e.g. a 7170 and a
      "fritzed" W701V both named "fritz.box". Where would
      "http://fritz.box:81" really point to, then? So in this case usually the
      user will call their respective web UIs using their local IPs, and this
      is what our scripts see in their environment as part of HTTP_REFERER. We
      pick out the host/IP part and use it as our target host/IP for the
      redirection to the DS-Mod or WoL web UI.
    * Improve script tools/push_firmware.sh so it accepts an optional IP
      parameter (not all boxes have 192.168.178.1)
    * Yet another push_firmware.sh improvement: script is now Cygwin-enabled
      (needs ncftpput command line client from ncftp package), so a firmware
      can also be easily updated from Windows via command line. This does NOT
      mean that ds26 could be built on Cygwin, so please do not ask about it.
    * Bugfix for "Eumex 300IP as phone" 3rd phone patch
    * Midnight Commander (mc): fix missing terminfo problem
    * Fix FUSE install (fuse.pc was not copied, thus pkgconfig could not
      detect it)
    * Ppppd: fix missing prerequisite (libpcap)
    * Set eumex.ip as hostname for 300ip_as_fon
    * Fix OpenSSL compilation with gcc-4.2 (also helps with dependent OpenVPN
      problems)
    * Add 'chmod 755' for libreadline/libhistory so they are executable
    * Allow BusyBox to install applets to /usr, e.g. telnetd is now under
      /usr/sbin insetead of /sbin, because 'telefon' is looking for it there
      when a user tries to switch it on via "#96*7*".
    * Fix typo in PPPD make file: TARGET-CFLAGS -> TARGET_CFLAGS
    * Fix CFLAGS for several other packages
    * Extend "remove UPnP" patches to make rc.S aware of possible dsld
      parameter '-g' for starting without igd
    * W501V: Copy ar7login from TK firmware to ds-mod filesystem, because the
      501 does not contain this binary by default. Background: ar7login is
      needed if a console login with the web password should be performed,
      e.g. in telnet sessions.
    * Orange!Box patch failed for W701V -> create patch variant for Speedport
    * W701V build: fix copy routine for defaults
    * Add patch for W900V (diff from 7150 web UI to sp2fritz web UI)
    * Speedport boxes:
        + ATA patch did not work as expected on the Speedports (at least W501V
          and W900V): rc.S needs to be patched, too. This makes ATA avaiable
          to the Speedports.
        + Add patch that should fix password problem after reset to factory
          defaults
        + Force favicon symlink to avoid warning
    * Fix Tcpdump CFLAGS
    * Device tables, mounts etc.:
        + Add /dev/misc/fuse to device.table
        + Remove devpts mount in rc.S
        + Add /dev/pts to device.table
        + Fix mount of /dev, /var, /proc and /sys
        + Put fstab patch in own file, should be the same for all boxes
    * Tor / libevent: disable epoll support in libevent due to unresolved
      problems. This fixes recently reported Tor segfaults.


### ds26-15.0

- Many makefile changes, some big, some small, some cosmetic, to
    * make default target indirectly dependent on 'precompiled':
        + simple 'make' now also executed 'precompiled'
        + old 'firmware' target renamed to 'firmware-nocompile'
        + new 'firmware' target depends on 'firmware-nocompile' and
          'precompiled'
        + The purpose of 'firmware-nocompile' is to enable users to build a
          firmware manually in special cases (e.g. 'precompiled' failure or
          the wish to build packages containing binaries).
    * make the hierarchical build more consistent,
    * avoid spurious unnecessary rebuilds,
    * no longer support "external compiler" option in menuconfig. This means
      that ds26 does not support external toolchains anymore, because we assume
      that experts who need this will manage to set it up by themselves using
      links etc.
    * add makefile prerequisites for target binaries so as to avoid files
      being stripped and copied unnecessarily. How to:
        + avoid doing anything in synthetic targets like xy-precompiled
        + make sure to have targets for source binaries as well as target
          binaries (e.g. source/xy-1.3/src/xy and
          packages/xy-1.3/root/usr/bin/xy)
    * add xy-uninstall to all packages and shared libs,
    * update make files of eight (8) packages which have sub-options
      influencing the build result in menuconfig, so they are automatically
      rebuilt whenever a relevant option has changed. The packages are: Bftpd,
      Bird, Dropbear, OpenVPN, Apache, PHP, Tinyproxy, Nano.
      This was achieved by the following structural changes in *.mk:
    * add config option "all modules", if "replace kernel" is active,
    * add oldconfig targets for kernel and busybox
    * make more packages work with + without LFS (large file support)
    * compile gcc with "--with-float=soft",
    * not always include toolchain stuff into big makefile,
    * add libgcc_s to DS_INSTALL_BASE (i.e. it will always be installed)
    * add each single 'tools' package to 'noconfig_targets',
    * make DL_DIR and PACKAGES_DIR order-only prerequisites for many dependent
      targets,
    * rename busybox-tools targets so they do not collide with busybox package
      targets anymore, but adhere to naming conventions instead,
    * add menuconfig bub-section for a few BusyBox applets (currently inetd,
      ar, diff, patch - see below in BB section), so they can be chosen
      directly from the main configuation dialog (Advanced options -> BusyBox)
    * 'make %lib%-clean' will now remove files from toolchain and
      root/(usr/)lib
    * new make macro INSTALL_BINARY_STRIP for more easily and cleanly
      stripping and installing binaries
    * delete firmware images in common-clean, fix delete command,
    * get make structure more in sync with Buildroot,
    * create a clearer dependency structure and
    * achieve world domination in general...

- Multi-job build improvements:
    * Added new config option for multiple jobs. This can now be configured in
      menuconfig.
    * New multijob config option will be used for kernel toolchain, target
      toolchain, libs and packages.
    * Targets that cannot be compiled with multiple jobs should use $(MAKE1)
      instead of $(MAKE).
    * multijob.sh is not needed anymore and will be removed in future releases.
      It now does not do anything anymore, just prints a "deprecated" warning.
    * Target "packages-precompiled" is removed because it is obsolete with these
      changes.

- Enhance fwmod,
    * so it can be used to handle FW images by either specifying an
      alternative DOT_CONFIG file name or by explicitly providing command line
      parameters for often-used settings needed to unpack different firmware
      versions. Just call fwmod without any parameters to get a proper
      description. BTW: The DOT_CONFIG alternative may be a very small file
      consisting only of about five settings, if fwmod is just used to unpack
      (-u) an image.
    * output name of rejected patch file during build in fwmod,
    * create functions for echo, beautify symlink creation in fwmod,
    * include timestamp into firmware name,
    * add new menuconfig setting DS_DEVELOPER_VERSION_STRING so as to
      optionally include SVN repository revision numbers into
        + firmware image name
        + target file /etc/.subversion
        + target script /etc/version
    * make patch output a little more informative + readable in verbosity
      level 2: print patch file names and separator lines ("---...")
    * fix typo: libc.so.0 was not copied into firmware, but as it already
      exists nobody noticed this.
    * New feature for modpatch: If $AUTO_FIX_PATCHES == "y", then the applied
      patch is analysed and automatically fixed, if fuzzy. Now what the h...
      does that mean and how does it work?
        1. Perform dry run in order to check if the patch will be both
           successful *and* fuzzy (i.e. containing moved or fuzzy-fitting
           hunks).
        2. If so, enter auto-fixing mode and generate a list of all files
           changed by the patch.
        3. Apply patch with the option to create a 'foo.orig' backup for each
           patched file 'foo'.
        4. Finally, auto-fix the original fuzzy patch by creating a new one,
           cycling through each pair 'foo.orig' / 'foo', creating a fresh
           'diff' for them, but preserving the old patch as 'xy.patch.orig'.
        5. The 'foo.orig' files are cleaned up once they are not needed
           anymore, but the 'xy.patch.orig' files are being kept so they can
           be compared to their auto-fixed versions. Nobody is perfect, so a
           closer look should be taken.
      The next time 'fwmod' is run with the newly created, polished-up
      patches, they should all fit perfectly - no moved hunks, no fuzzy
      matches. As an exception, modpatch does not try to fix patches
      containing failed hunks but exits 'fwmod' as usual in this case, because
      the patch needs to be fixed anyway. It should be enough to fix it
      roughly so it can be applied as a fuzzy patch - modpatch can do the rest
      in the next run. ;-)

- New packages, libs, modules, tools, hooks:
    * Added section 'debug helpers' in menuconfig
    * Debug helper package strace (binary only)
    * Binary package inotify-tools (inotifywait, inotifywatch), including
      patches to inotify-enable uClibc
    * Init script for inotify-tools file access logging (via inotifywait)
    * New shell function API (/usr/bin/kernel_args) to handle variables
      defined via boot loader environment variable 'kernel_args' (found in
      /proc/sys/urlader/environment). A limited set of values are allowed for
      variables: integer values >= 1 or 'y'|'n'. This makes it easy to handle
      cases like this:
        + Permanently (de-)activate certain functionalities during the system
          init process such as logging, mini_fo overlay file system etc.
        + Temporarily activate those functionalities by assigning a countdown
          value to them, e.g. 'FooBar=3 -> 2 -> 1 -> n', so after a certain
          number of reboots the functionality would deactivate itself. This
          can be helpful if you want to make sure that a box not booting up
          with an activated feature for any reason does not get a recover
          case, but heals itself be just booting up a number of times, until
          the countdown is down to zero, setting the corresponding variable's
          value to 'n'.
    * Boot-time hooks for /etc/rc.S to activate both
        + inotify-tools file access logging and
        + dmesg (klogd ring-buffer) output so as not to lose its earliest
          entries because of the small buffer size of 16 KB.
      Both logging features use the kernel-args API (/usr/bin/kernel_args)
      in order to dynamically determine if they should be activated during the
      boot process.
    * Debug helper package ltrace 0.5-svn-77 (binary only)
    * Libelf library needed by ltrace
    * Debug helper package lsof 4.78, binary-only
    * Spindown-CGI and sg3_utils (by IPPF user 'derheimi')
    * Libusb added to menuconfig
    * Apache 1.3.37 + PHP 5.2.1 package group added. Please cf. menuconfig
      online help (press 'H' at packages / testing / Apache + PHP) for more
      information and/or check out http://www.ip-phone-forum.de/showthread.php?t=127089
      for tips, tricks, patches and extensions.
    * Ctorrent dnh3.1
    * Bluetooth kernel modules
    * Nano editor 2.0.6 incl. a set of ten (10) different build options for
      inclusion of more features at the cost of some disk and RAM space;
      options are extensively documented in menuconfig online help.
    * OpenNTPD 3.9p1
    * Netcat 0.7.1
    * Libcapi20, Common ISDN API (CAPI) 2.0 library 3.0.4 (needed by rcapid)
    * Rcapid, Remote CAPI daemon 0.1 from isdn4linux (by Nicolai Ehemann)
    * DTMF-Box 0.3.9 (by Bodega) with pjsip (statically compiled)
    * Add generic editor wrapper script 'wrap_editors' which can handle files
      in /var/flash, /var/mod/etc/conf and /var/tmp/flash and call multiple
      editors via symlinks. Now all n/m-scripts (nvi, mvi, nmcedit, mmcedit,
      nnano, mnano are just symlinks to 'wrap_editors'.
    * New helper script 'tools/lib_report.sh' generates a report showing which
      DS-Mod binaries depend on which shared libraries. Usage:
        tools/lib_report.sh [<ds-mod base directory> [<fw base directory>]]
        ds-mod base directory defaults to '.'
        fw base directory defaults to 'build/original/filesystem'
      I.e. the easiest way to call the script is from ds-mod base without
      parameters in order to get a report about the original file system. Call
      tools/lib_report.sh . build/original/filesystem to generate a report
      about the modified file system.
    * New helper script 'tools/push_firmware.sh' to flash a 'kernel.image'
      directly to mtd1 using FTP via ADAM2. This is a convenience function for
      people who are tired of typing in these commands every time. Use at your
      own risk!
    * Two new EXPERIMENTAL patch options for menuconfig directly on the
      front page:
        1. Replace AVM websrv by BusyBox httpd and remove web server from
           firmware image. /etc/init.d/rc.websrv starts + stops httpd on
           port 80.
        2. Remove UPnP daemon (igdd) including two libs, several UPnP XML
           schemes and a GIF image.
      If both 1 + 2 are chosen, libwebsrv also becomes obsolete and will be
      removed, because only those two daemons seem to use it. All in all,
      those two features in combination make kernel.image about 76 KB smaller
      on my 7170. The figures should be similar for other boxes. Furthermore,
      not starting igdd + libs and using the smaller httpd instead of websrv
      should also save a considerable amount of RAM. both effects are
      especially desireable for smaller boxes like 5050/7050.
     * pppd 2.4.3

- Updated packages, libs, modules:
    * (Download) toolchain (target)
        + add gcc-4.2.0 + binutils 2.17.50.0.16 and make them default
        + Remove uclibc download package for download toolchain, instead
          copy libs from toolchain
    * BusyBox 1.5.1 (target and tools instances)
        + a few applets are chosen by mod packages requiring them:
          Debootstrap -> ar, Inetd-CGI -> inetd
        + a few applets can be selected from DS-Mod menuconfig, indirectly
          changing BB configuration: diff, patch
        + getcons applet reactivated (broken patch finally repaired)
        + fix stty option parsing, reactivating old 100-profile.patch
        + activate command line editing + tab completion for 4mb_26
        + patch that fixes shifted usage messages (--help)
    * Inetd support for several server daemons (Telnetd, DS-Mod Web UI,
      Dropbear)
    * Lua 5.1.2
    * Ntfs-3g 1.516
    * Callmonitor 1.9.5
    * Syslogd-CGI 0.2.2: allow rotating log files with a value of '-b 1'
    * SquashFS 2.2-r
    * Lzma 4.43
    * Iptables 1.3.7
    * Classpath 0.95
    * FUSE 2.6.5
    * Dnsmasq 2.39
    * Transmission 0.72
    * Libevent 1.3b
    * Tor 0.1.2.14
    * Rudi-Shell: save screen real estate by suppressing HTML H1 element
      "Rudi-Shell"
    * Cifsmount package 0.2 features a CGI (web config) interface for up to
      three mounts, start/stop scripts and convenience script 'cifsmount' for
      more easier command line (un-)mounting.
    * Debootstrap build process simplified by removing the "convert Debian
      package to DS-Mod package" intermediate staging step and providing an
      extensive description about how to build + update the DS-Mod package in
      packages/debootstrap-0.3.3.2/README instead. This results in
        + an updated download package 0.2 with mentioned README and without
          binary
        + the removal of 01_trap.patch (patched file is part of DS-Mod package)
        + a dramatically simplified debootstrap.mk
    * CRC_CCITT compiled as kernel module (Config.4mb_26)
    * Fakeroot 1.7.1 (build tools section)
    * uClibc++ 0.2.2
    * Libpcap 0.9.6
    * Tcpdump 3.9.6
    * OpenVPN 2.1-rc4 (incl. option for management console)

- Firmware updates:
    * 7170 Labor USB 29.04.34-7553
    * 7170 Labor Phone 29.04.34-7269
    * 7170 Labor VPN 29.04.34-7728
    * Add 7170 Labor DSL 29.04.34-7584
    * Add 7170 Labor WLAN 29.04.35-7787
    * Remove 7170 Labor Eco support , because it is obsolete. Its features
      have been included into the current regular firmware releases.
    * 7150 firmware 38.04.32
    * 7050 firmware 14.04.33
    * FB Fon firmware 06.04.33
    * Add FB Fon WLAN firmware 08.04.33
    * Add Eumex300ip, uses Fon firmware 06.04.33
    * Add 3130 WLAN firmware 44.04.34
    * Add Speedport W501V (original fw 28.04.38 + 7140 fw 30.04.33)
    * Remove 7140 international (kernel 2.4.17_mvl21)
    * Add AVM web interface for W900V
    * Extension for W701V: /sbin/mailer is copied from tk-firmware
    * Add ATA Patch for W701V and W900V (Inet over LAN A)
    * W900V: make web interface available for OEM=avm
    * W900V: copy modules from tk-firmware
    * W900V: add patch to copy libgcc_s.so.1 from AVM firmware to modified
      DS-Mod firmware. This is just a temp solution, as the original T-Com
      firmware does not have libgcc_s.so.1 - and since a lot of DS-Mod's
      stuff  needs this lib, you sould install it ;)
    * W701V: integrate copy modules: modules are copied from tk-firmware
      (29.04.33), so self.built kernel can be used
    * W701V: accept OEM avm
    * W501V, W701V, W901V: copy igdd from AVM firmware, so UPnP can be used
      with the "fritzed" Speedports, too. The patch to remove UPnP can also
      be applied (no, don't say it!).
    * run_mount patch enables all firmwares with USB host to mount all file
      systems, not just FAT

- Other stuff:
    * Fix about 150 or so patches to apply cleanly without any failures or
      even fuzzy matches
    * Fix tools/ds_download  (fallback mirror download did not work)
    * Mount sysfs to /sys, symlink /var/sysfs to /sys
    * New BusyBox httpd patch to make it work better with symbolic links in
      CGIs, effectively enabling it to be used as an AVM  websrv replacement
    * Sync uclibc.mk with buildroot structure
    * depmod.pl moved to tools directory and removed from kernel build
    * Fix netsnmp build (fails with multiple jobs)
    * Fix bird build (fails with multiple jobs)
    * Mention 'make precompiled' in previously outdated README
    * Add uClibc config for 04.30
    * Fix typo in make/libs/Makefile.in concerning libpcap, making it
      dependent on libncurses config switch accidentally.
    * Fix awk segfault (busybox) when called without any parameters
    * Clean up some obsolete code in Config.in and fwmod
    * Fix small error in netsnmp package (update to 0.3): create /var/lib/snmp
    * Mod version number now says ds26-14.x rather than ds-0.2.9-14
    * Bugfix for tools/busybox: make-include tried to apply all tools patches
      instead of only busybox-specific ones.
    * Remove cygwin howto because it's out of date
    * Add several fallbacks for CGI variable HTTP_HOST missing in BusyBox
      httpd into files /usr/bin/dsmod_{status,wol}. Note: This is a
      workaround, normally httpd should be enhanced. A corresponding request
      was sent to the BB mailing list.
    * /usr/bin/modload: don't exit if loading /var/flash/ds_mod fails but
      create new file
    * Add patch that opens a controlling tty instead /dev/console; cf.
      http://www.busybox.net/lists/busybox/2007-May/027448.html
    * Remove terminfo stuff from MC, Nano and Screen packages, because it can
      be copied from the toolchain staging dir.
    * Activate unionfs module build in kernel configs
    * Change name of kernel config files to differentiate between ar7 and
      ohio. Until lately, all 4mb boxes were ar7 and all 8mb boxes were ohio.
      Since W501V we have a 4mb ohio box, so the old naming scheme has become
      inappropriate.
    * Replace package URLs (eiband.info -> magenbrot.net) because Danisahne
      will soon discard his domain name. eiband.info ist still mentioned in
      several package README files, but I do not care, because this is plain
      cosmetics. (kriegaex: And Daniel deserves credits anyway, anywhere.)


### ds26-14.4

- Busybox patch for 'ash' shell: When a remote client (e.g. ssh) was killed,
  the remaining shell process would get into an endless loop stressing the CPU
  with >90%, making the system slow, unresponsive and possibly instable.
- Rudi Shell: new optional environment variable (or non-GUI POST parameter,
  respecively) FORM_download_name enables users to define a target name for
  files downloaded via scripting.
- Menuconfig: help texts for all brandings explaining briefly what a branding
  is and explaining that at least one of them should be selected for the
  firmware to work.
- Bump callmonitor version to 1.9.2
- Fix busybox rebuild when config changes (copied from openwrt)
- Add FritzBox Fon (06.04.30) to ds26
- Disable CONFIG_KMOD kernel option (module auto-loader) because of missing
  symbol in original kernel. This is needed to make iptables run smoothly, but
  also makes it necessary to load iptables modules with modprobe or insmod.
- Update Firewall CGI to explicitly use modprobe/rmmod, because CONFIG_KMOD
  was removed from default kernel config
- Version update for USB and VPN 'labor' firmware (AURA 7125, VPN 6937)
- Ntfs3g: bump version to 1.417
- Fix typo in make/avm-gpl/avm-gpl.mk
- Minor menuconfig improvements:
  * Don't show open source package selection, always usedefault (currently
    04.30 for 7141, 04.29 for all other supported boxes)
  * Rename "firmware type" to "hardware type"
  * Rename "firmware version" to "firmware language"
- Kernel build: do not use /sbin/depmod while cross-compiling
- Integrate new AVM open source package (7141-04.30)
- Bftpd: bump version to 1.8 and update download site
- Fix typo in toolchain/make/target/uclibc/uclibc.mk causing make to always use
  the precompiled uClibc, the manual build never got fired.
- Update Speedport W701V to firmware version 33.04.26
- Improved menuconfig tool adopted from buildroot2:
  * Comprehensive online help
  * Options' help texts also show dependency information:
    + Which condition(s) does an option depend on?
    + By which other option(s) was an option selected?
    + Which other options does an option select?
    + Where is an option defined (file name + line no.)?
  * Seach mode: wildcard search for option names via "/" hotkey.
    By the way: search mode also has online help.
- Added download mirror #3 to Config.in
- tools/make/busybox-tools.mk: activate download target on demand to avoid
  collision with identical target for regular busybox on one hand and to
  avoid make complaining about a missing target when building tools busybox
  from scratch on the other hand.
- tools/ds_download: changed 'od -D' to 'od -d' to make it compatible with
  old versions of GNU coreutils (e.g. od 5.2.1)

### ds26-14.3

- Cross-cutting changes in ds-mod-specific package download:
  * New shell script tools/ds_download provides a uniform way to download
    ds-mod-specific packages such as application and add-on packages as well
    as precompiled toolchains. The script first checks a predefined list of
    download servers (mirrors) and only uses an optionally provided "original"
    server as fallback, which is important for new package versions not
    available on mirrors yet.
  * New variable DL_TOOL in Makefile points to tools/ds_download
  * List of download sites (mirrors) can be edited in menuconfig (Advanced
    options -> DS-Mod package download sites). Currently there are five slots
    for download servers, two of which have default values. Two others are
    reserved for later use and #5 is freely editable by users. This enables
    users to set up their private mirrors on their own LAN or WAN servers.
  * *.mk files loading mod-specific packages have all been made "mirror-aware",
    i.e. they all call DL_TOOL with the appropriate parameters. Specifically,
    all former primary download sites have been preserved as fallback servers.
- Major menuconfig restructuring. For example (there is more):
  * Iptables' shared libs and kernel modules are dependent on a top level
    setting and can be deselected as  whole groups.
  * JamVM + classpath + ffi-sable can now be found in one place and are also
    interdependent.
  * Sub-menus in packages section
  * Major case first letters in package names
  * More and improved menu descriptions
  * Removed redundant library descriptions for iptables and classpath stuff by
    putting them in groups (see above).
  * Some changes in include structure ('source' commands in Config.in files),
    e.g. several libs' descriptions are now closer to their required top level
    applications.
- Fix firmware build: iptables binary was always included in image, even if not
  selected in menuconfig.
- Fix syslogd ring buffer size parameter leading to "Starting syslogd...failed";
  package version updated to 0.2.1
- Mini_fo package now listed as regular package, not "testing" anymore (no
  known problem reports)
- Tinyproxy package now listed as "testing" and "unfinished, experts only",
  because there is no web config yet.
- Obsolete package telefon removed (and "obsolete" section with it)
- Fix make target 'busybox-tools-clean', so busybox and makedevs are removed.
  This avoids an error when subsequently calling 'make precompiled' again.
- Fix mini_fo: use modprobe instead of insmod, because module path can differ
  with other box types. Package updated to 0.2.
- External IP can now be determined without calling external servers: Shell
  script /bin/get_ip prints external IP to stdout, giving the user a choice
  between three different methods:
    -w, --webcm    - webcm CGI handler method [default]
    -d, --dsld     - showdsldstat method (use only with kernel 2.6 firmwares)
    -e, --extquery - external site query method (ask whatismyip.org)
- Fix typo in make target 'kernel-clean'
- netsnmp.cgi is now executable, so the package can be web-configured.
- Fix typo in kernel/Config.in: DS_MODULE_crc-ccitt -> DS_MODULE_crc_ccitt.
  So menuconfig no longer complains about DS_MODULE_ppp_async.
- Suppress tar "lone zero block" warning when unpacking certain firmware images
- Don't be so restrictive on addon-names (e.g. openvpn-2.1.offline)

### ds-0.2.9_26-14.2

- Fix fakeroot problems with chown (operation not permitted) on systems with
  newer glibc + coreutils combinations using *at(). The version has been
  promoted to fakeroot-1.5.10 and a new patch for *at() is available.
- Fix package virtualip-cgi and promote to version 0.4.1. There were bugs in
  the make script and in the download package itself.
- Fixed 'tar --exclude .svn' for dnsmasq, cifsmount and deco: option was not
  set for '*-package' targets (tar -c), but for unpack targets (tar -x).
- Remove "depends on DS_REPLACE_KERNEL" for iptables libs
- Checking for and cleaning up Subversion directories in build/modified
  before packing firmware image
- Updated copyright notices and acknowledgements
- Updated MOTD to reflect DS-Mod_26 series (different ASCII art)
- Fix menuconfig warning concerning download toolchain
- Remove kernel-toolchain from target-toolchain prerequisites
- Add gcc-4.1.2 to target toolchain menu after it has been fixed
- FUSE module got lost when removed KERNEL_MODULES_DIR
- Add mirror for download toolchain
- Added, fixed and enhanced a few help texts for menuconfig in Config.in and
  toolchain/Config.in.
- Introducing detailed help texts for menuconfig's shared library section.
  Unfortunately, this blows up libs/Config.in immensely - even more so, because
  sub-menus cannot get their own help texts for technical reasons. So, for menus
  containing several entries there is a lot of redundancy (i.e. repetition). The
  worst example is iptables, but there are others as well.
- Add xdelta3 (for binary diffs) to build tools
- Added and enhanced menuconfig help texts for several packages: screen,
  matrixtunnel, lynx, dropbear, wol-cgi, mini_fo, lua, callmonitor, samba, mc,
  cifsmount, deco.
- Set tinyproxy autostart to manual
- Bump 5050 Firmware to 04.31
- Add patch and modules for mppe-mppc
- Increase MOD_LIMIT default to 61440
- Extra patch for soft-float problem
- Delete some unnecessary files
- Forgot to add patches for gdb 6.3 and 6.4

### ds-0.2.9_26-14.1-p2

- add ubik2_boot_0, ubik2_boot_last to device.table (should fix 7050 Image)
- chmod +x for 250-orangebox.sh

### ds-0.2.9_26-14.1-p1

- hide depmod output
- fixed gdb-dirclean target
- fixed 120-rc.S-dev.patch for 2170,3131,3170,5050,7050
- added gdb-clean and gdb-dirclean targets
- reverted .phony targets (toolchain)
- fixes gdb build
- added 140-printk.patch for 7140 and 7141
- fixed deco (select DS_LIB_libncurses)
- fix typo in /root/usr/mww/cgi-bin/file.cgi
- add printk.patch for labors
- libraries are also having dependencies...

### ds-0.2.9_26-14.1

- fixed jamvm patch (100-fix-trace.patch)
- fixed typo in deco.mk
- changed all library-dependencies in packages makefiles. Hopefully there will
  be no more sensless configure runs.
- add "--exclude .svn" to tar for all package-targets
- added gdb
- fixed deco.mk (forgot ncurses dependency, wrong path)
- removed ar7kernel-loader
- added evalzmaloader (thanks Enrik) https://web.archive.org/20200701000000/www.wehavemorefun.de/fritzbox/EVA
- fix error with download and external toolchain:
  uClibc-libs are not in /root/lib
- updated download toolchain to 0.2
- add/remove patches for (non-working) uClibc-0.9.28.3/1
- fix 7170 Labor patches

### ds-0.2.9_26-14.0

- fix precompiled toolchain download URL in toolchain/make/download-toolchain.mk
- add forgotten cpmaccfg in make/Config.in
- remove precompiled libs from root/lib
- Moving all files back to SVN project's trunk, because we have given up plans
  to merge the repository with Danisahne's Sourceforge repository one day
  (licencing issues concerning AVM copyrighted file patches). So we thought we
  could as well have our own trunk again.
- added download location for toolchain (thanks @ DPR)
- updated orangebox to 1.05
- fixed download toolchain
- disable tr069 if selected openssl
- updated orangebox to 1.02
- fix dropbear-sshd-only package
- try different binutil download locations (stable, developer) for target toolchain
- fixed rebuilding of a kernel with different modules
- small fixes in download-toolchain.mk, kernel/Config.in and make/deco/Config.in
- worked on precompiled toolchain
- fixed netsnmp-package
- added busybox patch
- updated 7050 to 04.31
- updated 7170_phone_labor to 6572
- added deco and tinyproxy
- prepare for downloadable toolchain (i386)
- added more packages to ./packages
- updated netsnmp-package to 0.2
- added tinyproxy-1.7.0 package
- added deco-39 package
- new patch fixes mc-4.5.0 build error on GNOME systems
- change in lzma.mk (dos2unix no more needed, thanks aholler)
- remove getcons (not working for me)
- fixed typo in menuconfig (uClibc-version)
- fixed busybox patch (440-httpd_chdir.patch)
- added fon_7150
- fixed openvpn-lzo_conf
- fixed download location of target toolchain binutils
- fixed openvpn-lzo.cgi
- fixed Config.in
- fixed pingtunnel/Config.in
- fixed jamvm/Config.in
- fixed target "openvpn-package" (exclude .svn directories)
- added ./packages/openvpn-2.1_rc2/
- updated openssl to 0.9.8e
- updated to openvpn-2.1_rc2-dsmod-0.6c
- removed ./dl/openvpn-2.1_rc2-dsmod-0.6b.tar.bz2
- fixed bug in modhosts (http://www.ip-phone-forum.de/showthread.php?t=128048)
- removed packages from dl/
- updated bird.mk
- added 2170, 3131, 3170 and 5050 (untested)
- added cifsmount (Package and kernel-patch)
- removed iptables from vpnc-script
- updated dropbear to 0.49
- added debootstrap, lynx and netsnmp (thanks to derheimi)
- added gcc-4.1.2 to toolchain-options
- fixed classpath, fuse, jamvm, ntfs
- updated callmonitor to 1.8.3
- other small changes
- added 7050
- updated openvpn to 2.1_rc2
- downgrade matrixssl to 1.7.3 (because of download-source)
- fixed ntfs-3g (2 fuse patches)
- more busybox-patches
- vpnc updated to 0.4.0
- updated backup/restore-cgi to Haserl 0.9.x syntax
- added matrixssl-1-8-3-open (lib)
- added matrixtunnel-0.2 (package)
- added Rudi-Shell
- minor fixes in bird.mk, readline.mk
- added fuse 2.6.3
- added ntfs-3g-1.0
- added classpath-0.93
- added libffi-sable-3325
- added jamvm-1.4.5
- minor fixes in pingtunnel.mk, streamripper.mk, tcpdump.mk and bird.mk
- added busybox-patch (tar -t segfault)
- added pingtunnel
- minor fixes in libpcap-patches, busybox-patches
- added tcpdump
- haserl updated to 0.9.16
- minor changes in file.cgi, modhosts
- added bird-1.0.11 (thanks to derheimi)
- added streamripper-1.61.17
- added libmad-0.15.1b
- added Lua scripting language
- updated dnsmasq to version 2.38
- updated busybox-patches
- make target for uclibc-utils
- added backup/restore-cgi
- added 7140 30.04.30
- moved missing files into branch
- restructured SVN to hold branches (for a later merge into official svn)
- added haserl
- target toolchain update (binutils 2.17, gcc-4.1.1, uclibc-0.9.28.1) (edit: not working)
- added libpcap
- added knock-package
- updatet 7141 to 40.04.30
- added cpmaccfg-package
- added shadow000's webinterface mod (orangebox)
- fixed calllist for labor-firmwares (foncalls.patch)
- update to busybox-1.4.1
- cpmac-ioctl.patch
- kernel-printk.patch
- update to busybox-1.4.0
- added some kernel-modules (ntfs, cifs, smbfs)
- fixed W701V-webmenu patch
- more W701V fixes
- added some iptable-modules
- updated openvpn-Package to 0.6b
- updated .version
- fixed W701V patch
- added avm-ftpd-remove patch
- fixed modules_install with parallel make
- added unionfs
- added libreadline
- initial checkin

```

Latest change of this file: $Id$
```
