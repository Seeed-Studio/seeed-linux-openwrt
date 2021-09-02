include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lan78xx
PKG_RELEASE:=1

#include $(INCLUDE_DIR)/local-development.mk
ifeq ($(DUMP)$(PKG_VERSION),)
PKG_VERSION:=1.0
endif

include $(INCLUDE_DIR)/package.mk

define KernelPackage/lan78xx
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  URL:=http://www.microchip.com
  MAINTAINER:=WOOJUNG HUH <woojung.huh@microchip.com>.
  TITLE:=Microchip LAN78XX Based USB Ethernet Adapters
  DEPENDS:=
  KCONFIG:=CONFIG_USB_NET_DRIVERS=y
  FILES:=$(PKG_BUILD_DIR)/lan78xx.ko
  AUTOLOAD:=$(call AutoLoad,41,lan78xx)
endef

define KernelPackage/lan78xx/description
  Microchip LAN78XX Based USB Ethernet Adapters
endef

define Build/InstallDev
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(KERNEL_MAKE) M=$(PKG_BUILD_DIR) modules
endef

$(eval $(call KernelPackage,lan78xx))