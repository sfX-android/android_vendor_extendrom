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

ifeq ($(EXTENDROM_BOOT_DEBUG),true)
BOARD_SEPOLICY_DIRS += $(VENDOR_DIR)/sepolicy/boot_debug

PRODUCT_COPY_FILES += \
    $(VENDOR_DIR)/config/init.er.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.extendrom.rc
endif

# pre-rooting with magisk
ifeq ($(EXTENDROM_PREROOT_BOOT),true)

# do not overwrite a custom bootimg mk
ifndef (true,$(BOARD_CUSTOM_BOOTIMG_MK))
BOARD_CUSTOM_BOOTIMG_MK := true
BOARD_CUSTOM_BOOTIMG_MK := $(VENDOR_DIR)/preroot_bootimg.mk
endif

endif 
