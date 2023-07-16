##################################################################
# backwards compat for at least A9 where the environment vars
# do not get parsed and become build flags automatically

ifeq ($(EXTENDROM_BOOT_DEBUG),)
EXTENDROM_BOOT_DEBUG := $(shell echo $$EXTENDROM_BOOT_DEBUG)
endif
ifeq ($(EXTENDROM_PREROOT_BOOT),)
EXTENDROM_PREROOT_BOOT := $(shell echo $$EXTENDROM_PREROOT_BOOT)
endif
ifeq ($(EXTENDROM_SIGNATURE_SPOOFING),)
EXTENDROM_SIGNATURE_SPOOFING := $(shell echo $$EXTENDROM_SIGNATURE_SPOOFING)
endif

##################################################################
# Custom packages

ifdef EXTENDROM_PACKAGES
PRODUCT_PACKAGES += $(EXTENDROM_PACKAGES)
endif

##################################################################
# enable gesture support in /e/ OS
# DEPRECATED?!

ifeq ($(EOS_GESTURES),true)
# set specific overlay
DEVICE_PACKAGE_OVERLAYS += \
    vendor/extendrom/overlay-gestures
# build TrebuchetQuickStep (get_prebuilts.sh must be executed once at least)
PRODUCT_PACKAGES += eOSTrebuchetQuickStep
endif

##################################################################
# extendrom vendor makefile

$(call inherit-product, vendor/extendrom/er.mk)
