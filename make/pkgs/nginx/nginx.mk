$(call PKG_INIT_BIN, 1.29.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=9befcced12ee09c2f4e1385d7e8e21c91f1a5a63b196f78f897c2d044b8c9312
$(PKG)_SITE:=https://nginx.org/download
### WEBSITE:=https://nginx.org/
### MANPAGE:=https://nginx.org/en/docs/
### CHANGES:=https://nginx.org/en/CHANGES
### CVSREPO:=https://github.com/nginx/nginx

$(PKG)_BINARY:=$($(PKG)_DIR)/objs/nginx
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/nginx

$(PKG)_STARTLEVEL=40

# Nginx uses a custom configure script that doesn't support standard autoconf options
$(PKG)_CONFIGURE_DEFOPTS := n

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NGINX_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NGINX_WITH_HTTP_V2
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NGINX_WITH_STREAM
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NGINX_WITH_GZIP_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NGINX_CONF_PATH
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NGINX_PID_PATH
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NGINX_ERROR_LOG_PATH
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NGINX_HTTP_LOG_PATH

NGINX_EXTRA_CFLAGS:=-ffunction-sections -fdata-sections
NGINX_EXTRA_LDFLAGS:=-Wl,--gc-sections

$(PKG)_DEPENDS_ON += pcre
$(PKG)_DEPENDS_ON += zlib

ifeq ($(strip $(FREETZ_PACKAGE_NGINX_WITH_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION
$(PKG)_DEPENDS_ON += openssl
endif

$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += LD="$(TARGET_LD)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS) $(NGINX_EXTRA_CFLAGS)"
$(PKG)_CONFIGURE_ENV += LDFLAGS="$(TARGET_LDFLAGS) $(NGINX_EXTRA_LDFLAGS)"

# Cross-compilation variables for nginx
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_c_compiler=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_c99_have_variadic_macros=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_gcc_have_variadic_macros=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_gcc_have_atomic=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_libatomic=no;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_epoll=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_eventfd=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_sendfile=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_sendfile64=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_pr_set_dumpable=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_timer_event=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_sys_nerr=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_map_anon=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_map_devzero=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_sysvshm=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_have_posix_sem=yes;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_sizeof_int=4;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_sizeof_long=4;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_sizeof_long_long=8;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_sizeof_void_p=4;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_sizeof_sig_atomic_t=4;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_sizeof_size_t=4;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_sizeof_off_t=8;
$(PKG)_CONFIGURE_PRE_CMDS += export ngx_force_sizeof_time_t=4;

# Nginx configure options (nginx doesn't use standard autoconf, so we specify only what it supports)
$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --sbin-path=/usr/sbin/nginx
$(PKG)_CONFIGURE_OPTIONS += --conf-path=$(call qstrip,$(FREETZ_PACKAGE_NGINX_CONF_PATH))
$(PKG)_CONFIGURE_OPTIONS += --error-log-path=$(call qstrip,$(FREETZ_PACKAGE_NGINX_ERROR_LOG_PATH))
$(PKG)_CONFIGURE_OPTIONS += --http-log-path=$(call qstrip,$(FREETZ_PACKAGE_NGINX_HTTP_LOG_PATH))
$(PKG)_CONFIGURE_OPTIONS += --pid-path=$(call qstrip,$(FREETZ_PACKAGE_NGINX_PID_PATH))
$(PKG)_CONFIGURE_OPTIONS += --lock-path=/var/run/nginx.lock
$(PKG)_CONFIGURE_OPTIONS += --http-client-body-temp-path=/tmp/nginx/client_body
$(PKG)_CONFIGURE_OPTIONS += --http-proxy-temp-path=/tmp/nginx/proxy
$(PKG)_CONFIGURE_OPTIONS += --http-fastcgi-temp-path=/tmp/nginx/fastcgi
$(PKG)_CONFIGURE_OPTIONS += --http-uwsgi-temp-path=/tmp/nginx/uwsgi
$(PKG)_CONFIGURE_OPTIONS += --http-scgi-temp-path=/tmp/nginx/scgi
$(PKG)_CONFIGURE_OPTIONS += --user=root
$(PKG)_CONFIGURE_OPTIONS += --group=root

# PCRE support
$(PKG)_CONFIGURE_OPTIONS += --with-cc-opt="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_OPTIONS += --with-ld-opt="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"

# SSL support
ifeq ($(strip $(FREETZ_PACKAGE_NGINX_WITH_SSL)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-http_ssl_module
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_HTTP_V2),--with-http_v2_module,)
$(PKG)_CONFIGURE_OPTIONS += --with-stream_ssl_module
else
endif

# HTTP modules
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_STUB_STATUS),--with-http_stub_status_module,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_GZIP_STATIC),--with-http_gzip_static_module,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_REALIP),--with-http_realip_module,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_AUTH_REQUEST),--with-http_auth_request_module,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_DAV),--with-http_dav_module,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_FLV),--with-http_flv_module,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_MP4),--with-http_mp4_module,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_SUB),--with-http_sub_module,)

# Stream module
ifeq ($(strip $(FREETZ_PACKAGE_NGINX_WITH_STREAM)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-stream
$(PKG)_CONFIGURE_OPTIONS += --with-stream_realip_module
endif

# Disable unwanted modules (configurable via menuconfig)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_SSI),,--without-http_ssi_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_USERID),,--without-http_userid_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_AUTOINDEX),,--without-http_autoindex_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_GEO),,--without-http_geo_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_MAP),,--without-http_map_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_SPLIT_CLIENTS),,--without-http_split_clients_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_REFERER),,--without-http_referer_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_PROXY),,--without-http_proxy_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_FASTCGI),,--without-http_fastcgi_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_UWSGI),,--without-http_uwsgi_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_SCGI),,--without-http_scgi_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_MEMCACHED),,--without-http_memcached_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_LIMIT_CONN),,--without-http_limit_conn_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_LIMIT_REQ),,--without-http_limit_req_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_EMPTY_GIF),,--without-http_empty_gif_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_BROWSER),,--without-http_browser_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_UPSTREAM_HASH),,--without-http_upstream_hash_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_UPSTREAM_IP_HASH),,--without-http_upstream_ip_hash_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_UPSTREAM_LEAST_CONN),,--without-http_upstream_least_conn_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_UPSTREAM_RANDOM),,--without-http_upstream_random_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_UPSTREAM_KEEPALIVE),,--without-http_upstream_keepalive_module)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_UPSTREAM_ZONE),,--without-http_upstream_zone_module)

# Mail modules
ifeq ($(strip $(FREETZ_PACKAGE_NGINX_WITH_MAIL)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-mail
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGINX_WITH_MAIL_SSL),--with-mail_ssl_module,)
else
# no --without-mail nor --without-mail_ssl_module
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NGINX_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(NGINX_DIR) clean
	$(RM) $(NGINX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NGINX_TARGET_BINARY)

$(PKG_FINISH)

