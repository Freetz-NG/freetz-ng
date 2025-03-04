# Targets von Freetz's "make"


```
help                                    Zeigt die englische Dokumentation an: docs/wiki/20_Advanced/make_targets.en.md
hilfe                                   Zeigt die deutsche Dokumentation an: docs/wiki/20_Advanced/make_targets.de.md

menuconfig                              Konfiguration mit Ncurses (benötigt ncurses-devel)
menuconfig-single                       Konfiguration mit Ncurses (Einzelmenü)
menuconfig-nocache                      Konfiguration mit Ncurses (ohne Zwischenspeicherung der .in-Dateien)
nconfig                                 Alternative Konfiguration (benötigt ncurses-devel)
nconfig-single                          Alternative Konfiguration (Einzelmenü)
gconfig                                 Konfiguration mit GTK+2 (benötigt libglade2-devel)
xconfig                                 Konfiguration mit QT5 (benötigt qt5-qtbase-devel)
config                                  Konfiguration (Dialog)

olddefconfig                            Aktualisiert die vorhandene .config-Datei automatisch
oldconfig                               Aktualisiert die vorhandene .config-Datei interaktiv
reuseconfig                             Entfernt Geräte- und toolchain-spezifische Einstellungen aus der .config-Datei
allnoconfig                             Setzt alle Einstellungen auf (n)ein
allyesconfig                            Setzt alle Einstellungen auf (j)a
listnewconfig                           Zeigt eine Liste neuer Konfigurationssymbole an (jeweils eine pro Zeile)
config-compress                         Behält nur nicht-standardmäßige Auswahlmöglichkeiten und kein Signaturschlüssel-Passwort

config-clean-deps                       Wählt Alles ab, was nicht zwingend erforderlich ist
config-clean-deps-keep-busybox          Wählt Alles außer BusyBox-Applets ab
config-clean-deps-modules               Wählt alle Kernel-Module ab
config-clean-deps-libs                  Wählt alle Bibliotheken ab
config-clean-deps-busybox               Wählt alle BusyBox-Applets ab
config-clean-deps-terminfo              Wählt alle Terminfo-Dateien ab

cacheclean                              Entfernt kleine zwischengespeicherte Dateien und Verzeichnisse
clean                                   Entfernt entpackte Images und einige Cache-Dateien
dirclean                                Bereinigt die Quellen (außer Tools und .config)
distclean                               Bereinigt alles außer dem Download-Verzeichnis

$(pkg)-unpacked                         Entpackt und patched $(pkg)
$(pkg)-precompiled                      Kompiliert das Paket/die Bibliothek $(pkg)
$(pkg)-recompile                        Kompiliert das Paket/die Bibliothek $(pkg) erneut
$(pkg)-autofix                          Passt Patches des Pakets/der Bibliothek $(pkg) an
$(pkg)-dirclean                         Entfernt das Build-Verzeichnis von $(pkg)
$(pkg)-distclean                        Entfernt das Build-Verzeichnis und alle Ziel-Dateien von $(pkg)

kernel-menuconfig                       Konfiguration des ausgewählten Kernels
kernel-precompiled                      Kompiliert den ausgewählten Kernel
kernel-dirclean                         Löscht alle Dateien des ausgewählten Kernels

tools-push_firmware                     Erstellt die für push_firmware (pfp) erforderlichen Tools
tools                                   Erstellt die für die aktuelle Auswahl erforderlichen Tools
tools-all                               Erstellt alle verfügbaren Freetz-Tools
tools-allexcept-local                   Erstellt alle nicht lokalen Freetz-Tools (dl-tools)
tools-distclean-local                   Löscht alle lokalen Tools (dl-tools)
tools-dirclean                          Löscht alle Freetz-Tools

uclibc-autofix                          Passt Patches der ausgewählten uClibc an
uclibc-menuconfig                       Konfiguration der ausgewählten uClibc
uclibc-olddefconfig                     Aktualisiert die .config-Datei der ausgewählten uClibc

firmware-nocompile                      Erstellt eine Firmware ohne Pakete und Bibliotheken
mirror                                  Lädt alle ausgewählten Paketquellen-Dateien herunter
release                                 Erstellt eine Release-Datei (vorher .version ändern)

push_firmware                           Ruft tools/push_firmware mit images/latest.image (pf) auf
                                        Für weitere Optionen ausführen: tools/push_firmware -h
recover                                 Ruft tools/recover-eva mit der konfigurierten Firmware auf
```


