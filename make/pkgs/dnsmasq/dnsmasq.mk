$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_DNSMASQ_VERSION_ABANDON),2.80,2.89))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=cdaba2785e92665cf090646cba6f94812760b9d7d8c8d0cfb07ac819377a63bb
$(PKG)_HASH_CURRENT:=02bd230346cf0b9d5909f5e151df168b2707103785eb616b56685855adebb609
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_DNSMASQ_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://thekelleys.org.uk/dnsmasq
### WEBSITE:=https://thekelleys.org.uk/dnsmasq/doc.html
### MANPAGE:=https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
### CHANGES:=https://thekelleys.org.uk/dnsmasq/CHANGELOG
### CVSREPO:=https://thekelleys.org.uk/gitweb/?p=dnsmasq.git;a=summary

$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_DNSMASQ_VERSION_ABANDON),abandon,current)
$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_AVM_VERSION_05_5X_MAX),$(if $(FREETZ_PACKAGE_DNSMASQ_VERSION_ABANDON),abandon,current)/multid)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/dnsmasq
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dnsmasq

$(PKG)_TRUST_ANCHORS:=$($(PKG)_DIR)/trust-anchors.conf
$(PKG)_TARGET_TRUST_ANCHORS:=$($(PKG)_DEST_DIR)/etc/default.dnsmasq/trust-anchors.conf

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DNSMASQ_VERSION_ABANDON
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DNSMASQ_WITH_DNSSEC
$(PKG)_REBUILD_SUBOPTS += FREETZ_AVM_HAS_MULTID_LEASES_FORMAT_V2
$(PKG)_REBUILD_SUBOPTS += FREETZ_AVM_VERSION_05_5X_MAX

$(PKG)_COPTS := -DCONFFILE=\\\"/mod/etc/dnsmasq.conf\\\"
$(PKG)_COPTS += -DRUNFILE=\\\"/var/run/dnsmasq/dnsmasq.pid\\\"
$(PKG)_COPTS += -DLEASEFILE=\\\"/var/tmp/dnsmasq.leases\\\"
$(PKG)_COPTS += -DNO_INOTIFY
ifeq ($(FREETZ_PACKAGE_DNSMASQ_VERSION_ABANDON),y)
$(PKG)_COPTS += -DNO_IPV6
endif
ifeq ($(FREETZ_AVM_HAS_MULTID_LEASES_FORMAT_V2),y)
$(PKG)_COPTS += -DMULTID_LEASES_FORMAT_V2
endif
ifeq ($(FREETZ_PACKAGE_DNSMASQ_WITH_DNSSEC),y)
$(PKG)_DEPENDS_ON += nettle
$(PKG)_COPTS += -DHAVE_DNSSEC -DHAVE_DNSSEC_STATIC
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DNSMASQ_DIR) \
		CC="$(TARGET_CC)" \
		COPTS="$(DNSMASQ_COPTS)" \
		CFLAGS="$(TARGET_CFLAGS) -ffunction-sections -fdata-sections" \
		LDFLAGS="-Wl,--gc-sections" \
		version=-DVERSION=\'\\\"$(DNSMASQ_VERSION)\\\"\' \
		PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../lib/pkgconfig"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TRUST_ANCHORS): $($(PKG)_DIR)/.unpacked
	@touch -c $@

$($(PKG)_TARGET_TRUST_ANCHORS): $($(PKG)_TRUST_ANCHORS)
	@mkdir -p $(dir $@); cat $< | grep "^trust-anchor" > $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_DNSMASQ_WITH_DNSSEC),$($(PKG)_TARGET_TRUST_ANCHORS))


$(pkg)-clean:
	-$(SUBMAKE) -C $(DNSMASQ_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNSMASQ_TARGET_BINARY) $(DNSMASQ_TARGET_TRUST_ANCHORS)

$(PKG_FINISH)
