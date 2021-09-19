# NEWS

 * __[2021-05-05](#2021-05-05)__<a id='2021-05-05'></a><br>
   Die libc und `SEPARATE_AVM_UCLIBC`<br>
   Bis zu Fritzos 7.0x hat AVM uClibc-ng 1.0.14 oder ältere uClibc verwendet. Beginnend mit 7.1x wurden dann<br>
   neuere und teilweise verschiedene Versionen von uClibc-ng, musl oder glibc genutzt. Freetz nutzt weiterhin<br>
   ausschliesslich eine neuere Version von uClibc-ng. Diese wird von den AVM-Binaries nicht gefunden und bei<br>
   den Freetz-Binaries wird der Pfad nach `/usr/lib/freetz/` fest vorgegeben.<br>
   Falls man nur mit Freetz erstellte Binaries nutzen möchte, muss die libc Library auch kopiert werden! Der<br>
   Pfad kann gegebenenfalls mit `FREETZ_RPATH` angepasst werden.

 * __[2021-04-10](#2021-04-10)__<a id='2021-04-10'></a><br>
   Neue Linux-Benutzer werden jetzt mit IDs ab 900 angelegt. Dadurch werden sie nicht mehr von AVM gelöscht.<br>
   Siehe [8d2700ef](https://github.com/Freetz-NG/freetz-ng/commit/8d2700ef40fc5ccee7a1dd03c55b11430b13b0c4)<br>

 * __[2021-03-04](#2021-03-04)__<a id='2021-03-04'></a><br>
   Es wurde ein neuer [Tag](https://github.com/Freetz-NG/freetz-ng/tags) `ng21030` erstellt.<br>
   Die automatisch angebotene und nicht deaktivierbare `.zip`-Datei darf auf keinen Fall verwendet werden, da<br>
   darin keine Dateiberechtigungen enthalten sind! In der `.tar.gz` fehlt mindestens die Versionsinformation.<br>
   Stattdessen sollte ein Tag wie in der [README](https://github.com/Freetz-NG/freetz-ng#or-clone-a-single-tag) beschrieben mit git ausgecheckt werden.<br>
   Siehe [ng21030](https://github.com/Freetz-NG/freetz-ng/releases/tag/ng21030)<br>

 * __[2021-03-02](#2021-03-02)__<a id='2021-03-02'></a><br>
   Vorcompilierte Tools und Toolchains sowie ccache sind nun komplett deaktiviert.<br>
   Es scheint wohl doch sehr kompliziert zu sein `apt-get` zu bedienen.<br>
   Die 30 Minuten die ein Imagebau nun mehr benötig hat man zur freien Verfügung.<br>
   Siehe [d6c35401](https://github.com/Freetz-NG/freetz-ng/commit/d6c35401204f899f11478ef316b0a003faef9ab9)<br>

 * __[2021-03-01](#2021-03-01)__<a id='2021-03-01'></a><br>
   [Akute Angriffswelle auf Fritzbox-Nutzer, jetzt handeln!](https://heise.de/-5068111) berichtet Heise. Laut [AVM](https://avm.de/service/aktuelle-sicherheitshinweise/) ist das ganz normal und macht nichts.<br>
   Dies mag stimmen, solange in den closed-source Teilen die aus dem Internet erreichbar sind kein Bug entdeckt wird,<br>
   das kommt aber auch schon mal vor: [Hack gegen AVM-Router: Fritzbox-Lücke offengelegt, Millionen Router in Gefahr](https://heise.de/-2136784)<br>
   Das eigentliche Problem liegt aber darin dass ein Hersteller einen DynDNS-Dienst anbietet ("myfritz") und sich so leicht<br>
   viele seiner Geräte finden lassen. Die kyrptischen Namen die hierbei vergeben werden verursachen ausschliesslich Probleme<br>
   beim Merken, irgendeinen Vorteil haben sie nicht. Denn jedes ausgestelle HTTPS Zertifikat ist öffentlich einsehbar, zb im<br>
   [Transparenzreport von Google](https://transparencyreport.google.com/). Dieser listet aktuell [etwa 100.000 Zertifikate für Hostnamen](https://transparencyreport.google.com/https/certificates?cert_search=include_subdomains:true;domain:myfritz.net;issuer_uid:6637846985631092092) unter `myfritz.net` auf.<br>
   Was kann man tun?
    - Auf keinen Fall Standardports (HTTPS: 443) verwenden
    - Am besten einen anderen Dyndns-Anbieter nutzen
    - Optimalerweise keine Dienste der Fritzbox ins Internet freigeben

 * __[2021-02-27](#2021-02-27)__<a id='2021-02-27'></a><br>
   Alternativ zu [fakeroot](http://freshmeat.sourceforge.net/projects/fakeroot) kann [pseudo](https://www.yoctoproject.org/software-item/pseudo/) zur Imageerstellung ausgewählt werden.<br>
   Siehe [74ad5acd](https://github.com/Freetz-NG/freetz-ng/commit/74ad5acd02bd31e83dc249563345a9f8f6c602fe)<br>

 * __[2021-02-17](#2021-02-17)__<a id='2021-02-17'></a><br>
   Zu den `Download-Toolchains` gibt es jetzt die `Download-Host-Tools`. Dies spart etwas Zeit beim Imagebau. Auf einem<br>
   64-Bit Linux muss die 32-Bit Version von `libz` installiert sein! Für Ubuntu: ```sudo apt-get install lib32z1-dev```<br>
   Siehe [cc66c126](https://github.com/Freetz-NG/freetz-ng/commit/cc66c1264725c60edc8ca5bc7795c6243a9ab41e)<br>

 * __[2021-02-09](#2021-02-09)__<a id='2021-02-09'></a><br>
   In den Makefiles von Packages können nun "Kommentare" angegeben werden aus denen Links im `docs/` Verzeichnis<br>
   generiert werden. Aktuell möglich sind:<br>
   ```### WEBSITE:=http...```<br>
   ```### MANPAGE:=http...```<br>
   ```### CHANGES:=http...```<br>
   ```### CVSREPO:=http...```<br>
   Beispiel: [dnsmasq.html](https://freetz-ng.github.io/freetz-ng/make/dnsmasq.html) - [dnsmasq.mk](https://github.com/Freetz-NG/freetz-ng/blob/master/make/dnsmasq/dnsmasq.mk)<br>
   Siehe [551baf7b](https://github.com/Freetz-NG/freetz-ng/commit/551baf7bf9ed902be832fe69ed1bdf49c7b6e333)<br>

 * __[2021-02-05](#2021-02-05)__<a id='2021-02-05'></a><br>
   Juis ist jetzt bei allen Geräten auch für stabile Firmwareversionen aktivierbar. Aus technischen Gründen ist dies nur für die<br>
   jeweils neueste Firmwarereihe wie zB `07.2x` möglich.<br>
   Siehe [c12795f5](https://github.com/Freetz-NG/freetz-ng/commit/c12795f57d8ba7cb139da6c75fec0940483ff0c6)<br>

 * __[2021-01-31](#2021-01-31)__<a id='2021-01-31'></a><br>
   Für Labor und Inhaus können im menuconfig durch Aktivieren der Option `Detect the latest firmware version`<br>
   automatisch mittels PeterPawns juis_check.sh von AVMs JUIS die aktuellste Firmwareversionen abgerufen werden.<br>
   Siehe [39f7254b](https://github.com/Freetz-NG/freetz-ng/commit/39f7254bbe83c5edb62a1163c948603a521d13d1)<br>

 * __[2021-01-28](#2021-01-28)__<a id='2021-01-28'></a><br>
   Ein alter Kompatibilitätseintrag wurde entfernt. Falls die .config noch nicht aktualisiert wurde kann<br>
   dies so erzwungen werden: `sed '/FEATURE_CROND_DIR/d' -i .config ; make olddefconfig`<br>
   Siehe [8441999c](https://github.com/Freetz-NG/freetz-ng/commit/8441999c177216cbeb54eefa711e867905a6864c)<br>

 * __[2021-01-27](#2021-01-27)__<a id='2021-01-27'></a><br>
   Es wurde ein neuer [Tag](https://github.com/Freetz-NG/freetz-ng/tags) `ng21010` erstellt.<br>
   Die automatisch angebotene und nicht deaktivierbare `.zip`-Datei darf auf keinen Fall verwendet werden, da<br>
   darin keine Dateiberechtigungen enthalten sind! In der `.tar.gz` fehlt mindestens die Versionsinformation.<br>
   Stattdessen sollte ein Tag wie in der [README](https://github.com/Freetz-NG/freetz-ng#or-clone-a-single-tag) beschrieben mit git ausgecheckt werden.<br>
   Siehe [ng21010](https://github.com/Freetz-NG/freetz-ng/releases/tag/ng21010)<br>

 * __[2021-01-01](#2021-01-01)__<a id='2021-01-01'></a><br>
   Auf GitHub gibt es einen neuen [Discussions](https://github.com/Freetz-NG/freetz-ng/discussions)-Bereich für
   jedes Projekt. Im Gegensatz zu den [Issues](https://github.com/Freetz-NG/freetz-ng/issues) stellt dies keinen<br>
   Bugtrack sondern mehr etwas in Richtung eines Forums dar. Wohin es sich entwickelt wird sich mit der Zeit zeigen.<br>
   Hoffentlich wird es mehr als 1 Person geben die dort Fragen beantwortet!<br>
   Wer seine Mitmenschen mit täglichen Wasserstandmeldungen über die mehr/weniger/gleichen Megabait seines Indaneds<br>
   nach dem Laden der 100. Inhaus belästigen möchte ist dort allerdings falsch. Dafür gibt es ein Forum auf den Seychellen<br>
   mit zensurfreudigen möchtegern Sittenwächtern. Solch einen Mist ist dort gerne gesehen und zuhauf zu finden.<br>
   Siehe [DISCUSSIONS](https://github.com/Freetz-NG/freetz-ng/discussions)<br>

 * __[2020-12-18](#2020-12-18)__<a id='2020-12-18'></a><br>
   Es gibt nun den ersten [Tag](https://github.com/Freetz-NG/freetz-ng/tags) `ng20120`. Weitere git-Tags sind vor "grösseren" Änderungen geplant. Der Name setzt<br>
   sich aus `ng`+`JJahr`+`MMonat`+`Unterversion` zusammen. Die Unterversion sollte meist eine `0` sein.<br>
   Die automatisch angebotene und nicht deaktivierbare `.zip`-Datei darf auf keinen Fall verwendet werden, da<br>
   darin keine Dateiberechtigungen enthalten sind! In der `.tar.gz` fehlt mindestens die Versionsinformation.<br>
   Stattdessen sollte ein Tag wie in der [README](https://github.com/Freetz-NG/freetz-ng#or-clone-a-single-tag) beschrieben mit git ausgecheckt werden.<br>
   Siehe [ng20120](https://github.com/Freetz-NG/freetz-ng/releases/tag/ng20120)<br>

 * __[2020-12-05](#2020-12-05)__<a id='2020-12-05'></a><br>
   Die rc.mod (also Freetz selbst) wird nun asynchron gestartet. Dadurch kann der Bootvorgang nicht mehr<br>
   blockiert oder der AVM-Watchdog auslöset werden.<br>
   Siehe [28ebac1a](https://github.com/Freetz-NG/freetz-ng/commit/28ebac1a84cda2ff1d014de428e8b60856ff55b0)<br>

 * __[2020-11-18](#2020-11-18)__<a id='2020-11-18'></a><br>
   Die rc.custom wird nun asynchron ausgeführt und kann den Startvorgang nicht mehr blockieren.<br>
   Siehe [680b9ef6](https://github.com/Freetz-NG/freetz-ng/commit/680b9ef65c47a1eb4cbdcc18b0f9e9ff4799ba9e)<br>

 * __[2020-11-02](#2020-11-02)__<a id='2020-11-02'></a><br>
   Wegen Änderungen von Dateinamen durch die neuere Version von Ncurses kann es zu Problemen bei<br>
   ```make``` kommen. Ein ```make distclean``` sollte helfen.<br>
   Siehe
   [825600d4](https://github.com/Freetz-NG/freetz-ng/commit/825600d4c37e5784eeb650fc997447ffe882cb72) /
   [3a1864a2](https://github.com/Freetz-NG/freetz-ng/commit/3a1864a225479cd30305d9dc33369e7980ab2157)
   <br>

 * __[2020-10-13](#2020-10-13)__<a id='2020-10-13'></a><br>
   Für Patches von Packages kann Patchlevel 0-9 genutzt werden. Autofix erstellt immer Patches mit Level 0.<br>
   Siehe [050b65e7](https://github.com/Freetz-NG/freetz-ng/commit/050b65e721f81885ddcbc35878a6dc51128a3806)<br>

 * __[2020-09-26](#2020-09-26)__<a id='2020-09-26'></a><br>
   Mit dem Script ```tools/image2inmemory``` können inmemory-Dateien von Images für "nand"-Geräte erstellt werden.<br>
   Siehe [a8ec702e](https://github.com/Freetz-NG/freetz-ng/commit/a8ec702e382705d29a9dee02b28e693358c5cae5)<br>

 * __[2020-08-17](#2020-08-17)__<a id='2020-08-17'></a><br>
   Es können keine inmemory-Dateien mehr direkt mit ```make``` erstellt werden.<br>
   Siehe [d2bd1d25](https://github.com/Freetz-NG/freetz-ng/commit/d2bd1d25a66534dcea5db6f009f26c5ca238ef62)<br>

 * __[2020-07-20](#2020-07-20)__<a id='2020-07-20'></a><br>
   Es kann zu einer ungültigen Kombination aus ```squashfs4``` Binary und Aufrufparametern in der ```fwmod```<br>
   kommen. Um dies zu verhindern: ```make squashfs4-le-dirclean ; make squashfs4-be-dirclean```<br>
   Siehe
   [86c23d96](https://github.com/Freetz-NG/freetz-ng/commit/86c23d96d76585825fa81b5cb29105e9d2ad6654) /
   [e311bb12](https://github.com/Freetz-NG/freetz-ng/commit/e311bb1257ee180c90579b3947f9200f11d62a1f) /
   [761e1923](https://github.com/Freetz-NG/freetz-ng/commit/761e1923f9d410b639c1535278f188c698b3653a)
   <br>

 * __[2020-07-18](#2020-07-18)__<a id='2020-07-18'></a><br>
   Mit dem Branch ```kernel49``` können Kernelmodule für die neuesten FritzOS von 7590/7580/6890/7583VDSL<br>
   gebaut werden.<br>
   UPDATE: Die Änderungen des Branches befindet sich mittlerweile im ```master```.<br>

 * __[2020-07-11](#2020-07-11)__<a id='2020-07-11'></a><br>
   Aktueller Status der 7590 mit FritzOS 7.20<br>
    - ~~Bei nicht eingehängten Datenträgern den Patch ```Remove UMTS``` nicht auswählen.~~<br>
    - ~~Bei durch den Watchdog ausgelöste Reboots ("Bootloop") den Patch ```Disable AVM watchdog``` auswählen.~~<br>
    - ~~Es können noch keine Kernelmodule gebaut werden, Sourcen von AVM gibt es bereits.~~<br>
    - Für OpenVPN usw wird vermutlich ```yf_patchkernel``` weiterhin benötigt.<br>

 * __[2020-07-08](#2020-07-08)__<a id='2020-07-08'></a><br>
   In den letzten Tagen gab es einige Änderungen an der Busybox. So wurde die experimentelle Version<br>
   1.32 hinzugefügt und kann nach Auswähl im menuconfig getestet werden. Ausserdem wurden viel Optionen<br>
   aktiviert die in der Busybox von AVM bereits aktviert sind. Diese werden grösstenteils nicht von<br>
   AVM genutzt, in machen Fällen werden dadurch aber Probleme verursacht wie keine LTE-Funktionalität<br>
   mit der 6890.<br>
    - Meistens wurden neue Applets zusätzlich aktiviert<br>
    - Die meisten Änderungen betreffen FritzOS ab 7.0<br>
   
   Ich hab bislang keine Probleme festgestellt...<br>
 
 * __[2020-07-06](#2020-07-06)__<a id='2020-07-06'></a><br>
   Eigener Kernel und Module für aktuelle FritzOS<br>
   Für die 7590 (und ähnliche GRX5) gibt es nach wie vor keinen replace-kernel, da noch niemand das neue<br>
   Format des Bootloaders analysiert und für Freetz angepasst hat. ~~Module für den Kernel sind für viele<br>
   aktuelle FritzOS auch nicht verfügbar. Dadurch sind Dinge wie Wireguard, OpenVPN, zusätzliche Dateisysteme<br>
   usw deaktiviert. Ursache hierfür ist dass das Tool ```avm_kernel_config``` bzw ```yourfritz-akc-host``` noch nicht<br>
   angepasste wurde. Dies wurde ursprünglich von PeterPawn entwickelt und von er13 erweitert.<br>
   Leider fühlt sich mittlerweile niemand mehr dafür zuständig. Freiwillige vor!~~<br>

 * __[2020-07-02](#2020-07-02)__<a id='2020-07-02'></a><br>
   Nun verhindert eine unspezifische höhere Macht die Herausgabe von Sourcecode.<br>
   Dass die 7369 weder offiziell EOS/EOL ist, noch das Dateidatum der letzt Firmware älter als 3 Jahre ist, konnte<br>
   AVM nicht abstreiten. Der Sourcecode wird dennoch nicht herausgegeben, weil es schlicht "nicht möglich" ist.<br>
   <br>
   AVM schrieb dazu auf eine Anfrage per Mail:<br>
   ```...```<br>
   ```Sie haben vollkommen recht, die 7369 taucht nicht in der EOS-Liste auf, warum das so ist,```<br>
   ```ist mir nicht bekannt. Sie ist bereits seit 2016 EOS. Das letzte Update gab es den mir vorliegen```<br>
   ```Informationen nach 06/2016.```<br>
   ```Aber ganz davon abgesehen, würde es keine entscheidende Rolle spielen, ob jetzt drei Jahre```<br>
   ```überschritten sind oder nicht, wenn wir Ihnen den Quellcode bereit stellen könnten, würden wir```<br>
   ```es tun. Nun habe ich aber intern die Information bekommen, dass es nicht möglich ist. Etwas```<br>
   ```anderes kann ich Ihnen dazu leider nicht sagen.```<br>
   ```...```<br>
   <br>
   Dann macht es halt möglich!!1<br>
   Hiervon unabhängig erfuhr AVM [vs. Cybits](https://www.heise.de/newsticker/meldung/AVM-vs-Cybits-Gericht-staerkt-GPL-1389738.html) bereits leidlich, dass die [Bedingungen der GPL nicht optional](https://gpl-violations.org/news/20110620-avm-cybits/) sind.<br>

 * __[2020-06-30](#2020-06-30)__<a id='2020-06-30'></a><br>
   Für den 546E wurden von AVM pünktlich zum erreichen des EOS (End of Support) erstmalig Sourcen veröffentlicht!

 * __[2020-06-12](#2020-06-12)__<a id='2020-06-12'></a><br>
   AVM verweigert die Herausgabe von Sourcecode aufgrund "Verjährung".<br>
   Dies betrifft die 7369 für die aktuell es nur ein [unvollständiges Quellpaket](https://web.archive.org/web/20200701201542/http://osp.avm.de/fritzbox/fritzbox-7369/) dem [wichtige Dateien fehlen](https://www.ip-phone-forum.de/threads/306749) gibt.<br>
   <br>
   AVM schrieb dazu auf eine Anfrage per Mail:<br>
   ```...```<br>
   ```Leider sieht es so aus, als könnten wir Ihnen in dieser Angelegenheit keine Lösung anbieten.```<br>
   ```Intern wurde nämlich nochmal drauf gesehen und festgestellt, dass das vermutlich auch weiterhin```<br>
   ```ein Problem werden wird zu kompilieren. Ausserdem haben die Kollegen festgestellt und bitten```<br>
   ```um Verständnis, dass GPL drei Jahre nach Produkteinstellung seine Wirkung verliert.```<br>
   ```Leider kann ich Ihnen daher keine weiteren Fragen zum Quellpaket der seit 2016 nicht mehr im```<br>
   ```Verkauf befindlichen 7369 beantworten. Ich wünsche Ihnen dennoch viel Erfolg mit Ihrem Projekt!```<br>
   ```...```<br>
   <br>
   Tatsache dagegen ist, dass die neueste Firmware '119.06.32' vom [11.10.2017](http://web.archive.org/web/20200701223436/https://download.avm.de/fritzbox/fritzbox-7369/other/fritz.os/) stammt und KEINE 3 Jahre alt ist!<br>
   Desweiteren ist die 7369 [weder als EOM noch als EOS](https://web.archive.org/web/20200624140752/https://avm.de/service/ende-des-produktsupports-und-der-produktweiterentwicklung/fritzbox/) gelistet.<br>
   Also bitte AVM: Nachbessern!<br>

 * __[2020-05-12](#2020-05-12)__<a id='2020-05-12'></a><br>
   ~~Wer kann Freetz-NG einen Mirror-Server zur Verfügung stellen?<br>
   Zugriff: Download via http, am besten https<br>
   Speicherplatz: Maximal 10GB notwendig<br>
   Traffic: Unbekannt, am besten unbegrenzt<br>
   Upload: Entweder mittels FTP oder GIT vom [dl-mirror](https://github.com/Freetz-NG/dl-mirror)<br>
   Kontakt: Hier ein Issue öffnen oder PM im Forum~~<br>

 * __[2020-05-05](#2020-05-05)__<a id='2020-05-05'></a><br>
   Mit ```LIBCTEST``` gekennzeichnete Geräte und/oder Firmware ist EXPERIMENTAL!<br>
   Es können zB Problemen mit der Benutzerverwaltung in ```/etc/passwd``` auftreten.<br>
   In diesem Fall lädt ```modusers load``` die Freetz-Konfiguration wieder.<br>
   Es gibt 4 neue Geräte: 6591 6660 7581 7582<br>
   Und 10 Laborversionen: 1200 1750 2400 3000 6490 6590 6591 7490 7530 7590<br>
   Siehe [r16706](https://trac.boxmatrix.info/freetz-ng/changeset/16706/freetz-ng)
   / [6607e747](https://github.com/Freetz-NG/freetz-ng/commit/6607e747bf9214db24a417aafd8a962f360d8ffc)<br>

 * __[2020-05-04](#2020-05-04)__<a id='2020-05-04'></a><br>
   BusyBox 1.31 ist nun die Standardversion.<br>
   Diese Version ist für Firmware mit Kernel 2.6 nicht verfügbar.<br>
   Siehe [r16708](https://trac.boxmatrix.info/freetz-ng/changeset/16708/freetz-ng)
   / [8ebedc0c](https://github.com/Freetz-NG/freetz-ng/commit/8ebedc0c292f23889b487cbcedc074c791253944)<br>

 * __[2020-04-17](#2020-04-17)__<a id='2020-04-17'></a><br>
   Patch [multiple fax pages](patches/README.md#patch-faxpages) hinzugefügt.<br>
   Mit diesem Patch können mehrere Seiten in einem Fax verschickt werden.<br>
   Siehe [r16674](https://trac.boxmatrix.info/freetz-ng/changeset/16674/freetz-ng)
   / [44ab5583](https://github.com/Freetz-NG/freetz-ng/commit/44ab55837827ac991284708ed34fafa2b8e84783)<br>

 * __[2020-03-09](#2020-03-09)__<a id='2020-03-09'></a><br>
   Auf der Hauptseite des Webinterfaces werden nun zusätzlich der ```Temporäre```<br>
   ```Speicher``` und die ```Konfigurationspartition``` (falls verfügbar) angezeigt.<br>
   Dies kann im Webinterface unter ```Freetz > Weboberfläche``` konfiguriert werden.<br>
   Siehe [r16637](https://trac.boxmatrix.info/freetz-ng/changeset/16637/freetz-ng)
   / [76b57af6](https://github.com/Freetz-NG/freetz-ng/commit/76b57af63447928e84b5fe11adc0e1e5c854bad8)<br>

 * __[2020-03-05](#2020-03-05)__<a id='2020-03-05'></a><br>
   Neuer Branch [libctest](https://github.com/Freetz-NG/freetz-ng/tree/libctest).<br>
   In diesem Branch können verschieden Geräte und Firmware getestet werden, die diese<br>
   libc nutzen: uclibc 1.0.30, uclibc 1.0.31, glib 2.23, glibc 2.28 und musl libc 1.1.24<br>
   Bekannte Probleme in der [README](https://github.com/Freetz-NG/freetz-ng/blob/libctest/README.md) beachten!<br>
   Siehe [4b64a268](https://github.com/Freetz-NG/freetz-ng/commit/4b64a268c688875dacf0c9089ff89299277d6b55)<br>

 * __[2020-03-03](#2020-03-03)__<a id='2020-03-03'></a><br>
   Patch [web menu secure message](patches/README.md#patch-secure) hinzugefügt.<br>
   Der Patch entfernt dein Hinweis auf der Hauptseite bei unsicheren Einstellungen.<br>
   Dies betrifft aktuell ```IP-Phone von Aussen``` und ```2-Faktor deaktiviert```.<br>
   Siehe [r16610](https://trac.boxmatrix.info/freetz-ng/changeset/16610/freetz-ng)
   / [a7a60102](https://github.com/Freetz-NG/freetz-ng/commit/a7a60102d4a6fbb2739f9c5d09d9ab87bb1615c6)<br>

 * __[2020-02-02](#2020-02-02)__<a id='2020-02-02'></a><br>
   Der neue Link ```/ftp``` zeigt immer auf das Verzeichnis ```/var/media/ftp/```.<br>
   Siehe [r16542](https://trac.boxmatrix.info/freetz-ng/changeset/16542/freetz-ng)
   / [dfeeec6d](https://github.com/Freetz-NG/freetz-ng/commit/dfeeec6d00066b5877c71a8d7ecabc9b3586e863)<br>

 * __[2020-01-31](#2020-01-31)__<a id='2020-01-31'></a><br>
   Standard GID der ```users``` zu ```80``` geändert.<br>
   Dies sollte keine Auswirkungen auf bestehende Konfigurationen haben.<br>
   Die vorherige GID ```1``` wird von AVM für ```watchdog``` verwendet.<br>
   Siehe [r16534](https://trac.boxmatrix.info/freetz-ng/changeset/16534/freetz-ng)
   / [78a39a9d](https://github.com/Freetz-NG/freetz-ng/commit/78a39a9d9067ccf79c19e44c54a9b7a890d155cd)<br>

 * __[2020-01-30](#2020-01-30)__<a id='2020-01-30'></a><br>
   Freetz-NG hat Geburtstag!<br>
   Ein erfolgreiches Jahr unter dem Motto: Mehr Features - weniger Bugs.<br>
   Siehe [r15015](https://trac.boxmatrix.info/freetz-ng/changeset/15015/freetz-ng)
   / [eaf06dbb](https://github.com/Freetz-NG/freetz-ng/commit/eaf06dbb153d8ee2eabeedb827f1c8d80e409744)<br>

 * __[2020-01-19](#2020-01-19)__<a id='2020-01-19'></a><br>
   Compilierfehler beim Kernel für 7490 etc.<br>
   Dies kann durch einen nicht angewendeten Patch auftreten.<br>
   Zum beheben reicht ```make kernel-dirclean``` aus.<br>
   Siehe [r16472](https://trac.boxmatrix.info/freetz-ng/changeset/16472/freetz-ng)
   / [4421b48d](https://github.com/Freetz-NG/freetz-ng/commit/4421b48d92022fa9e15d50edd3384dbe6089111b)<br>
   Siehe [r16464](https://trac.boxmatrix.info/freetz-ng/changeset/16464/freetz-ng)
   / [66c33a0a](https://github.com/Freetz-NG/freetz-ng/commit/66c33a0a9e2c945a9ff70a7f527819402b6073e7)<br>
   Siehe [r16459](https://trac.boxmatrix.info/freetz-ng/changeset/16459/freetz-ng)
   / [fcf48be8](https://github.com/Freetz-NG/freetz-ng/commit/fcf48be8ff4385f5bfb264b96ee61c3d903d28ef)<br>

 * __[2019-12-11](#2019-12-11)__<a id='2019-12-11'></a><br>
   FRITZ!Box 6591 Cable Support.<br>
   Images für dieses Gerät können nun gebaut werden, sind aber noch nicht lauffähig.<br>
   Den aktuellen Status kann man [FIRMWARES](FIRMWARES.md#not-supported-devices) entnehmen.<br>
   Siehe [r16424](https://trac.boxmatrix.info/freetz-ng/changeset/16424/freetz-ng)
   / [2c56b535](https://github.com/Freetz-NG/freetz-ng/commit/2c56b5354f0e2aa06d87ab7c6aedd70b639be08e)<br>

 * __[2019-11-06](#2019-11-06)__<a id='2019-11-06'></a><br>
   Das Trac auf boxmatrix funktioniert aktuell nicht richtig.<br>
   Bitte stattdessen [GitHub](https://github.com/Freetz-NG/freetz-ng/issues) verwenden.<br>

 * __[2019-11-03](#2019-11-03)__<a id='2019-11-03'></a><br>
   In [./docs](./) liegt nun die gesammte Dokumentation und das alte Wiki.<br>
   Darauf kann über die [README.md](README.md) oder [https://freetz-ng.github.io/](https://freetz-ng.github.io/) zugegriffen werden.<br>
   Nach einem Checkout sind die docs nun auch offline lesbar und passen immer zum aktuellen Revisionsstand.<br>

 * __[2019-11-01](#2019-11-01)__<a id='2019-11-01'></a><br>
   Package [AVM-portfw](make/avm-portfw.md) hinzugefügt.<br>
   Damit können Ports auf die Fritzbox selbst freigegeben werden.<br>
   Falls vorher [AVM-rules (deprecated)](make/avm-rules.md) verwendet wurde, sollten in diesem zuerst die Freigaben gelöscht werden!<br>
   Ein Port kann nur mit einem Package freigegeben werden.<br>
   Siehe [r16331](https://trac.boxmatrix.info/freetz-ng/changeset/16331/freetz-ng)
   / [e1b77975](https://github.com/Freetz-NG/freetz-ng/commit/e1b77975a25a939ca935ce324b3d90f27d3013ba)<br>

 * __[2019-10-27](#2019-10-27)__<a id='2019-10-27'></a><br>
   BusyBox auf Version 1.31.1 aktualisiert.<br>
   Falls diese genutzt werden soll, muss sie ausgewählt werden - auch wenn vorher bereits die 1.30.0 genutzt wurde!<br>
   Siehe [r16311](https://trac.boxmatrix.info/freetz-ng/changeset/16311/freetz-ng)
   / [6f93fa14](https://github.com/Freetz-NG/freetz-ng/commit/6f93fa14d35e709c09467b4fd450575094beeeb2)<br>

 * __[2019-10-06](#2019-10-06)__<a id='2019-10-06'></a><br>
   Patch [udevmount](patches/README.md#patch-udevmount) hinzugefügt.<br>
   Dies ist der Nachfolger von [FREETZMOUNT](patches/README.md#patch-freetzmount) und unterstützt udev.<br>
   Siehe [r16207](https://trac.boxmatrix.info/freetz-ng/changeset/16207/freetz-ng)
   / [0b6eefe0](https://github.com/Freetz-NG/freetz-ng/commit/0b6eefe0091040bf0bf51245bc08446656f21a12)<br>

 * __[2019-09-20](#2019-09-20)__<a id='2019-09-20'></a><br>
   Busybox Version 1.31.0 hinzugefügt.<br>
   Falls diese verwendet werden soll, muss sie im ```menuconfig``` ausgewählt werden.<br>
   Nicht verfügbar für Geräte mit altem 2.6 Kernel.<br>
   Siehe [r16118](https://trac.boxmatrix.info/freetz-ng/changeset/16118/freetz-ng)
   / [27b492b7](https://github.com/Freetz-NG/freetz-ng/commit/27b492b7c2471de6e8013fe5bed35508076e37d7)<br>

 * __[2019-09-17](#2019-09-17)__<a id='2019-09-17'></a><br>
   Package [Dehydrated](make/dehydrated.md) (ursprünglich LetsEncrypt) hinzugefügt.<br>
   Dieses kann zusammen mit Lightpd HTTPS-Zertifikate generieren und verwenden.<br>
   Siehe [r16103](https://trac.boxmatrix.info/freetz-ng/changeset/16103/freetz-ng)
   / [084f67df](https://github.com/Freetz-NG/freetz-ng/commit/084f67df21b53a34cfddb9a12ccd84cf850e61b9)<br>
   Siehe [r15110](https://trac.boxmatrix.info/freetz-ng/changeset/15110/freetz-ng)
   / [1386ec4b](https://github.com/Freetz-NG/freetz-ng/commit/1386ec4bdf9d3ace1d92410218e2a949c73aa85d)<br>

 * __[2019-09-16](#2019-09-16)__<a id='2019-09-16'></a><br>
   Package [minisatip](make/minisatip.md) hinzugefügt.<br>
   Dies kann die DVB-c Tuner von AVM Geräten als normales SAT>IP bereitstellen.<br>
   Siehe [r16090](https://trac.boxmatrix.info/freetz-ng/changeset/16090/freetz-ng)
   / [8f8a081e](https://github.com/Freetz-NG/freetz-ng/commit/8f8a081e32a2e8c936558ea0247eaf7b99312c8b)<br>

 * __[2019-09-12](#2019-09-12)__<a id='2019-09-12'></a><br>
   Package [Addhole](make/addhole.md) hinzugefügt.<br>
   Dieses lädt Hostlisten herunter und blockiert sie mit Dnsmasq.<br>
   Siehe [r16055](https://trac.boxmatrix.info/freetz-ng/changeset/16055/freetz-ng)
   / [d1b88097](https://github.com/Freetz-NG/freetz-ng/commit/d1b8809796f3dfecae95c3c76f3fdf921a72cd32)<br>

 * __[2019-09-06](#2019-09-06)__<a id='2019-09-06'></a><br>
   Patch [start-wlan-if-on-boot](patches/README.md#patch-start-wlan-if-on-boot) hinzugefügt.<br>
   Workaround für Probleme mit Wlan und DHCP auf VR9 Geräten wie 7490.<br>
   Siehe [r16031](https://trac.boxmatrix.info/freetz-ng/changeset/16031/freetz-ng)
   / [9f1eec67](https://github.com/Freetz-NG/freetz-ng/commit/9f1eec67f7cad2824fb4306020964aed9e8c00fe)<br>

 * __[2019-08-25](#2019-08-25)__<a id='2019-08-25'></a><br>
   ```tools/push_firmware```: Alle Parameters sind nun optional.<br>
   Siehe [r15987](https://trac.boxmatrix.info/freetz-ng/changeset/15987/freetz-ng)
   / [f5433ffc](https://github.com/Freetz-NG/freetz-ng/commit/f5433ffc7ad3ab453382ba377c0206ef350d4a26)<br>

 * __[2019-08-13](#2019-08-13)__<a id='2019-08-13'></a><br>
   Patch [add-telnetd](patches/README.md#add-telnetd) hinzugefügt.<br>
   Dies betrifft nur neuere Geräte und ist standardmässig deaktiviert.<br>
   Siehe [r15937](https://trac.boxmatrix.info/freetz-ng/changeset/15937/freetz-ng)
   / [3a818412](https://github.com/Freetz-NG/freetz-ng/commit/3a8184127e24c266d28413eb4633a25ddd079252)<br>

 * __[2019-08-13](#2019-08-13)__<a id='2019-08-13'></a><br>
   Patch [remove-telnetd](patches/README.md#remove-telnetd) hinzugefügt.<br>
   Dies betrifft nur ältere Geräte und ist standardmässig aktiviert.<br>
   Siehe [r15931](https://trac.boxmatrix.info/freetz-ng/changeset/15931/freetz-ng)
   / [4e05ae21](https://github.com/Freetz-NG/freetz-ng/commit/4e05ae21279a6cff2a914c60904290a8674ecfff)<br>

 * __[2019-08-03](#2019-08-03)__<a id='2019-08-03'></a><br>
   Freetz-Webui: Das Sicherheitslevel ist nun standardmässig '0', kann im menuconfig geändert werden.<br>
   Siehe [r15874](https://trac.boxmatrix.info/freetz-ng/changeset/15874/freetz-ng)
   / [a2f55ca4](https://github.com/Freetz-NG/freetz-ng/commit/a2f55ca4bb5ef2e1f66e2800fb1cd08a05c19004)<br>

 * __[2019-07-31](#2019-07-31)__<a id='2019-07-31'></a><br>
   Addons: Es können nun ```./addon/*.pkg``` zum aktivieren von Addons verwendet werden.<br>
   Siehe [r15856](https://trac.boxmatrix.info/freetz-ng/changeset/15856/freetz-ng)
   / [3dda6456](https://github.com/Freetz-NG/freetz-ng/commit/3dda64565e9f58f35c310455fbc2e61a4b095ddc)<br>

 * __[2019-06-22](#2019-06-22)__<a id='2019-06-22'></a><br>
   Package [LCD4linux](make/lcd4linux.md) hinzugefügt.<br>
   Damit kann ein USB-Display angesteuert werden.<br>
   Siehe [r15768](https://trac.boxmatrix.info/freetz-ng/changeset/15768/freetz-ng)
   / [a59ff246](https://github.com/Freetz-NG/freetz-ng/commit/a59ff246fc55a1c438723a404bf73afda8a6e7a1)<br>

 * __[2019-06-12](#2019-06-12)__<a id='2019-06-12'></a><br>
   Patch [add-swapoptions](patches/README.md#add-swapoptions) hinzugefügt.<br>
   Die Swap-Optionen sind nun optional und standardmässig deaktiviert.<br>
   Siehe [r15727](https://trac.boxmatrix.info/freetz-ng/changeset/15727/freetz-ng)
   / [fcca7109](https://github.com/Freetz-NG/freetz-ng/commit/fcca7109eaae438d88e519bd63232d8e203b3d64)<br>

 * __[2019-05-09](#2019-05-09)__<a id='2019-05-09'></a><br>
   Patch [drop-noexec](patches/README.md#drop-noexec-external) hinzugefügt.<br>
   Wenn auf dem USB Speicher Dateien ausgeführt werden sollen (external), muss dieser ausgewählt werden.<br>
   Siehe [r15530](https://trac.boxmatrix.info/freetz-ng/changeset/15530/freetz-ng)
   / [dcbd4885](https://github.com/Freetz-NG/freetz-ng/commit/dcbd4885dea3ee8ef7a15a54ecd852ce913a0492)<br>
   Siehe [r15505](https://trac.boxmatrix.info/freetz-ng/changeset/15505/freetz-ng)
   / [8f331457](https://github.com/Freetz-NG/freetz-ng/commit/8f3314576395b855356a7515ce86e4ceb13414a9)<br>

 * __[2019-04-15](#2019-04-15)__<a id='2019-04-15'></a><br>
   Das Downloadverzeichnis ```./dl``` ist nun ein Link.<br>
   Dieser verweiset auf ```~/.freetz-dl``` wodurch mehrere Checkouts sich das gleiche Verzeichis teilen.<br>
   Wem dies nicht gefällt kann den Link durch ein Verzeichnis ersetzen.<br>
   Siehe [r15411](https://trac.boxmatrix.info/freetz-ng/changeset/15411/freetz-ng)
   / [0c7fafc8](https://github.com/Freetz-NG/freetz-ng/commit/0c7fafc8ee4b980c89aece585a196b38cff579c6)<br>

 * __[2019-04-02](#2019-04-02)__<a id='2019-04-02'></a><br>
   Package [ProxyChains-NG](make/proxychains-ng.md) hinzugefügt.<br>
   Damit kann jedes Programm einen Proxy verwenden.<br>
   Siehe [r15112](https://trac.boxmatrix.info/freetz-ng/changeset/15112/freetz-ng)
   / [d8f65059](https://github.com/Freetz-NG/freetz-ng/commit/d8f65059f28ff8f22332efb73059e6ae7d21f04c)<br>

 * __[2019-03-12](#2019-03-12)__<a id='2019-03-12'></a><br>
   Änderung bei der Signierung von Images.<br>
   Der private Schlüssel wird in ```./.signature``` abgelegt. Dies ist ein Link auf ```~/.freetz-signature```.<br>
   Damit nutzt jeder Checkout den gleichen Schlüssel und benötigt das gleiche Passwort.<br>
   Wem dies nicht gefällt kann den Link durch ein Verzeichnis ersetzen.<br>
   Siehe [r15300](https://trac.boxmatrix.info/freetz-ng/changeset/15300/freetz-ng)
   / [c3437a4e](https://github.com/Freetz-NG/freetz-ng/commit/c3437a4eb47bcefa209aefa67d77b9de606c4676)<br>

 * __[2019-03-08](#2019-03-08)__<a id='2019-03-08'></a><br>
   Signaturprüfung von AVM-Images beim _Entpacken_.<br>
   Bislang wurde die Firmware nach dem _Download_ mittel MD5 geprüft.<br>
   Dies hatte den Nachteil dass eine Dateien die manuell nach dl/fw/ kopiert wurden nicht geprüft wurden.<br>
   Man kann die Signatur auch manuell mit ```fwmod -v $key $img``` prüfen.<br>
   Hinweis: Die allerersten AVM Geräte nutzten noch keine Signatur und werden weiterhin via MD5 geprüft.<br>
   Siehe [r15284](https://trac.boxmatrix.info/freetz-ng/changeset/15284/freetz-ng)
   / [be2994f7](https://github.com/Freetz-NG/freetz-ng/commit/be2994f7e61c3168617905e665462569d9110b71)<br>

 * __[2019-02-04](#2019-02-04)__<a id='2019-02-04'></a><br>
   Package [CA-bundle](make/ca-bundle.md) (ursprünglich CAbundle) hinzugefügt.<br>
   Damit können wget, curl usw HTTPS-Zertifikate prüfen.<br>
   Siehe [r15109](https://trac.boxmatrix.info/freetz-ng/changeset/15109/freetz-ng)
   / [3b38f82c](https://github.com/Freetz-NG/freetz-ng/commit/3b38f82c7b5beebe35696c7c3de9aad1d8296e8d)<br>

 * __[2019-02-19](#2019-02-19)__<a id='2019-02-19'></a><br>
   Freetz-Webui: Option "Downgrade" des Firmware-Updates repariert.<br>
   Nach einem Downgrade sollte man die Einstellungen zurücksetzen oder ein Backup einspielen.<br>
   Siehe [r15190](https://trac.boxmatrix.info/freetz-ng/changeset/15190/freetz-ng)
   / [f300b9a7](https://github.com/Freetz-NG/freetz-ng/commit/f300b9a71754d98a56e6794770269cb63142fc60)<br>

 * __[2019-02-04](#2019-02-04)__<a id='2019-02-04'></a><br>
   Patch [modify-dsl-dettings](patches/MODIFY_DSL_SETTINGS.md) hinzugefügt.<br>
   Mit diesem Patch wird die DSL Störsicherheit um 4 Performance-Stufen erweitert.<br>
   Siehe [r15100](https://trac.boxmatrix.info/freetz-ng/changeset/15100/freetz-ng)
   / [09aae63e](https://github.com/Freetz-NG/freetz-ng/commit/09aae63ee888ea4d3cbe38d0ef9990a73e04bf31)<br>
   Siehe [r15119](https://trac.boxmatrix.info/freetz-ng/changeset/15119/freetz-ng)
   / [262d8a9e](https://github.com/Freetz-NG/freetz-ng/commit/262d8a9ee9dc8c05dda60974b93ce531c91194f2)<br>

 * __[2019-02-04](#2019-02-04)__<a id='2019-02-04'></a><br>
   Patch [modify-counter](patches/MODIFY_COUNTER.md) hinzugefügt.<br>
   Mit diesem Patch wird der Online-Zähler von AVM verändert, es werden Gigabyte und Tage angezeigt.<br>
   Siehe [r15099](https://trac.boxmatrix.info/freetz-ng/changeset/15099/freetz-ng)
   / [e6d16b75](https://github.com/Freetz-NG/freetz-ng/commit/e6d16b75436fdb8322434b5e380ae5e05d9ec604)<br>
   Siehe [r15119](https://trac.boxmatrix.info/freetz-ng/changeset/15119/freetz-ng)
   / [262d8a9e](https://github.com/Freetz-NG/freetz-ng/commit/262d8a9ee9dc8c05dda60974b93ce531c91194f2)<br>

 * __[2019-02-01](#2019-02-01)__<a id='2019-02-01'></a><br>
   Freetz-Webui: Hostname im Seitentitel.<br>
   Es wird der Hostname ohne Domain angezeigt, falls er verändert wurde.<br>
   Diesen kann man in der ar7.cfg mit Domain oder im AVM-Webui unter "Fritz!Box-Name" setzen.<br>
   Siehe [r15073](https://trac.boxmatrix.info/freetz-ng/changeset/15073/freetz-ng)
   / [f97f6679](https://github.com/Freetz-NG/freetz-ng/commit/f97f66795b1a4de2e67ec8f92d646c820674ff1b)<br>
   Siehe [r15743](https://trac.boxmatrix.info/freetz-ng/changeset/15743/freetz-ng)
   / [9bf028d7](https://github.com/Freetz-NG/freetz-ng/commit/9bf028d7425c18fabe689b3ae27658718169c892)<br>

 * __[2019-02-01](#2019-02-01)__<a id='2019-02-01'></a><br>
   Skin [cuma](themes/skin.md#cuma) (dark) hinzugefügt.<br>
   Siehe [r15071](https://trac.boxmatrix.info/freetz-ng/changeset/15071/freetz-ng)
   / [bebcd72a](https://github.com/Freetz-NG/freetz-ng/commit/bebcd72a13140e137d56374035081b18de2a9567)<br>

