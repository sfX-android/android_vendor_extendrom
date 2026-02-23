#!/bin/bash
############################################################################
#
# Copyright (C) 2017-2018 Andreas Schneider <asn@crytpomilk.org>
# Copyright (C) 2020-2026 steadfasterX <steadfasterX |AT| binbash #DOT# rocks>
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
	EXTENDROM_SIGNING_FORCE_PDIR \
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
        EXTENDROM_ALLOW_ANY_CALL_RECORDING \
	EXTENDROM_INTERCEPT_INSTALLSRC \
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
echo "MAGISK_TARGET_ARCH: $MAGISK_TARGET_ARCH"
export ER_TARGET_ARCH=$(build/soong/soong_ui.bash --dumpvar-mode TARGET_ARCH  2>/dev/null)
echo "ER_TARGET_ARCH: $ER_TARGET_ARCH"
echo "EXTENDROM_PACKAGES: $EXTENDROM_PACKAGES"
echo "EOS_EDITION: $EOS_EDITION"
echo "EXTENDROM_SIGNING_PATCHES: $EXTENDROM_SIGNING_PATCHES"
echo "EXTENDROM_SIGNING_FORCE_PDIR: $EXTENDROM_SIGNING_FORCE_PDIR"
echo "EXTENDROM_ALLOW_ANY_CALL_RECORDING: $EXTENDROM_ALLOW_ANY_CALL_RECORDING"
echo "EXTENDROM_SIGNATURE_SPOOFING: $EXTENDROM_SIGNATURE_SPOOFING"
echo "EXTENDROM_SIGSPOOF_RESET: $EXTENDROM_SIGSPOOF_RESET"
echo "EXTENDROM_SIGSPOOF_FORCE_PDIR: $EXTENDROM_SIGSPOOF_FORCE_PDIR"
echo "EXTENDROM_INTERCEPT_INSTALLSRC: $EXTENDROM_INTERCEPT_INSTALLSRC"

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
if [ "$EXTENDROM_TARGET_VERSION" -ge 11 ];then
    export EXTENDROM_DEBUG_LOGCAT_PATH=/system_ext
else
    export EXTENDROM_DEBUG_LOGCAT_PATH=/system
fi
echo "EXTENDROM_DEBUG_LOGCAT_PATH: $EXTENDROM_DEBUG_LOGCAT_PATH"
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
# the mirror monitor repo README (as it gets updates with most active ones)
FDROID_MIRRORMON="https://gitlab.com/fdroid/mirror-monitor/-/raw/master/README.md?ref_type=heads"

# list of keyservers for importing gpg pub keys
# space separated
GPG_KEYSERVER="hkps://keys.openpgp.org hkp://keys.openpgp.org:80 hkps://keyserver.ubuntu.com hkp://keyserver.ubuntu.com:80 hkps://pgp.mit.edu hkp://pgp.mit.edu:80"

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

# write $PRODUCTMK so all EXTENDROM_PACKAGES (except Magisk) will be built by the Android build process
export PRODUCTMK="$MY_DIR/packages.mk"

# write mk vars
export ERMKVARS="ENABLE_EXTENDROM EXTENDROM_BOOT_DEBUG EXTENDROM_PREROOT_BOOT EXTENDROM_SIGNATURE_SPOOFING
"
> $MY_DIR/mkvars.mk
for ermk in $ERMKVARS;do
    echo "$ermk := ${!ermk}" >> $MY_DIR/mkvars.mk
done

# prepare to remove Magisk from EXTENDROM_PACKAGES as we don't build it
# see https://github.com/sfX-android/android_vendor_extendrom/wiki/FAQ#extendrom_preroot_boot
if [ "$EXTENDROM_PREROOT_BOOT" == "true" ];then
    export MAGNAME=$(echo "$EXTENDROM_PACKAGES" | tr ' ' '\n' | grep -E '^Magisk$|Magisk_v[0-9]+(\.[0-9])*$|SignMagisk$')
    export EXTENDROM_PACKAGES_CLEANED=$(echo "$EXTENDROM_PACKAGES" | tr ' ' '\n' | sed "s/$MAGNAME//g" | tr '\n' ' ')
    echo "PRODUCT_PACKAGES += $EXTENDROM_PACKAGES_CLEANED" > $PRODUCTMK
else
    echo "PRODUCT_PACKAGES += $EXTENDROM_PACKAGES" > $PRODUCTMK
fi

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
else
    mkdir -p $PREBUILT_DIR/app $PREBUILT_DIR/priv-app
fi

F_GIT_COMMIT(){
    local git_path="$1"
    local git_msg="$2"
    local cur_path="$(pwd)"
    if [ -z "$git_path" -o -z "$git_msg" ];then
    	echo "ERROR: missing git_path($git_path) or git_msg ($git_msg)"
	exit 4
    fi
    cd $git_path
    git add -A
    git commit -m "$(echo -e \"$git_msg\")"
    cd $cur_path
}
export -f F_GIT_COMMIT

F_GET_FDROID_MIRRORS(){
    curl -s "$FDROID_MIRRORMON" | grep -E '^\*\s+http' |grep -v onion |cut -d ' ' -f2 | tail -n 3
}

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
            isfdroid=1
	else
	    local repouri="${package_baseuri}"
            isfdroid=0
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
	    package_name=$(python3 $PARSEAPK -repourl "${repouri}" -apkname "$package_name" 2>/dev/null)
	    PERR=$?
	    if [ $PERR -eq 0 ];then
	        echo "[$FUNCNAME] ... parsing result: $old_package_name -> $package_name"
	    else
                echo "[$FUNCNAME] ERROR occured while finding latest apk file name for $package, trying mirror(s)!"
		PERR=99
                for m in $(F_GET_FDROID_MIRRORS);do
                    echo "[$FUNCNAME] re-trying from mirror:"
                    echo -e "[$FUNCNAME] ${package/*\//} @ $m"
                    repouri="${m}"
                    repo="${repouri}/${package_name}"
                    package_name=$(python3 $PARSEAPK -repourl "${repouri}" -apkname "$old_package_name")
                    PERR=$?
                    package="$PREBUILT_DIR/$package_name"
                    target_split=$(echo ${line} |cut -d "|" -f4)
                    target_pkg="$PREBUILT_DIR/$(target_file $target_split | sed 's/\;.*//')"
                    package_human=$(echo $(target_file $target_split | sed 's/\;.*//;s/\.apk//g;s/\.zip//g'))
                    if [ $PERR -eq 0 ];then echo -e "[$FUNCNAME] Mirror download: OK!" && break;fi
                done
                if [ $PERR -ne 0 ];then echo "[$FUNCNAME] ERROR: all mirrors tried without success.. Aborted with $PERR!" && exit 3;fi
	    fi
	fi
	local repo="${repouri}/${package_name}"

	should_verify=$(echo ${line} |cut -d "|" -f5)
	DLRESP1=$(download_package "$repo" "$package")
	if [ $? -ne 0 ];then
            echo "[$FUNCNAME] ERROR occured while downloading $package!"
	    DERR=99
            if [ $isfdroid -eq 1 ];then
              for m in $(F_GET_FDROID_MIRRORS);do
                echo "[$FUNCNAME] re-trying from mirror:"
                echo -e "[$FUNCNAME] ${package/*\//} @ $m"
                repouri="${m}"
                repo="${repouri}/${package_name}"
                DLRESP=$(download_package "$repo" "$package" 2>&1)
                DERR=$?
                if [ $DERR -eq 0 ];then echo -e "[$FUNCNAME] Mirror download: OK!" && break;fi
              done
              if [ $DERR -ne 0 ];then echo -e "[$FUNCNAME] ERROR: all mirrors tried without success.. Aborted! Last error ($DERR):\n\n$DLRESP" && exit 3;fi
	    else
              echo -e "[$FUNCNAME] ERROR:\n$DLRESP1"
	      exit 88
            fi
        fi
        
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
           echo "[$FUNCNAME] trying to receive $k from $s"
           gpg --keyserver $s --recv-key $k >> /dev/null 2>&1 && echo "[$FUNCNAME] ... imported gpg key $k from $s" && continue 2
       done
       echo "[$FUNCNAME] ERROR: Cannot download a required gpg pub key: $k"
       exit 3
    done
}

# the ultimate boot debugger
F_BOOT_DEBUG(){
    export EXTENDROM_DEBUG_PATH_ORIGIN="${EXTENDROM_DEBUG_PATH}"
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
        case "${EXTENDROM_DEBUG_PATH_ORIGIN}" in
            "/cache")
                # special handling for dedicated /cache partition
                for p in $(find $MY_DIR/config/boot_debug/cache -maxdepth 1 -type f -name '*.sepolicy' 2>/dev/null);do
                    pf=$(basename $p)
                    cp $p $MY_DIR/sepolicy/boot_debug/${pf/\.sepolicy/} && echo "[$FUNCNAME] ... copied sepolicy file: $pf"
                done
            ;;
            "/persist"|"/mnt/vendor/persist")
                # special handling for /mnt/vendor/persist
                for p in $(find $MY_DIR/config/boot_debug/persist -maxdepth 1 -type f -name '*.sepolicy' 2>/dev/null);do
                    pf=$(basename $p)
                    cp $p $MY_DIR/sepolicy/boot_debug/${pf/\.sepolicy/} && echo "[$FUNCNAME] ... copied sepolicy file: $pf"
                done
            ;;
        esac
        # special flag since A11 to disable encryption on EXTENDROM_DEBUG_PATH 
	if [ $EXTENDROM_TARGET_VERSION -ge 11 ];then
	    MKDARG="encryption=None"
	else
	    MKDARG=""
	fi
	sed "s#%%DEBUGLOG_LOGCAT_PATH%%#$EXTENDROM_DEBUG_LOGCAT_PATH#g;\
	     s#%%DEBUGLOG_PATH%%#$EXTENDROM_DEBUG_PATH#g;s#%%DEBUGLOG_MKDARG%%#$MKDARG#g;\
	     s#%%DEBUGLOG_PATH_SIZE_FULL%%#$EXTENDROM_DEBUG_PATH_SIZE_FULL#g;\
	     s#%%DEBUGLOG_PATH_SIZE_CRASH%%#$EXTENDROM_DEBUG_PATH_SIZE_CRASH#g;\
	     s#%%DEBUGLOG_PATH_SIZE_KERNEL%%#$EXTENDROM_DEBUG_PATH_SIZE_KERNEL#g;\
	     s#%%DEBUGLOG_PATH_SIZE_SELINUX%%#$EXTENDROM_DEBUG_PATH_SIZE_SELINUX#g" \
	     $MY_DIR/config/init.er.rc.in > $MY_DIR/config/init.er.rc
	echo "[$FUNCNAME] ... configured EXTENDROM_DEBUG_LOGCAT_PATH (init.er.rc) to $EXTENDROM_DEBUG_LOGCAT_PATH"
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

    # revert LOS patches
    case ${EXTENDROM_TARGET_VERSION} in
    	14) MGCOMMITS="6b793fa98a40dd6c2d6eb02988161ed123439428" ;;
     	13) MGCOMMITS="6d2955f0bd55e9938d5d49415182c27b50900b95" ;;
      	12) MGCOMMITS="83fe523914728a3674debba17a6019cb74803045" ;;
        11) MGCOMMITS="438d9feacfcad73d3ee918541574132928a93644" ;;
    esac
    if [ ! -z "$MGCOMMITS" ] && [ "$EXTENDROM_SIGSPOOF_RESET" != "false" ];then
    	cd frameworks/base
        echo "[$FUNCNAME] reverting DOS commit to allow sigspoofing"
    	git revert $MGCOMMITS
    	cd ../..
    fi
    
    PATCHX="/bin/bash $MY_DIR/tools/apply_patches.sh"
    PDIR="$SRC_TOP_FULL/$MY_DIR/config/sigspoof/$EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION}"
    [ ! -z "$EXTENDROM_SIGSPOOF_FORCE_PDIR" ] && [ -d "$EXTENDROM_SIGSPOOF_FORCE_PDIR" ] && PDIR=$EXTENDROM_SIGSPOOF_FORCE_PDIR

    $PATCHX $PDIR $EXTENDROM_PATCHER_RESET
    ERR=$?
    echo "[$FUNCNAME] Signature spoofing patching ended with $ERR"
    echo "[$FUNCNAME] adding signature spoof controller"
    cp $PDIR/*-packages-apps-Settings-src-com-android-settings-development-SpoofSignaturePreferenceController.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/SpoofSignaturePreferenceController.java || exit 3
    cp $PDIR/*-packages-apps-Settings-src-com-android-settings-development-SpoofSignatureInfo.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/SpoofSignatureInfo.java || exit 3
    F_GIT_COMMIT "packages/apps/Settings" "ER: advanced signature spoofing\nF_SIGPATCH: adding controller files"
    

    # if [ -f $PDIR/*-packages-apps-Settings-src-com-android-settings-development-SpoofSignaturePreferenceController.java ]; then
    #     cp $PDIR/*-packages-apps-Settings-src-com-android-settings-development-SpoofSignaturePreferenceController.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/SpoofSignaturePreferenceController.java || exit 3
    # fi

    # if [ -f $PDIR/*-packages-apps-Settings-src-com-android-settings-development-SpoofSignatureInfo.java ]; then
    #     cp $PDIR/*-packages-apps-Settings-src-com-android-settings-development-SpoofSignatureInfo.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/SpoofSignatureInfo.java || exit 3
    # fi
    
    echo "[$FUNCNAME] adding signature spoof controller ended with $?"
    if [ $ERR -eq 0 ];then echo "[$FUNCNAME] finished successfully" && return; else exit 3;fi
}

# signing patches
F_SIGNINGPATCHES(){
    echo "[$FUNCNAME] Signing patches requested ..."
    PATCHX="/bin/bash $MY_DIR/tools/apply_patches.sh"
    PDIR="$SRC_TOP_FULL/$MY_DIR/config/signing/$EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION}"
    [ ! -z "$EXTENDROM_SIGNING_FORCE_PDIR" ] && [ -d "$EXTENDROM_SIGNING_FORCE_PDIR" ] && PDIR=$EXTENDROM_SIGNING_FORCE_PDIR
    $PATCHX $PDIR $EXTENDROM_PATCHER_RESET
    ERR=$?
    echo "[$FUNCNAME] addding signing patches ended with $ERR"
    if [ $ERR -eq 0 ];then echo "[$FUNCNAME] finished successfully" && return; else exit 3;fi
}

# allow unrestricted call recording
F_CALLREC(){
    echo "[$FUNCNAME] unrestricted call recordings requested ..."

    OLMK="vendor/extendrom/overlays/call-rec/active"
    PDIR="$SRC_TOP_FULL/$MY_DIR/config/call-rec/$EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION}"
    DEVOPTSETTINGS="$SRC_TOP_FULL/packages/apps/Settings/src/com/android/settings/development/DevelopmentSettingsDashboardFragment.java"
    DEVOPTXML="$SRC_TOP_FULL/packages/apps/Settings/res/xml/development_settings.xml"
    CALLRECORDER="$SRC_TOP_FULL/packages/apps/Dialer/java/com/android/incallui/call/CallRecorder.java"
    SECSETTINGS="frameworks/base/core/java/android/provider/Settings.java"

    echo "[$FUNCNAME] adding call recording overlay"
    if [ -L "$OLMK" ]; then rm $OLMK; fi
    ln -s $EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION} $OLMK

    echo "[$FUNCNAME] adding call recording controller"
    cp $PDIR/packages-apps-Settings-src-com-android-settings-development-CallRecPreferenceController.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/ER_CallRecPreferenceController.java || exit 3
    cp $PDIR/packages-apps-Settings-src-com-android-settings-development-CallRecInfo.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/ER_CallRecInfo.java || exit 3
    F_GIT_COMMIT "packages/apps/Settings" "ER: unrestricted call recording\nF_CALLREC: adding controller files"
    
    # add controller after the last controllers.add line
    PREQ=0
    grep -q 'ER_CallRec' $DEVOPTSETTINGS || PREQ=1
    if [ $PREQ -eq 1 ];then
        echo "[$FUNCNAME] adding call recording controller - java"
        awk '
        /controllers.add/ { last = NR; lines[NR] = $0 }
        { lines[NR] = $0 }
        END {
            for (i = 1; i <= NR; i++) {
                print lines[i]
                if (i == last) {
                    print "        controllers.add(new ER_CallRecPreferenceController(context)); // extendrom call recording"
                    print "        controllers.add(new ER_CallRecInfo(context)); // extendrom call recording"
                }
            }
        }' $DEVOPTSETTINGS > ${DEVOPTSETTINGS}.temp && mv ${DEVOPTSETTINGS}.temp ${DEVOPTSETTINGS}
	F_GIT_COMMIT "packages/apps/Settings" "ER: unrestricted call recording\nF_CALLREC: DEVOPTSETTINGS"
    else
        echo "[$FUNCNAME] SKIPPED: adding call recording controller - java (already patched)"
    fi

    # add key to settings.secure
    PREQ=0
    grep -q 'ER_ALLOW_ANY_CALL_REC' $SECSETTINGS || PREQ=1
    if [ $PREQ -eq 1 ];then
        echo "[$FUNCNAME] adding call recording key to secure settings"
        awk '
        /public static final class Secure extends NameValueTable {/ && !done {
            print
            print ""
            print "        /**"
            print "         * extendrom: unrestricted call recording"
            print "         *"
            print "         * <p>1 = permit any country to record"
            print "         * <p>0 = allow only defined countries to record"
            print "         * @hide"
            print "         */"
            print "        public static final String ER_ALLOW_ANY_CALL_REC = \"extendrom_call_recording\";"
            print ""
            done = 1
            next
        }
        { print }
        ' $SECSETTINGS > ${SECSETTINGS}.temp && mv ${SECSETTINGS}.temp ${SECSETTINGS}
	F_GIT_COMMIT "frameworks/base" "ER: unrestricted call recording\nF_CALLREC: SECSETTINGS"
    else
        echo "[$FUNCNAME] SKIPPED: adding call recording key to secure settings (already patched)"
    fi

    # add controller to developer options
    PREQ=0
    grep -q 'extendrom call recording' $DEVOPTXML || PREQ=1
    if [ $PREQ -eq 1 ];then
        echo "[$FUNCNAME] adding call recording to developer options"
        awk '
        /android:title="@string\/development_settings_title">/ && !done {
            print
            print ""
            print "    <!-- extendrom call recording patch -->"
            print "    <PreferenceCategory"
            print "        android:key=\"extendrom_call_recording_category\""
            print "        android:title=\"@string/extendrom_call_recording_category\""
            print "        android:order=\"9980\">"
            print ""
            print "       <Preference"
            print "            android:key=\"extendrom_call_recording_info\""
            print "            android:summary=\"@string/extendrom_call_recording_details\" />"
            print ""
            print "       <SwitchPreference"
            print "            android:key=\"extendrom_call_recording\""
            print "            android:title=\"@string/extendrom_call_recording\""
            print "            android:summary=\"@string/extendrom_call_recording_summary\""
            print "            android:defaultValue=\"false\" />"
            print ""
            print "    </PreferenceCategory>"
            print "    <!-- end: extendrom call recording patch -->"
            print ""
            done = 1
            next
        }
        { print }
        ' $DEVOPTXML > ${DEVOPTXML}.temp && mv ${DEVOPTXML}.temp ${DEVOPTXML}
	F_GIT_COMMIT "packages/apps/Settings" "ER: unrestricted call recording\nF_CALLREC: DEVOPTXML"
    else
        echo "[$FUNCNAME] SKIPPED: adding call recording controller to developer options (already patched)"
    fi

    # add required import line to dialer
    PREQ=0
    grep -q 'import android.provider.Settings' $CALLRECORDER || PREQ=1
    if [ $PREQ -eq 1 ];then
        echo "[$FUNCNAME] adding import to call recording controller"
        awk '
        /import / { last = NR; lines[NR] = $0 }
        { lines[NR] = $0 }
        END {
            for (i = 1; i <= NR; i++) {
                print lines[i]
                if (i == last) {
                    print "import android.provider.Settings; // extendrom call recording"
                }
            }
        }' $CALLRECORDER > ${CALLRECORDER}.temp && mv ${CALLRECORDER}.temp ${CALLRECORDER}
	F_GIT_COMMIT "packages/apps/Dialer" "ER: unrestricted call recording\nF_CALLREC: CALLRECORDER1"
    else
        echo "[$FUNCNAME] SKIPPED: adding import to call recording controller (already there)"
    fi

    # enforce extendrom overwrite in dialer
    PREQ=0
    grep -q 'ER_CallRec' $CALLRECORDER || PREQ=1
    if [ $PREQ -eq 1 ];then
        echo "[$FUNCNAME] force call recording in dialer"
        awk '
            /public boolean canRecordInCurrentCountry.*/ && !done {
            print
            print "      // extendrom - any call recording"
            print "      int ER_CallRecordingEnabled = Settings.Secure.getInt("
            print "      context.getContentResolver(),"
            print "      \"extendrom_call_recording\", 0);"
            print ""
            print "      if (ER_CallRecordingEnabled == 1) {"
            print "          return true;"
            print "      }"
            print "      // END: extendrom - any call recording"
            print ""
            done = 1
            next
        }
        { print }
        ' $CALLRECORDER > ${CALLRECORDER}.temp && mv ${CALLRECORDER}.temp ${CALLRECORDER}
	F_GIT_COMMIT "packages/apps/Dialer" "ER: unrestricted call recording\nF_CALLREC: CALLRECORDER2"
    else
        echo "[$FUNCNAME] SKIPPED: force call recording in dialer (already patched)"
    fi

    if [ $ERR -eq 0 ];then echo "[$FUNCNAME] finished successfully" && return; else exit 3;fi
}

# intercept installation source check
F_ORR_INSTALLSRC(){
    local ER_MOD_NAME="orr_installsrc"
    echo "[$FUNCNAME] intercept installation source check requested ..."

    rm -rf $MY_DIR/sepolicy/property 2>/dev/null; mkdir -p $MY_DIR/sepolicy/property 2>/dev/null
    cp $MY_DIR/config/extendrom.te.sepolicy $MY_DIR/sepolicy/property/extendrom.te && echo "[$FUNCNAME] added extendrom sepolicy"
    cp $MY_DIR/config/property.te.sepolicy $MY_DIR/sepolicy/property/property.te && echo "[$FUNCNAME] added property sepolicy"
    cp $MY_DIR/config/property_contexts.sepolicy $MY_DIR/sepolicy/property/property_contexts && echo "[$FUNCNAME] added selinux property contexts"

    OLMK="vendor/extendrom/overlays/${ER_MOD_NAME}/active"
    PATCHX="/bin/bash $MY_DIR/tools/apply_patches.sh"
    PDIR="$SRC_TOP_FULL/$MY_DIR/config/${ER_MOD_NAME}/$EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION}"
    DEVOPTSETTINGS="$SRC_TOP_FULL/packages/apps/Settings/src/com/android/settings/development/DevelopmentSettingsDashboardFragment.java"
    DEVOPTXML="$SRC_TOP_FULL/packages/apps/Settings/res/xml/development_settings.xml"
    SECSETTINGS="frameworks/base/core/java/android/provider/Settings.java"

    IMPORTLIST="java.util.Arrays android.os.SystemProperties"
    case ${EXTENDROM_TARGET_VERSION} in
        9|10|11) IMPORTSETTINGS="frameworks/base/services/core/java/com/android/server/pm/PackageManagerService.java" ;;
        *) IMPORTSETTINGS="frameworks/base/services/core/java/com/android/server/pm/ComputerEngine.java" ;;
    esac

    echo "[$FUNCNAME] adding overlay"
    if [ -L "$OLMK" ]; then rm $OLMK; fi
    ln -s $EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION} $OLMK

    echo "[$FUNCNAME] adding controller"
    cp $PDIR/packages-apps-Settings-src-com-android-settings-development-OrrInstallSrcPreferenceController.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/ER_OrrInstallSrcPreferenceController.java || exit 3
    cp $PDIR/packages-apps-Settings-src-com-android-settings-development-OrrInstallSrcInfo.java ${SRC_TOP}/packages/apps/Settings/src/com/android/settings/development/ER_OrrInstallSrcInfo.java || exit 3
    F_GIT_COMMIT "packages/apps/Settings" "ER: intercept installation source\nF_ORR_INSTALLSRC: add controller files"

    # add controller after the last 'controllers.add' line
    PREQ=0
    grep -q "${ER_MOD_NAME}" $DEVOPTSETTINGS || PREQ=1
    if [ $PREQ -eq 1 ];then
        echo "[$FUNCNAME] adding controller - java"
        awk '
        /controllers.add/ { last = NR; lines[NR] = $0 }
        { lines[NR] = $0 }
        END {
            for (i = 1; i <= NR; i++) {
                print lines[i]
                if (i == last) {
                    print "        controllers.add(new ER_OrrInstallSrcPreferenceController(context)); // extendrom '${ER_MOD_NAME}'"
                    print "        controllers.add(new ER_OrrInstallSrcInfo(context)); // extendrom '${ER_MOD_NAME}'"
                }
            }
        }' $DEVOPTSETTINGS > ${DEVOPTSETTINGS}.temp && mv ${DEVOPTSETTINGS}.temp ${DEVOPTSETTINGS}
	F_GIT_COMMIT "packages/apps/Settings" "ER: intercept installation source\nF_ORR_INSTALLSRC: load controller"
    else
        echo "[$FUNCNAME] SKIPPED: adding controller - java (already patched)"
    fi

    # add key to settings.secure
    PREQ=0
    grep -q "${ER_MOD_NAME}" $SECSETTINGS || PREQ=1
    if [ $PREQ -eq 1 ];then
        echo "[$FUNCNAME] adapting secure settings"
        awk '
        /public static final class Secure extends NameValueTable {/ && !done {
            print
            print ""
            print "        /**"
            print "         * extendrom: '${ER_MOD_NAME}'"
            print "         *"
            print "         * <p>1 = intercept installation source check"
            print "         * <p>0 = report real installation source"
            print "         * @hide"
            print "         */"
            print "        public static final String ER_ORR_INSTALLSRC = \"extendrom_orr_installsrc\";"
            print ""
            done = 1
            next
        }
        { print }
        ' $SECSETTINGS > ${SECSETTINGS}.temp && mv ${SECSETTINGS}.temp ${SECSETTINGS}
	F_GIT_COMMIT "frameworks/base" "ER: intercept installation source\nF_ORR_INSTALLSRC: SECSETTINGS"
    else
        echo "[$FUNCNAME] SKIPPED: adapting secure settings (already patched)"
    fi

    # add controller to developer options
    PREQ=0
    grep -q "${ER_MOD_NAME}" $DEVOPTXML || PREQ=1
    if [ $PREQ -eq 1 ];then
        echo "[$FUNCNAME] adding to developer options"
        awk '
        /android:title="@string\/development_settings_title">/ && !done {
            print
            print ""
            print "    <!-- extendrom intercept installation source check -->"
            print "    <PreferenceCategory"
            print "        android:key=\"extendrom_orr_installsrc_category\""
            print "        android:title=\"@string/extendrom_orr_installsrc_category\""
            print "        android:order=\"9990\">"
            print ""
            print "       <Preference"
            print "            android:key=\"extendrom_orr_installsrc_info\""
            print "            android:summary=\"@string/extendrom_orr_installsrc_details\" />"
            print ""
            print "       <SwitchPreference"
            print "            android:key=\"extendrom_orr_installsrc\""
            print "            android:title=\"@string/extendrom_orr_installsrc\""
            print "            android:summary=\"@string/extendrom_orr_installsrc_summary\""
            print "            android:defaultValue=\"false\" />"
            print ""
            print "    </PreferenceCategory>"
            print "    <!-- end: extendrom intercept installation source check -->"
            print ""
            done = 1
            next
        }
        { print }
        ' $DEVOPTXML > ${DEVOPTXML}.temp && mv ${DEVOPTXML}.temp ${DEVOPTXML}
	F_GIT_COMMIT "packages/apps/Settings" "ER: intercept installation source\nF_ORR_INSTALLSRC: DEVOPTXML"
    else
        echo "[$FUNCNAME] SKIPPED: adding controller to developer options (already patched)"
    fi

    # add required import line to access Settings.Secure after the last found import line
    PREQ=0
    for imp in $IMPORTLIST;do
        grep -q "$imp" $IMPORTSETTINGS || PREQ=1
        if [ $PREQ -eq 1 ];then
            echo "[$FUNCNAME] adding Settings import: $imp"
            awk '
            /import / { last = NR; lines[NR] = $0 }
            { lines[NR] = $0 }
            END {
                for (i = 1; i <= NR; i++) {
                    print lines[i]
                    if (i == last) {
                        print "import '$imp'; // extendrom '${ER_MOD_NAME}'"
                    }
                }
            }' $IMPORTSETTINGS > ${IMPORTSETTINGS}.temp && mv ${IMPORTSETTINGS}.temp ${IMPORTSETTINGS}
	    F_GIT_COMMIT "frameworks/base" "ER: intercept installation source\nF_ORR_INSTALLSRC: IMPORTSETTINGS"
        else
            echo "[$FUNCNAME] SKIPPED: adding Settings import for $imp (already there)"
        fi
    done

    echo "[$FUNCNAME] using patch dir: $PDIR"
    $PATCHX $PDIR $EXTENDROM_PATCHER_RESET
    ERR=$?
    echo "[$FUNCNAME] patching process ended with $ERR"

    if [ $ERR -eq 0 ];then echo "[$FUNCNAME] finished successfully" && return; else exit 3;fi
}


# append a signature to every overlay in vendor/ 
# (as we cannot predict which will be used during build)
F_ADD_WV(){
    WVS="$1"

    for x in $(find vendor/ -type f -name config_webview_packages.xml);do
        # start fresh xml
        echo "[$FUNCNAME] constructing config_webview_packages.xml"

        cat > $_OUTDIR/_config_webview_packages.xml <<_EOFF
<?xml version="1.0" encoding="utf-8"?>
<webviewproviders>

_EOFF
        # add all webviews
        for w in $WVS;do
	    cat ${SRC_TOP}/vendor/extendrom/extra/$w >> $_OUTDIR/_config_webview_packages.xml && echo "[$FUNCNAME] ... added $w to config_webview_packages.xml"
        done
        # finalize the xml and overwrite the source
        echo -e '\n</webviewproviders>' >> $_OUTDIR/_config_webview_packages.xml
        mv $_OUTDIR/_config_webview_packages.xml $x && echo "[$FUNCNAME] constructing config_webview_packages.xml completed"
    done
}

# ensure PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS is always relaxed, if set.
# this avoids errors like:
# > build/make/core/artifact_path_requirements.mk:30: warning: device/xxx/xxx.mk includes redundant artifact path requirement allowed list entries.
F_RELAX_ARTIFACTS(){
    echo "[$FUNCNAME] ... checking PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS"

    for a in $(find device/ -type f -name '*.mk' -exec grep --files-with-matches -E "^PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS.*(strict|true)" {} \;);do
       sed -i 's/^PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS.*/PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := relaxed/g' $a \
           && echo "[$FUNCNAME] enforced PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS to >relaxed< on $a"
    done
}

# webviews handling
# format: <filename>:<existence-check-string>
if [[ "$EXTENDROM_PACKAGES" =~ "AOSmium_webview" ]];then WVL="webview_aosmium.sig.xml"; fi
if [[ "$EXTENDROM_PACKAGES" =~ "Cromite_webview" ]];then WVL="${WVL} webview_cromite.sig.xml"; fi
if [ ! -z "$WVL" ]; then F_ADD_WV "$WVL";fi

if [ "$EXTENDROM_SIGNATURE_SPOOFING" == "true" ];then F_SIGPATCH ;fi
if [ "$EXTENDROM_SIGNING_PATCHES" == "true" ];then F_SIGNINGPATCHES ;fi
if [ "$EXTENDROM_ALLOW_ANY_CALL_RECORDING" == "true" ];then F_CALLREC; fi
if [ "$EXTENDROM_INTERCEPT_INSTALLSRC" == "true" ];then F_SIGPATCH; F_ORR_INSTALLSRC; fi

F_GET_GPG_KEYS
get_packages "$MY_DIR/repo/packages.txt"

if [ ! -z "$EXTENDROM_BOOT_DEBUG" -a  "$EXTENDROM_BOOT_DEBUG" == "true" ];then
    F_BOOT_DEBUG
fi

F_RELAX_ARTIFACTS

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
    PDIR="$SRC_TOP_FULL/$MY_DIR/config/magisk/$EXTENDROM_TARGET_PRODUCT/A${EXTENDROM_TARGET_VERSION}"

    echo "[MAGISK] using patch dir: $PDIR"
    $PATCHX $PDIR $EXTENDROM_PATCHER_RESET
    ERR=$?
    echo "[MAGISK] Injecting Magisk patcher ended with $ERR"
    [ "$ERR" -ne 0 ] && exit $ERR

    MAGISKOUT=$(realpath $MY_DIR/../../out/.magisk)
    [ -d "$MAGISKOUT" ] && rm -rf $MAGISKOUT
    mkdir -p $MAGISKOUT
    if [ -z $MAGISK_TARGET_ARCH ];then
        if [ -z $ER_TARGET_ARCH ];then
            MAGISK_TARGET_ARCH=arm64
        else
            MAGISK_TARGET_ARCH=$ER_TARGET_ARCH
        fi
    fi

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
    echo "[MAGISK] ... Preparing work dir.."

    if [ $MAGISK_TARGET_ARCH == "arm64" ];then
	echo "[MAGISK] ... $(cp -v $MAGISKOUT/src/lib/arm64-v8a/libmagisk64.so $MAGISKOUT/magisk64 || cp -v $MAGISKOUT/src/lib/arm64-v8a/libmagisk.so $MAGISKOUT/magisk)"
	echo "[MAGISK] ... $(cp -v $MAGISKOUT/src/lib/arm64-v8a/libmagiskinit.so $MAGISKOUT/magiskinit)"
        if [ -f $MAGISKOUT/src/lib/arm64-v8a/libinit-ld.so ]; then echo "[MAGISK] ... $(cp -v $MAGISKOUT/src/lib/arm64-v8a/libinit-ld.so $MAGISKOUT/init-ld)"; fi
    else
        if [ -f $MAGISKOUT/src/lib/armeabi-v7a/libmagisk32.so ]; then
            echo "[MAGISK] ... $(cp -v $MAGISKOUT/src/lib/armeabi-v7a/libmagisk32.so $MAGISKOUT/magisk32)"
        else
            echo "[MAGISK] ... $(cp -v $MAGISKOUT/src/lib/armeabi-v7a/libmagisk.so $MAGISKOUT/magisk)"
        fi
        echo "[MAGISK] ... $(cp -v $MAGISKOUT/src/lib/armeabi-v7a/libmagiskinit.so $MAGISKOUT/magiskinit)"
        echo "[MAGISK] ... $(cp -v $MAGISKOUT/src/lib/armeabi-v7a/libinit-ld.so $MAGISKOUT/init-ld)"
    fi
    chmod 755 $MAGISKOUT/src/assets/boot_patch.sh
    rm -rf $MAGISKOUT/src/assets/dexopt $MAGISKOUT/src/assets/chromeos
    cp $MAGISKOUT/src/assets/* $MAGISKOUT/
    # keep backwards compability
    cp $MAGISKOUT/src/assets/boot_patch.sh $MAGISKOUT/root_boot.sh

    # remove Magisk from Android mk list - as we do not build/add the Magisk app
    # see https://github.com/sfX-android/android_vendor_extendrom/wiki/FAQ#extendrom_preroot_boot
    export EXTENDROM_PACKAGES="$EXTENDROM_PACKAGES_CLEANED"
    echo -e "[MAGISK] removed >$MAGNAME< from Android makefile generation:\nEXTENDROM_PACKAGES is now: $EXTENDROM_PACKAGES"
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
