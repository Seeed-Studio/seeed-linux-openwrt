#
# Copyright (C) 2009 OpenWrt.org
#

SUBTARGET:=cv180x
BOARDNAME:=cv180x based boards
DTSDIR:=cvitek
DEVICE_PACKAGES := u-boot-milkvduo



define Target/Description
	Build firmware images for sophgo cv180x based boards.
endef

