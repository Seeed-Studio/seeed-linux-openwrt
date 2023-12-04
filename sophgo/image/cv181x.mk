# SPDX-License-Identifier: GPL-2.0-only
define Device/huashanpi
	DEVICE_VENDOR := hw100k
	DEVICE_MODEL := huashanpi-cv1812h
	DEVICE_DTS_DIR := ${PWD}/cv181x/dts
	DEVICE_DTS := cv1812h_wevb_0007a_emmc
endef
TARGET_DEVICES += huashanpi

