# ADDONS
Addons der "Digitalen Elite" werden hier nicht supported!

Diese Addons wurden augenscheinlich von Personen programmiert die wenig bis gar keine Ahnung von Freetz haben.<br>
Deshalb sind die dadurch verursachten Fehler vielfältig. Es ist sogar möglich dass die Freetz-Konfiguration<br>
so nachhaltig beschädigt wird, dass selbst mit einem später geflashten Image ohne Addons die Fritzbox nicht<br>
mehr richtig funktioniert.

### Vielfältige aus Foren bekannte Fehler
Diese Liste erhebt keinen Anspruch auf Vollständigkeit oder Korrektheit
 - Das Freetz-Webinterface funktioniert überhaupt nicht mehr
 - Crond funktioniert nicht mehr
 - Die Onlinehilfe funktionieren nicht mehr
 - Es werden Datein von Freetz überschrieben
 - Ein Watchdog löst ohne Grund Reboots aus, bis hin zum Bootloop
 - Cron wird missbraucht um endlos externe STUN/VoIP Server zu hammern
 - Es werden fehlerhafte Binaries gestartet die Crashes verursachen
 - Binaries werden auch gerne mit UPX gepackt und verursachen ebenfalls Crashes
 - Es werden alberne Standardwert in der Config gesetzt die Segfaults verursachen
 - Manche Einstellungen werden doppelt gespeichert
 - Andere Einstellungen dagegen werden gar nicht mehr gespeichert
 - Es ist nicht mehr möglich ein Einstellungsbackup wiederherzustellen
 - Benutzer werden gelöscht
 - Planloses setzen von Systemvariablen verursachen Segfaults von AVM Binaries
 - Überflüssiges ständiges Speichern ins Flash lässt den Speicher schneller altern
 - Die rc.custom wird verändert und durch Flashen eines sauberen Images nicht bereinigt
 - ...

### Steigerung der Unzulänglichkeit
Dies alles betrifft ausdrücklich auch Sammys l-matic Script da dort nicht nur diese mangelhaften DEB-Addons<br>
eingebaut werden, sondern noch weiter in Freetz herumgemurkst wird.<br>

### Die Scheisse wieder vom Stiefel bekommen
Falls aus versehen ein Image mit Addon geflasht wurds, empfiehlt sich ein Recovery um alle Einstellungen zu<br>
löschen. Danach kann Freetz wieder geflasht werden. **Es darf keine alte Sicherung zurückgespielt werden!**<br>

### Nervt mit dem Krempel nicht herum
Wenn ihr irgend wo herumheult dass etwas nicht funktioniert schreibt dazu dass ihr den Müll eingebaut habt.<br>
**Auf keinen Fall sollten wegen einem Image mit solch einem Addon hier ein Issue erstellt werden.**


