# PREREQUISITES: Installation der benötigten Pakete
Eine einfache Möglichkeit die benötigten Pakete zu installieren besteht darin, diesen Code per Copy and Paste auf der Konsole auszuführen!

### Getestete Distributionen
 - [Fedora](#fedora)
 - [Debian](#debian)
 - [Ubuntu](#ubuntu)
 - [Kali](#kali)
 - sonst keine

### Problematische Distributionen
 - Gentoo

### Alle anderen Distributionen
... sind ungetestet und können funktionieren oder auch nicht. Dies hängt stark von den Fähigkeiten des Bedieners ab.

### Distribution ermitteln
Wenn man vergessen hat welche Linux Version installiert ist kann dies so prüfen:

 - Linux Distribution:
```
$ hostnamectl status
  Operating System: Fedora 33 (Thirty Three)
	    Kernel: Linux 5.10.15-200.fc33.x86_64
```

 - Ubuntu/Debian Version:
```
$ lsb_release -d
Description:    Ubuntu 14.04.6 LTS
```

 - Maschinen Typ: `i686` bei 32-Bit x86 und `x86_64` bei 64-Bit x86:
```
$ uname -m
aarch64
```

### Fedora

 - System aktualisieren:
```
sudo dnf -y update && sudo systemctl daemon-reload
```

 - Fedora 36 64-Bit:
```
sudo dnf -y groupinstall 'Development Tools' 'Development Libraries'
sudo dnf -y install pv cpio rsync kmod execstack sqlite.i686 sqlite-devel cmake zlib-devel.i686 libstdc++-devel.i686 openssl xz bc unar inkscape ImageMagick subversion ccache gcc gcc-c++ binutils autoconf automake libtool make bzip2 libglade2-devel qt5-qtbase-devel ncurses-devel ncurses-term zlib-devel flex bison patch texinfo gettext pkgconfig ecj perl perl-String-CRC32 wget glib2-devel git util-linux libacl-devel libattr-devel libcap-devel ncurses-devel.i686 glibc-devel.i686 libgcc.i686 libuuid-devel openssl-devel gnutls-devel libzstd-devel.x86_64 libstdc++-devel.x86_64 netcat curl sharutils
```

 - Fedora 35 64-Bit:
```
sudo dnf -y groupinstall 'Development Tools' 'Development Libraries'
sudo dnf -y install pv cpio rsync kmod execstack sqlite.i686 sqlite-devel cmake zlib-devel.i686 libstdc++-devel.i686 openssl xz bc unar inkscape ImageMagick subversion ccache gcc gcc-c++ binutils autoconf automake libtool make bzip2 libglade2-devel qt5-qtbase-devel ncurses-devel ncurses-term zlib-devel flex bison patch texinfo gettext pkgconfig ecj perl perl-String-CRC32 wget glib2-devel git util-linux libacl-devel libattr-devel libcap-devel ncurses-devel.i686 glibc-devel.i686 libgcc.i686 libuuid-devel openssl-devel gnutls-devel libzstd-devel.x86_64 libstdc++-devel.x86_64 sharutils
```

 - Fedora 33/34 64-Bit:
```
sudo dnf -y groupinstall 'Development Tools' 'Development Libraries'
sudo dnf -y install pv cpio rsync kmod execstack sqlite.i686 sqlite-devel cmake zlib-devel.i686 libstdc++-devel.i686 openssl xz bc unar inkscape ImageMagick subversion ccache gcc gcc-c++ binutils autoconf automake libtool make bzip2 libglade2-devel qt5-qtbase-devel ncurses-devel ncurses-term zlib-devel flex bison patch texinfo gettext pkgconfig ecj perl perl-String-CRC32 wget glib2-devel git util-linux libacl-devel libattr-devel libcap-devel ncurses-devel.i686 glibc-devel.i686 libgcc.i686 libuuid-devel openssl-devel gnutls-devel libzstd-devel.i686
```

 - Falls auf dem folgenden System ein 64-Bit Linux installiert ist wird zusätzlich benötigt:
```
sudo yum -y install ncurses-devel.i686 glibc-devel.i686 libgcc.i686
```

 - Fedora ~20 32-Bit:
```
sudo yum -y install ImageMagick subversion gcc gcc-c++ binutils autoconf automake libtool make bzip2 ncurses-devel zlib-devel flex bison patch texinfo gettext pkgconfig ecj perl perl-String-CRC32 wget glib2-devel git libacl-devel libattr-devel libcap-devel
```

### Debian

 - System aktualisieren:
```
sudo apt -y update
sudo apt -y upgrade
sudo apt -y dist-upgrade
```
 - Debian 11 (Bullseye) 64-Bit:
```
sudo apt -y install pv cpio rsync kmod imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar perl libstring-crc32-perl ruby gawk python2 python-is-python3 libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 libzstd-dev netcat curl uuid-dev libssl-dev libgnutls28-dev sharutils
wget http://ftp.de.debian.org/debian/pool/main/p/prelink/execstack_0.0.20131005-1+b10_amd64.deb
sudo apt install ./execstack_0.0.20131005-1+b10_amd64.deb
echo "export PATH=$PATH:/usr/sbin" >> ~/.bashrc
```


### Ubuntu

 - Deutsche Tastaturbelegung:<br>
Siehe [ubuntu.com: LocaleConf](https://help.ubuntu.com/community/LocaleConf)
```
sudo apt-get -y install console-data && sudo locale-gen de_DE && sudo dpkg-reconfigure console-data && exit
```

 - 32-Bit (Multiarch) aktivieren:<br>
Siehe [debian.org: Multiarch HOWTO](https://wiki.debian.org/Multiarch/HOWTO) und [heise.de: Pakete für mehrere CPU-Architekturen in Linux installieren](http://heise.de/-2056403)
```
# dpkg --print-foreign-architectures
sudo dpkg --add-architecture i386
sudo apt-get -y update
```

 - System aktualisieren:
```
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
```

 - Ubuntu 22 64-Bit:
```
sudo apt-get -y install pv cpio rsync kmod execstack imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar perl libstring-crc32-perl ruby gawk python2 python-is-python3 libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 libzstd-dev netcat curl uuid-dev libssl-dev libgnutls28-dev sharutils
```

 - Ubuntu 20 64-Bit:
```
sudo apt-get -y install pv cpio rsync kmod execstack imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar perl libstring-crc32-perl ruby gawk python libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 libzstd-dev netcat curl uuid-dev libssl-dev libgnutls28-dev sharutils
# sqlite-32bit lässt sich mit apt nicht installieren, aber mit apt-get schon. Siehe auch: https://developpaper.com/ubuntu-solves-the-problem-of-libsqlite3-0-dependency-recommended/
sudo apt -y install libzstd-dev:i386 sqlite3:i386
```

 - Ubuntu 18 64-Bit:
```
sudo apt-get -y install pv cpio rsync kmod execstack imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar          perl libstring-crc32-perl ruby ruby1.9 gawk python libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 libzstd-dev netcat curl uuid-dev libssl-dev libgnutls28-dev openssl build-essential
```

 - Ubuntu 16 64-Bit:
```
sudo apt-get -y install pv cpio rsync kmod execstack imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar realpath perl libstring-crc32-perl ruby ruby1.9 gawk python libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev
```

 - Ubuntu 15 64-Bit:
```
sudo apt-get -y install pv cpio rsync kmod execstack imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar realpath perl libstring-crc32-perl ruby ruby1.9 gawk python libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev
```

 - Ubuntu 14 64-Bit:
```
sudo apt-get -y install pv cpio rsync kmod execstack imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake autopoint libtool make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar realpath perl libstring-crc32-perl ruby ruby1.9 gawk python libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 netcat curl openssl build-essential automake1.9
```
Zusätzlich muss manuell installiert werden:
```
cmake min v3.4.3  https://ftp.osuosl.org/pub/blfs/conglomeration/cmake/cmake-3.4.3.tar.gz
cpio min v2.12    https://ftp.gnu.org/gnu/cpio/cpio-2.12.tar.bz2
make min v3.82    https://ftp.gnu.org/gnu/make/make-3.82.tar.bz2
libzstd min v0    https://github.com/facebook/zstd/releases/download/v1.4.9/zstd-1.4.9.tar.gz
```
Und ausserdem falls ccache gebaut werden soll:
```
cmake min v3.10   https://ftp.osuosl.org/pub/blfs/conglomeration/cmake/cmake-3.10.3.tar.gz
gmp min v4.2      https://ftp.gnu.org/gnu/gmp/gmp-4.2.4.tar.bz2
mpfr min v2.4     https://ftp.gnu.org/gnu/mpfr/mpfr-2.4.2.tar.xz
mpc min v0.8      https://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz
gcc min v6        https://ftp.gnu.org/gnu/gcc/gcc-6.5.0/gcc-6.5.0.tar.xz
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/lib64:/usr/local/lib32"
```

 - Falls auf den folgenden Systemen ein 64-Bit Linux installiert ist wird zusätzlich benötigt:
```
sudo apt-get -y install libc6-dev-i386 lib32ncurses5-dev gcc-multilib lib32stdc++6
```

 - Ubuntu 15 32-Bit / Debian 8: Zusätzlich zu Ubuntu 13/14 32-Bit wird benötigt:
```
sudo apt-get -y install libtool-bin
```

 - Ubuntu 13/14 32-Bit:
```
sudo apt-get -y install graphicsmagick subversion gcc g++ binutils autoconf automake automake1.9 libtool make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar realpath perl libstring-crc32-perl ruby ruby1.8 gawk python libusb-dev unzip intltool libacl1-dev libcap-dev
```

 - Ubuntu 9/10/11/12 32-Bit:
```
sudo apt-get -y install imagemagick subversion gcc g++ bzip2 binutils automake patch autoconf libtool pkg-config make libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar realpath perl libstring-crc32-perl ruby ruby1.8 gawk python libusb-dev unzip intltool libglib2.0-dev xz-utils git-core libacl1-dev libattr1-dev libcap-dev
```

 - Ubuntu 9.04 32-Bit (kein automake 1.8, "ecj" statt "ecj-bootstrap"):
```
sudo apt-get -y install imagemagick subversion gcc g++ binutils autoconf automake automake1.9 libtool make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config jikes ecj fastjar realpath perl libstring-crc32-perl ruby ruby1.8 gawk python libusb-dev unzip intltool libglib2.0-dev xz-utils git-core libacl1-dev libattr1-dev libcap-dev
```

### Kali
Kali rolling wurde schon erfolgreich zum Bauen benutzt. Einfach die Pakete installieren, die für Ubuntu vorgeschlagen werden.
Das meiste wird bei Kali sowieso schon dabei installiert sein.
