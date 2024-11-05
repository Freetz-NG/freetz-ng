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

### Basic infos:
 * A web interface will be started on [port :81](http://fritz.box:81/), credentials: `admin`/`freetz`<br>
 * Default credentials for shell/ssh/telnet access are: `root`/`freetz`<br>
 * For more see: [freetz-ng.github.io](https://freetz-ng.github.io/)

### Requirements:
 * You need an up to date Linux System with some [prerequisites](docs/PREREQUISITES/README.md).
 * Or download a ready-to-use VM like Gismotro's [Freetz-Linux](https://freetz.digital-eliteboard.com/?dir=Teamserver/Freetz/Freetz-VM/VirtualBox/) (user & pass: `freetz`).
 * There are also Docker images available like [pfichtner-freetz](https://hub.docker.com/r/pfichtner/freetz) ([README](https://github.com/pfichtner/pfichtner-freetz#readme)).

### Clone the main branch:
```
  git clone https://github.com/Freetz-NG/freetz-ng ~/freetz-ng
```

### Or clone a single [tag](../../tags):
```
  git clone https://github.com/Freetz-NG/freetz-ng ~/freetz-ng --single-branch --branch TAGNAME
```

### Install prerequisites:
```
  cd ~/freetz-ng
  tools/prerequisites install # -y
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
  cd ~/freetz-ng
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
```

### Documentation:
See [https://freetz-ng.github.io/](https://freetz-ng.github.io/) (or [docs/](docs/README.md)).

