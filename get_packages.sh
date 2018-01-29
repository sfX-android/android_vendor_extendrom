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


FDROID_REPO_URL="https://f-droid.org/repo"

###########################################################

MY_DIR=$(pwd)
PROPRIETARY_DIR="$MY_DIR/proprietary"

source tools/extract_utils.sh

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
    cmd="wget --quiet -O $pkg_path $repo/$pkg 2>&1"
    out=$(eval $cmd)
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "ERROR: Failed to download $pkg"
        echo
        echo "$out"
        exit 1
    fi

    echo "- Downloading signature: $pkg_sig"
    cmd="wget --quiet -O $pkg_dir/$pkg_sig $repo/$pkg_sig 2>&1"
    out=$(eval $cmd)
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "ERROR: Failed to download $pkg_sig"
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
    echo
}

function get_packages() {
    local repo="$1"
    local package_file_list="$2"

    if [ ! -d "proprietary" ]; then
        mkdir "proprietary"
    fi

    parse_file_list $package_file_list

    local filelist=( ${PRODUCT_COPY_FILES_LIST[@]} ${PRODUCT_PACKAGES_LIST[@]} )
    local count=${#filelist[@]}

    for ((i=0; i < count; i++)); do
        local split=(${filelist[$i]//;/ })
        local package_name="${split[0]#-}"
        local package="proprietary/$package_name"

        download_package "$repo" "$package"
        verify_package "$package"
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
write_footers

exit 0
