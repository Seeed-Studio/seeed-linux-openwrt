#!/bin/bash

. scripts/file-editor.sh
. scripts/source-operator.sh

# parse commandline options
while [ ! -z "$1" ]; do
	case $1 in
	--package-op)
		./scripts/update_packages.py
		;;
	--source-op)
		source_update
		;;
	--feeds)
	    WORKSPACE_ROOT=`pwd`
		cd ${OPENWRTROOT}
		./scripts/feeds update -a
		cd ${OPENWRTROOT}/feeds/packages
		git am ${WORKSPACE_ROOT}/patches/fd03fc267e077bf948ada8af2d9fcb3616551247.patch
		cd ${OPENWRTROOT}
		./scripts/feeds install -a
		./scripts/feeds uninstall luci-app-dockerman
		./scripts/feeds install -f -p seeed luci-app-dockerman
		./scripts/feeds uninstall luci-lib-docker
		./scripts/feeds install -f -p seeed luci-lib-docker
		;;
	--deconfig)
		cd ${OPENWRTROOT}
		if [ ! -d '../staging_dir' ]; then
			mkdir ../staging_dir
		fi
		ln -s ../staging_dir 

		if [ ! -d '../build_dir/host' ]; then
			mkdir ../build_dir/host	-p
			mkdir ./build_dir
		fi
		ln -s ../../build_dir/host build_dir/host

		if [ "${OPENWRT_CONFIG_FILE}" = "configs/x86_defconfig" ]; then
			cp -rf ../files/x86 files

			git clone  https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git /tmp/linux-firmware
			mkdir -p files/lib/firmware
			cp /tmp/linux-firmware/iwlwifi-QuZ-a0-*.* files/lib/firmware

			echo "use x86 default custom rootfs config files"
		fi
		if [ "${OPENWRT_CONFIG_FILE}" = "configs/rpi_cm4_defconfig" ]; then
			cp -rf ../files/rpi files
			echo "use rpi default custom rootfs config files"
		fi
		cp ../$OPENWRT_CONFIG_FILE .config
		make defconfig
		;;
	--download)
		cd ${OPENWRTROOT}
		make download -j8 || make download -j8
		;;
	--tools-compile)
		cd ${OPENWRTROOT}
		make tools/compile -j$(nproc) || make tools/compile -j1 V=s
		make toolchain/compile -j$(nproc) || make toolchain/compile -j1 V=s
		;;
	--target-compile)
		cd ${OPENWRTROOT}
		make target/compile -j$(nproc) || make target/compile -j1 V=s
		;;
	--package-compile)
		cd ${OPENWRTROOT}
		make package/compile -j$(nproc) || make package/compile -j1 V=s
		;;
	--package-install)
		cd ${OPENWRTROOT}
		make package/install -j$(nproc) || make package/install -j1 V=s
		;;
	--target-install)
		cd ${OPENWRTROOT}
		make target/install -j$(nproc) || make target/install -j1 V=s
		make checksum
		;;
	esac
	shift
done
