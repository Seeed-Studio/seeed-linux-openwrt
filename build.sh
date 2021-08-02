#!/bin/bash

. scripts/file-editor.sh
. scripts/source-operator.sh

# parse commandline options
while [ ! -z "$1" ] ; do
	case $1 in
	--source-op)
		source_update
		;;
	--feeds)
		cd ${OPENWRT_ROOT}
		./scripts/feeds update -a
		./scripts/feeds install -a
		;;
	--deconfig)
		cd ${OPENWRT_ROOT}
		if [ "${OPENWRT_CONFIG_FILE}" = "configs/x86_defconfig" ] ; then
			cp -rf  ${WORKSPACE_ROOT}/files/x86  files
			echo "use x86 default custom rootfs config files"
		fi
		if [ "${OPENWRT_CONFIG_FILE}" = "configs/rpi_cm4_defconfig" ] ; then
			cp -rf  ${WORKSPACE_ROOT}/files/rpi  files
			echo "use rpi default custom rootfs config files"
		fi
		cp ${WORKSPACE_ROOT}/$OPENWRT_CONFIG_FILE .config
		make defconfig
		;;
	--download)
		cd ${OPENWRT_ROOT}
		make download -j8 || make download -j8
		;;
	--tools-compile)
		cd ${OPENWRT_ROOT}
		make tools/compile -j$(nproc) || make tools/compile -j1 V=s
		make toolchain/compile -j$(nproc) || make toolchain/compile -j1 V=s
		;;
	--target-compile)
		cd ${OPENWRT_ROOT}
		make target/compile -j$(nproc) || make target/compile -j1 V=s IGNORE_ERRORS=1
		;;
	--package-compile)
		cd ${OPENWRT_ROOT}
		make package/compile -j$(nproc) || make package/compile -j1 V=s IGNORE_ERRORS=1
		;;
	--package-install)
		cd ${OPENWRT_ROOT}
		make package/install -j$(nproc) || make package/install -j1 V=s IGNORE_ERRORS=1
	--target-install)
		cd ${OPENWRT_ROOT}
		make target/install -j$(nproc) || make target/install -j1 V=s IGNORE_ERRORS=1
		make checksum
		;;
	esac
	shift
done
