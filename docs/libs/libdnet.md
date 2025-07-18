# libdnet (libdnet.so) 665
  - Library: [master/make/libs/libdnet/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/libs/libdnet/)
  - Maintainer: -

libdnet provides a simplified, portable interface to several low-level networking routines, including: * network address manipulation * kernel arp(4) cache and route(4) table lookup and manipulation * network firewalling (IP filter, ipfw, ipchains, pf, PktFilter, ...) * network interface lookup and manipulation * IP tunnelling (BSD/Linux tun, Universal TUN/TAP device) * raw IP packet and Ethernet frame transmission http://libdnet.sourceforge.net/ dnet is a simple test program for the dnet(3) library. It can be used to compose and transmit network datagrams as a Unix-style filter (e.g. reading from or writing to files and pipes) or modify the local system network configuration (including the ARP cache, firewall ruleset, network interfaces, and routing table). http://libdnet.sourceforge.net/dnet.8.txt
