# CA-bundle 2025-07-15
  - Homepage: [https://www.curl.se/ca](https://www.curl.se/ca)
  - Package: [master/make/pkgs/ca-bundle/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/ca-bundle/)
  - Maintainer: [@fda77](https://github.com/fda77)

Das CA-bundle ist ein Paket von root CA (Certificate Authority) Zertifikaten.
<br>
 * Damit kann die Glaubwürdigkeiten von HTTPS Zertifikaten geprüft werden.
 * Als Benutzer ```root``` nutzen die Programme ```wget``` und ```curl``` diese Zertifikate automatisch.
 * Anderen Benutzer oder Programmen muss die Datei ```/mod/etc/ssl/certs/ca-bundle.crt``` bekannt gemacht werden.

