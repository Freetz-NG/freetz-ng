# wireguard-tools 1.0.20250521
  - Homepage: [https://www.wireguard.com/](https://www.wireguard.com/)
  - Manpage: [https://www.wireguard.com/quickstart/](https://www.wireguard.com/quickstart/)
  - Changelog: [https://git.zx2c4.com/wireguard-tools/log/](https://git.zx2c4.com/wireguard-tools/log/)
  - Repository: [https://git.zx2c4.com/wireguard-tools/](https://git.zx2c4.com/wireguard-tools/)
  - Package: [master/make/pkgs/wireguard/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/wireguard/)
  - Maintainer: [@fda77](https://github.com/fda77)

Mit Wireguard kann ein VPN aufgebaut werden. Es ist schneller als [OpenVPN](openvpn.md) und einfach zu konfugurieren als IPsec.<br>

[![screenshot](../screenshots/000-PKG_wireguard_md.png)](../screenshots/000-PKG_wireguard.png)

### Hinweise

 - Ein Wireguard-Client auf der Fritzbox kann nicht als Default-Gateway verwendet werden, siehe [ip-phone-forum.de/threads/304914/](https://www.ip-phone-forum.de/threads/304914/).
 - Falls der Wireguard-Server nicht der Router ist muss auf dem Router eine Route zum IP-Bereich von Wireguard eingerichtet werden.
 - Um AVM-VoIP über Wireguard nutzen zu können muss der Interfacename in "tun0" geändert werden.

### Datendurchsatz
Erfahrungswerte mit verschiedener Hardware.
```
|  Client  |     Server     |    Download    |     Upload    | Quelle  |
| -------- | -------------- | -------------- | ------------- | ------- |
| Computer | Raspberry PI 4 | min 100 MBit/s | min 45 MBit/s | cuma    |
| Computer | Fritz!Box 7590 | min  85 MBit/s | min 40 MBit/s | cuma    |
| Computer | Fritz!Box 7490 | max  35 MBit/s | min 45 MBit/s | cuma    |
| Computer | Fritz!Box 7520 | ca   35 MBit/s | ca  35 MBit/s | wall007 |
```

### Konfiguration für einen Wireguard-Server auf der Fritzbox mit einem PC erstellen

Die `PresharedKey`-Zeilen bzw `psk`-Dateien sind optional und können entfernt werden.
Der Port muss gegebenenfalls in der Firewall freigegben werden, zum Beispiel mit [AVM-portfw](avm-portfw.md).

##### Erforderliche Programme installieren
Bei Ubuntu heisst der Paketmanager `apt-get`.
```
sudo dnf install wireguard-tools qrencode
```

##### MTU
Die MTU sollte für Server und Clients gleich gesetzt werden. Die Zeilen sind optional.
Möglich Werte liegen von 1280 bis 1420 Bytes. 1280 ist eine "sichere" Wahl, höhere Werte
sind besser können aber abhängig vom Netzwerk und Internetanschluss Probleme verursachen.

##### Variablendefinition
Diese Variablen werden weiter unten genutzt und sollten angepasst werden.
```
NUMCLIENTS="9"
HOSTNAME="mein.dyndns.host"
UDPPORT="51820"
IPBEREICH="10.0.0.1/24"
DNSSERVER="192.168.178.1"
MTUBYTES="1280"

```

##### Schlüsseldateien erstellen
Es werden die Schlüsseldateien `*.prv`, `*.psk` und `*.pub` generiert. Mit diesen werden die Konfigurationsdateien erstellt.
```
for x in SRV $(seq -f "CL%g" $NUMCLIENTS); do
touch           $x.prv   $x.psk     $x.pub
chmod 640       $x.prv   $x.psk     $x.pub
wg genkey | tee $x.prv | wg pubkey >$x.pub
wg genpsk >              $x.psk
[ "$x" == "SRV" ] && rm  $x.psk
done

```


##### Serverkonfiguration erstellen
Es wird die Serverkonfiguration in `SRV.conf` erstellt die auf der Fritzbox eingefügt werden kann.
```
touch      SRV.conf
chmod 640  SRV.conf
cat >  SRV.conf << EOX
[Interface]
ListenPort   = $UDPPORT
PrivateKey   = $(cat SRV.prv)
MTU          = $MTUBYTES

EOX
for x in $(seq -f "CL%g" $NUMCLIENTS); do
cat >> SRV.conf << EOX
[Peer]
PublicKey    = $(cat $x.pub)
PresharedKey = $(cat $x.psk)
AllowedIPs   = ${IPBEREICH%.*}.1${x#CL}/32

EOX
done

```

##### Clientkonfigurationen erstellen
Die Clientkonfigurationen werden in `CL*.conf` erstellt.
Die QR-Codes zum scannen mit einer App befinden sich in `CL*.txt` und `CL*.png`.
```
for x in $(seq -f "CL%g" $NUMCLIENTS); do
cat > $x.conf << EOX
[Interface]
Address             = ${IPBEREICH%.*}.1${x#CL}/32
DNS                 = $DNSSERVER
PrivateKey          = $(cat $x.prv)
MTU                 = $MTUBYTES

[Peer]
Endpoint            = $HOSTNAME:$UDPPORT
PublicKey           = $(cat SRV.pub)
PresharedKey        = $(cat $x.psk)
AllowedIPs          = 0.0.0.0/0
PersistentKeepalive = 90

EOX
cat $x.conf | qrencode -t ansiutf8 > $x.txt
cat $x.conf | qrencode -t png     -o $x.png
done

```

