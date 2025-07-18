# LCD4linux eadf4603
  - Manpage: [https://wiki.vuplus-support.org/index.php?title=LCD4Linux](https://wiki.vuplus-support.org/index.php?title=LCD4Linux)
  - Changelog: [https://github.com/TangoCash/lcd4linux/commits/master/](https://github.com/TangoCash/lcd4linux/commits/master/)
  - Repository: [https://github.com/TangoCash/lcd4linux](https://github.com/TangoCash/lcd4linux)
  - Package: [master/make/pkgs/lcd4linux/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/lcd4linux/)
  - Maintainer: [@fda77](https://github.com/fda77)

Mit LCD4linux kann ein an die Fritz!Box angeschlossenes Display angesteuert werden.<br>

[![screenshot](../screenshots/000-PKG_lcd4linux_md.png)](../screenshots/000-PKG_lcd4linux.png)
&emsp;
[![screenshot](../screenshots/000-PKG_lcd4linux_output_md.png)](../screenshots/000-PKG_lcd4linux_output.png)

Aktuell verfügbare Displays und Plugins:

```
$ lcd4linux -l

LCD4Linux 0.11.0-60925a0
Copyright (C) 2005, 2006, 2007, 2008, 2009 The LCD4Linux Team <lcd4linux-devel@users.sourceforge.net>

available display drivers:
   ASTUSB              : ASTUSB display interface
   Beckmann+Egle       : MT16x1 MT16x2 MT16x4 MT20x1 MT20x2 MT20x4 MT24x1 MT24x2 MT32x1 MT32x2 MT40x1 MT40x2 MT40x4 CT20x4 
   BWCT                : BWCT USB to HD44780 interface
   Crystalfontz        : 626 631 632 633 634 635 636 
   Curses              : pure ncurses based text driver
   Cwlinux             : CW1602 CW12232 CW12832 
   D4D                 : 4D Systems Display Graphics Modules
   DPF                 : Hacked dpf-ax digital photo frame
   EA232graphic        : GE120-5NV24 GE128-6N3V24 GE128-6N9V24 KIT160-6 KIT160-7 KIT240-6 KIT240-7 KIT320-8 GE128-7KV24 GE240-6KV24 GE240-6KCV24 GE240-7KV24 GE240-7KLWV24 GE240-6KLWV24 KIT120-5 KIT129-6 
   EFN                 : EFN LED modules + EUG100 Ethernet to serial converter
   FutabaVFD           : Futaba VFD M402SD06GL
   FW8888              : Allnet-FW8888
   G-15                : Logitech G-15 or Z-10 / Dell M1730
   GLCD2USB            : GLCD2USB homebrew USB interface for graphic displays
   HD44780             : generic Noritake Soekris HD66712 LCM-162 
   Image               : PPM PNG 
   IRLCD               : USBtiny LCD controller
   LCD2USB             : LCD2USB homebrew USB interface for HD44780 text displays
   LCDTerm             : LCDTerm serial-to-HD44780 adapter board
   LEDMatrix           : LEDMATRIX by Till Harbaum
   LW_ABP              : Logic Way ABP driver
   MatrixOrbital       : LCD0821 LCD2021 LCD1641 LCD2041 LCD4021 LCD4041 LK202-25 LK204-25 LK404-55 VFD2021 VFD2041 VFD4021 VK202-25 VK204-25 GLC12232 GLC24064 GLK24064-25 GLK12232-25 LK404-AT VFD1621 LK402-12 LK162-12 LK204-25PC LK202-24-USB LK204-24-USB VK204-24-USB DE-LD011 DE-LD021 DE-LD023 
   MatrixOrbitalGX     : Matrix Orbital GX Series driver
   MDM166A             : MDM166A 96x16 Graphic LCD
   MilfordInstruments  : MI216 MI220 MI240 MI420 
   Newhaven            : Newhaven driver
   NULL                : NULL driver for testing purposes
   Pertelian           : Pertelian X2040 displays
   PHAnderson          : PHAnderson serial-to-HD44780 adapter
   PICGraphic          : PICGraphic serial-to-graphic by Peter Bailey
   picoLCD             : picoLCD 20x2 Text LCD
   picoLCDGraphic      : picoLCD 256x64 Graphic LCD
   SamsungSPF          : SamsungSPF driver, supported models [SPF-AUTO, SPF-72H, SPF-75H, SPF-76H, SPF-83H, SPF-85H, SPF-85P, SPF-86H, SPF-86P, SPF-87H, SPF-87H-v2, SPF-105P, SPF-107H, SPF-107H-v2, SPF-700T, SPF-1000P]

   ShuttleVFD          : Shuttle SG33G5M, Shuttle PF27 upgrade kit
   SimpleLCD           : generic vt100
   TeakLCM             : TeakLCM driver
   TREFON              : TREFON USB LCD
   ULA200              : ULA200
   USBHUB              : USBHUB
   USBLCD              : USBLCD
   WincorNixdorf       : BA63 BA66

available plugins:
  cfg, math, string, test, time, apm, asterisk, button_exec, cpuinfo, diskstats, dvb, exec, event, fifo, file, hddtemp, huawei, i2c_sensors, iconv, imon, isdn, kvv, loadavg, meminfo, netdev, pop3, ppp, proc_stat, sample, seti, statfs, uname, uptime, w1retap, xmms
```

