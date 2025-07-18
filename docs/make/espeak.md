# eSpeak 1.48.04 (binary only) - DEPRECATED
  - Package: [master/make/pkgs/espeak/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/espeak/)
  - Maintainer: -

eSpeak ist ein "Text to Speech" Generator - oder, anders ausgedrückt,
ein "Vorlese-Programm", welches ASCII Texte mit synthetischer Stimme
wiedergeben ("vorlesen") kann. Bei Freetz wird es u.a. von
[DTMFBox](dtmfbox.md) genutzt.

### Installation

Zur Installation ist das Paket einfach im Paket-Menü von
`make menuconfig` auszuwählen. Unterstützung für zahlreiche zusätzliche
Sprachen lassen sich nochmals (als "Bundle") auswählen, sobald das
Paket selbst ausgewählt wird. Dies macht spätestens dann Sinn, wenn man
auch mehrere Sprachen benötigt.

Wer die Sprachausgabe lediglich für DTMFBox benötigt, muss das
eSpeak-Paket nicht zwangsweise installieren: DTMFBox unterstützt auch
sogenanntes "WebStreaming" (die Audio-Daten werden dann auf einem
anderen Server generiert) - was allerdings eine bestehende
Internet-Verbindung voraussetzt.

### Aufruf

An dieser Stelle nur ein paar **kurze** Tipps zum Aufruf von eSpeak -
Details finden sich auf der
[Projektseite](http://espeak.sourceforge.net/commands.html):

`espeak "Hallo Welt"` sagt einfach "Hallo Welt" mit den
Default-Einstellungen. Das kann recht komisch klingen, wenn z.B.
Englisch als Default-Sprache eingestellt ist. Daher kann man sowohl
Sprache als auch Sprecher per Parameter übergeben:
`espeak -vde+f3 "Hallo Welt"` lässt den gleichen Text von einer
deutschen Frauenstimme säuseln - richtig geraten: "-vde" wählt Deutsch
("-ven" Englisch), das "+f" steht für "feminin" (wovon es
mindestens +f1, +f2, +f3 verschiedene "Modelle" gibt), und es gibt
auch (+m1, +m2, +m3) "maskuline" Stimmen. Den "+XX" Teil kann man
ebenfalls weglassen, wenn nur die Sprache festgelegt werden soll.

Sollte sich die Stimme überschlagen, so kann man mit dem Parameter `-s`
am "Speed" drehen (`-s 170` ist ein guter Ausgangswert). Auch die
Stimmhöhe lässt sich beeinflussen: `-p 50` setzt den "Pitch" auf 50
(guter Ausgangswert). Höhere Werte machen männliche Stimmen zu Eunuchen
- niedrigere transformieren "anwesendes Weibsvolk" zu "bärtigen
Ladies".

### Hinweis

Das Executeable findet sich auf der Box unter `/usr/bin/speak`.

### Weiterführende Links

-   [http://espeak.sourceforge.net](http://espeak.sourceforge.net)

