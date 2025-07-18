# shellinabox 2.21
  - Homepage: [https://code.google.com/archive/p/shellinabox/](https://code.google.com/archive/p/shellinabox/)
  - Changelog: [https://github.com/shellinabox/shellinabox/releases](https://github.com/shellinabox/shellinabox/releases)
  - Repository: [https://github.com/shellinabox/shellinabox](https://github.com/shellinabox/shellinabox)
  - Package: [master/make/pkgs/shellinabox/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/shellinabox/)
  - Maintainer: [@fda77](https://github.com/fda77)

### Anmerkungen (05.02.2024 - getestet mit FritzBox Firmware 154.07.57 und Shell-In-A-Box v2.21)
Intern verwendet Shell-In-A-Box standardmässig das Programm `/bin/login` - und das kann nicht mit Passwörtern umgehen, die in `/etc/shadow` gespeichert sind.
Damit schlägt ein Login dann unweigerlich fehl...

Es gibt zwei mögliche Lösungen für das Problem:<br>
1) Passwörter aus `/etc/shadow` nach `/etc/passwd` kopieren oder verschieben.<br>
    (dies betrifft v.a. das Passwort des root-Benutzers...)
    Das lässt sich bei einer ssh-Session und Kenntnissen mit dem vi oder einem anderen Texteditor machen;
    Um es dauerhaft zu machen, darf ein `modsave flash` danach nicht vergessen werden!
    Ist aber m.E. nicht schön; beim neuen Setzen eines Passworts für ssh (z.B. über `/usr/bin/passwd`) wandert das Passwort wieder nach `/etc/shadow`...<br>
	Deshalb bevorzuge ich die zweite Lösung:<br>
2) eine SSH-Session statt der LOGIN-Session aufbauen.<br>
   Die zweite Lösung benötigt einen laufenden ssh-Daemon (z.B. dropbear) auf der Box - aber wer hat das nicht? ;-)
   Dann muss man Shell-In-A-Box dazu bringen, statt dem "normalen" *LOGIN*-Service den *SSH*-Service zu verwenden.
   Hierzu trägt man über die Konfigurationsseite des Shell-In-A-Box-Pakets in der Freetz WebUI unter "Service:" folgendes ein:<br>
     `/:SSH:<hostname|ip>[:<sshport>]`<br>
     Für einen SSH-Daemon der lokal auf der Box angesprochen werden soll, kann als *hostname* `localhost` eingetragen werden.
     Hört der SSH-Daemon auf den Standardport `22`, kann die optionale *sshport*-Angabe auch weg gelassen werden.
     Für einen dropbear-Paket, das auf der Box läuft und auf alle Schnittstellen hört und dessen Port z.B. auf `2222` gesetzt ist,
     würde die Angabe also folgendermaßen aussehen:<br>
     `/:SSH:localhost:2222`<br>

Übrigens ließe sich der Shell-In-A-Box-Dienst auch verwenden, um SSHs auf anderen (internen) Rechnern zu benutzen; und es ließen sich lt. Doku auch mehrere (durch Leerzeichen getrennte) Services definieren, die gleichzeitig aktiv sind.
Die Shell-In-A-Box-Doku gibt darüber Auskunft, was sonst noch möglich ist (allerdings steht dort aktuell die Möglichkeit, den SSH-Port angeben zu können nicht drin - obwohl da bereits seit 2018 ein Patch für integriert wurde)...
Sind mehrere Services aktiv, kann auf der Shell-In-A-Box Login-Webseite (standardmässig Port 4200) per Rechtsklick ein Menü aufgeschaltet werden, in dem die eingestellten Services auswählbar sein sollen (habe ich bisher nicht ausprobiert).

Nachdem auf SSH-Service umgestellt wurde, klappt auch der Login.

