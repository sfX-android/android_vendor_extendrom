#!/bin/bash
############################################################################
#
# Copyright (C) 2017-2018 Andreas Schneider <asn@crytpomilk.org>
# Copyright (C) 2020-2021 steadfasterX <steadfasterX@binbash.rocks>
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
GPG_FORCE_DL=1

###########################################################

MY_DIR="$1"
[ -z "$MY_DIR" ] && MY_DIR=${0%/*}

unset CURLDNS
CUSTDNS="$2"
[ ! -z "$CUSTDNS" ] && CURLDNS="--dns-servers $CUSTDNS"

PREBUILT_DIR="$MY_DIR/prebuilt"

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

    echo "- Downloading package: $pkg"
    cmd=$($CURL --fail -o $pkg_path $repo 2>&1)
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "ERROR: Failed to download $pkg (returned: $ret)"
        echo
        echo "$cmd"
        return $ret
    fi

    if [ "$should_verify" == "true" ];then
       echo "- Downloading signature: ${repo}.asc"
       cmd="$CURL -o $pkg_dir/$pkg_sig ${repo}.asc 2>&1"
       out=$(eval $cmd)
       ret=$?
       if [ $ret -ne 0 ]; then
           echo "ERROR: Failed to download $repo/$pkg_sig (returned: $ret)"
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

    echo -n "- Verifing package signature for $pkg_path: "
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
        local package="$PREBUILT_DIR/$package_name"

	if [ "$package_baseuri" == "FDROIDREPO" ];then
	    local repo="${FDROID_REPO_URL}/${package_name}"
	else
	    local repo="$package_baseuri/${package_name}"
	fi

       should_verify=$(echo ${line} |cut -d "|" -f5)
        download_package "$repo" "$package"
       [ $? -ne 0 ] && echo "ERROR occured while downloading, aborted"  && exit 3
        
	if [ "$should_verify" == "true" ];then
	    verify_package "$package"
	fi

	local target_split=$(echo ${line} |cut -d "|" -f4)
        target_pkg="$PREBUILT_DIR/$(target_file $target_split | sed 's/\;.*//')"
        echo "- Target package: $target_pkg"
        cp $package $target_pkg
       [ $? -ne 0 ] && echo "ERROR occured during copying, aborted"  && exit 3
        echo
    done
}

F_GET_GPG_KEYS(){
    # import all required gpg pub keys
    for k in $GPG_KEYS;do
       if [ $GPG_FORCE_DL -eq 0 ];then
           gpg -k $k 2>&1 >> /dev/null && echo "- skipping already imported gpg pub key ($k)" && continue
       fi
       for s in $GPG_KEYSERVER;do
           echo "- trying $k from $s"
           gpg --keyserver $s --recv-key $k >> /dev/null 2>&1 && echo "- imported gpg key $k from $s" && continue 2
       done
       echo "- ERROR: Cannot download a required gpg pub key: $k"
       exit 3
    done
}

F_GET_GPG_KEYS
get_packages "$MY_DIR/repo/packages.txt"

INITIAL_COPYRIGHT_YEAR=2021
VENDOR="extendrom"
ANDROIDMK="$MY_DIR/Android.mk"

DEVICE="true"
write_headers "" ENABLE_EXTENDROM
DEVICE=

echo "- writing makefile"
F_WRITE_MAKEFILE "$MY_DIR/repo/packages.txt"
cat >> $ANDROIDMK <<EOMK

# include additional repos for F-droid 
include $MY_DIR/extra/Android.mk

EOMK
write_footers

# special handling for /e/ OS gestures support
if [ "$EOS_GESTURES" == "true" ];then
    TBMK="packages/apps/Trebuchet/Android.mk"
    TBTESTMK="packages/apps/Trebuchet/tests/Android.mk"
    ICOLIB="packages/apps/iconloaderlib"
    if [ -f $TBMK ];then
       sed -i 's/LOCAL_PACKAGE_NAME := TrebuchetQuickStep/LOCAL_PACKAGE_NAME := eOSTrebuchetQuickStep/g' $TBMK
    else
       echo -e "\n*** ERROR ***\n/e/ OS gesture support is enabled (EOS_GESTURES=true) but a required file is missing:\n\n\t>${TBMK}<\n\nCheck if your local manifest contains the source for 'TrebuchetQuickStep'!"
       echo -e "For testing purposes you can clone it manually like this \n\ngit clone https://github.com/LineageOS/android_packages_apps_Trebuchet.git packages/apps/Trebuchet -b lineage-<version>\n"
       exit 3
    fi
    [ -f "$TBTESTMK" ] && rm $TBTESTMK
    [ -d "$ICOLIB" ] && rm -rf $ICOLIB
fi
