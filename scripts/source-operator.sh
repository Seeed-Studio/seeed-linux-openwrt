#!/bin/bash


source_update () {
	echo "download code ..."
	WORKSPACE_ROOT=`pwd`
	OPENWRT_MAINLINE="https://github.com/openwrt/openwrt"
	LEAN_PACKAGE="https://github.com/coolsnowwolf/lede"
	git clone ${OPENWRT_MAINLINE} openwrt 
	cd openwrt
	OPENWRT_ROOT=`pwd`

	git clone ${LEAN_PACKAGE} /tmp/lede  --bare
	git clone /tmp/lede /tmp/lede-ucl
	git clone /tmp/lede /tmp/lede-upx

	cd /tmp/lede-ucl/
	git-filter-repo --path tools/ucl/

	cd /tmp/lede-upx/
	git-filter-repo --path tools/upx/

	cd ${OPENWRT_ROOT}
	git checkout remotes/origin/openwrt-21.02 -b openwrt-21.02
	git remote add -f ucl /tmp/lede-ucl
	git remote add -f upx /tmp/lede-upx 

	git merge ucl/master --allow-unrelated-histories --commit -m "merge: coolsnowwolf's ucl dir"
	git merge upx/master --allow-unrelated-histories --commit -m "merge: coolsnowwolf's upx dir"

	echo "clean dir"
	rm  -rf /tmp/lede
	rm  -rf /tmp/lede-ucl
	rm  -rf /tmp/lede-upx

	echo "modify openwrt tools/Makefile"
	insert_line "${OPENWRT_ROOT}/tools/Makefile" "tools-y += autoconf autoconf-archive automake bc bison cmake dosfstools" "tools-y += ucl upx"
	insert_line "${OPENWRT_ROOT}/tools/Makefile" "\$(curdir)/bison/compile := \$(curdir)/flex/compile" "\$(curdir)/upx/compile := \$(curdir)/ucl/compile"
	git add tools/Makefile
	git commit -m "tools: add  ucl upx to Makefile"


	echo "modify feeds.conf.default"
	echo -e "src-git seeed https://github.com/Seeed-Studio/seeed-linux-openwrt;packages" >> ${OPENWRT_ROOT}/feeds.conf.default
	git add feeds.conf.default
	git commit -m "feeds: add seeed's packages"
	echo -e "src-git node https://github.com/nxhack/openwrt-node-packages.git;openwrt-21.02" >> ${OPENWRT_ROOT}/feeds.conf.default
	git add feeds.conf.default
	git commit -m "feeds: add nxhack's node packages"
	
	echo "add latest lan78xx driver"
	cp ../patches/961-drivers-net-lan78xx-dervers-update-to-lan78xx.napi20.patch  $OPENWRT_ROOT/target/linux/bcm27xx/patches-5.4/
	git add target/linux/bcm27xx/patches-5.4/961-drivers-net-lan78xx-dervers-update-to-lan78xx.napi20.patch
	git commit -m "add latest lan78xx driver patches"

	echo  "cm4: enable lan78xx and usb net drivers"
	echo -e "CONFIG_USB_LAN78XX=y\nCONFIG_USB_NET_DRIVERS=y" >> $OPENWRT_ROOT/target/linux/bcm27xx/bcm2711/config-5.4
	git add target/linux/bcm27xx/bcm2711/config-5.4
	git commit -m "cm4: enable lan78xx and usb net drivers"

	echo  "x86: enable igc net drivers"
	echo -e "CONFIG_IGC=y" >> $OPENWRT_ROOT/target/linux/x86/config-5.4
	git add target/linux/x86/config-5.4
	git commit -m "x86: enable igc net drivers"

	echo  "enable cm4 wifi"
	sed -i 's/36/44/g;s/VHT80/VHT20/g' $OPENWRT_ROOT/package/kernel/mac80211/files/lib/wifi/mac80211.sh
	sed -i 's/disabled=1/disabled=0/g' $OPENWRT_ROOT/package/kernel/mac80211/files/lib/wifi/mac80211.sh
	git add package/kernel/mac80211/files/lib/wifi/mac80211.sh
	git commit -m "enable cm4 wifi default"

	#merge build: fix opkg install step for large package selection 
	git cherry-pick 1854aeec4d37079690309dec3171d0864339f73a 

}

