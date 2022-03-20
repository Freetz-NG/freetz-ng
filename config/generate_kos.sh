#!/bin/bash
#by cuma, 2020

SCRIPT="$(readlink -f $0)"
PARENT="$(dirname ${SCRIPT%/*})"
PDIR="config/.kos"
PROP="$PARENT/$PDIR"
CINTMP="$PROP/Config.in"
SYMS="
 SWAP

 MTD_BLOCK2MTD

 CRYPTO_AEAD CRYPTO_AES CRYPTO_ARC4 CRYPTO_BLKCIPHER CRYPTO_CBC CRYPTO_ALGAPI CRYPTO_HASH
 CRYPTO_WORKQUEUE CRYPTO_MANAGER CRYPTO_PCOMP CRYPTO_RNG CRYPTO_SHA1 CRYPTO_SHA256
 
 USB
 BT_HCIBFUSB BT_HCIBTUSB BT_INTEL BT_HCIBTUSB_BCM BT_HCIBTUSB_RTL
  ISDN_CAPI_CAPICONN CDROM_PKTCDVD DUMMY BLK_DEV_DM DM_CRYPT FW_LOADER BT_HCIUSB_SCO BLK_DEV_LOOP USB_MUSB_HDRC
  MTD_NAND BLK_DEV_NBD MTD_NAND_OHIO SCSI_MOD BLK_DEV_SD CHR_DEV_SG SLHC BLK_DEV_SR USB_PRINTER USB_STORAGE USB_IP_HOST USB_IP_COMMON USB_MON
 PPP_ASYNC PPP_DEFLATE PPP PPP_MPPE_MPPC PPPOE PPPOL2TP
 USB_SERIAL_CH341 USB_SERIAL_CP2101 USB_SERIAL_CP210X USB_SERIAL_FTDI_SIO USB_SERIAL_IPAQ USB_SERIAL_OPTION USB_SERIAL_PL2303 USB_SERIAL
 
 EXT2_FS EXT3_FS JBD EXT4_FS EXT4_USE_FOR_EXT23 CRC16 JBD2 FS_MBCACHE
  FAT_FS VFAT_FS HFS_FS HFSPLUS_FS ISO9660_FS JFFS2_FS MINI_FO MINIX_FS MSDOS_FS REISERFS_FS UDF_FS UNION_FS
 AUTOFS4_FS CIFS CRYPTO_CMAC CRYPTO_DES CRYPTO_ECB CRYPTO_HMAC CRYPTO_MD4 CRYPTO_MD5 FUSE_FS
 LOCKD GRACE_PERIOD SUNRPC NFS_FS NFS_V2 NFS_V3 NFSD EXPORTFS
 NLS_CODEPAGE_437 NLS_ISO8859_1 NLS_ISO8859_15 NLS_UTF8
 
 CRC_CCITT LZO_COMPRESS LZO_DECOMPRESS
 
 TUN
 BT BT_BNEP BT_L2CAP BT_RFCOMM
 NET_CLS_U32 NET_SCH_CBQ NET_SCH_HTB NET_SCH_LLQ NET_SCH_SFQ NET_SCH_TBF
"
rm -rf "$PROP"
mkdir -p "$PROP"
touch "$CINTMP"

for src in $PARENT/make/linux/configs/avm/*; do
	src="${src%--not-available}"
	[ ! -e "$src" ] && src="${src/avm/freetz}"
	echo "source \"$PDIR/${src##*/}.in\"" >> "$CINTMP"

	case ${src##*/} in
		config-ar7-04.33)        box="04_33 \&\& !FREETZ_TYPE_7140 \&\& FREETZ_SYSTEM_TYPE_AR7_SANGAM"  ;;
		config-ohio-04.33)       box="04_33 \&\& !FREETZ_TYPE_7140 \&\& FREETZ_SYSTEM_TYPE_AR7_OHIO"    ;;
		config-ohio-7140_04.33)  box="04_33 \&\& FREETZ_TYPE_7140"                                      ;;
		config-ohio-5140_04.67)  box="04_67 \&\& FREETZ_TYPE_5140"                                      ;;
		config-ohio-04.67)       box="04_67 \&\& !FREETZ_TYPE_5140"                                     ;;
		config-ohio-r7203)       box="r7203"                                                            ;;
		*)                       box="$(echo $src | sed 's/.*-//;s/\./_/')"                             ;;
	esac

	echo -n .
	out="$PROP/${src##*/}.in"
	for sym in $SYMS; do
		grep -q "^CONFIG_$sym=y$" "$src" && echo -e "config FREETZ_AVM_HAS_${sym}_BUILTIN"
	done | sort > "$out"
	sed -i "s/$/\n\tdef_bool y\n/g;1s/^/if FREETZ_AVM_SOURCE_$box\n\n/;$ s/$/\nendif/g" "$out"
done
echo " done."

