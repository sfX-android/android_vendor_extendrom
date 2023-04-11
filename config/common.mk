# Custom packages
ifdef EXTENDROM_PACKAGES
PRODUCT_PACKAGES += $(EXTENDROM_PACKAGES)
endif

# enable gesture support in /e/ OS
# DEPRECATED?!
ifeq ($(EOS_GESTURES),true)
# set specific overlay
DEVICE_PACKAGE_OVERLAYS += \
    vendor/extendrom/overlay-gestures
# build TrebuchetQuickStep (get_prebuilts.sh must be executed once at least)
PRODUCT_PACKAGES += eOSTrebuchetQuickStep
endif

# extendrom vendor makefile
$(call inherit-product, vendor/extendrom/er.mk)
