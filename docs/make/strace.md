# strace 4.9/5.0/6.15 (binary only)
  - Homepage: [https://www.strace.io/](https://www.strace.io/)
  - Manpage: [https://man7.org/linux/man-pages/man1/strace.1.html](https://man7.org/linux/man-pages/man1/strace.1.html)
  - Changelog: [https://github.com/strace/strace/releases](https://github.com/strace/strace/releases)
  - Repository: [https://github.com/strace/strace](https://github.com/strace/strace)
  - Package: [master/make/pkgs/strace/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/strace/)
  - Maintainer: [@fda77](https://github.com/fda77)

**[strace](http://sourceforge.net/projects/strace/)**
verfolgt System-Calls und Signale eines Prozesses. Dabei schaltet es
sich zwischen einen Benutzerprozeß und den Kernel und protokolliert alle
Aktivitäten an dieser Schnittstelle. Wenn der verfolgte Prozess einen
Systemaufruf macht, gibt *strace* den Namen, die Argumente des Aufrufs
und den Rückgabewert dieses Systemaufrufs aus. Wenn der verfolgte
Prozess ein Signal erhält, gibt *strace* den Namen des Signals aus.
Falls ein Systemaufruf mit einem Fehler zurückkehrt, wird, wenn
vorhanden, die dem Fehlerstatus zugeordnete Fehlermeldung angezeigt.

Kurzum: *strace* kommt meist dann zum Einsatz, wenn "etwas nicht
funktioniert, und keiner weiß warum". Sprich: Ein Programm stürzt ab,
ein Prozess hängt - und man möchte herausfinden, bei welcher Aktion dies
passiert.

Das "Geschwisterchen" [ltrace](ltrace.md) kann dabei auch
hilfreich zur Seite stehen: Anstelle der System-Calls protokolliert
*ltrace* Bibliotheks-Aufrufe (aka "Library Calls").

### Tip: Vermeiden von "unfinished" und "resumed" in strace-Logs

Wenn man strace mit "-f" aufruft, um Unterprozesse bzw. Threads
mitzuverfolgen, sieht man oft unterbrochene Systemaufrufe im Log, weil
strace im Fall einer Unterbrechung den Start- und Rückkehrzeitpunkt der
Aufrufe separat notiert. Darunter leidet aber die Lesbarkeit, weil man
weiter unten oft nicht mehr weiß, zum welchem "unfinished" welches
"resume" gehört (hier im Beispiel ist es noch einfach):

```
719   14:55:13.562840 clock_gettime(CLOCK_MONOTONIC,  <unfinished ...>
1010  14:55:13.563457 getppid( <unfinished ...>
719   14:55:13.563818 <... clock_gettime resumed> {337216, 716098754}) = 0
1010  14:55:13.564329 <... getppid resumed> ) = 719
719   14:55:13.564701 clock_gettime(CLOCK_MONOTONIC,  <unfinished ...>
1010  14:55:13.565066 poll([{fd=21, events=POLLIN}], 1, 2000 <unfinished ...>
719   14:55:13.565543 <... clock_gettime resumed> {337216, 717736704}) = 0
```

Mittels "-ff" schreibt man eine separate Log-Datei pro PID, aber dann
kann mit die Zeitlinie nicht mehr anschaulich verfolgen. Möchte man
beides zusammen haben, hilft folgendes Skript (der *sed*-Befehl ist
deshalb so kompliziert, weil bei Aufrufen des Skripts mit mehreren
"-p" die in diesem Modus als erste Spalte auftauchenden PIDs in den
Einzeldateien zuerst entfernt werden müssen, weil sonst keine Sortierung
nach Zeitstempel möglich wäre):

```
#!/bin/sh

# Logfile as first parameter is required
logfile="$1"
shift

# Ctrl-C should only kill strace, not the rest of the script
trap '' INT

# Create one logfile per pid, then consolidate them into one,
# sorted by timestamp and containing the pid as 2nd column
strace -tt -ff -o "$logfile" "$@"
{
for file in "$logfile".*; do
pid=$(printf "%-5u" "${file##$logfile.}")
cat "$file" | sed -r "s/^([0-9]+ +)?([^ ]+)(.*)/2 $pid3/"
done
} | sort > "$logfile"

# Clean up temporary logfiles
rm "$logfile".*
```

### Weiterführende Links

-   [strace
    Projektseite](http://sourceforge.net/projects/strace/)
    (Sourceforge)
-   [Artikel: Mit ''strace'' Systemaufrufe
    verfolgen](http://www.pronix.de/pronix-585.html)
-   [strace Man
    page](http://linux.die.net/man/1/strace)


