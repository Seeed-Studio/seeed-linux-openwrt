# SPDX-License-Identifier: GPL-2.0-only


# When the factory image won't fit anymore, it can be removed.
# New installation will be performed booting the initramfs image from
# ram and then flashing the sysupgrade image from OpenWrt
define Device/milk-v-duo
  DEVICE_VENDOR := milkv.io
  DEVICE_MODEL := milkv-duo
  DEVICE_DTS_DIR := ${PWD}/cv180x/dts
  DEVICE_DTS := cv1800b_milkv_duo_sd
endef
TARGET_DEVICES += milk-v-duo

