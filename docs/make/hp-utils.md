# hp-utils 0.3.2 - DEPRECATED
  - Package: [master/make/pkgs/hp-utils/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/hp-utils/)
  - Maintainer: -

[hp-utils](http://www.michaeldenk.de/projects/hp-utils/)
ist eine Portierung einiger Tools von
[HPLIP](http://hplipopensource.com/) von Python
nach C. hp-utils greift dabei auf die Bibliothek libhpmud zurück und
setzt das Paket [HPLIP](hplip.md) voraus.

hp-utils stellt Commandline-Tools zur Verfügung und bietet auch ein
Web-Interface (standardmäßig unter
[http://fritz.box:83/](http://fritz.box:83/)), das
derzeit den Druckerstatus und Tintenstand anzeigt und mit dem man eine
Druckkopfreinigung starten kann.

Folgende Tools sind enthalten:

  ------------------ ---------------------------------------------------------------------------
  **hp-probe**       Probe connected HP devices.
  **hp-status**      Display current status for supported HPLIP printers.
  **hp-levels**      Display bar graphs of current supply levels for supported HPLIP printers.
  **hp-clean**       Cartridge cleaning utility for HPLIP supported inkjet printers.
  **hp-printserv**   Simple print server.
  **hp-timedate**    Set the time and date on an HP Officejet.
  **hp-faxsetup**    Setup fax settings on an HP Officejet.
  ------------------ ---------------------------------------------------------------------------
