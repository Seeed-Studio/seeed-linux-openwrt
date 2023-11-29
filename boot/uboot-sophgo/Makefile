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
PKG_SOURCE_VERSION:=da8eda89e1749b5fc1d35e1fc784b648f5cf149b

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
	UBOOT_DTS:=cv1812h_wevb_0007a_emmc_huashan.dtb
	BUILD_DEVICES:=cvitek_cv1812h_wevb_0007a_emmc_huashan
endef


UBOOT_TARGETS := \
	cvitek_cv1812h_wevb_0007a_emmc_huashan 

#for dtb-$(CONFIG_TARGET_CVITEK) += $(CHIP)_$(CVIBOARD).dtb
UBOOT_MAKE_FLAGS += \
  CHIP=cv1812h_wevb_0007a_emmc \
  BOARD=cv181x \
  CVIBOARD=huashan 


define Build/InstallDev
	$(INSTALL_DIR) $(BIN_DIR)
	$(CP) $(PKG_BUILD_DIR)/u-boot.bin $(BIN_DIR)/u-boot.bin
endef

$(eval $(call BuildPackage/U-Boot))
