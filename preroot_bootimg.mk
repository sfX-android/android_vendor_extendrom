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

ifeq ($(OUT_DIR), $(PWD)/out)
UNI_OUT_DIR := $(OUT_DIR)
UNI_PRODUCT_OUT := $(PRODUCT_OUT)
else
UNI_OUT_DIR := $(PWD)/out
UNI_PRODUCT_OUT := $(PWD)/$(PRODUCT_OUT)
endif
ROOT_BOOT_DIR := $(UNI_OUT_DIR)/.magisk
ROOT_BOOT_BIN := $(ROOT_BOOT_DIR)/boot_patch.sh

############################################################################################################
# DT.IMG | dt.img
############################################################################################################

ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DT)),true)
INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img

ifeq ($(strip $(BOARD_KERNEL_PREBUILT_DT)),)

ifeq ($(strip $(TARGET_CUSTOM_DTBTOOL)),)
DTBTOOL_NAME := dtbToolLineage
else
DTBTOOL_NAME := $(TARGET_CUSTOM_DTBTOOL)
endif

DTBTOOL := $(HOST_OUT_EXECUTABLES)/$(DTBTOOL_NAME)$(HOST_EXECUTABLE_SUFFIX)

ifeq ($(strip $(TARGET_CUSTOM_DTBTOOL)),)
# dtbToolLineage will search subdirectories
possible_dtb_dirs = $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/
else
# Most specific paths must come first in possible_dtb_dirs
possible_dtb_dirs = $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/dts/ $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/
endif

define build-dtimage-target
    $(call pretty,"Target dt image: $@")
    $(hide) for dir in $(possible_dtb_dirs); do \
        if [ -d "$$dir" ]; then \
            dtb_dir="$$dir"; \
            break; \
        fi; \
    done; \
    $(DTBTOOL) $(BOARD_DTBTOOL_ARGS) -o $@ -s $(BOARD_KERNEL_PAGESIZE) -p $(KERNEL_OUT)/scripts/dtc/ "$$dtb_dir";
    $(hide) chmod a+r $@
endef

ifeq ($(strip $(BOARD_KERNEL_LZ4C_DT)),true)
LZ4_DT_IMAGE := $(PRODUCT_OUT)/dt-lz4.img
endif

$(INSTALLED_DTIMAGE_TARGET): $(DTBTOOL) $(INSTALLED_KERNEL_TARGET)
	$(build-dtimage-target)
ifeq ($(strip $(BOARD_KERNEL_LZ4C_DT)),true)
	prebuilts/tools-lineage/${HOST_OS}-x86/bin/lz4 -9 < $@ > $(LZ4_DT_IMAGE)
	$(hide) $(ACP) $(LZ4_DT_IMAGE) $@
endif
	@echo "Made DT image: $@"

else

$(INSTALLED_DTIMAGE_TARGET) : $(BOARD_KERNEL_PREBUILT_DT) | $(ACP)
	$(transform-prebuilt-to-target)

endif # BOARD_KERNEL_PREBUILT_DT

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_DTIMAGE_TARGET)
ALL_MODULES.$(LOCAL_MODULE).INSTALLED += $(INSTALLED_DTIMAGE_TARGET)

.PHONY: dtimage
dtimage: $(INSTALLED_DTIMAGE_TARGET)

endif # BOARD_KERNEL_SEPARATED_DT

############################################################################################################
# BOOT.IMG | boot.img
############################################################################################################

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
    @/bin/bash $(ROOT_BOOT_BIN) $(UNI_PRODUCT_OUT)/boot.img
    @cp -v $(ROOT_BOOT_DIR)/new-boot.img $(UNI_PRODUCT_OUT)/boot.img
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
    @/bin/bash $(ROOT_BOOT_BIN) $(UNI_PRODUCT_OUT)/boot.img
    @cp -v $(ROOT_BOOT_DIR)/new-boot.img $(UNI_PRODUCT_OUT)/boot.img
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
    @/bin/bash $(ROOT_BOOT_BIN) $(UNI_PRODUCT_OUT)/boot.img
    @cp -v $(ROOT_BOOT_DIR)/new-boot.img $(UNI_PRODUCT_OUT)/boot.img
    @echo "++++  PRE-ROOTing BOOT image - DONE  ++++"
endef

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target boot image: $@")
	$(call er_preroot_novboot,$@)

endif # BOARD_AVB_ENABLE

############################################################################################################
# RECOVERY.IMG | recovery.img
############################################################################################################

# recovery
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_ramdisk) $(recovery_kernel) \
	$(RECOVERYIMAGE_EXTRA_DEPS)
	@echo ----- Making recovery image ------
	$(call build-recoveryimage-target, $@)
