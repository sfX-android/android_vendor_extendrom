############################################################################
#
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
#
############################################################################

VENDOR_DIR := vendor/extendrom

# backwards compat for at least A9 where the environment vars
# do not be parsed and become build flags automatically
ifeq ($(EXTENDROM_BOOT_DEBUG),)
EXTENDROM_BOOT_DEBUG := $(shell echo $$EXTENDROM_BOOT_DEBUG)
endif
ifeq ($(EXTENDROM_PREROOT_BOOT),)
EXTENDROM_PREROOT_BOOT := $(shell echo $$EXTENDROM_PREROOT_BOOT)
endif

ifeq ($(EXTENDROM_BOOT_DEBUG),true)
#BOARD_SEPOLICY_DIRS += $(VENDOR_DIR)/sepolicy/boot_debug
BOARD_VENDOR_SEPOLICY_DIRS += $(VENDOR_DIR)/sepolicy/boot_debug

PRODUCT_PACKAGES += \
	er-logcat

PRODUCT_COPY_FILES += \
    $(VENDOR_DIR)/config/init.er.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.extendrom.rc
endif

# pre-rooting with magisk
ifeq ($(EXTENDROM_PREROOT_BOOT),true)

# do not overwrite a custom bootimg mk
ifneq (true,$(BOARD_CUSTOM_BOOTIMG))
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_BOOTIMG_MK := $(VENDOR_DIR)/preroot_bootimg.mk
else
$(error EXTENDROM_PREROOT_BOOT and BOARD_CUSTOM_BOOTIMG are both set to true but are mutually exclusive)
endif # BOARD_CUSTOM_BOOTIMG

endif # EXTENDROM_PREROOT_BOOT
