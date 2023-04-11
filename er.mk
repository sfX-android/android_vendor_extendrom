VENDOR_DIR := vendor/extendrom

ifeq ($(EXTENDROM_BOOT_DEBUG),true)
BOARD_SEPOLICY_DIRS += $(VENDOR_DIR)/sepolicy/boot_debug

PRODUCT_COPY_FILES += \
    $(VENDOR_DIR)/config/init.er.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.extendrom.rc
endif
