#!/bin/bash

. scripts/file-editor.sh

echo "download code ..."
WORKSPACE_ROOT=`pwd`
OPENWRT_MAINLINE="https://github.com/openwrt/openwrt"
LEAN_PACKAGE="https://github.com/coolsnowwolf/lede"
git clone ${OPENWRT_MAINLINE} openwrt
cd openwrt
OPENWRT_ROOT=`pwd`
git remote add -f lean ${LEAN_PACKAGE}
git checkout remotes/lean/master -b lean-master

echo "merge lede/package/lean to openwrt/package/lean"
git subtree split -P package/lean/ -b lean-package 
git checkout remotes/origin/openwrt-21.02 -b openwrt-21.02
git subtree add --prefix=package/lean lean-package 

echo "merge lede/tools/ucl to openwrt/tools/ucl"
git checkout lean-master
git subtree split -P tools/ucl -b openwrt-tools-ucl 
git checkout openwrt-21.02
git subtree add --prefix=tools/ucl openwrt-tools-ucl 

echo "merge lede/tools/upx to openwrt/tools/upx"
git checkout lean-master
git subtree split -P tools/upx -b openwrt-tools-upx
git checkout openwrt-21.02
git subtree add --prefix=tools/upx openwrt-tools-upx 

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
git  remote add -f luci-lib-docker https://github.com/lisaac/luci-lib-docker
git checkout  remotes/luci-lib-docker/master -b lisaac-luci-lib-docker
git checkout openwrt-21.02
git subtree add --prefix=package/lean/luci-lib-docker lisaac-luci-lib-docker


echo "modify feeds.conf.default"
delete_line  "${OPENWRT_ROOT}/feeds.conf.default"   "src-git luci https://git.openwrt.org/project/luci.git;openwrt-21.02"
echo -e "src-git luci https://github.com/coolsnowwolf/luci" >> ${OPENWRT_ROOT}/feeds.conf.default
git add feeds.conf.default
git commit -m "feeds: use coolsnowwolf's luci default"

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
#ln -s  /home/baozhu/storage/openwrt/dl/ .
#ln -s  ${WORKSPACE_ROOT}/files  .
#ln -s  ${WORKSPACE_ROOT}/build_dir  .
#ln -s  ${WORKSPACE_ROOT}/staging_dir  .


./scripts/feeds update -a
./scripts/feeds install -a

#cp ${WORKSPACE_ROOT}/configs/rpi_cm4_defconfig .config
cp ${WORKSPACE_ROOT}/$OPENWRT_CONFIG_FILE .config
make defconfig
make download -j8
echo -e "$(nproc) thread compile"

make tools/upx/compile -j$(nproc) || make tools/upx/compile V=s
make tools/compile -j$(nproc) || make tools/compile -j1 V=s
make toolchain/compile -j$(nproc) || make toolchain/compile -j1 V=s
make target/compile -j$(nproc) || make target/compile -j1 V=s IGNORE_ERRORS=1
make -j $(nproc) || make V=s


