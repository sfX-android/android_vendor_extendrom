#!/vendor/bin/sh
##########################################################################################
#
# This code is part of extendrom (https://github.com/sfX-android/android_vendor_extendrom)
# Copyright (C) 2023 steadfasterX <steadfasterX@binbash.rocks>
#
##########################################################################################

# check setup state
FBOOT=$(getprop persist.vendor.er.pi.setup.done)

# only on the very first boot
if [ "$FBOOT" != "1" ];then
    /system/bin/pm install /vendor/er/er-r-wa/er-r-wa.apk
fi

# finalizing
setprop persist.vendor.er.pi.setup.done 1
