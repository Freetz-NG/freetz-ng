# PREREQUISITES: Installation der benötigten Pakete
Eine einfache Möglichkeit die benötigten Pakete zu installieren besteht darin, diesen Code per Copy and Paste auf der Konsole auszuführen, zB in PuTTY per Rechtsclick!

Mit `tools/prerequisites` können die Pakete auch installiert werden.

### Getestete Distributionen
 - [Fedora](#fedora)
 - [Debian](#debian)
 - [Devuan](#devuan)
 - [Ubuntu](#ubuntu)
 - [Mint](#mint)
 - [Kali](#kali)
 - sonst keine

### Problematische Distributionen
 - Gentoo
 - NixOS

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

 - Fedora 41 64-Bit:
```
sudo dnf -y install %%Fedora41%%
```

 - Fedora 40 64-Bit:
```
sudo dnf -y install %%Fedora40%%
```

 - Fedora 37/38/39 64-Bit:
```
sudo dnf -y install %%Fedora37%%
```

 - Fedora 36 64-Bit:
```
sudo dnf -y install %%Fedora36%%
```

 - Fedora 35 64-Bit:
```
sudo dnf -y install %%Fedora35%%
```

 - Fedora 33/34 64-Bit:
```
sudo dnf -y install %%Fedora33%%
```

 - Falls auf dem folgenden System ein 64-Bit Linux installiert ist wird zusätzlich benötigt:
```
sudo yum -y install ncurses-devel.i686 glibc-devel.i686 libgcc.i686
```

 - Fedora ~20 32-Bit:
```
sudo yum -y install %%Fedora20%%
```

### Debian

 - System aktualisieren:
```
sudo apt -y update
sudo apt -y upgrade
sudo apt -y dist-upgrade
```

 - Debian 12 64-Bit:
```
sudo apt -y install %%Debian12%%
```

 - Debian 11 64-Bit:
```
sudo apt -y install %%Debian11%%
```


### Devuan
Devuan wurde schon erfolgreich zum Bauen benutzt. Einfach die Pakete installieren, die für Debian vorgeschlagen werden.


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

 - Ubuntu 23/24/25 64-Bit:
```
sudo apt-get -y install %%Ubuntu23%%
```

 - Ubuntu 22 64-Bit:
```
sudo apt-get -y install %%Ubuntu22%%
```

 - Ubuntu 20/21 64-Bit:
```
sudo apt-get -y install %%Ubuntu20%%
# sqlite-32bit lässt sich mit apt nicht installieren, aber mit apt-get schon. Siehe auch:
# https://developpaper.com/ubuntu-solves-the-problem-of-libsqlite3-0-dependency-recommended/
sudo apt -y install libzstd-dev:i386 sqlite3:i386
```

 - Ubuntu 18/19 64-Bit:
```
sudo apt-get -y install %%Ubuntu18%%
```

 - Ubuntu 15/16/17 64-Bit:
```
sudo apt-get -y install %%Ubuntu15%%
```

 - Ubuntu 14 64-Bit:
```
sudo apt-get -y install %%Ubuntu14%%
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
sudo apt-get -y install %%Ubuntu13%%
```

 - Ubuntu 10/11/12 32-Bit:
```
sudo apt-get -y install %%Ubuntu10%%
```

 - Ubuntu 9.04 32-Bit (kein automake 1.8, "ecj" statt "ecj-bootstrap"):
```
sudo apt-get -y install %%Ubuntu09%%
```

### Mint
Mint wurde schon erfolgreich zum Bauen benutzt. Einfach die Pakete installieren, die für Ubuntu vorgeschlagen werden.

### Kali
Kali rolling wurde schon erfolgreich zum Bauen benutzt. Einfach die Pakete installieren, die für Ubuntu vorgeschlagen werden.
Das meiste wird bei Kali sowieso schon dabei installiert sein.


