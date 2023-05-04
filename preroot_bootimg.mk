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

ROOT_BOOT_DIR := $(PWD)/$(OUT_DIR)/.magisk
ROOT_BOOT_BIN := $(ROOT_BOOT_DIR)/boot_patch.sh

# backwards compatibility
ifndef bootimage-to-kernel
# $1: boot image target
# returns the kernel used to make the bootimage
define bootimage-to-kernel
  $(if $(BOARD_KERNEL_BINARIES),\
    $(PRODUCT_OUT)/$(subst .img,,$(subst boot,kernel,$(notdir $(1)))),\
    $(INSTALLED_KERNEL_TARGET))
endef
endif # bootimage-to-kernel

# backwards compatibility
ifndef get-bootimage-partition-size
define get-bootimage-partition-size
$(BOARD_$(call to-upper,$(subst .img,,$(subst $(2),kernel,$(notdir $(1)))))_BOOTIMAGE_PARTITION_SIZE)
endef
endif # get-bootimage-partition-size

ifeq (true,$(BOARD_AVB_ENABLE))

define er_preroot_avb
    $(eval kernel := $(call bootimage-to-kernel,$(1)))
    $(MKBOOTIMG) --kernel $(kernel) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $(1)
    @echo "++++  PRE-ROOTing BOOT image (avb)  ++++"
    @$(ROOT_BOOT_DIR)/zygote_faker 45 &
    @/bin/bash $(ROOT_BOOT_BIN) $(PWD)/$@
    @cp -v $(ROOT_BOOT_DIR)/new-boot.img $(PRODUCT_OUT)/boot.img
    @echo "++++  Exec regular AVB handling after rooting  ++++"
    $(call assert-max-image-size,$(1),$(call get-hash-image-max-size,$(call get-bootimage-partition-size,$(1),boot)))
    $(AVBTOOL) add_hash_footer \
	--image $(1) \
        $(call get-partition-size-argument,$(call get-bootimage-partition-size,$(1),boot)) \
	--partition_name boot $(INTERNAL_AVB_BOOT_SIGNING_ARGS) \
	$(BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS)
    @echo "++++  PRE-ROOTing BOOT image - DONE  ++++"
endef

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(AVBTOOL) $(INTERNAL_BOOTIMAGE_FILES) $(BOARD_AVB_BOOT_KEY_PATH) $(INTERNAL_GKI_CERTIFICATE_DEPS) $(BOOTIMAGE_EXTRA_DEPS)
	$(call er_preroot_avb,$@)

else ifeq (true,$(PRODUCT_SUPPORTS_VBOOT)) # PRODUCT_SUPPORTS_BOOT_SIGNER != true

define er_preroot_vboot
    @echo "++++  Exec regular boot.img handling before rooting  ++++"
    $(MKBOOTIMG) --kernel $(call bootimage-to-kernel,$(1)) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $(1).unsigned
    $(VBOOT_SIGNER) $(FUTILITY) $(1).unsigned $(PRODUCT_VBOOT_SIGNING_KEY).vbpubk $(PRODUCT_VBOOT_SIGNING_KEY).vbprivk $(PRODUCT_VBOOT_SIGNING_SUBKEY).vbprivk $(1).keyblock $(1)
    @echo "++++  PRE-ROOTing BOOT image (vboot)  ++++"
    @/bin/bash $(ROOT_BOOT_BIN) $$PWD/$@
    @cp -v $(ROOT_BOOT_DIR)/new-boot.img $(PRODUCT_OUT)/boot.img
    $(call assert-max-image-size,$(1),$(call get-bootimage-partition-size,$(1),boot))
    @echo "++++  PRE-ROOTing BOOT image - DONE  ++++"
endef

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(VBOOT_SIGNER) $(FUTILITY) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target boot image: $@")
	$(call er_preroot_vboot,$@)

else # PRODUCT_SUPPORTS_VBOOT != true

define er_preroot_novboot
    @echo "++++  Exec regular boot.img handling before rooting  ++++"
    $(MKBOOTIMG) --kernel $(call bootimage-to-kernel,$(1)) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $(1)
    $(call assert-max-image-size,$1,$(call get-bootimage-partition-size,$(1),boot))
    @echo "++++  PRE-ROOTing BOOT image (novboot)  ++++"
    @/bin/bash $(ROOT_BOOT_BIN) $$PWD/$@
    @cp -v $(ROOT_BOOT_DIR)/new-boot.img $(PRODUCT_OUT)/boot.img
    @echo "++++  PRE-ROOTing BOOT image - DONE  ++++"
endef

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target boot image: $@")
	$(call er_preroot_novboot,$@)

endif # BOARD_AVB_ENABLE

