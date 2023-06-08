#!/bin/bash
#################################################################################
# Copyright (C) 2021-2022 steadfasterX <steadfasterX -AT- gmail #DOT# com>
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
#

COMMON=-1

TMPDIR=$(mktemp -d)

#
# cleanup
#
# kill our tmpfiles with fire on exit
#
function cleanup() {
    rm -rf "${TMPDIR:?}"
}

trap cleanup 0

#
# write_header:
#
# $1: file which will be written to
#
# writes out the copyright header with the current year.
# note that this is not an append operation, and should
# be executed first!
#
function write_header() {
    if [ -f $1 ]; then
        rm $1
    fi

    local FILE=$1
    [ -z "$FILE" ] && echo "ERROR: missing filename" && exit 3

    YEAR=$(date +"%Y")

    [ "$COMMON" -eq 1 ] && local DEVICE="$DEVICE_COMMON"

    NUM_REGEX='^[0-9]+$'
    if [[ $INITIAL_COPYRIGHT_YEAR =~ $NUM_REGEX ]] && [ $INITIAL_COPYRIGHT_YEAR -le $YEAR ]; then
        if [ $INITIAL_COPYRIGHT_YEAR -eq $YEAR ]; then
            echo -e "# Copyright (C) $YEAR steadfasterX <steadfasterX@gmail.com>\n" >> $1
        else
            printf "# Copyright (C) $INITIAL_COPYRIGHT_YEAR-$YEAR steadfasterX <steadfasterX@gmail.com>\n" >> $1
        fi
    else
        printf "# Copyright (C) $YEAR steadfasterX \<steadfasterX@gmail.com\>\n" > $1
    fi

    cat << EOF >> $1
# This file is generated by $0

EOF
}

#
# write_headers:
#
# $1: devices falling under common to be added to guard - optional
# $2: custom guard - optional
#
# Calls write_header for each of the makefiles and creates
# the initial path declaration and device guard for the
# Android.mk
#
function write_headers() {
    write_header "$ANDROIDMK"

    GUARD="$2"
    if [ -z "$GUARD" ]; then
        GUARD="TARGET_DEVICE"
    fi

    cat << EOF >> "$ANDROIDMK"
VENDOR_DIR := \$(call my-dir)

EOF
    if [ "$COMMON" -ne 1 ]; then
        cat << EOF >> "$ANDROIDMK"
ifeq (\$($GUARD),$DEVICE)

EOF
    else
        if [ -z "$1" ]; then
            echo "Argument with devices to be added to guard must be set!"
            exit 1
        fi
        cat << EOF >> "$ANDROIDMK"
ifneq (\$(filter $1,\$($GUARD)),)

EOF
    fi
    if [ "$EXTENDROM_BOOT_DEBUG" == true ];then
	cat << EOF >> "$ANDROIDMK"
LOCAL_PATH := \$(PRODUCT_OUT)
include \$(CLEAR_VARS)
LOCAL_MODULE            := er-logcat
LOCAL_REQUIRED_MODULES  := logcat
LOCAL_MODULE_TAGS       := optional
LOCAL_MODULE_CLASS      := EXECUTABLES
LOCAL_SRC_FILES         := \$(TARGET_COPY_OUT_SYSTEM)/bin/logcat
LOCAL_MODULE_PATH       := \$(TARGET_OUT_VENDOR_EXECUTABLES)
ifeq (\$(call math_gt_or_eq,\$(PLATFORM_SDK_VERSION),29), true)
LOCAL_CHECK_ELF_FILES   := false
else
LOCAL_SHARED_LIBRARIES  := libbase libc++ libprocessgroup
endif
#LOCAL_VENDOR_MODULE    := true
include \$(BUILD_PREBUILT)
LOCAL_PATH := \$(VENDOR_DIR)
EOF
    else

	 cat << EOF >> "$ANDROIDMK"
LOCAL_PATH := \$(VENDOR_DIR)
EOF
    fi
}

#
# write_footers:
#
# Closes the inital guard and any other finalization tasks. Must
# be called as the final step.
#
function write_footers() {
    cat << EOF >> "$ANDROIDMK"

endif
EOF
}

#
# target_file:
#
# $1: colon delimited list
#
# Returns destination filename without args
#
function target_file() {
    local LINE="$1"
    appdir=$(echo "$LINE" |cut -d "|" -f3)
    appname=$(echo "$LINE" |cut -d "|" -f1)
    app=$(echo "$LINE" |cut -d "|" -f4)
    appmodule=${app/\.apk*/}
    printf '%s\n' "${appdir}/${appname}:${appmodule}"
}

F_WRITE_MAKEFILE(){
    if [ -z "$1" ]; then
        echo "An input file is expected!"
        exit 1
    elif [ ! -f "$1" ]; then
        echo "Input file "$1" does not exist!"
        exit 1
    fi

    if [ $# -eq 2 ]; then
        LIST=$TMPDIR/files.txt
        cat $1 | sed -n '/# '"$2"'/I,/^\s*$/p' > $LIST
    else
        LIST=$1
    fi

    while read -r line; do
        if [ -z "$line" ]; then continue; fi

	unset EXTRA appsrcname appdir appnamefull _appsign appname overrides requiredmods uses_required_libs uses_optional_libs package_human
        appsrcname=$(echo "$line" |cut -d "|" -f1)
        appdir=$(echo "$line" |cut -d "|" -f3)
	appnamefull=$(echo "$line" |cut -d "|" -f4 | cut -d ";" -f1)
	_appsign=$(echo "$line" |cut -d "|" -f4 | cut -d ";" -f2)
	appname="${appnamefull/\.apk/}"
	overrides=$(echo "$line" |cut -d "|" -f6 )
	requiredmods=$(echo "$line" |cut -d "|" -f7)
	uses_required_libs=$([ -f vendor/extendrom/prebuilt/$appnamefull ] && aapt dump badging vendor/extendrom/prebuilt/$appnamefull | grep "uses-library:" | sed -n "s/uses-library:'\(.*\)'/\1/p" | tr "\n" " ")
	uses_optional_libs=$([ -f vendor/extendrom/prebuilt/$appnamefull ] && aapt dump badging vendor/extendrom/prebuilt/$appnamefull | grep "uses-library-not-required:" | sed -n "s/uses-library-not-required:'\(.*\)'/\1/p" | tr "\n" " ")
        package_human="${appnamefull/\.apk}"

	if [[ "$appname" =~ .*Magisk.* ]];then
	    echo "[$FUNCNAME] ... skipping $package_human (Magisk is not allowed to be a system app)"
	    continue
	fi

	# allow empty LOCAL_CERTIFICATE
	# that means DEFAULT_SYSTEM_DEV_CERTIFICATE will be used
	# https://github.com/aosp-mirror/platform_build/blob/master/core/package_internal.mk#L446-L452
	[ ! -z "$_appsign" ] && appsign="\nLOCAL_CERTIFICATE := $_appsign"

        # do not process what we do not want to build
	echo "$EXTENDROM_PACKAGES" | tr ' ' '\n' | grep -E "^${package_human}\$"
	if [ $? -ne 0 ];then
            echo "[$FUNCNAME] ... skipping $package_human as not requested by EXTENDROM_PACKAGES"
            continue
	else
	    echo "[$FUNCNAME] ... WRITING $package_human as requested by EXTENDROM_PACKAGES"
        fi

	if [[ "$appdir" =~ .*priv-app ]];then
	    EXTRA="LOCAL_PRIVILEGED_MODULE := true"
	fi
	if [ ! -z "$overrides" ];then
	   p_overrides=$(echo "$overrides" | tr ";" " ")
	    [ ! -z "$EXTRA" ] && EXTRA="$EXTRA
"
	   EXTRA="${EXTRA}LOCAL_OVERRIDES_PACKAGES := $p_overrides"
	fi
	if [ "${#requiredmods}" -gt 4 ];then
	   p_requiredmods=$(echo "$requiredmods" | tr ";" " ")
	    [ ! -z "$EXTRA" ] && EXTRA="$EXTRA
"
	   EXTRA="${EXTRA}LOCAL_REQUIRED_MODULES := $p_requiredmods"
	fi
	if [ "${#uses_required_libs}" -gt 4 ];then
	    [ ! -z "$EXTRA" ] && EXTRA="$EXTRA
"
           EXTRA="${EXTRA}LOCAL_USES_LIBRARIES := $uses_required_libs"
	fi
	if [ "${#uses_optional_libs}" -gt 4 ];then
	    [ ! -z "$EXTRA" ] && EXTRA="$EXTRA
"
           EXTRA="${EXTRA}LOCAL_OPTIONAL_USES_LIBRARIES := $uses_optional_libs"
        fi
	if [ -z "$EXTRA" ];then
	    EXTRA="include \$(BUILD_PREBUILT)"
	else
	    EXTRA="$EXTRA
include \$(BUILD_PREBUILT)"
	fi
	cat >> $ANDROIDMK << _EOAPP

include \$(CLEAR_VARS)
LOCAL_MODULE := $appname
LOCAL_MODULE_OWNER := extendrom
LOCAL_SRC_FILES := prebuilt/$appsrcname$(echo -e "$appsign")
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
${EXTRA}
_EOAPP
    done < <(grep -E -v '(^#|^[[:space:]]*$)' "$LIST" | LC_ALL=C sort | uniq)
}

