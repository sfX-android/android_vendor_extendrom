#!/bin/bash
############################################################################
#
# Copyright (C) 2017-2018 Andreas Schneider <asn@crytpomilk.org>
# Copyright (C) 2020-2023 steadfasterX <steadfasterX@binbash.rocks>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

####################
# base info
echo "ENABLE_EXTENDROM: $ENABLE_EXTENDROM"
echo "EXTENDROM_PACKAGES: $EXTENDROM_PACKAGES"
echo "EOS_EDITION: $EOS_EDITION"
export EXTENDROM_TARGET_VERSION=$(build/soong/soong_ui.bash --dumpvar-mode PLATFORM_VERSION)
echo "EXTENDROM_TARGET_VERSION: $EXTENDROM_TARGET_VERSION"

FDROID_REPO_URL="https://mirror.cyberbits.eu/fdroid/repo/"

# list of keyservers for importing gpg pub keys
# space separated
GPG_KEYSERVER="keyserver.ubuntu.com pgp.mit.edu keys.openpgp.org keyring.debian.org"

# gpg keys to import
# space separated
# f-droid:     7A029E54DD5DCE7A
# microg:      22F796D6E62E6625A0BCEFEA7F979A66F3E08422
GPG_KEYS="7A029E54DD5DCE7A 22F796D6E62E6625A0BCEFEA7F979A66F3E08422"

# force a gpg pub key refresh
# 0: will only download pub key when not installed
# 1: will always download pub key even when installed already
GPG_FORCE_DL=0

###########################################################

MY_DIR="$1"
[ -z "$MY_DIR" ] && MY_DIR=${0%/*}
_OUTDIR="$MY_DIR/out"
[ ! -d "$_OUTDIR" ] && mkdir $_OUTDIR
FDROID_REPO_DIR="$MY_DIR/fdroid_repos"

unset CURLDNS
CUSTDNS="$2"
[ ! -z "$CUSTDNS" ] && CURLDNS="--dns-servers $CUSTDNS"

PREBUILT_DIR="$MY_DIR/prebuilt"
PARSEAPK="$MY_DIR/tools/get_latest_apkname.py"

CURLARGS=" -L $CURLDNS"
CURL="$MY_DIR/tools/curl_x64_static $CURLARGS"
source $MY_DIR/tools/extract_utils.sh

if [ -d "$PREBUILT_DIR" ]; then
    rm -rf "$PREBUILT_DIR"
fi
mkdir $PREBUILT_DIR $PREBUILT_DIR/app $PREBUILT_DIR/priv-app

function download_package() {
    local repo="$1"
    local pkg_path="$2"
    local pkg_dir=$(dirname $pkg_path)
    local pkg="$(basename $pkg_path)"
    local pkg_sig="$pkg.asc"
    local cmd=""
    local out=""
    local ret=0

    if [ ! -d "$pkg_dir" ]; then
        mkdir -p "$pkg_dir"
    fi

    echo "[$FUNCNAME] ... downloading package: $pkg"
    cmd=$($CURL --fail -o $pkg_path $repo 2>&1)
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "[$FUNCNAME] ERROR: Failed to download $pkg (returned: $ret)"
        echo
	echo "$CURL --fail -o $pkg_path $repo"
        echo "$cmd"
        return $ret
    fi

    if [ "$should_verify" == "true" ];then
       echo "[$FUNCNAME] ... downloading signature: ${repo}.asc"
       cmd="$CURL -o $pkg_dir/$pkg_sig ${repo}.asc 2>&1"
       out=$(eval $cmd)
       ret=$?
       if [ $ret -ne 0 ]; then
           echo "[$FUNCNAME] ERROR: Failed to download $repo/$pkg_sig (returned: $ret)"
           echo
           echo "$out"
           return $ret
       fi
    fi
}

function verify_package() {
    local pkg_path="$1"
    local cmd=""
    local out=""
    local ret=0

    echo -n "[$FUNCNAME] ... verifing package signature for $pkg_path: "
    cmd="gpg --verify $pkg_path.asc 2>&1"
    out=$(eval $cmd)
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "INVALID"
        echo
        echo "$out"
        exit 1
    fi
    echo "VALID"
}

function get_packages() {
    local package_file_list="$1"

    for line in $(grep -v '^#' $package_file_list); do
        if [ -z "$line" ]; then
            continue;
        fi
	unset repo

        local package_name=$(echo ${line} |cut -d "|" -f1)

        local package_baseuri=$(echo ${line} |cut -d "|" -f2)
	if [ "$package_baseuri" == "FDROIDREPO" ];then
	    local repouri="${FDROID_REPO_URL}"
	else
	    local repouri="${package_baseuri}"
	fi

        local package="$PREBUILT_DIR/$package_name"
       local target_split=$(echo ${line} |cut -d "|" -f4)
        target_pkg="$PREBUILT_DIR/$(target_file $target_split | sed 's/\;.*//')"
       local package_human=$(echo $(target_file $target_split | sed 's/\;.*//;s/\.apk//g;s/\.zip//g'))

       # do not download what we do not want to build
       if [[ ! "$EXTENDROM_PACKAGES" =~ "$package_human" ]];then
           echo "[$FUNCNAME] ... skipping $package_human as not requested by EXTENDROM_PACKAGES"
           continue
	else
	    for i in $EXTENDROM_PACKAGES; do
		if [ "$i" != "$package_human" ];then
		    EXACTM=0
		else
		    EXACTM=1
		    break
		fi
	    done
	    if [ "$EXACTM" -ne 1 ];then
		echo "[$FUNCNAME] ... skipping $package_human as not requested by EXTENDROM_PACKAGES"
		continue
	    fi
       fi

	echo "$package_name" | grep -q "LATEST"
	if [ $? -eq 0 ];then
	    echo "[$FUNCNAME] ... parsing repo to find latest apk file name"
	    old_package_name="$package_name"
	    echo "PARSEAPK -repourl ${repouri} -apkname $package_name"
	    package_name=$(python3 $PARSEAPK -repourl "${repouri}" -apkname "$package_name")
	    PERR=$?
	    if [ $PERR -eq 0 ];then
	        echo "[$FUNCNAME] ... parsing result: $old_package_name -> $package_name"
	    else
	        echo "[$FUNCNAME] ... ERROR $PERR occured while identifying the latest apk name from ${FDROID_REPO_URL}"
	        exit 3
	    fi
	    local repo="${repouri}/${package_name}"
	else
	    local repo="$package_baseuri/${package_name}"
	fi

       should_verify=$(echo ${line} |cut -d "|" -f5)
       download_package "$repo" "$package"
       [ $? -ne 0 ] && echo "[$FUNCNAME] ERROR occured while downloading, aborted"  && exit 3
        
	if [ "$should_verify" == "true" ];then
	    verify_package "$package"
	fi

	local target_split=$(echo ${line} |cut -d "|" -f4)
        target_pkg="$PREBUILT_DIR/$(target_file $target_split | sed 's/\;.*//')"
        echo "[$FUNCNAME] ... target package: $target_pkg"
        cp $package $target_pkg
       [ $? -ne 0 ] && echo "[$FUNCNAME] ERROR occured during copying, aborted"  && exit 3
        echo
    done
}

F_GET_GPG_KEYS(){
    # import all required gpg pub keys
    for k in $GPG_KEYS;do
       if [ $GPG_FORCE_DL -eq 0 ];then
           gpg -k $k 2>&1 >> /dev/null && echo "[$FUNCNAME] ... skipping already imported gpg pub key ($k)" && continue
       fi
       for s in $GPG_KEYSERVER;do
           echo "- trying $k from $s"
           gpg --keyserver $s --recv-key $k >> /dev/null 2>&1 && echo "[$FUNCNAME] ... imported gpg key $k from $s" && continue 2
       done
       echo "[$FUNCNAME] ERROR: Cannot download a required gpg pub key: $k"
       exit 3
    done
}

# the ultimate boot debugger
F_BOOT_DEBUG(){
    rm -rf $MY_DIR/sepolicy/boot_debug && echo "[$FUNCNAME] ... cleaned sepolicy dir"
    mkdir -p $MY_DIR/sepolicy/boot_debug && echo "[$FUNCNAME] ... created sepolicy dir"
    for p in $(find $MY_DIR/config/boot_debug/ -type f -name '*.sepolicy');do
	pf=$(basename $p)
	cp $p $MY_DIR/sepolicy/boot_debug/${pf/\.sepolicy/} && echo "[$FUNCNAME] ... copied sepolicy file: $pf"
    done
    if [ $EXTENDROM_TARGET_VERSION -ge 11 ];then
	MKDARG="encryption=None"
    else
	MKDARG=""
    fi
    sed "s#%%DEBUGLOG_PATH%%#$EXTENDROM_DEBUG_PATH#g;s#%%DEBUGLOG_MKDARG%%#$MKDARG#g" $MY_DIR/config/init.er.rc.in > $MY_DIR/config/init.er.rc && echo "[$FUNCNAME] ... configured EXTENDROM_DEBUG_PATH (init.er.rc) to $EXTENDROM_DEBUG_PATH"
    sed -i "s#%%DEBUGLOG_PATH%%#$EXTENDROM_DEBUG_PATH#g" $MY_DIR/sepolicy/boot_debug/* && echo "[$FUNCNAME] ... configured EXTENDROM_DEBUG_PATH (sepolicies) to $EXTENDROM_DEBUG_PATH"
    echo "[$FUNCNAME] ... enabled and configured EXTENDROM_BOOT_DEBUG"
}

F_GET_GPG_KEYS
get_packages "$MY_DIR/repo/packages.txt"

if [ ! -z "$EXTENDROM_BOOT_DEBUG" -a  "$EXTENDROM_BOOT_DEBUG" == "true" ];then
    if [ -z "$EXTENDROM_DEBUG_PATH" ];then
	cat << _EOH

ERROR: You have specified EXTENDROM_BOOT_DEBUG=$EXTENDROM_BOOT_DEBUG but >EXTENDROM_DEBUG_PATH< is empty!

    If you are NOT using encryption (FBE or FDE) you can basically choose any path you wish for EXTENDROM_DEBUG_PATH.
    When you are trying to debug encrypted devices though you might have to choose a proper path so you can access
    it later when boot fails.

    Depending on which Android version you build on there are several options to set EXTENDROM_DEBUG_PATH on encrypted devices:

    Android 9 and lower hard coded encryption exceptions here:
     -> https://cs.android.com/android/platform/superproject/+/android-9.0.0_r34:system/extras/ext4_utils/ext4_crypt_init_extensions.cpp;l=85-94
	e.g. /data/data, /data/user etc

    Android 10 hard coded encryption exceptions here:
     -> https://cs.android.com/android/platform/superproject/+/android-10.0.0_r18:system/extras/libfscrypt/fscrypt_init_extensions.cpp;l=83-95
	e.g. /data/data, /data/user etc

    since Android 11 this can be handled directly within init and the mkdir command (encryption=None)
    that means you can basically use any path which is writable at boot time.
    While you are free to choose any it is recommended setting EXTENDROM_DEBUG_PATH=/data/debug for A11 and later.
    extendrom will ensure that EXTENDROM_DEBUG_PATH will NOT get encrypted so you can access it via recovery.


    Hint: using /cache/xxx MIGHT be an alternative as well - while this does not work on all devices.
    Even if this works in general /cache might be limited in disk space and also can cause other issues.

_EOH
	exit 4
    fi
    F_BOOT_DEBUG
fi

INITIAL_COPYRIGHT_YEAR=2021
VENDOR="extendrom"
ANDROIDMK="$MY_DIR/Android.mk"

DEVICE="true"
write_headers "" ENABLE_EXTENDROM
DEVICE=

# special handling for locked bootloaders
if [ "$EXTENDROM_SIGN_ALL_APKS" == "true" ];then
    sed -i 's#PRESIGNED#user-keys/shared#g' $MY_DIR/repo/packages.txt
fi

# MAGISK rooting preparation
if [ "$EXTENDROM_PREROOT_BOOT" == "true" ];then
    echo
    MAGISKOUT=$(realpath $MY_DIR/../../out/.magisk)
    [ -z $MAGISK_TARGET_ARCH ] && MAGISK_TARGET_ARCH=arm64

    [ -d "$MAGISKOUT" ] && rm -rf $MAGISKOUT
    mkdir -p $MAGISKOUT
    if [ ! -f $MY_DIR/prebuilt/Magisk.zip ];then
	if [ ! -f $MY_DIR/prebuilt/SignMagisk.zip ];then
	    echo "[main] MAGISK zip cannot be found! Do you have set 'Magisk' or 'SignMagisk' in your vendorsetup.sh??" && exit 4
	else
	    MAGZIP=$MY_DIR/prebuilt/SignMagisk.zip
	fi
    else
	MAGZIP=$MY_DIR/prebuilt/Magisk.zip
    fi
    unzip -q $MAGZIP -d $MAGISKOUT/src

    cp $MAGISKOUT/src/lib/x86/libmagiskboot.so $MAGISKOUT/magiskboot
    chmod 755 $MAGISKOUT/magiskboot
    echo "[main] MAGISK_TARGET_ARCH specified as $MAGISK_TARGET_ARCH"

    cp $MAGISKOUT/src/lib/armeabi-v7a/libmagisk32.so $MAGISKOUT/magisk32
    if [ $MAGISK_TARGET_ARCH == "arm64" ];then
	cp $MAGISKOUT/src/lib/arm64-v8a/libmagisk64.so $MAGISKOUT/magisk64
	cp $MAGISKOUT/src/lib/arm64-v8a/libmagiskinit.so $MAGISKOUT/magiskinit
    else
	cp $MAGISKOUT/src/lib/armeabi-v7a/libmagiskinit.so $MAGISKOUT/magiskinit
    fi
    cp $MY_DIR/root/* $MAGISKOUT/
    chmod 755 $MAGISKOUT/src/assets/boot_patch.sh
    cp $MAGISKOUT/src/assets/boot_patch.sh $MAGISKOUT/
    # keep backwards compability
    cp $MAGISKOUT/src/assets/boot_patch.sh $MAGISKOUT/root_boot.sh
fi

# write specific F-Droid module
F_WRITE_MAKEFILE_FDROID(){
    echo "[$FUNCNAME] writing additional_repos.xml makefile"
    cat >> $ANDROIDMK << _EOFFD
# additional F-Droid repos
include \$(CLEAR_VARS)
LOCAL_MODULE := additional_repos.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := \$(TARGET_OUT_VENDOR_ETC)/org.fdroid.fdroid
LOCAL_SRC_FILES := out/_additional_repos.xml
include \$(BUILD_PREBUILT)
_EOFFD

    echo "[$FUNCNAME] copying additional_repos.xml"
    cp $FDROID_REPO_DIR/additional_repos.xml $_OUTDIR/_additional_repos.xml

    if [ ! -z "$EXTENDROM_FDROID_REPOS" ];then
	for repo in $EXTENDROM_FDROID_REPOS;do
	    [ ! -f "$FDROID_REPO_DIR/$repo" ] && echo "[$FUNCNAME] ERROR: missing $FDROID_REPO_DIR/$repo" && exit 4
	    grep -v 'xml version=' $FDROID_REPO_DIR/$repo >> $_OUTDIR/_additional_repos.xml && echo "[$FUNCNAME] ... added $repo to additional_repos.xml"
	done
    fi
}

echo
echo "[main] Writing makefiles (if needed)"
echo
F_WRITE_MAKEFILE "$MY_DIR/repo/packages.txt"
[[ "$EXTENDROM_PACKAGES" =~ "additional_repos.xml" ]] && F_WRITE_MAKEFILE_FDROID
cat >> $ANDROIDMK <<EOMK

# include additional static configs
include $MY_DIR/extra/Android.mk

EOMK
write_footers

# special handling for /e/ OS gestures support
if [ "$EOS_GESTURES" == "true" ];then
    TBMK="packages/apps/Trebuchet/Android.mk"
    TBTESTMK="packages/apps/Trebuchet/tests/Android.mk"
    ICOLIB="packages/apps/iconloaderlib"
    LOSMK="vendor/lineage/config/common.mk"
    if [ -f $TBMK ];then
       sed -i 's/LOCAL_PACKAGE_NAME := TrebuchetQuickStep$/LOCAL_PACKAGE_NAME := eOSTrebuchetQuickStep/g' $TBMK
    else
       echo -e "\n*** ERROR ***\n/e/ OS gesture support is enabled (EOS_GESTURES=true) but a required file is missing:\n\n\t>${TBMK}<\n\nCheck if your local manifest contains the source for 'TrebuchetQuickStep'!"
       echo -e "For testing purposes you can clone it manually like this \n\ngit clone https://github.com/LineageOS/android_packages_apps_Trebuchet.git packages/apps/Trebuchet -b lineage-<version>\n"
       exit 3
    fi
    # remove duplicated tests causing build errors
    [ -f "$TBTESTMK" ] && rm $TBTESTMK
    # remove duplicated iconloaderlib causing build errors
    [ -d "$ICOLIB" ] && rm -rf $ICOLIB
    # remove legacy recents activated in /e/
    [ -f "$LOSMK" ] && sed -E -i '/SystemUIWithLegacyRecents\s+\\/d' $LOSMK
fi
