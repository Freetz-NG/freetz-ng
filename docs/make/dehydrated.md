# dehydrated 0.7.2
  - Homepage: [https://dehydrated.io/](https://dehydrated.io/)
  - Manpage: [https://github.com/dehydrated-io/dehydrated/wiki](https://github.com/dehydrated-io/dehydrated/wiki)
  - Changelog: [https://github.com/dehydrated-io/dehydrated/releases](https://github.com/dehydrated-io/dehydrated/releases)
  - Repository: [https://github.com/dehydrated-io/dehydrated/commits/master](https://github.com/dehydrated-io/dehydrated/commits/master)
  - Package: [master/make/pkgs/dehydrated/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/dehydrated/)
  - Maintainer: [@fda77](https://github.com/fda77)

Mit Dehydrated (und LigHTTPd) können Let's Encrypt Zertifikate erstellt und automatisch aktualisiert werden.

[![screenshot](../screenshots/000-PKG_letsencrypt_md.png)](../screenshots/000-PKG_letsencrypt.png)

### Zertifikat erstellen
 * LigHTTPd so konfigurieren, dass über das Internet unter dem dyndns-Namen via http erreichbar ist (mit "webproxy"-Seite prüfen).
 * In Dehydrated die "Optionen" entsprechend ausfüllen (eMail ist optional).
 * ```rc.dehydrated init``` ausführen.
 * Den angezeigten Befehl zur (einmaligen) Registrierung ausführen.
 * Nochmal ```rc.dehydrated init``` ausführen.

### Zertifikat benutzen
 * In LigHTTPd unter "erweitert" einen vhost für https mit den Pfaden zum Zertifikat eintragen.
 * Oder die ssl.pem und fullchain.pem übers webif von LigHTTPd eintragen.
 * Noch besser (falls nur 1 Domain genutzt wird) die Dehydrated Zertifikate so verlinken:
```
rm -f /tmp/flash/lighttpd/ca.pem
ln -s /var/media/ftp/.. ../dehydrated/DOMAIN/fullchain.pem /tmp/flash/lighttpd/ca.pem
rm -f /tmp/flash/lighttpd/crt.pem
ln -s /var/media/ftp/.. ../dehydrated/DOMAIN/ssl.pem  /tmp/flash/lighttpd/crt.pem
modsave
rc.lighttpd restart
```

