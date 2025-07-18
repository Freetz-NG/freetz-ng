# AutoFS 5.0.5/5.1.9
  - Homepage: [https://docs.kernel.org/filesystems/autofs.html](https://docs.kernel.org/filesystems/autofs.html)
  - Manpage: [https://github.com/torvalds/linux/blob/master/Documentation/filesystems/autofs-mount-control.rst](https://github.com/torvalds/linux/blob/master/Documentation/filesystems/autofs-mount-control.rst)
  - Changelog: [https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/](https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/)
  - Repository: [https://github.com/torvalds/linux/tree/master/fs/autofs](https://github.com/torvalds/linux/tree/master/fs/autofs)
  - Package: [master/make/pkgs/autofs/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/autofs/)
  - Maintainer: [@fda77](https://github.com/fda77)

Mit diesem Paket können verschiedene Dateisysteme nach /var/media/autofs
gemountet werden.

Zweck ist, dass Mountpoints nur eingebunden werden, wenn darauf
zugegriffen wird. Nach einem Timeout ohne Zugriffe werden sie wieder
ausgehängt. Das funktioniert mit allen Dateisystemen und ist besonders
praktisch bei Netzwerk-Freigaben (NFS, CIFS, DAVFS etc.), da der Server,
auf den man zugreifen möchte, nicht bei Start des Freetz-Packages, das
diesen mountet, erreichbar sein muss, sondern nur bei Zugriff.

### Optionale Aufrufparameter

Zur Fehlersuche empfiehlt sich der Parameter `-v` und zusätzlich evtl
`-d`. Die Meldungen werden per [syslogd-cgi](syslogd.md)
ausgegeben.



### Beispielkonfigurationen der auto.conf

### NFS

Für NFS wird lediglich das Modul nfs.ko benötigt.

```
NFS-SHARE -rw,soft,intr,rsize=8192,wsize=8192         SERVER:/SHARE
```

### Samba

Hierfür wird das Paket [cifsmount](cifsmount.md) benötigt,
dessen Webinterface nicht.

```
SMB-SHARE -fstype=cifs,user=USER,pass=PASS,ro         ://SERVER/SHARE
```

### WebDAV

Für WebDAV wird das [davfs2](davfs2.html)-Paket (ohne
Webinterface) benötigt.

```
DAV-SHARE -fstype=davfs     :https://SERVER
```

Außerdem noch diese 2 Dateien:

/tmp/flash/autofs/davfs2.conf

```
ask_auth 0
#falls benötigt:
#if_match_bug 1
```

/tmp/flash/autofs/davfs2.secrets (Dateirechte 600!)

```
https://SERVER USERNAME    PASSWORT
```

### CurlFtpFS

Es wird das Package CurlFtpFS (ohne Webinterface) benötigt

```
FTP-SHARE -fstype=fuse,allow_other       :curlftpfs\#SERVER
```

### SSHfs

Es werden die Packages OpenSSH und SSHfs-FUSE benötigt

```
SSH-SHARE -fstype=fuse,rw,allow_other             :sshfs#USER@SERVER:/
```

Außerdem muss der Server in der known_hosts bekannt sein und in id_rsa
oder id_dsa muss der private Schlüssel hinterlegt sein. Diese Dateien
können mit dem SSH/[authorized_keys](authorized-keys.md)
Package bearbeitet werden

