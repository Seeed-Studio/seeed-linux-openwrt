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
		#source_update
		git clone https://github.com/Seeed-Studio/seeed-linux-openwrt -b openwrt-21.02 --depth=1 --single-branch openwrt
		;;
	--feeds)
	    WORKSPACE_ROOT=`pwd`
		cd ${OPENWRTROOT}
		./scripts/feeds update -a
		cd ${OPENWRTROOT}/feeds/packages
		git checkout 56c120b067979d62f3d8e007748eaaaf01e55a0e
		cd ${OPENWRTROOT}/feeds/luci
		git checkout d548d858c8cf62d36ab87dcf5d317fe05ede19cf
		cd ${OPENWRTROOT}/feeds/routing
		git checkout 2c21c1627b38e14826b8d5b67a58544136dcd240
		cd ${OPENWRTROOT}/feeds/telephony
		git checkout 920fbc5c0a2e4badf51bceff42e9a1e3eb693462
		cd ${OPENWRTROOT}/feeds/node
		git checkout ab5ebe0faaa8635d4bd5971ede12bedb203910a5
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
			echo "staging_dir cache not ready."
			mkdir ../staging_dir
		fi
		ln -s ../staging_dir 

		if [ ! -d '../build_dir/host' ]; then
			echo "build_dir cache not ready."
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
