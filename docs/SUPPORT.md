# Support
Wie kann ich Freetz-NG unterstützen?

 * __[Sponsor](#sponsor)__<a id='sponsor'></a><br>
    - [![](https://img.shields.io/static/v1?label=GitHub&message=fda77&logo=GitHub&color=%230e8e86)](https://github.com/sponsors/fda77)
    - [![](https://img.shields.io/static/v1?label=Bitcoin&message=fda77&logo=Bitcoin&color=%230e8e86)](bitcoin:BC1QXT5LP7C5HFHXRXSQRLTG964GMAZEUM07XQCRHU?label=Freetz-NG)
 * __[UNTESTED](#untested)__<a id='untested'></a><br>
   Im ```menuconfig``` und in [FIRMWARES](FIRMWARES.md) sind verschieden Geräte als ```UNTESTED``` markiert.<br>
   Mangels Hardware konnte auf diesen nicht ausprobiert werden ob Freetz-NG funktioniert.<br>
   Falls jemand so ein Gerät erfolgreich mit Freetz-NG betreibt, bitte Rückmeldung geben.<br>
   Am besten gleich mit einem Screenshot von ```Box-Info```.<br>
 * __[Quellcode](#quellcode)__<a id='quellcode'></a><br>
   Um ein modifiziertes Image zu erstellen, ist von AVM der passende Quellcode notwendig.<br>
   Da AVM Software nutzt die zB unter der GPL steht, muss dieser Sourcecode herausgegeben<br>
   werden - allerdings nur auf Anfrage!<br>
   Dazu sollte **jeder** für **jedes** seiner Geräte eine E-Mail an [fritzbox_info@avm.de](mailto:fritzbox_info@avm.de) schicken.<br>
   Dies zu **jeder** veröffentlichten FritzOS Version, auch für die sogenannten "Labor".<br>
   AVM veröffentlicht das Paket dann früher oder später auf [osp.avm.de/](https://osp.avm.de/).<br>
 * __[Pull request](#pull-request)__<a id='pull-request'></a><br>
   Eigene Änderungen zu Freetz-NG "pushen":
    - Auf [github.com/Freetz-NG/freetz-ng/](https://github.com/Freetz-NG/freetz-ng/) oben mit ```Fork``` einen Fork im eigenen Account erstellen.
    - Eigenen Fork auschecken: ```git clone https://github.com/BENUTZERNAME/freetz-ng.git```
    - Einen Branch erstellen: ```git branch BRANCHNAME``` ; ```git checkout BRANCHNAME``` ; ```git push -u origin BRANCHNAME```
    - Geänderte/hinzugefügte Dateien hochladen: ```git add . ; git commit -m "BESCHREIBUNG" ; git push```
    - Auf [github.com/Freetz-NG/freetz-ng/](https://github.com/Freetz-NG/freetz-ng/) mit ```New pull request``` die eigenen Änderungen abschicken.
 * __[Mailbox Format](#mailbox-format)__<a id='mailbox-format'></a><br>
   Falls ein pull request zu aufwändig ist kann auch ein Patch erstellt werden:
    - Auschecken: `git clone https://github.com/Freetz-NG/freetz-ng.git`
    - Sicherstellen dass der Name gesetzt ist: `git config --global user.name "GITHUB-NAME"`
    - Sicherstellen dass die eMail gesetzt ist: `git config --global user.email GITHUB-NAME@users.noreply.github.com`
    - Veränderungen vornehmen, Dateien löschen oder hinzufügen.
    - Alle Veränderungen hinzufügen: `git add .`
    - Einen Commit erstellen: `git commit -m "BESCHREIBUNG"`
    - Die Patchdatei erstellen: `git format-patch origin/HEAD`
    - Alle lokalen Veränderungen wieder löschen `git reset --hard  origin/HEAD`
 * __[Package bump](#package-bump)__<a id='package-bump'></a><br>
   Minimale Schritte um die Version eines Packages/Library zu aktualisieren:
    - Changelog lesen, es kann sich etwas geändert haben das beachtet werden muss.
    - Hinweis: Libraries befinden sich nicht in ```make/pkgs/$PKG/``` sondern: ```make/libs/$PKG/```
    - Die Datei ```docs/CHANGELOG.md``` anpassen.
    - Die Version in ```make/pkgs/$PKG/Config.in``` anpassen.
    - Die Version in ```make/pkgs/$PKG/$PKG.mk``` anpassen.
    - Die Prüfsumme in ```make/pkgs/$PKG/$PKG.mk``` anpassen.
    - Falls der Dateiname die Version enthält, ```make/pkgs/$PKG/external.*``` anpassen.
    - Vorhandene Patches in ```make/pkgs/$PKG/patches/``` aktualisieren durch ausführen von: ```make $PKG-autofix```
    - Compilieren testen mit: ```make $PKG-recompile```
    - Am besten noch auf eine Fritzbox flashen und testen.
 * __[Wiki](#wiki)__<a id='wiki'></a><br>
    Viele Teile des unter [freetz-ng.github.io/](https://freetz-ng.github.io/) zu erreichenden Wikis sind veraltet und bedürfen einer<br>
    Überarbeitung. Alle Datein des Wikis sind im Checkout unter ```docs/wiki/``` zu finden.<br>

