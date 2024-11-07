##################################################################
# backwards compat for at least A9 where the environment vars
# do not get parsed and become build flags automatically

$(call inherit-product-if-exists, vendor/extendrom/mkvars.mk)

ifeq ($(EXTENDROM_BOOT_DEBUG),)
EXTENDROM_BOOT_DEBUG := $(shell echo $$EXTENDROM_BOOT_DEBUG)
endif

ifeq ($(EXTENDROM_PREROOT_BOOT),)
EXTENDROM_PREROOT_BOOT := $(shell echo $$EXTENDROM_PREROOT_BOOT)
endif

##################################################################
# enable gesture support in /e/ OS
# DEPRECATED!

ifeq ($(EOS_GESTURES),true)
# set specific overlay
DEVICE_PACKAGE_OVERLAYS += \
    vendor/extendrom/overlays/gestures
# build TrebuchetQuickStep (get_prebuilts.sh must be executed once at least)
PRODUCT_PACKAGES += eOSTrebuchetQuickStep
endif

##################################################################
# Signature spoofing overlays

# backwards compat for old Android releases where environment vars do not become build flags
ifeq ($(EXTENDROM_SIGNATURE_SPOOFING),)
EXTENDROM_SIGNATURE_SPOOFING := $(shell echo $$EXTENDROM_SIGNATURE_SPOOFING)
endif

ifeq ($(EXTENDROM_SIGNATURE_SPOOFING),true)
DEVICE_PACKAGE_OVERLAYS += \
    vendor/extendrom/overlays/sigspoof
endif

##################################################################
# Call recording overlay

# backwards compat for old Android releases where environment vars do not become build flags
#ifeq ($(EXTENDROM_ALLOW_ANY_CALL_RECORDING),)
#EXTENDROM_ALLOW_ANY_CALL_RECORDING := $(shell echo $$EXTENDROM_ALLOW_ANY_CALL_RECORDING)
#endif

ifeq ($(EXTENDROM_ALLOW_ANY_CALL_RECORDING),true)
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/extendrom/overlays/call-rec/active
endif # EXTENDROM_ALLOW_ANY_CALL_RECORDING

##################################################################
# extendrom vendor makefile

$(call inherit-product, vendor/extendrom/er.mk)
