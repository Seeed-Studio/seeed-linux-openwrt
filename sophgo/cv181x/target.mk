#
# Copyright (C) 2009 OpenWrt.org
#

SUBTARGET:=cv181x
BOARDNAME:=cv181x based boards
DTSDIR:=cvitek

DEVICE_PACKAGES := u-boot-huashanpi


define Target/Description
	Build firmware images for sophgo cv181x based boards.
endef

