# Nmap 4.76/5.51/7.97 (binary only)
  - Homepage: [https://nmap.org/](https://nmap.org/)
  - Manpage: [https://nmap.org/docs.html](https://nmap.org/docs.html)
  - Changelog: [https://nmap.org/changelog.html](https://nmap.org/changelog.html)
  - Repository: [https://github.com/nmap/nmap](https://github.com/nmap/nmap)
  - Package: [master/make/pkgs/nmap/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/nmap/)
  - Maintainer: [@fda77](https://github.com/fda77)

"*Nmap ("Network Mapper") is a free and open source (license) utility
for network exploration or security auditing. Many systems and network
administrators also find it useful for tasks such as network inventory,
managing service upgrade schedules, and monitoring host or service
uptime. Nmap uses raw IP packets in novel ways to determine what hosts
are available on the network, what services (application name and
version) those hosts are offering, what operating systems (and OS
versions) they are running, what type of packet filters/firewalls are in
use, and dozens of other characteristics. It was designed to rapidly
scan large networks, but works fine against single hosts.*"

### Example

```
root@fritz:/var/media/ftp/uData# nmap localhost

Starting Nmap 4.68 ( http://nmap.org ) at 2011-04-20 09:06 CEST
Interesting ports on localhost (127.0.0.1):
Not shown: 1699 closed ports
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
23/tcp   open  telnet
53/tcp   open  domain
80/tcp   open  http
81/tcp   open  hosts2-ns
111/tcp  open  rpcbind
443/tcp  open  https
1011/tcp open  unknown
1012/tcp open  unknown
2007/tcp open  dectalk
2047/tcp open  dls
5060/tcp open  sip
8080/tcp open  http-proxy
8123/tcp open  polipo
8888/tcp open  sun-answerbook

Nmap done: 1 IP address (1 host up) scanned in 4.598 seconds
```

### Known open ports

  ---------- ------------------------ --------------------- -------------------------------------
  **Port**   **Function**             **Program/process**   **Anmerkung**
  81         Freetz!                  inetd                 
  82         AVM's Webfilter         contfiltd             bei Firmware 7270 05.05 auf Port 81
  111        portmapper (nfs)         portmap               
  1011       AVM's telefon-daemon    telefon               
  1012       AVM's telefon-daemon    telefon               
  2007       ???                      telefon               
  2047       nfs v3                   nfsd                  
  8080       AVM's Kindersicherung   ctlmgr.bin            
  8888       AVM's telefon-daemon    telefon               
  ---------- ------------------------ --------------------- -------------------------------------

Useful command:

```
netstat -anp
```

### Weiterführende Links

-   [home page](http://nmap.org/)
-   [IPPF: Port
    8080](http://www.ip-phone-forum.de/showthread.php?t=188842)
-   [IPPF: Offene
    (Freetz-)Ports](http://www.ip-phone-forum.de/showthread.php?t=213465)
