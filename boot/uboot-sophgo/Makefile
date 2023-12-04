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
PKG_SOURCE_VERSION:=c5d4e427ae3ab736c3d72043715b9a990b07d1c9
PKG_MIRROR_HASH=857f84db3f8ae47d7441c863c496d61611dcf94460726557517bd887bdfbe6a4

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
	BUILD_TARGET:=sophgo
	BUILD_DEVICES=$(1)
	UBOOT_IMAGE:=u-boot.bin
	DTS_DIR:=arch/riscv/dts
	UENV:=default
endef

# sophgo boards

define U-Boot/sophgo
	NAME:=Sophgo huashan
	UBOOT_DTS:=cv1812h_wevb_0007a_emmc.dtb
	BUILD_DEVICES:=cvitek_cv1812h_wevb_0007a_emmc
endef


UBOOT_TARGETS := \
	cvitek_cv1812h_wevb_0007a_emmc 

#for dtb-$(CONFIG_TARGET_CVITEK) += $(CHIP)_$(CVIBOARD).dtb
UBOOT_MAKE_FLAGS += \
  CHIP=cv1812h \
  BOARD=cv181x \
  CVIBOARD=wevb_0007a_emmc 


define Build/InstallDev
	$(INSTALL_DIR) $(BIN_DIR)
	$(CP) $(PKG_BUILD_DIR)/u-boot.bin $(STAGING_DIR_IMAGE)/u-boot.bin
endef

$(eval $(call BuildPackage/U-Boot))
