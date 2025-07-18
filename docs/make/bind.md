# BIND 9.11.37/9.20.10
  - Homepage: [https://www.isc.org/bind/](https://www.isc.org/bind/)
  - Manpage: [https://bind9.readthedocs.io/en/](https://bind9.readthedocs.io/en/)
  - Changelog: [https://downloads.isc.org/isc/bind9/cur/9.20/](https://downloads.isc.org/isc/bind9/cur/9.20/)
  - Repository: [https://gitlab.isc.org/isc-projects/bind9/](https://gitlab.isc.org/isc-projects/bind9/)
  - Package: [master/make/pkgs/bind/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/bind/)
  - Maintainer: [@fda77](https://github.com/fda77)

Mit [bind](http://isc.org/software/bind) (Berkeley
Internet Name Daemon) kann ein DNS-Server zur IP- und Namensauflösung
betrieben werden.



### named.conf

Die möglichen Optionen können der Manpage oder den vielen Internetseiten
entnommen werden.

Minimal *named.conf*:

```
options {
    directory "/var/media/ftp/uFlash/bind";
    listen-on port 53 { any; };
    allow-query { any; };
    notify no;
};

zone "example.org" in {
      type master;
      file "example.org";
};
```

Minimal zone file */var/media/ftp/uFlash/bind/example.org*:

```
$TTL 300
@       IN      SOA     @ example.org. (
                        2011032701      ;serial
                        300             ;refresh
                        300             ;retry
                        300             ;expire
                        300             ;minimum
                        )

        IN      NS      ns.example.org.
*       IN      A       85.214.209.234
```
