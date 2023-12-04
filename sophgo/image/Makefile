# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

include $(SUBTARGET).mk


define Image/Prepare
	$(warning print....................... Image/Prepare: ${SUBTARGET} $$(DEVICE_DTS)  $(STAGING_DIR_IMAGE) )
	mkdir -p $(STAGING_DIR_IMAGE)
	cp ${PWD}/image/multi.its ${STAGING_DIR_IMAGE}/multi.its
	sed -i "s=\$$$${images_dir}=$(STAGING_DIR_IMAGE)=" ${STAGING_DIR_IMAGE}/multi.its
	sed -i "s=\$$$${dts_name}=$$(DEVICE_DTS).dtb=" ${STAGING_DIR_IMAGE}/multi.its
endef


define Image/BuildKernel
	echo $(TARGET_LDFLAGS)
	cp $(KDIR)/Image $(STAGING_DIR_IMAGE)/Image
	# cp $(DTS_DIR)/$(DTSDIR)/$$$(DEVICE_DTS).dtb $(STAGING_DIR_IMAGE)/$$(DEVICE_DTS).dtb
	cp $(KDIR)/image-$$(DEVICE_DTS).dtb $(STAGING_DIR_IMAGE)/$$(DEVICE_DTS).dtb
endef


define Image/Build/gzip
	gzip -f9n $(STAGING_DIR_IMAGE)/$(IMG_ROOTFS)-$(1).img
endef

$(eval $(call Image/gzip-ext4-padded-squashfs))

define Image/Build
	$(call Image/Build/$(1))
	python3 ${PWD}/image/fiptool.py -v genfip $(STAGING_DIR_IMAGE)/fip.bin \
	--MONITOR_RUNADDR=0x80000000 \
	--CHIP_CONF=${PWD}/image/firmware/${SUBTARGET}/chip_conf.bin \
	--NOR_INFO=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF \
	--NAND_INFO=00000000 \
	--BL2=${PWD}/image/firmware/${SUBTARGET}/bl2.bin \
	--BLCP_IMG_RUNADDR=0x05200200 \
	--BLCP_PARAM_LOADADDR=0 \
	--DDR_PARAM=${PWD}/image/firmware/${SUBTARGET}/ddr_param.bin \
	--MONITOR=${PWD}/image/firmware/${SUBTARGET}/fw_dynamic.bin \
	--LOADER_2ND=$(STAGING_DIR_IMAGE)/u-boot.bin

	lzma e $(STAGING_DIR_IMAGE)/Image $(STAGING_DIR_IMAGE)/Image.lzma


	mkimage -f ${STAGING_DIR_IMAGE}/multi.its ${STAGING_DIR_IMAGE}/boot.sd
	# ${PWD}/image/genimage.sh -c  ${PWD}/image/genimage.cfg

	genimage --rootpath $(call mkfs_target_dir,$(1)) --inputpath $(STAGING_DIR_IMAGE) --outputpath $(BIN_DIR) --config ${PWD}/image/genimage.cfg
	rm -rf ${PWD}/image/tmp || true
endef



$(eval $(call BuildImage))
