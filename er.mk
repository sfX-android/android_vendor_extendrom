############################################################################
#
# Copyright (C) 2020-2024 steadfasterX <steadfasterX@binbash.rocks>
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
############################################################################

VENDOR_DIR := vendor/extendrom

ifeq ($(ENABLE_EXTENDROM), true)

##########################################
# boot debugger

ifeq ($(EXTENDROM_BOOT_DEBUG), true)

ifeq ($(call math_gt_or_eq,$(PLATFORM_VERSION),11),true)
BOARD_VENDOR_SEPOLICY_DIRS += $(VENDOR_DIR)/sepolicy/boot_debug
else
BOARD_SEPOLICY_DIRS += $(VENDOR_DIR)/sepolicy/boot_debug
endif

PRODUCT_PACKAGES += \
	er-logcat

ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
PRODUCT_COPY_FILES += \
    $(VENDOR_DIR)/config/init.er.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.extendrom.rc
else
PRODUCT_COPY_FILES += \
    $(VENDOR_DIR)/config/init.er.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.extendrom.rc
endif # call math_gt_or_eq = true
endif # EXTENDROM_BOOT_DEBUG = true

# include package definitions generated by er.sh
$(call inherit-product-if-exists, vendor/extendrom/packages.mk)

# Android 11 introduced the /system_ext partition to avoid writing
# stuff into /system. If a device has PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS set
# writing to /system will be even prohibited and a build will fail.
# extendrom will use /system_ext as default when A11 or later to satisfy this.
# see: https://source.android.com/docs/core/architecture/partitions/product-interfaces#about-the-artifact-path-requirements
#
# Some apps and settings REQUIRE to be installed into /system though.
# 1. add them here to exclude them from the "require-artifacts-in-path" check
# 2. add an exception in tools/extract_utils.sh to not use /system_ext for them
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST := \
    $(TARGET_COPY_OUT_SYSTEM)/priv-app/Phonesky_AXP-OS/Phonesky_AXP-OS.apk \
    $(TARGET_COPY_OUT_SYSTEM)/etc/default-permissions/phonesky-permissions.xml \
    $(TARGET_COPY_OUT_SYSTEM)/etc/permissions/com.android.vending.xml \

endif # ENABLE_EXTENDROM = true
