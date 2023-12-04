# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2022 Toco Technologies <info@toco.ae>
#
include $(TOPDIR)/rules.mk

ARCH:=riscv64
BOARD:=sophgo
BOARDNAME:=Sophgo U-based RISC-V
FEATURES:=ext4
KERNELNAME:=Image dtbs
SUBTARGETS:=cv180x cv181x

KERNEL_PATCHVER:=5.15


include $(INCLUDE_DIR)/target.mk

# TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib
# TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
# $(warning print....................... TARGET_CFLAGS: $(TARGET_CFLAGS))


DEFAULT_PACKAGES += u-boot-cvitek_cv1812h_wevb_0007a_emmc_huashan
define Target/Description
	Build firmware images for the Sophgo U-based boards
endef

$(eval $(call BuildTarget))
