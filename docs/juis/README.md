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
  * You need an up to date Linux System with some [prerequisites](docs/prerequisites/README.md).
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


<details>
  <summary>Testing your Documentation changes localy</summary>

When working on this repo, it is advised that you review your changes locally before committing them. The `mkdocs serve` command can be used to live preview your changes (as you type) on your local machine.

Please make sure you fork the repo and change the clone URL in the example below for your fork:

- Linux Mint / Ubuntu 20.04 LTS / 23.10 and later:
    - Preparations (only required once):

    ```bash
    git clone https://github.com/YOUR-USERNAME/freetz-ng
    cd freetz-ng
    sudo apt install python3-pip python3-venv
    python3 -m venv .venv
    source .venv/bin/activate
    pip3 install -r .github/mkdocs/requirements.txt
    ```

    - Enter the virtual environment (if exited):

    ```bash
    source .venv/bin/activate
    ```

    - Running the docs server:

    ```bash
    mkdocs serve --dev-addr 0.0.0.0:8000 --config-file .github/mkdocs/mkdocs.yml
    ```

- Fedora Linux instructions (tested on Fedora Linux 28):
    - Preparations (only required once):

    ```bash
    git clone https://github.com/YOUR-USERNAME/freetz-ng
    cd freetz-ng
    pip install --user -r .github/mkdocs/requirements.txt
    ```

    - Running the docs server:

    ```bash
    mkdocs serve --dev-addr 0.0.0.0:8000 --config-file .github/mkdocs/mkdocs.yml
    ```

After these commands, the current branch is accessible through your favorite browser at <http://localhost:8000>

</details>
ritz.os/FRITZ.Box_6842_LTE.123.06.35.image)
  - HWR 196: [FRITZ.Box_Fon_WLAN_7360-06.88.image](http://download.avm.de/fritzbox/fritzbox-7360-v2/deutschland/fritz.os/FRITZ.Box_Fon_WLAN_7360-06.88.image)
  - HWR 198: [FRITZ.Box_3272.126.06.89.image](http://download.avm.de/fritzbox/fritzbox-3272/deutschland/fritz.os/FRITZ.Box_3272.126.06.89.image)
  - HWR 200: [FRITZ.Box_WLAN_Repeater_450E-07.15.image](http://download.avm.de/fritzwlan/fritzwlan-repeater-450e/deutschland/fritz.os/FRITZ.Box_WLAN_Repeater_450E-07.15.image)
  - HWR 201: [FRITZ.Powerline_540E.129.07.15.image](http://download.avm.de/fritzpowerline/fritzpowerline-540e/deutschland/fritz.os/FRITZ.Powerline_540E.129.07.15.image)
  - HWR 203: [FRITZ.Box_7362_SL-07.18.image](http://download.avm.de/fritzbox/fritzbox-7362-sl/deutschland/fritz.os/FRITZ.Box_7362_SL-07.18.image)
  - HWR 205: [FRITZ.Repeater_DVB_C.en-de-es-it-fr-pl.133.07.04.image](http://download.avm.de/fritzwlan/fritzwlan-repeater-dvb-c/deutschland/fritz.os/FRITZ.Repeater_DVB_C.en-de-es-it-fr-pl.133.07.04.image)
  - HWR 206: [FRITZ_Repeater_1750E-07.32.image](http://download.avm.de/fritzwlan/fritzwlan-repeater-1750e/deutschland/fritz.os/FRITZ_Repeater_1750E-07.32.image)
  - HWR 209: [FRITZ.Box_7412.137.06.88.image](http://download.avm.de/fritzbox/fritzbox-7412/deutschland/fritz.os/FRITZ.Box_7412.137.06.88.image)
  - HWR 212: [FRITZ.Box_3490-07.12.image](http://download.avm.de/firmware/3490/jz76373/3754863962/deutschland/fritz.os/FRITZ.Box_3490-07.12.image)
  - HWR 214: [FRITZ.Box_6820v1_LTE-07.30.image](http://download.avm.de/fritzbox/fritzbox-6820-lte/deutschland/fritz.os/FRITZ.Box_6820v1_LTE-07.30.image)
  - HWR 215: [FRITZ.Repeater_310-07.16.image](http://download.avm.de/fritzwlan/fritzwlan-repeater-310-b/deutschland/fritz.os/FRITZ.Repeater_310-07.16.image)
  - HWR 216: [FRITZ.Box_WLAN_Repeater_1160-07.15.image](http://download.avm.de/fritzwlan/fritzwlan-repeater-1160/deutschland/fritz.os/FRITZ.Box_WLAN_Repeater_1160-07.15.image)
  - HWR 218: [FRITZ.Box_7430-07.12.image](http://download.avm.de/firmware/7430/jz76373/9273521133/deutschland/fritz.os/FRITZ.Box_7430-07.12.image)
  - HWR 219: [FRITZ.Box_4020.07.04.image](http://download.avm.de/fritzbox/fritzbox-4020/deutschland/fritz.os/FRITZ.Box_4020.07.04.image)
  - HWR 220: [FRITZ.Box_6590_Cable-07.57.image](http://download.avm.de/fritzbox/fritzbox-6590-cable/deutschland/fritz.os/FRITZ.Box_6590_Cable-07.57.image)
  - HWR 221: [FRITZ.Box_7560-07.30.image](http://download.avm.de/fritzbox/fritzbox-7560/deutschland/fritz.os/FRITZ.Box_7560-07.30.image)
  - HWR 222: [FRITZ.Powerline_1240E.150.07.16.image](http://download.avm.de/fritzpowerline/fritzpowerline-1240e/deutschland/fritz.os/FRITZ.Powerline_1240E.150.07.16.image)
  - HWR 223: [FRITZ.Box_5490-07.31.image](http://download.avm.de/fritzbox/fritzbox-5490/other/fritz.os/FRITZ.Box_5490-07.31.image)
  - HWR 225: [FRITZ.Box_7580-07.30.image](http://download.avm.de/fritzbox/fritzbox-7580/deutschland/fritz.os/FRITZ.Box_7580-07.30.image)
  - HWR 226: [FRITZ.Box_7590-08.20.image](http://download.avm.de/fritzbox/fritzbox-7590/deutschland/fritz.os/FRITZ.Box_7590-08.20.image)
  - HWR 227: [FRITZ.Box_4040-08.03.image](http://download.avm.de/fritzbox/fritzbox-4040/deutschland/fritz.os/FRITZ.Box_4040-08.03.image)
  - HWR 228: [FRITZ.Box_7582-07.18.image](http://download.avm.de/fritzbox/fritzbox-7582/other/fritz.os/FRITZ.Box_7582-07.18.image)
  - HWR 229: [FRITZ.Powerline_1260E.157.07.58.image](http://download.avm.de/fritzpowerline/fritzpowerline-1260e/deutschland/fritz.os/FRITZ.Powerline_1260E.157.07.58.image)
  - HWR 231: [FRITZ.Box_6430_Cable-07.30.image](http://download.avm.de/fritzbox/fritzbox-6430-cable/deutschland/fritz.os/FRITZ.Box_6430_Cable-07.30.image)
  - HWR 233: [FRITZ.Box_6591_Cable-08.21.image](http://download.avm.de/fritzbox/fritzbox-6591-cable/deutschland/fritz.os/FRITZ.Box_6591_Cable-08.21.image)
  - HWR 234: [FRITZ.Box_6890_LTE-07.57.image](http://download.avm.de/fritzbox/fritzbox-6890-lte/deutschland/fritz.os/FRITZ.Box_6890_LTE-07.57.image)
  - HWR 236: [FRITZ.Box_7530-08.02.image](http://download.avm.de/fritzbox/fritzbox-7530/deutschland/fritz.os/FRITZ.Box_7530-08.02.image)
  - HWR 239: [FRITZ.Box_7583-08.20.image](http://download.avm.de/fritzbox/fritzbox-7583/deutschland/fritz.os/FRITZ.Box_7583-08.20.image)
  - HWR 240: [FRITZ.Repeater_600-08.20.image](http://download.avm.de/fritzwlan/fritzrepeater-600/deutschland/fritz.os/FRITZ.Repeater_600-08.20.image)
  - HWR 241: [FRITZ.Repeater_2400-08.20.image](http://download.avm.de/fritzwlan/fritzrepeater-2400/deutschland/fritz.os/FRITZ.Repeater_2400-08.20.image)
  - HWR 243: [FRITZ.Box_5491-07.31.image](http://download.avm.de/fritzbox/fritzbox-5491/deutschland/fritz.os/FRITZ.Box_5491-07.31.image)
  - HWR 244: [FRITZ.Repeater_1200-08.20.image](http://download.avm.de/fritzwlan/fritzrepeater-1200/deutschland/fritz.os/FRITZ.Repeater_1200-08.20.image)
  - HWR 246: [FRITZ.Repeater_3000-08.20.image](http://download.avm.de/fritzwlan/fritzrepeater-3000/deutschland/fritz.os/FRITZ.Repeater_3000-08.20.image)
  - HWR 247: [FRITZ.Box_7520-08.02.image](http://download.avm.de/fritzbox/fritzbox-7520/deutschland/fritz.os/FRITZ.Box_7520-08.02.image)
  - HWR 249: [FRITZ.Powerline_1260.249.07.58.image](http://download.avm.de/fritzpowerline/fritzpowerline-1260/deutschland/fritz.os/FRITZ.Powerline_1260.249.07.58.image)
  - HWR 252: [FRITZ.Box_6660_Cable-08.21.image](http://download.avm.de/fritzbox/fritzbox-6660-cable/deutschland/fritz.os/FRITZ.Box_6660_Cable-08.21.image)
  - HWR 253: [FRITZ.Repeater_6000-07.58.image](http://download.avm.de/fritzwlan/fritzrepeater-6000/deutschland/fritz.os/FRITZ.Repeater_6000-07.58.image)
  - HWR 254: [FRITZ.Box_6820v3_LTE-07.59.image](http://download.avm.de/fritzbox/fritzbox-6820-lte-v3/deutschland/fritz.os/FRITZ.Box_6820v3_LTE-07.59.image)
  - HWR 256: [FRITZ.Box_7530_AX-08.20.image](http://download.avm.de/fritzbox/fritzbox-7530-ax/deutschland/fritz.os/FRITZ.Box_7530_AX-08.20.image)
  - HWR 257: [FRITZ.Box_5530_Fiber-08.20.image](http://download.avm.de/fritzbox/fritzbox-5530-fiber/deutschland/fritz.os/FRITZ.Box_5530_Fiber-08.20.image)
  - HWR 258: [FRITZ.Box_6850_5G-08.20.image](http://download.avm.de/fritzbox/fritzbox-6850-5g/deutschland/fritz.os/FRITZ.Box_6850_5G-08.20.image)
  - HWR 259: [FRITZ.Box_7590_AX-08.20.image](http://download.avm.de/fritzbox/fritzbox-7590-ax/deutschland/fritz.os/FRITZ.Box_7590_AX-08.20.image)
  - HWR 260: [FRITZ.Box_7583_VDSL-08.20.image](http://download.avm.de/fritzbox/fritzbox-7583-vdsl/deutschland/fritz.os/FRITZ.Box_7583_VDSL-08.20.image)
  - HWR 261: [FRITZ.Box_4060-08.02.image](http://download.avm.de/fritzbox/fritzbox-4060/deutschland/fritz.os/FRITZ.Box_4060-08.02.image)
  - HWR 262: [FRITZ.Box_6850_LTE-08.20.image](http://download.avm.de/fritzbox/fritzbox-6850-lte/deutschland/fritz.os/FRITZ.Box_6850_LTE-08.20.image)
  - HWR 263: [FRITZ.Repeater_600v2-08.20.image](http://download.avm.de/fritzwlan/fritzrepeater-600v2/deutschland/fritz.os/FRITZ.Repeater_600v2-08.20.image)
  - HWR 267: [FRITZ.Box_6690_Cable-08.03.image](http://download.avm.de/fritzbox/fritzbox-6690-cable/deutschland/fritz.os/FRITZ.Box_6690_Cable-08.03.image)
  - HWR 268: [FRITZ.Repeater_1200_AX-07.58.image](http://download.avm.de/fritzwlan/fritzrepeater-1200-ax/deutschland/fritz.os/FRITZ.Repeater_1200_AX-07.58.image)
  - HWR 270: [FRITZ.Repeater_3000_AX-07.58.image](http://download.avm.de/fritzwlan/fritzrepeater-3000-ax/deutschland/fritz.os/FRITZ.Repeater_3000_AX-07.58.image)
  - HWR 271: [FRITZ.Box_7510-08.20.image](http://download.avm.de/fritzbox/fritzbox-7510/deutschland/fritz.os/FRITZ.Box_7510-08.20.image)
  - HWR 272: [FRITZ.Box_5590_Fiber-08.02.image](http://download.avm.de/fritzbox/fritzbox-5590-fiber/deutschland/fritz.os/FRITZ.Box_5590_Fiber-08.02.image)
  - HWR 275: [FRITZ.Powerline_1240_AX.275.07.58.image](http://download.avm.de/fritzpowerline/fritzpowerline-1240-ax/deutschland/fritz.os/FRITZ.Powerline_1240_AX.275.07.58.image)
  - HWR 276: [FRITZ.Box_7520_B-08.02.image](http://download.avm.de/fritzbox/fritzbox-7520-B/deutschland/fritz.os/FRITZ.Box_7520_B-08.02.image)

### FOS-Labor
  - HWR 226: [FRITZ.Box_7590-08.10-122720-LabBETA.image](http://download.example.com/labor/Smart24P2/7590/FRITZ.Box_7590-08.10-122720-LabBETA.image)
  - HWR 229: [FRITZ.Powerline_1260E-08.10-126297-LabBETA.image](http://download.example.com/labor/Smart24P2/1260E/FRITZ.Powerline_1260E-08.10-126297-LabBETA.image)
  - HWR 236: [FRITZ.Box_7530-08.10-125959-LabBETA.image](http://download.example.com/labor/Smart24P2/7530/FRITZ.Box_7530-08.10-125959-LabBETA.image)
  - HWR 239: [FRITZ.Box_7583-07.39-103075-LabBETA.image](http://download.example.com/labor/MOVE21/7583/FRITZ.Box_7583-07.39-103075-LabBETA.image)
  - HWR 240: [FRITZ.Repeater_600-07.58.image](http://download.avm.de/fritzwlan/fritzrepeater-600/deutschland/fritz.os/FRITZ.Repeater_600-07.58.image)
  - HWR 247: [FRITZ.Box_7520-08.10-125985-LabBETA.image](http://download.example.com/labor/Smart24P2/7520/FRITZ.Box_7520-08.10-125985-LabBETA.image)
  - HWR 249: [FRITZ.Powerline_1260-08.10-126298-LabBETA.image](http://download.example.com/labor/Smart24P2/1260/FRITZ.Powerline_1260-08.10-126298-LabBETA.image)
  - HWR 253: [FRITZ.Repeater_6000-08.10-126469-LabBETA.image](http://download.example.com/labor/Smart24P2/6000/FRITZ.Repeater_6000-08.10-126469-LabBETA.image)
  - HWR 258: [FRITZ.Box_6850_5G-08.10-124812-LabBETA.image](http://download.example.com/labor/Smart24P2/68505G/FRITZ.Box_6850_5G-08.10-124812-LabBETA.image)
  - HWR 260: [FRITZ.Box_7583_VDSL-07.39-103078-LabBETA.image](http://download.example.com/labor/MOVE21/7583VDSL/FRITZ.Box_7583_VDSL-07.39-103078-LabBETA.image)
  - HWR 262: [FRITZ.Box_6850_LTE-08.10-124817-LabBETA.image](http://download.example.com/labor/Smart24P2/6850LTE/FRITZ.Box_6850_LTE-08.10-124817-LabBETA.image)
  - HWR 267: [FRITZ.Box_6690_Cable-08.10-127006-LabBETA.image](http://download.example.com/labor/Smart24P2/6690Cable/FRITZ.Box_6690_Cable-08.10-127006-LabBETA.image)
  - HWR 270: [FRITZ.Repeater_3000_AX-08.10-126879-LabBETA.image](http://download.example.com/labor/Smart24P2/3000AX/FRITZ.Repeater_3000_AX-08.10-126879-LabBETA.image)
  - HWR 271: [FRITZ.Box_7510-08.10-124565-LabBETA.image](http://download.example.com/labor/Smart24P2/7510/FRITZ.Box_7510-08.10-124565-LabBETA.image)
  - HWR 272: [FRITZ.Box_5590_Fiber-08.10-126849-LabBETA.image](http://download.example.com/labor/Smart24P2/5590Fiber/FRITZ.Box_5590_Fiber-08.10-126849-LabBETA.image)
  - HWR 276: [FRITZ.Box_7520_B-08.10-125988-LabBETA.image](http://download.example.com/labor/Smart24P2/7520B/FRITZ.Box_7520_B-08.10-125988-LabBETA.image)

### FOS-Inhaus
  - HWR 226: [FRITZ.Box_7590-08.21-126889-Inhaus.image](http://download.example.com/inhaus/Smart24P2NL1/7590/FRITZ.Box_7590-08.21-126889-Inhaus.image)
  - HWR 229: [FRITZ.Powerline_1260E-08.10-126210-Inhaus.image](http://download.example.com/inhaus/Smart24P2/1260E/FRITZ.Powerline_1260E-08.10-126210-Inhaus.image)
  - HWR 236: [FRITZ.Box_7530-08.10-126414-Inhaus.image](http://download.example.com/inhaus/Smart24P2/7530/FRITZ.Box_7530-08.10-126414-Inhaus.image)
  - HWR 240: [FRITZ.Repeater_600-08.10-125798-Inhaus.image](http://download.example.com/inhaus/Smart24P2/600/FRITZ.Repeater_600-08.10-125798-Inhaus.image)
  - HWR 247: [FRITZ.Box_7520-08.10-125983-Inhaus.image](http://download.example.com/inhaus/Smart24P2/7520/FRITZ.Box_7520-08.10-125983-Inhaus.image)
  - HWR 249: [FRITZ.Powerline_1260-08.10-126208-Inhaus.image](http://download.example.com/inhaus/Smart24P2/1260/FRITZ.Powerline_1260-08.10-126208-Inhaus.image)
  - HWR 253: [FRITZ.Repeater_6000-08.10-126880-Inhaus.image](http://download.example.com/inhaus/Smart24P2/6000/FRITZ.Repeater_6000-08.10-126880-Inhaus.image)
  - HWR 256: [FRITZ.Box_7530_AX-08.20-126919-Inhaus.image](http://download.example.com/inhaus/Smart24P2NL1/7530AX/FRITZ.Box_7530_AX-08.20-126919-Inhaus.image)
  - HWR 257: [FRITZ.Box_5530_Fiber-08.20-126921-Inhaus.image](http://download.example.com/inhaus/Smart24P2NL1/5530Fiber/FRITZ.Box_5530_Fiber-08.20-126921-Inhaus.image)
  - HWR 258: [FRITZ.Box_6850_5G-08.10-124810-Inhaus.image](http://download.example.com/inhaus/Smart24P2/68505G/FRITZ.Box_6850_5G-08.10-124810-Inhaus.image)
  - HWR 259: [FRITZ.Box_7590_AX-08.20-126923-Inhaus.image](http://download.example.com/inhaus/Smart24P2NL1/7590AX/FRITZ.Box_7590_AX-08.20-126923-Inhaus.image)
  - HWR 261: [FRITZ.Box_4060-08.10-126860-Inhaus.image](http://download.example.com/inhaus/Smart24P2/4060/FRITZ.Box_4060-08.10-126860-Inhaus.image)
  - HWR 262: [FRITZ.Box_6850_LTE-08.10-124815-Inhaus.image](http://download.example.com/inhaus/Smart24P2/6850LTE/FRITZ.Box_6850_LTE-08.10-124815-Inhaus.image)
  - HWR 263: [FRITZ.Repeater_600v2-08.10-125800-Inhaus.image](http://download.example.com/inhaus/Smart24P2/600v2/FRITZ.Repeater_600v2-08.10-125800-Inhaus.image)
  - HWR 267: [FRITZ.Box_6690_Cable-08.10-127004-Inhaus.image](http://download.example.com/inhaus/Smart24P2/6690Cable/FRITZ.Box_6690_Cable-08.10-127004-Inhaus.image)
  - HWR 268: [FRITZ.Repeater_1200_AX-08.10-126868-Inhaus.image](http://download.example.com/inhaus/Smart24P2/1200AX/FRITZ.Repeater_1200_AX-08.10-126868-Inhaus.image)
  - HWR 270: [FRITZ.Repeater_3000_AX-08.10-126877-Inhaus.image](http://download.example.com/inhaus/Smart24P2/3000AX/FRITZ.Repeater_3000_AX-08.10-126877-Inhaus.image)
  - HWR 271: [FRITZ.Box_7510-08.10-124563-Inhaus.image](http://download.example.com/inhaus/Smart24P2/7510/FRITZ.Box_7510-08.10-124563-Inhaus.image)
  - HWR 272: [FRITZ.Box_5590_Fiber-08.10-126847-Inhaus.image](http://download.example.com/inhaus/Smart24P2/5590Fiber/FRITZ.Box_5590_Fiber-08.10-126847-Inhaus.image)
  - HWR 275: [FRITZ.Powerline_1240_AX-08.10-126883-Inhaus.image](http://download.example.com/inhaus/Smart24P2/1240AX/FRITZ.Powerline_1240_AX-08.10-126883-Inhaus.image)
  - HWR 276: [FRITZ.Box_7520_B-08.10-125986-Inhaus.image](http://download.example.com/inhaus/Smart24P2/7520B/FRITZ.Box_7520_B-08.10-125986-Inhaus.image)

### Dect-Release
  - MHW 01.01: [01.01.02.92.avme.de.upd](http://download.avm.de/dect/0101/01.01.02.92.avme.de.upd)
  - MHW 02.01: [02.01.01.79.avm.de.upd](http://download.avm.de/dect/0201/02.01.01.79.avm.de.upd)
  - MHW 03.01: [03.01.04.08.avm.de.upd](http://download.avm.de/dect/0301/iq17/03.01.04.08.avm.de.upd)
  - MHW 04.01: [04.01.03.47.avm.de.upd](http://download.avm.de/dect/0401/p15/04.01.03.47.avm.de.upd)
  - MHW 04.02: [04.02.03.47.avm.de.upd](http://download.avm.de/dect/0402/p15/04.02.03.47.avm.de.upd)
  - MHW 05.01: [05.01.04.88.avm.de.upd](http://download.avm.de/dect/0501/move21/05.01.04.88.avm.de.upd)
  - MHW 06.02: [06.02.05.44.avm.de.upd](http://download.avm.de/dect/0602/Smart24P2/06.02.05.44.avm.de.upd)
  - MHW 06.03: [06.03.04.92.avm.de.upd](http://download.avm.de/dect/0603/move21/06.03.04.92.avm.de.upd)
  - MHW 06.04: [06.04.03.50.avm.de.upd](http://download.avm.de/dect/0604/p15/06.04.03.50.avm.de.upd)
  - MHW 06.05: [06.05.04.85.avm.de.upd](http://download.avm.de/dect/0605/iq17/06.05.04.85.avm.de.upd)
  - MHW 06.06: [06.06.05.23.avm.de.upd](http://download.avm.de/dect/0606/Smart24P2/06.06.05.23.avm.de.upd)
  - MHW 06.07: [06.07.05.23.avm.de.upd](http://download.avm.de/dect/0607/Smart24P2/06.07.05.23.avm.de.upd)
  - MHW 06.08: [06.08.04.93.avm.de.upd](http://download.avm.de/dect/0608/naut_test/06.08.04.93.avm.de.upd)
  - MHW 06.10: [06.10.04.90.avm.de.upd](http://download.avm.de/dect/0610/06.10.04.90.avm.de.upd)
  - MHW 06.12: [06.12.05.44.avm.de.upd](http://download.avm.de/dect/0612/Smart24P2/06.12.05.44.avm.de.upd)
  - MHW 06.13: [06.13.03.58.avm.de.upd](http://download.avm.de/dect/0613/Smart24/06.13.03.58.avm.de.upd)
  - MHW 06.14: [06.14.03.72.avm.de.upd](http://download.avm.de/dect/0614/Release/06.14.03.72.avm.de.upd)
  - MHW 07.01: [07.01.04.25.avm.de.upd](http://download.avm.de/dect/0701/07.01.04.25.avm.de.upd)
  - MHW 07.02: [07.02.04.27.avm.de.upd](http://download.avm.de/dect/0702/smart24/07.02.04.27.avm.de.upd)
  - MHW 07.03: [07.03.04.25.avm.de.upd](http://download.avm.de/dect/0703/move21/07.03.04.25.avm.de.upd)
  - MHW 07.04: [07.04.04.27.avm.de.upd](http://download.avm.de/dect/0704/smart24/07.04.04.27.avm.de.upd)
  - MHW 08.01: [08.01.04.93.avm.de.upd](http://download.avm.de/dect/0801/move21/08.01.04.93.avm.de.upd)
  - MHW 08.02: [08.02.04.94.avm.de.upd](http://download.avm.de/dect/0802/move21/08.02.04.94.avm.de.upd)
  - MHW 08.03: [08.03.04.94.avm.de.upd](http://download.avm.de/dect/0803/move21/08.03.04.94.avm.de.upd)
  - MHW 08.04: [08.04.05.12.avm.de.upd](http://download.avm.de/dect/0804/smart24p1/08.04.05.12.avm.de.upd)
  - MHW 10.01: [34.10.16.16.015.avm.de.upd](http://download.avm.de/dect/1001/Release/34.10.16.16.015.avm.de.upd)
  - MHW 12.01: [12.01.05.12.avm.de.upd](http://download.avm.de/dect/1201/initialrel/12.01.05.12.avm.de.upd)

### Dect-Labor
  - MHW 06.04: [06.04.03.54.avm.de.upd](http://download.avm.de/dect/0604/p15/06.04.03.54.avm.de.upd)
  - MHW 08.01: [08.01.05.11.avm.de.upd](http://download.avm.de/dect/0801/smart24p1/08.01.05.11.avm.de.upd)
  - MHW 08.02: [08.02.05.11.avm.de.upd](http://download.avm.de/dect/0802/smart24p1/08.02.05.11.avm.de.upd)
  - MHW 08.03: [08.03.05.12.avm.de.upd](http://download.avm.de/dect/0803/smart24p1/08.03.05.12.avm.de.upd)

### Dect-Inhaus

### BPjM
  - CRC 86f2ba52: [bpjm.data](http://download.avm.de/bpjm/290332/bpjm.data)
