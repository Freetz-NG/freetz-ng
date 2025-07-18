# Nano 8.5 (binary only)
  - Homepage: [https://www.nano-editor.org/](https://www.nano-editor.org/)
  - Manpage: [https://www.nano-editor.org/docs.php](https://www.nano-editor.org/docs.php)
  - Changelog: [https://www.nano-editor.org/dist/v8/NEWS](https://www.nano-editor.org/dist/v8/NEWS)
  - Repository: [https://git.savannah.gnu.org/cgit/nano.git/](https://git.savannah.gnu.org/cgit/nano.git/)
  - Package: [master/make/pkgs/nano/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/nano/)
  - Maintainer: [@fda77](https://github.com/fda77)

**Nano** ist ein kleiner Texteditor für die Konsole, der aber im
Gegensatz zu (n)vi eine Bedienung wie ein normaler Editor (z.B. der
Windows-Editor) besitzt. Es ist also nicht erforderlich viel Kommandos
zu lernen, bevor man ihn nutzen kann. Daher ist er für Anfänger und
User, die nicht des 10-Finger-Systems mächtig sind, oftmals weit besser
geeignet als vi.

Damit man die Pos1 und Home Tasten auch in Nano benutzen kann ist
(zumindest bei mir in der Kombination putty / Windows) das Setzen der
Umgebungsvariable TERM hilfreich:

```
export TERM=xterm
```

in der rc.custom tut den Trick.

