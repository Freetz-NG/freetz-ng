# Welcome to Freetz-NG

```
 _____              _            _   _  ____
|  ___| __ ___  ___| |_ ____    | \ | |/ ___|
| |_ | '__/ _ \/ _ \ __|_  /____|  \| | |  _
|  _|| | |  __/  __/ |_ / /_____| |\  | |_| |
|_|  |_|  \___|\___|\__/___|    |_| \_|\____|

```

Freetz-NG is a fork of Freetz.
More features - less bugs!

### Requirements:
 * You need an up to date Linux System with some [prerequisites](docs/PREREQUISITES.md).
 * Or download a ready-to-use VM like Gismotro's [Freetz-Linux](https://freetz.digital-eliteboard.com/?dir=Teamserver/Freetz/Freetz-VM/VirtualBox/). (admin & pass: freetz)
 * Your linux user needs to have set `umask 0022` before checkout and during make.

### Clone the main branch:
```
  git clone https://github.com/Freetz-NG/freetz-ng ~/freetz-ng
```

### Or clone a single [tag](../../tags):
```
  git clone https://github.com/Freetz-NG/freetz-ng ~/freetz-ng --single-branch --branch TAGNAME
```

### Build firmware:
```
  cd ~/freetz-ng
  make menuconfig
  make
  # make help
```

### Flash firmware:
```
  # make push-firmware
  tools/push_firmware -h
```

### Show GIT states:
```
  git status
  git diff --no-prefix # --cached # > file.patch
  git log --graph # --oneline
```

### Delete local changes:
```
  git checkout master ; git fetch --all --prune ; git reset --hard origin/HEAD ; git clean -fd
```

### Update GIT:
```
  git pull
```

### Checkout old revision:
```
  git checkout HASH-OF-COMMIT # -b NEW-BRANCH
```
### Checkout another branch:
```
  git checkout EXISTING-BRANCH
```

### Mirrors:
```
  git clone https://gitlab.com/Freetz-NG/freetz-ng ~/freetz-ng
  git clone https://bitbucket.org/Freetz-NG/freetz-ng ~/freetz-ng
  svn co https://svn.boxmatrix.info/freetz-ng/trunk ~/freetz-ng
```

### Documentation:
See [https://freetz-ng.github.io/](https://freetz-ng.github.io/) (or [docs/](docs/README.md)).

