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
############################################################################

# be strict on failures
set -e

# colored (optional) output
PRINT(){
    MSG="$2"
    case $1 in
	ERROR)
	    echo -e "\e[0;31mERROR: ${MSG}\e[0m" ;;
	INFO)
	    echo -e "\e[1;34mINFO: ${MSG}\e[0m" ;;
	OK)
	    echo -e "\e[0;32mOK: ${MSG}\e[0m" ;;
	*)
	    echo -e "${MSG}" ;;
    esac
}

# trap and print errors
_fetchError(){
    local cnt=1
    local last_status="$1"
    local error_line_number="$2"
    local last_func="$3"
    local file="$4"
    echo -e "\n\e[0;31mbash stack trace (first occurence is likely where you should look at):\e[0m\n"
    if [ ! -z "$last_func" ] && [ ! -z "$file" ];then
	PRINT ERROR "$file -> function: ${last_func}() ended with status >${last_status}< at line >$((error_line_number -1))< of that function"
    else
	PRINT ERROR "last command ended with status >${last_status}< at line >$((error_line_number -1))<"
    fi
    trap - EXIT ERR
}; export -f _fetchError

# ERR: needed to fetch aborts when set -e is set
trap 'ret=$?; _fetchError $ret $LINENO $FUNCNAME $BASH_SOURCE' EXIT ERR
#SIGINT SIGHUP TERM

######################
# parse through all supported makefile options and set them as env variable
# vendorsetup.sh will always take precedence though

MKOPTS="ENABLE_EXTENDROM \
	EXTENDROM_SIGNING_PATCHES \
	EXTENDROM_PACKAGES \
	EXTENDROM_PACKAGES_SKIP_DL \
	EXTENDROM_BOOT_DEBUG \
	EXTENDROM_DEBUG_PATH \
	EXTENDROM_DEBUG_PATH_SIZE_FULL \
	EXTENDROM_DEBUG_PATH_SIZE_CRASH \
	EXTENDROM_DEBUG_PATH_SIZE_KERNEL \
	EXTENDROM_DEBUG_PATH_SIZE_SELINUX \
	EXTENDROM_PREROOT_BOOT \
	EXTENDROM_FDROID_REPOS \
	EXTENDROM_SIGNATURE_SPOOFING \
	EXTENDROM_PATCHER_RESET \
	EXTENDROM_SIGSPOOF_FORCE_PDIR"

for opt in $MKOPTS; do
    [ -z "${!opt}" ] && export ${opt}="$(build/soong/soong_ui.bash --dumpvar-mode $opt 2>/dev/null)" && [ ! -z "${!opt}" ] && echo ".. setting $opt=${!opt} by makefile"
done

# check first if we want extendrom at all
if [ "$ENABLE_EXTENDROM" != "true" ];then echo "extendrom is disabled so no further processing" && exit;fi
echo -e "\n\n************************************************** STARTING EXTENDROM **************************************************\n\n"

####################
# base info

echo "extendrom version: $(repo forall vendor/extendrom -c 'git rev-parse --symbolic-full-name HEAD; git rev-parse --short=7 HEAD' 2>/dev/null | tr '\n' ' ')"
echo -e "\n\n"
echo "ENABLE_EXTENDROM: $ENABLE_EXTENDROM"
echo "EXTENDROM_PREROOT_BOOT: $EXTENDROM_PREROOT_BOOT"
echo "EXTENDROM_PACKAGES: $EXTENDROM_PACKAGES"
echo "EOS_EDITION: $EOS_EDITION"
echo "EXTENDROM_SIGNING_PATCHES: $EXTENDROM_SIGNING_PATCHES"
echo "EXTENDROM_SIGNATURE_SPOOFING: $EXTENDROM_SIGNATURE_SPOOFING"
echo "EXTENDROM_SIGSPOOF_RESET: $EXTENDROM_SIGSPOOF_RESET"
echo "EXTENDROM_SIGSPOOF_FORCE_PDIR: $EXTENDROM_SIGSPOOF_FORCE_PDIR"
export EXTENDROM_TARGET_VERSION=$(build/soong/soong_ui.bash --dumpvar-mode PLATFORM_VERSION  2>/dev/null)
echo "EXTENDROM_TARGET_VERSION: $EXTENDROM_TARGET_VERSION"
EXTENDROM_TARGET_PRODUCT_F=$(build/soong/soong_ui.bash --dumpvar-mode TARGET_PRODUCT  2>/dev/null)
export EXTENDROM_TARGET_PRODUCT=${EXTENDROM_TARGET_PRODUCT_F/_*}
echo "EXTENDROM_TARGET_PRODUCT: $EXTENDROM_TARGET_PRODUCT"
export SRC_TOP=$(build/soong/soong_ui.bash --dumpvar-mode TOP  2>/dev/null)
echo "SRC_TOP: ${SRC_TOP}/"
SRC_TOP_FULL=$(pwd)
echo SRC_TOP_FULL: $SRC_TOP_FULL

# boot debug log
export EXTENDROM_PRODUCT_DEVICE=$(build/soong/soong_ui.bash --dumpvar-mode PRODUCT_DEVICE 2>/dev/null)
echo "EXTENDROM_PRODUCT_DEVICE=$EXTENDROM_PRODUCT_DEVICE"
echo "EXTENDROM_BOOT_DEBUG=$EXTENDROM_BOOT_DEBUG"
# set default debug path if unset
[ -z "$EXTENDROM_DEBUG_PATH" ] && export EXTENDROM_DEBUG_PATH=/data/vendor_de
echo "EXTENDROM_DEBUG_PATH=$EXTENDROM_DEBUG_PATH (will be suffixed with /boot_debug)"
# set default file sizes for debug logs
[ -z "$EXTENDROM_DEBUG_PATH_SIZE_FULL" ] && export EXTENDROM_DEBUG_PATH_SIZE_FULL=5000
[ -z "$EXTENDROM_DEBUG_PATH_SIZE_CRASH" ] && export EXTENDROM_DEBUG_PATH_SIZE_CRASH=500
[ -z "$EXTENDROM_DEBUG_PATH_SIZE_KERNEL" ] && export EXTENDROM_DEBUG_PATH_SIZE_KERNEL=500
[ -z "$EXTENDROM_DEBUG_PATH_SIZE_SELINUX" ] && export EXTENDROM_DEBUG_PATH_SIZE_SELINUX=500
echo "EXTENDROM_DEBUG_PATH_SIZE_FULL=$EXTENDROM_DEBUG_PATH_SIZE_FULL KB"
echo "EXTENDROM_DEBUG_PATH_SIZE_CRASH=$EXTENDROM_DEBUG_PATH_SIZE_CRASH KB"
echo "EXTENDROM_DEBUG_PATH_SIZE_KERNEL=$EXTENDROM_DEBUG_PATH_SIZE_KERNEL KB"
echo "EXTENDROM_DEBUG_PATH_SIZE_SELINUX=$EXTENDROM_DEBUG_PATH_SIZE_SELINUX KB"

# main repo used for downloading F-Droid apk's
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

REQ_BINARIES="aapt"

for bin in $REQ_BINARIES;do
    which $bin || (PRINT ERROR "missing required binary: $bin" && false)
done

MY_DIR="$1"
[ -z "$MY_DIR" ] && MY_DIR=vendor/extendrom
echo MY_DIR: $MY_DIR
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

if [ -d "$PREBUILT_DIR" ] && [ "$EXTENDROM_PACKAGES_SKIP_DL" != "true" ]; then
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

    # skip download if the file exists locally and the user wants to
    if [ -s "$pkg_path" ] && [ "$EXTENDROM_PACKAGES_SKIP_DL" == "true" ];then
	echo "[$FUNCNAME] ... skipping $pkg, as EXTENDROM_PACKAGES_SKIP_DL=true and pkg exists"
	return
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
	ERR=0
	echo "$package_name" | grep -q "LATEST" || ERR=1
	if [ $ERR -eq 0 ];then
	    echo "[$FUNCNAME] ... parsing repo to find latest apk file name"
	    old_package_name="$package_name"
	    #echo "PARSEAPK -repourl ${repouri} -apkname $package_name"
	    package_name=$(python3 $PARSEAPK -repourl "${repouri}" -apkname "$package_name")
	    PERR=$?
	    if [ $PERR -eq 0 ];then
	        echo "[$FUNCNAME] ... parsing result: $old_package_name -> $package_name"
	    else
	        echo "[$FUNCNAME] ... ERROR $PERR occured while identifying the latest apk name from ${FDROID_REPO_URL}"
	        exit 3
	    fi
	fi
	local repo="${repouri}/${package_name}"

	should_verify=$(echo ${line} |cut -d "|" -f5)
	download_package "$repo" "$package"
	if [ $? -ne 0 ];then echo "[$FUNCNAME] ERROR occured while downloading, aborted"  && exit 3; fi
        
	if [ "$should_verify" == "true" ];then
	    verify_package "$package"
	fi

	local target_split=$(echo ${line} |cut -d "|" -f4)
        target_pkg="$PREBUILT_DIR/$(target_file $target_split | sed 's/\;.*//')"
        echo "[$FUNCNAME] ... target package: $target_pkg"
        if [ "$package" != "$target_pkg" ];then cp $package $target_pkg; fi
        if [ $? -ne 0 ];then echo "[$FUNCNAME] ERROR occured during copying, aborted"  && exit 3;fi
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
    export EXTENDROM_DEBUG_PATH="${EXTENDROM_DEBUG_PATH}/boot_debug"
    # check conflicts first
    ERR=0
    grep -qr "type boot_debug" ${SRC_TOP}device/ >/dev/null 2>&1|| ERR=1
    if [ $ERR -ne 0 ];then
	rm -rf $MY_DIR/sepolicy/boot_debug && echo "[$FUNCNAME] ... cleaned sepolicy dir"
	mkdir -p $MY_DIR/sepolicy/boot_debug && echo "[$FUNCNAME] ... created sepolicy dir"
	for p in $(find $MY_DIR/config/boot_debug/ $MY_DIR/config/boot_debug/${EXTENDROM_PRODUCT_DEVICE}/ -maxdepth 1 -type f -name '*.sepolicy' 2>/dev/null);do
	    pf=$(basename $p)
	    cp $p $MY_DIR/sepolicy/boot_debug/${pf/\.sepolicy/} && echo "[$FUNCNAME] ... copied sepolicy file: $pf"
	done
	if [ $EXTENDROM_TARGET_VERSION -ge 11 ];then
	    MKDARG="encryption=None"
	else
	    MKDARG=""
	fi
	#sed "s#%%DEBUGLOG_DEVICE%%#$EXTENDROM_DEBUG_DEVICE#g;s#%%DEBUGLOG_PATH%%#$EXTENDROM_DEBUG_PATH#g;s#%%DEBUGLOG_MKDARG%%#$MKDARG#g" $MY_DIR/config/init.er.rc.in > $MY_DIR/config/init.er.rc && echo "[$FUNCNAME] ... configured EXTENDROM_DEBUG_PATH (init.er.rc) to $EXTENDROM_DEBUG_PATH"
	#sed "s#%%DEBUGLOG_PATH%%#$EXTENDROM_DEBUG_PATH#g;s#%%DEBUGLOG_MKDARG%%#$MKDARG#g" $MY_DIR/config/init.er.rc.in > $MY_DIR/config/init.er.rc && echo "[$FUNCNAME] ... configured EXTENDROM_DEBUG_PATH (init.er.rc) to $EXTENDROM_DEBUG_PATH"
	sed "s#%%DEBUGLOG_PATH%%#$EXTENDROM_DEBUG_PATH#g;s#%%DEBUGLOG_MKDARG%%#$MKDARG#g;\
	     s#%%DEBUGLOG_PATH_SIZE_FULL%%#$EXTENDROM_DEBUG_PATH_SIZE_FULL#g;\
	     s#%%DEBUGLOG_PATH_SIZE_CRASH%%#$EXTENDROM_DEBUG_PATH_SIZE_CRASH#g;\
	     s#%%DEBUGLOG_PATH_SIZE_KERNEL%%#$EXTENDROM_DEBUG_PATH_SIZE_KERNEL#g;\
	     s#%%DEBUGLOG_PATH_SIZE_SELINUX%%#$EXTENDROM_DEBUG_PATH_SIZE_SELINUX#g" \
	     $MY_DIR/config/init.er.rc.in > $MY_DIR/config/init.er.rc
	echo "[$FUNCNAME] ... configured EXTENDROM_DEBUG_PATH (init.er.rc) to $EXTENDROM_DEBUG_PATH"
	echo "[$FUNCNAME] ... configured EXTENDROM_DEBUG_PATH_SIZE's (init.er.rc):"
	echo "[$FUNCNAME] ... EXTENDROM_DEBUG_PATH_SIZE_FULL=$EXTENDROM_DEBUG_PATH_SIZE_FULL KB"
	echo "[$FUNCNAME] ... EXTENDROM_DEBUG_PATH_SIZE_CRASH=$EXTENDROM_DEBUG_PATH_SIZE_CRASH KB"
	echo "[$FUNCNAME] ... EXTENDROM_DEBUG_PATH_SIZE_KERNEL=$EXTENDROM_DEBUG_PATH_SIZE_KERNEL KB"
	echo "[$FUNCNAME] ... EXTENDROM_DEBUG_PATH_SIZE_SELINUX=$EXTENDROM_DEBUG_PATH_SIZE_SELINUX KB"

	sed -i "s#%%DEBUGLOG_PATH%%#$EXTENDROM_DEBUG_PATH#g" $MY_DIR/sepolicy/boot_debug/* && echo "[$FUNCNAME] ... configured EXTENDROM_DEBUG_PATH (sepolicies) to $EXTENDROM_DEBUG_PATH"
	echo "[$FUNCNAME] ... enabled and configured EXTENDROM_BOOT_DEBUG"
    else
	echo -e "[$FUNCNAME] ... ERROR: it seems you have legacy code in your device/ path!\nFix this first before enabling EXTENDROM_BOOT_DEBUG"
    fi
}

# signature spoofing patch
F_SIGPATCH(){
    echo "[$FUNCNAME] Signature spoofing patch requested ..."

    PATCHX="/bin/bash $MY_DIR/tools/apply_patches.sh"
    PDIR="$MY_DIR/config/sigspoof/$EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION}"
    [ ! -z "$EXTENDROM_SIGSPOOF_FORCE_PDIR" ] && [ -d "$EXTENDROM_SIGSPOOF_FORCE_PDIR" ] && PDIR=$EXTENDROM_SIGSPOOF_FORCE_PDIR

    $PATCHX $PDIR $EXTENDROM_PATCHER_RESET
    ERR=$?
    echo "[$FUNCNAME] Signature spoofing patching ended with $ERR"
    echo "[$FUNCNAME] adding signature spoof controller"
    cp $PDIR/09-packages-apps-Settings-src-com-android-settings-development-SpoofSignaturePreferenceController.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/SpoofSignaturePreferenceController.java || exit 3
    cp $PDIR/10-packages-apps-Settings-src-com-android-settings-development-SpoofSignatureInfo.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/SpoofSignatureInfo.java || exit 3
    echo "[$FUNCNAME] adding signature spoof controller ended with $?"
    if [ $ERR -eq 0 ];then echo "[$FUNCNAME] finished successfully" && return; else exit 3;fi
}

# signing patches
F_SIGNINGPATCHES(){
    echo "[$FUNCNAME] Signing patches requested ..."
    PATCHX="/bin/bash $MY_DIR/tools/apply_patches.sh"
    PDIR="$MY_DIR/config/signing/$EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION}"
    $PATCHX $PDIR $EXTENDROM_PATCHER_RESET
    ERR=$?
    echo "[$FUNCNAME] addding signing patches ended with $ERR"
    if [ $ERR -eq 0 ];then echo "[$FUNCNAME] finished successfully" && return; else exit 3;fi
}

if [ "$EXTENDROM_SIGNATURE_SPOOFING" == "true" ];then F_SIGPATCH ;fi
if [ "$EXTENDROM_SIGNING_PATCHES" == "true" ];then F_SIGNINGPATCHES ;fi

F_GET_GPG_KEYS
get_packages "$MY_DIR/repo/packages.txt"

if [ ! -z "$EXTENDROM_BOOT_DEBUG" -a  "$EXTENDROM_BOOT_DEBUG" == "true" ];then
    F_BOOT_DEBUG
fi

# clean tmp
find $_OUTDIR -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

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
    echo "[MAGISK] preparing the root process as requested"

    # inject magisk patcher to releasetools
    PATCHX="/bin/bash $MY_DIR/tools/apply_patches.sh"
    PDIR="$MY_DIR/config/magisk/$EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION}"
    echo "[MAGISK] using patch dir: $PDIR"

    $PATCHX $PDIR $EXTENDROM_PATCHER_RESET
    ERR=$?
    echo "[MAGISK] Injecting Magisk patcher ended with $ERR"
    [ "$ERR" -ne 0 ] && exit $ERR

    MAGISKOUT=$(realpath $MY_DIR/../../out/.magisk)
    [ -d "$MAGISKOUT" ] && rm -rf $MAGISKOUT
    mkdir -p $MAGISKOUT
    [ -z $MAGISK_TARGET_ARCH ] && MAGISK_TARGET_ARCH=arm64

    MAGNAME=$(echo "$EXTENDROM_PACKAGES" | tr ' ' '\n' | grep -E '^Magisk$|Magisk_v[0-9]+\.[0-9]+$|SignMagisk$')

    if [ ! -f $MY_DIR/prebuilt/${MAGNAME}.apk ];then
	echo "[MAGISK] ERROR: apk cannot be found! Keep in mind that extendrom supports v22 and later only!"
	echo "[MAGISK] ERROR: Do you have set 'Magisk' or 'SignMagisk' in your vendorsetup.sh??"
	exit 4
    else
	MAGZIP=$MY_DIR/prebuilt/${MAGNAME}.apk
    fi
    echo "[MAGISK] ... Magisk found!"
    unzip -q $MAGZIP -d $MAGISKOUT/src

    cp $MAGISKOUT/src/lib/x86/libmagiskboot.so $MAGISKOUT/magiskboot
    chmod 755 $MAGISKOUT/magiskboot
    echo "[MAGISK] ... MAGISK_TARGET_ARCH specified as $MAGISK_TARGET_ARCH"

    cp $MAGISKOUT/src/lib/armeabi-v7a/libmagisk32.so $MAGISKOUT/magisk32
    if [ $MAGISK_TARGET_ARCH == "arm64" ];then
	cp $MAGISKOUT/src/lib/arm64-v8a/libmagisk64.so $MAGISKOUT/magisk64
	cp $MAGISKOUT/src/lib/arm64-v8a/libmagiskinit.so $MAGISKOUT/magiskinit
    else
	cp $MAGISKOUT/src/lib/armeabi-v7a/libmagiskinit.so $MAGISKOUT/magiskinit
    fi
    chmod 755 $MAGISKOUT/src/assets/boot_patch.sh
    rm -rf $MAGISKOUT/src/assets/dexopt $MAGISKOUT/src/assets/chromeos
    cp $MAGISKOUT/src/assets/* $MAGISKOUT/
    # keep backwards compability
    cp $MAGISKOUT/src/assets/boot_patch.sh $MAGISKOUT/root_boot.sh

    # remove Magisk from Android mk list - as we do not build/add the Magisk app
    # see https://github.com/sfX-android/android_vendor_extendrom/wiki/FAQ#extendrom_preroot_boot
    export EXTENDROM_PACKAGES=$(echo "$EXTENDROM_PACKAGES" | sed "s/$MAGNAME//g")
    echo -e "[MAGISK] removed >$MAGNAME< from Android makefile:\nEXTENDROM_PACKAGES is now: $EXTENDROM_PACKAGES"
    echo "[MAGISK] preparing root finished"
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

    echo "[$FUNCNAME] constructing additional_repos.xml"
    cat > $_OUTDIR/_additional_repos.xml <<_EOFF
<?xml version="1.0" encoding="utf-8"?>
<resources>
_EOFF
    cat $FDROID_REPO_DIR/additional_repos.xml >> $_OUTDIR/_additional_repos.xml

    if [ ! -z "$EXTENDROM_FDROID_REPOS" ];then
	for repo in $EXTENDROM_FDROID_REPOS;do
	    if [ ! -f "$FDROID_REPO_DIR/$repo" ];then echo "[$FUNCNAME] ERROR: missing $FDROID_REPO_DIR/$repo" && exit 4;fi
     	    cat $FDROID_REPO_DIR/$repo >> $_OUTDIR/_additional_repos.xml && echo "[$FUNCNAME] ... added $repo to additional_repos.xml"
	done
 	echo '</resources>' >> $_OUTDIR/_additional_repos.xml
    fi
    echo "[$FUNCNAME] constructing additional_repos.xml completed"
}

echo "[main] Writing makefiles (if needed)"
F_WRITE_MAKEFILE "$MY_DIR/repo/packages.txt"
if [[ "$EXTENDROM_PACKAGES" =~ "additional_repos.xml" ]];then F_WRITE_MAKEFILE_FDROID; fi
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
    if [ -f "$TBTESTMK" ];then rm $TBTESTMK;fi
    # remove duplicated iconloaderlib causing build errors
    if [ -d "$ICOLIB" ];then rm -rf $ICOLIB;fi
    # remove legacy recents activated in /e/
    if [ -f "$LOSMK" ];then sed -E -i '/SystemUIWithLegacyRecents\s+\\/d' $LOSMK;fi
fi

trap - EXIT ERR
echo -e "\n\n************************************************** EXTENDROM FINISHED **************************************************\n\n"
