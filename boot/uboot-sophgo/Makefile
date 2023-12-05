# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2022 OpenWrt.org
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_RELEASE:=1
PKG_VERSION:=2021.10

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=http://192.168.1.77:1080/baozhu/uboot-sophgo
PKG_SOURCE_VERSION:=3779bc1103f01422107e936b3e8cc099ab353763
PKG_MIRROR_HASH=c4409eea747f63e7234cc53bd77a4ae343d73493fd4fe1c840d7f51862868ba7

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk


define Build/Prepare
    $(call Build/Prepare/Default)
	$(warning print....................... Build/Prepare: ${SUBTARGET} $$(DEVICE_DTS)  $(STAGING_DIR_IMAGE) )
	cp files/$(SUBTARGET)/$(BUILD_DEVICES)_defconfig $(PKG_BUILD_DIR)/configs/$(BUILD_VARIANT)_defconfig
	cp files/$(SUBTARGET)/dts/*.dts $(PKG_BUILD_DIR)/arch/riscv/dts/
	cp files/$(SUBTARGET)/dts/*.dtsi $(PKG_BUILD_DIR)/arch/riscv/dts/
	cp files/$(SUBTARGET)/dts/cvi_board_memmap.h $(PKG_BUILD_DIR)/arch/riscv/dts/
	cp files/$(SUBTARGET)/cvitek.h $(PKG_BUILD_DIR)/include/cvitek/
	cp files/$(SUBTARGET)/cvi_board_init.c $(PKG_BUILD_DIR)/board/cvitek
endef


define U-Boot/Default
	BUILD_TARGET:=sophgo
	BUILD_DEVICES=$(1)
	UBOOT_IMAGE:=u-boot.bin
	DTS_DIR:=arch/riscv/dts
	UENV:=default
endef

# sophgo boards

define U-Boot/huashanpi
	NAME:=Sophgo huashan pi
	UBOOT_DTS:=cv1812h_wevb_0007a_emmc.dtb
	BUILD_DEVICES:=cvitek_cv1812h_wevb_0007a_emmc
	UBOOT_MAKE_FLAGS := \
		CHIP=cv1812h \
		CVIBOARD=wevb_0007a_emmc \
		BOARD=cv181x \
		CHIP_SEGMENT=cv181x
endef

define U-Boot/milkvduo
	NAME:=Sophgo milk-v duo
	UBOOT_DTS:=cv1800b_milkv_duo_sd.dtb
	BUILD_DEVICES:=cvitek_cv1800b_milkv_duo_sd
	UBOOT_MAKE_FLAGS := \
		CHIP=cv1800b \
		CVIBOARD=milkv_duo_sd \
		BOARD=cv180x \
		CHIP_SEGMENT=cv180x
endef



UBOOT_TARGETS := \
	huashanpi \
	milkvduo




define Build/InstallDev
	$(INSTALL_DIR) $(BIN_DIR)
	$(CP) $(PKG_BUILD_DIR)/u-boot.bin $(STAGING_DIR_IMAGE)/u-boot.bin
endef

$(eval $(call BuildPackage/U-Boot))
