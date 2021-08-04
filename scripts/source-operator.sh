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
	git clone /tmp/lede /tmp/lede-lean
	git clone /tmp/lede /tmp/lede-ucl
	git clone /tmp/lede /tmp/lede-upx

	cd /tmp/lede-lean
	git-filter-repo --path package/lean

	cd /tmp/lede-ucl/
	git-filter-repo --path tools/ucl/

	cd /tmp/lede-upx/
	git-filter-repo --path tools/upx/

	cd ${OPENWRT_ROOT}
	git checkout remotes/origin/openwrt-21.02 -b openwrt-21.02
	git remote add -f lean /tmp/lede-lean
	git remote add -f ucl /tmp/lede-ucl
	git remote add -f upx /tmp/lede-upx 

	git merge lean/master --allow-unrelated-histories --commit -m "merge: coolsnowwolf's lean dir"
	git merge ucl/master --allow-unrelated-histories --commit -m "merge: coolsnowwolf's ucl dir"
	git merge upx/master --allow-unrelated-histories --commit -m "merge: coolsnowwolf's ucl dir"

	echo "clean dir"
	rm  -rf /tmp/lede
	rm  -rf /tmp/lede-lean
	rm  -rf /tmp/lede-ucl
	rm  -rf /tmp/lede-upx

	echo "modify openwrt tools/Makefile"
	insert_line "${OPENWRT_ROOT}/tools/Makefile" "tools-y += autoconf autoconf-archive automake bc bison cmake dosfstools" "tools-y += ucl upx"
	insert_line "${OPENWRT_ROOT}/tools/Makefile" "\$(curdir)/bison/compile := \$(curdir)/flex/compile" "\$(curdir)/upx/compile := \$(curdir)/ucl/compile"
	git add tools/Makefile
	git commit -m "tools: add  ucl upx to Makefile"


	echo "add lisaac's  luci-app-diskman"
	rm -rf ${OPENWRT_ROOT}/package/lean/luci-app-diskman
	git add package/lean/luci-app-diskman
	git commit -m "remove lean's luci-app-diskman"
	git  remote add -f luci-app-diskman https://github.com/lisaac/luci-app-diskman
	git checkout  remotes/luci-app-diskman/master -b lisaac-luci-app-diskman
	git checkout openwrt-21.02
	git subtree add --prefix=package/lean/luci-app-diskman lisaac-luci-app-diskman

	echo "create parted package"
	mkdir -p package/lean/parted
	cp  package/lean/luci-app-diskman/Parted.Makefile package/lean/parted/Makefile
	git add  package/lean/parted/Makefile
	git commit -m "package: add parted "



	echo "add lisaac's  luci-app-docker"
	rm -rf ${OPENWRT_ROOT}/package/lean/luci-app-docker
	git add package/lean/luci-app-docker
	git commit -m "remove lean's luci-app-docker"
	git  remote add -f luci-app-dockerman https://github.com/lisaac/luci-app-dockerman
	git checkout  remotes/luci-app-dockerman/master -b lisaac-luci-app-dockerman
	git checkout openwrt-21.02
	git subtree add --prefix=package/lean/luci-app-dockerman lisaac-luci-app-dockerman


	echo "add lisaac's  luci-lib-docker"
	rm -rf ${OPENWRT_ROOT}/package/lean/luci-lib-docker
	git add package/lean/luci-lib-docker
	git commit -m "remove lean's luci-lib-docker"
	git  remote add -f luci-lib-docker https://github.com/lisaac/luci-lib-docker
	git checkout  remotes/luci-lib-docker/master -b community-luci-lib-docker
	git checkout openwrt-21.02
	git subtree add --prefix=package/lean/luci-lib-docker community-luci-lib-docker


	echo "add gztingting's luci-app-fileassistant"
	git  remote add -f luci-lib-docker https://github.com/lisaac/luci-lib-docker
	git  remote add -f luci-app-fileassistant https://github.com/gztingting/luci-app-fileassistant-test
	git checkout  remotes/luci-app-fileassistant/master -b community-luci-app-fileassistant
	git checkout openwrt-21.02
	git subtree add --prefix=package/lean/luci-app-fileassistant community-luci-app-fileassistant


	echo "modify feeds.conf.default"
	delete_line  "${OPENWRT_ROOT}/feeds.conf.default"   "src-git luci https://git.openwrt.org/project/luci.git;openwrt-21.02"
	echo -e "src-git luci https://github.com/coolsnowwolf/luci" >> ${OPENWRT_ROOT}/feeds.conf.default
	git add feeds.conf.default
	git commit -m "feeds: use coolsnowwolf's luci default"

	echo -e "src-git infinityfreedom https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git" >> ${OPENWRT_ROOT}/feeds.conf.default
	git add feeds.conf.default
	git commit -m "feeds: use infinityfreedom's luci theme"
	
	echo "add latest lan78xx driver"
	cp ../atches/961-drivers-net-lan78xx-dervers-update-to-lan78xx.napi20.patch  $OPENWRT_ROOT/target/linux/bcm27xx/patches-5.4/
	git add target/linux/bcm27xx/patches-5.4/961-drivers-net-lan78xx-dervers-update-to-lan78xx.napi20.patch
	git commit -m "add latest lan78xx driver patches"

	echo  "enable lan78xx and usb net drivers"
	echo -e "CONFIG_USB_LAN78XX=y\nCONFIG_USB_NET_DRIVERS=y" >> $OPENWRT_ROOT/target/linux/bcm27xx/bcm2711/config-5.4
	git add target/linux/bcm27xx/bcm2711/config-5.4
	git commit -m "enable lan78xx and usb net drivers"

	echo  "enable cm4 wifi"
	sed -i 's/36/44/g;s/VHT80/VHT20/g' $OPENWRT_ROOT/package/kernel/mac80211/files/lib/wifi/mac80211.sh
	sed -i 's/disabled=1/disabled=0/g' $OPENWRT_ROOT/package/kernel/mac80211/files/lib/wifi/mac80211.sh
	git add package/kernel/mac80211/files/lib/wifi/mac80211.sh
	git commit -m "enable cm4 wifi default"


	#mage build: fix opkg install step for large package selection 
	git cherry-pick 1854aeec4d37079690309dec3171d0864339f73a 

}

