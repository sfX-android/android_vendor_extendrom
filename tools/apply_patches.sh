#!/bin/bash
#########################################################################################################
#
# simple patch utility which parses a given directory for *.patch files
# generated by "repo diff > file.patch"
#
# NOTE: do NOT USE "repo diff -u" !!
#
#########################################################################################################
#
# Copyright (C) 2023 steadfasterX <steadfasterX -AT- binbash #DOT# rocks>
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
#########################################################################################################
#
# a git hard reset before applying is done by default. if you do NOT want to reset before:
# export EXTENDROM_PATCHER_RESET=false
#
# usage:
# ./apply_patches.sh <full-path-of-patch-dir>
#
#########################################################################################################

# DO NOT set -e !

# ensure we talk english only
export LC_ALL=C

F_LOG(){
    echo -e "[PATCHER] " "$1"
}

PDIR=$1
[ -z "$PDIR" -o ! -d "$PDIR" ] && echo "ABORT: missing or wrong parameter: $0 <patch-dir>" && exit 4
[ -z "$EXTENDROM_PATCHER_RESET" ] && EXTENDROM_PATCHER_RESET=true

INDI=$PDIR/EXTENDROM_PATCHER_DONE
[ -f $INDI ] && echo -e "\n\n***************************************************************************\nWARNING: EXTENDROM sources are already patched!\nIf you want to force patching remove the indicator file:\n./${INDI}\n***************************************************************************\n\n" && exit

F_LOG "starting"
F_LOG "... detecting patches in: $PDIR"

if [ $EXTENDROM_PATCHER_RESET == "true" ];then
    F_LOG "... will reset project paths first (bc PATCHER_RESET=true or unset)"
    for reset in $(find -L $PDIR -type f -name '*.patch' -exec grep -H project {} \; | sort | tr ' ' '#'); do
	dp=$(basename ${reset/:*})
	P=$(echo "$reset" | sed 's#^#-i '$(pwd)'/#g;s/:project#/ -d /g')
	    ROUT=$(repo forall "${reset/*#}" -c 'git reset --hard' 2>&1)
	    if [ $? -eq 0 ];then
		F_LOG "... git reset hard finished for ${reset/*#}"
	    else
		F_LOG "WARNING: issue occured while resetting:\n\n $ROUT"
	    fi
    done
fi

for p in $(find -L $PDIR -type f -name '*.patch' -exec grep -H project {} \; | sort | tr ' ' '#'); do
    ERR=0
    RES=1
    dp=$(basename ${p/:*})
    P=$(echo "$p" | sed 's#^#-i #g;s/:project#/ -d /g')
    F_LOG "... applying >${dp}< within >${p/*#}< now:"
    POUT=$(patch -r - --no-backup-if-mismatch --forward --ignore-whitespace --verbose -p1 $P 2>&1)
    RERR=$?
    # ensure there is a valid success message
    echo "$POUT" | grep -Eqi "succeed" && RES=0
    # ensure we really fail even when some hunks succeed:
    echo "$POUT" | grep -Eqi "failed" && ERR=3
    F_LOG "... ended with errorcode $RERR/$ERR"
    if [ $ERR -eq 3 ]||[ $RES -ne 0 ];then
	echo -e "$POUT" && F_LOG "FATAL ERROR occured while applying >${dp}<!!!" && exit 3
    fi
done

# create patch indicator
> $INDI

F_LOG "finished"
