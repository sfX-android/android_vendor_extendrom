#!/bin/bash

#
# Copyright (C) 2017-2018 Andreas Schneider <asn@crytpomilk.org>
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

###########################################################

MY_DIR="$1"
[ -z "$MY_DIR" ] && MY_DIR=$(pwd)

unset CURLDNS
CUSTDNS="$2"
[ ! -z "$CUSTDNS" ] && CURLDNS="--dns-servers $CUSTDNS"

PROPRIETARY_DIR="$MY_DIR/proprietary"

CURLARGS=" -L $CURLDNS"
CURL="$MY_DIR/tools/curl_x64_static $CURLARGS"
source $MY_DIR/tools/extract_utils.sh

echo "$CURL"

rm -rf "$PROPRIETARY_DIR"

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
    cmd=$($CURL -o $pkg_path $repo/$pkg 2>&1)
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "ERROR: Failed to download $pkg (returned: $ret)"
        echo
        echo "$cmd"
        exit 1
    fi

    echo "- Downloading signature: $pkg_sig"
    cmd="$CURL -o $pkg_dir/$pkg_sig $repo/$pkg_sig 2>&1"
    out=$(eval $cmd)
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "ERROR: Failed to download $pkg_sig (returned: $ret)"
        echo
        echo "$out"
        exit 1
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
    local repo="$1"
    local package_file_list="$2"

    if [ ! -d "$MY_DIR/proprietary" ]; then
        mkdir "$MY_DIR/proprietary"
    fi

    for line in $(grep -v '^#' $package_file_list); do
        if [ -z "$line" ]; then
            continue;
        fi

        local split=(${line//:/ })
        local package_name="${split[0]#-}"
        local package="$MY_DIR/proprietary/$package_name"

        download_package "$repo" "$package"
        verify_package "$package"

        local target_split="${split[1]#-}"
        target_pkg="$MY_DIR/proprietary/$(target_file $target_split | sed 's/\;.*//')"
        echo "- Target package: $target_pkg"
        cp $package $target_pkg
        echo
    done

    return 0
}

get_packages "$FDROID_REPO_URL" "$MY_DIR/repo/fdroid.txt"

INITIAL_COPYRIGHT_YEAR=2017
VENDOR="fdroid"
ANDROIDMK="$MY_DIR/Android.mk"
PRODUCTMK="$MY_DIR/$VENDOR-vendor.mk"

DEVICE="true"
write_headers "" WITH_FDROID
DEVICE=
write_makefiles "$MY_DIR/repo/fdroid.txt"
cat >> $ANDROIDMK <<EOMK
include $MY_DIR/extra/Android.mk
EOMK
write_footers

exit 0
