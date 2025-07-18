# JamVM 2.0.0 (binary only) - DEPRECATED
  - Homepage: [https://jamvm.sourceforge.net/](https://jamvm.sourceforge.net/)
  - Manpage: [https://sourceforge.net/projects/jamvm/files/jamvm/JamVM%202.0.0/](https://sourceforge.net/projects/jamvm/files/jamvm/JamVM%202.0.0/)
  - Changelog: [https://sourceforge.net/projects/jamvm/files/jamvm/](https://sourceforge.net/projects/jamvm/files/jamvm/)
  - Repository: [https://sourceforge.net/p/jamvm/code/ci/master/tree/](https://sourceforge.net/p/jamvm/code/ci/master/tree/)
  - Package: [master/make/pkgs/jamvm/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/jamvm/)
  - Maintainer: -

**[JamVM](http://jamvm.sourceforge.net/)** ist eine
neue [Java Virtual
Machine](http://en.wikipedia.org/wiki/Java_Virtual_Machine),
die der JVM Spezifikation Version 2 (blue book) entspricht. Im
[Vergleich mit den meisten anderen
VM's](http://bugblogger.com/java-vms-compared-160/) (frei
und kommerziell) ist *JamVM* extrem klein ("stripped executables" für
PowerPC nur ~160K, und für Intel 140K). Dennoch unterstützt es, anders
als andere "kleine" VMs (z.B. KVM) die vollständige Spezifikation, und
enthält Support für "object finalisation", Soft/Weak/Phantom
Referenzen, class-unloading, das [Java Native
Interface](http://de.wikipedia.org/wiki/Java_Native_Interface)
(JNI) und die Reflection API.

JamVM nutzt die [GNU
Classpath](http://de.wikipedia.org/wiki/GNU_Classpath) Java
Class Library. Eine Reihe von Klassen sind Referenz-Klassen, die für
eine spezielle VM angepasst werden müssen. Diese werden zusammen mit
*JamVM* gebündelt.

 * **Anmerkung:**
*JamVM* wird nicht mit der Class Library von Suns oder IBMs JVMs
funktionieren.

Da die normale Klassenbiliothek (glibj.zip) über 9 MB groß ist wird
standardmäßig nur eine reduzierte Version (mini.jar) installiert.
Deshalb muss jamvm folgendermaßen aufgerufen werden um z.B. die Datei
Hello.class im aktuellen Verzeichnis aufzurufen:

```
jamvm -Xbootclasspath/a:/usr/share/classpath/mini.jar Hello
```

### Weiterführende Links

-   [JavaVM
    Homepage](http://jamvm.sourceforge.net/)
-   [Vergleich verschiedener
    JVMs](http://bugblogger.com/java-vms-compared-160/)
-   [List of
    JVMs](http://en.wikipedia.org/wiki/List_of_Java_virtual_machines)
-   [freie Java
    Implementierungen](http://en.wikipedia.org/wiki/Free_Java_implementations)

