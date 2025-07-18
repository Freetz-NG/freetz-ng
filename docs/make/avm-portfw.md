# AVM-portfw
  - Package: [master/make/pkgs/avm-portfw/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/avm-portfw/)
  - Maintainer: [@fda77](https://github.com/fda77)

Mit AVM-portfw können (ausschliesslich) Ports der Fritz!Box selbst für Zugriff aus dem Internet freigegeben werden.<br>

[![screenshot](../screenshots/000-PKG_avm-portfw_md.png)](../screenshots/000-PKG_avm-portfw.png)

Dazu wird ```internet_forwardrules``` verwendet, nur für IPv4-Freigaben. Zu finden im menuconfig unter ```packages > webif```.
Da die ```ar7.cfg``` bearbeitet wird, sollte man vorher ein komplettes Backup anlegen - EXPERIMENTAL!

 * Portblöcke so angeben: PORT+ANZAHL, zB 55500+3 für 55500-55502.
 * Umleitungen so angeben: EXTERN(+ANZAHL):INTERN, zB 443:8443 oder 80+2:8008.
 * Die Einträge können im AVM-Webif unter Diagnose > Sicherheit überprüft werden.
 * Bei Syntaxfehlern wird die komplette ar7.cfg von AVM zurückgesetzt.

