# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Image/BuildKernel
	cp $(KDIR)/Image $(BIN_DIR)/Image
	cp $(DTS_DIR)/$(DTSDIR)/$(DTSNAME).dtb $(BIN_DIR)/$(DTSNAME).dtb
endef

define Image/Build/Initramfs
	cp $(KDIR)/Image-initramfs $(BIN_DIR)/$(IMG_PREFIX)-Image-initramfs
endef


define Image/Build/gzip
	gzip -f9n $(BIN_DIR)/$(IMG_ROOTFS)-$(1).img
endef

$(eval $(call Image/gzip-ext4-padded-squashfs))

define Image/Build
	$(call Image/Build/$(1))

	python3 ${PWD}/image/fiptool.py -v genfip $(BIN_DIR)/fip.bin \
	--MONITOR_RUNADDR=0x80000000 \
	--CHIP_CONF=${PWD}/image/input/chip_conf.bin \
	--NOR_INFO=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF \
	--NAND_INFO=00000000 \
	--BL2=${PWD}/image/input/bl2.bin \
	--BLCP_IMG_RUNADDR=0x05200200 \
	--BLCP_PARAM_LOADADDR=0 \
	--DDR_PARAM=${PWD}/image/input/ddr_param.bin \
	--MONITOR=${PWD}/image/input/fw_dynamic.bin \
	--LOADER_2ND=$(BIN_DIR)/u-boot.bin

	cp ${PWD}/image/multi.its ${BIN_DIR}/multi.its
	lzma e $(BIN_DIR)/Image $(BIN_DIR)/Image.lzma


	mkimage -f ${BIN_DIR}/multi.its ${BIN_DIR}/boot.sd
	# ${PWD}/image/genimage.sh -c  ${PWD}/image/genimage.cfg

	genimage --rootpath $(call mkfs_target_dir,$(1)) --inputpath $(BIN_DIR) --outputpath $(BIN_DIR) --config ${PWD}/image/genimage.cfg
	rm -rf ${PWD}/image/tmp || true
endef


$(eval $(call BuildImage))
