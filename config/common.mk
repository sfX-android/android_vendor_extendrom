# Custom packages
ifdef EXTENDROM_PACKAGES
PRODUCT_PACKAGES += $(EXTENDROM_PACKAGES)
endif

# enable gesture support in /e/ OS
ifeq ($(EOS_GESTURES),true)
# set specific overlay
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay-gestures
# build TrebuchetQuickStep (get_prebuilts.sh must be executed once at least)
PRODUCT_PACKAGES += eOSTrebuchetQuickStep
endif
