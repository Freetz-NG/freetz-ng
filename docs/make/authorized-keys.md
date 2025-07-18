# authorized_keys: Frontend for SSH keys
  - Package: [master/make/pkgs/authorized-keys/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/authorized-keys/)
  - Maintainer: -

Mit dem authorized_keys Package können diese für SSH benötigte Dateien
bearbeitet werden. Es ist im Webinterface unter "SSH" zu finden

-   authorized_keys - enthält öffentliche Schlüssel zur
    Authentifizierung
-   known_hosts - öffentliche Schlüssel zum Prüfen bekannter Server
-   id_dsa - private Schlüssel im DSA Format
-   id_rsa - private Schlüssel im RSA Format

Erläuterung zu den privaten Schlüsseln: Die Benutzer-Keys
~/.ssh/id_dsa und ~/.ssh/id_rsa sind nicht notwendig. Wenn sie
vorhanden sind, kann sich damit der Client gegenüber dem Server
ausweisen. Dies ist eine Alternative zur Eingabe eines Paßwortes zur
Anmeldung. Diese beiden Dateien haben nichts mit den Host-Keys zu tun.
Diese sind für den SSH-Server notwendig, und sie werden automatisch
erstellt, wenn sie noch nicht vorhanden sind. Damit weist sich der
Server gegenüber dem Client aus.

