/*
	Copyright (C) 2012 cuma
	Copyright (C) 2011 Joerg Jungermann

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
*/

// #define DEBUG

#include <stdio.h>      // printf, fprintf
#include <stdarg.h>     // vprintf
#include <stdlib.h>     // exit
#include <arpa/inet.h>  // ntohs, htons, htonl
#include <sys/types.h>  // socket...
#include <sys/socket.h> // socket...
#include <netinet/in.h> // in_addr, in6_addr, INADDR_LOOPBACK, in6addr_loopback
#include <dlfcn.h>      // dlopen, dlsym

#define xstr(s) str(s)
#define str(s) #s

#ifndef LIBC_LOCATION
#if defined(D_UCLIBC)
#define LIBC_LOCATION "/lib/libc.so." xstr(__UCLIBC_MAJOR__)
#endif
#if defined(D_MUSL)
#define LIBC_LOCATION "/lib/libc.so"
#endif
#if defined(D_GLIBC)
#define LIBC_LOCATION "/lib/libc.so.6"
#endif
#endif

#ifdef DEBUG
static void debug_printf(char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	vfprintf(stdout, fmt, ap);
	va_end(ap);
	fflush(stdout);
}
#endif

static int (*real_bind)(int, const struct sockaddr *, socklen_t) = NULL;

static void _libmultid_init (void) __attribute__((constructor));
static void _libmultid_init (void)
{
	const char *err;

#if defined(RTLD_NEXT) && 0
  /*
   * TODO: doesn't work because of a uClibc bug fixed by the following commit
   *       http://git.uclibc.org/uClibc/commit/ldso/libdl/libdl.c?id=df3a5fcc8d1c3402289375c92df705e978fab58d
   */
	void *libc_handle = RTLD_NEXT;
#else
	void *libc_handle = dlopen(LIBC_LOCATION, RTLD_LOCAL | RTLD_LAZY);
#endif
	if (!libc_handle || NULL != (err = dlerror())) {
		fprintf(stderr, "[libmultid::_libmultid_init()] Unable to get libc-handle: %s\n", err);
		exit(1);
	}

	real_bind = dlsym(libc_handle, "bind");
	if (!real_bind || NULL != (err = dlerror ())) {
		fprintf(stderr, "[libmultid::_libmultid_init()] Unable to get bind-handle: %s\n", err);
		exit(1);
	}

#ifdef DEBUG
	debug_printf("[libmultid::_libmultid_init()] Successfully initialized\n");
#endif
}

#ifdef D_LOCAL
#define BIND_TO_LOCAL4(_sin4_addr)	_sin4_addr = htonl(INADDR_LOOPBACK)
#define BIND_TO_LOCAL6(_sin6_addr)	_sin6_addr = in6addr_loopback
#else
#define BIND_TO_LOCAL4(_sin4_addr)
#define BIND_TO_LOCAL6(_sin6_addr)
#endif

static int
change_port (u_short *pport)
{
	u_short port = ntohs (*pport);
	switch (port) {
#if defined D_DNS || defined D_DHCP || defined D_LLMNR
#ifdef D_DNS
	case 53:
#endif
#ifdef D_DHCP
	case 67:
#endif
#ifdef D_LLMNR
	case 5353:
	case 5355:
#endif
		port += 50000;
		*pport = htons (port);
		return 1;
#endif
	default:
		return 0;
	}
}

int bind (int fd, const struct sockaddr *sk, socklen_t sl)
{
	switch (sk->sa_family) {
	case AF_INET: {
		struct sockaddr_in *lsk_in = (struct sockaddr_in *)sk;
#ifdef DEBUG
		char addr_buf[INET_ADDRSTRLEN];
		inet_ntop(AF_INET, &lsk_in->sin_addr, addr_buf, sizeof(addr_buf));
		debug_printf("[libmultid::bind()] IPv4 src: fd=%d %s:%d\n", fd, addr_buf, ntohs (lsk_in->sin_port));
#endif
		if (change_port (&lsk_in->sin_port))
			BIND_TO_LOCAL4(lsk_in->sin_addr.s_addr);
#ifdef DEBUG
		inet_ntop(AF_INET, &lsk_in->sin_addr, addr_buf, sizeof(addr_buf));
		debug_printf("[libmultid::bind()] IPv4 dst: fd=%d %s:%d\n", fd, addr_buf, ntohs (lsk_in->sin_port));
#endif
		}
		break;
#ifdef D_IPV6
	case AF_INET6: {
		struct sockaddr_in6 *lsk_in6 = (struct sockaddr_in6 *)sk;
#ifdef DEBUG
		char addr_buf[INET6_ADDRSTRLEN];
		inet_ntop(AF_INET6, &lsk_in6->sin6_addr, addr_buf, sizeof(addr_buf));
		debug_printf("[libmultid::bind()] IPv6 src: fd=%d [%s]:%d\n", fd, addr_buf, ntohs (lsk_in6->sin6_port));
#endif
		if (change_port (&lsk_in6->sin6_port))
			BIND_TO_LOCAL6(lsk_in6->sin6_addr);
#ifdef DEBUG
		inet_ntop(AF_INET6, &lsk_in6->sin6_addr, addr_buf, sizeof(addr_buf));
		debug_printf("[libmultid::bind()] IPv6 dst: fd=%d [%s]:%d\n", fd, addr_buf, ntohs (lsk_in6->sin6_port));
#endif
		}
		break;
#endif
	default:
		fprintf(stderr, "[libmultid::bind()] Address family unknown: af=%d fd=%d\n", sk->sa_family, fd);
		break;
	}
	return real_bind (fd, sk, sl);
}

