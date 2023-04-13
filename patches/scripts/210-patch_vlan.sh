[ "$FREETZ_ENABLE_VLAN" == "y" ] || return 0
echo1 "applying vlan patch"

patch_vlan() {
	modsed -r \
	  "s/^($1) ?=.*/\1 = $2/" \
	  $HTML_LANG_MOD_DIR/fon_num/phoneline.lua \
	  "^$1 = $2$"
}

# 6590: show.vlan = not (config.is_cable or (config.LTE and not config.multiwan_lte))
# 6591: show.vlan=not(config.is_cable or(config.LTE and not config.multiwan_lte))
patch_vlan "show.vlan" "true"

# 6590: result.multiwan_lte = config.multiwan_lte
# 6591: result.multiwan_lte=config.multiwan_lte
patch_vlan "result.multiwan_lte" "false"

# 6590: result.is_cable = config.is_cable
# 6591: result.is_cable=config.is_cable
patch_vlan "result.is_cable" "false"

