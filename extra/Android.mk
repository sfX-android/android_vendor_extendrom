LOCAL_PATH := $(call my-dir)

# override /e/ apps store
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSappstore
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Apps
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ BlissLauncher
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSlauncher
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := BlissLauncher
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ Mail
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSMail
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Mail
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ Calendar
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSCalendar
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Calendar
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ Message
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSMessage
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Message
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ PdfViewer
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSPdfViewer
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := PdfViewer
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ LibreOfficeViewer
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSLibreOfficeViewer
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := LibreOfficeViewer
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ Camera
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSCamera
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Camera
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ eSpeakTTS
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSeSpeakTTS
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := eSpeakTTS
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override eSpeakNG
include $(CLEAR_VARS)
LOCAL_MODULE := noeSpeakNG
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := eSpeakNG
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ GmsCore
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSGmsCore
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := GmsCore
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ GsfProxy
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSGsfProxy
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := GsfProxy
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ FakeStore
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSFakeStore
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := FakeStore
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ com.google.android.maps.jar
include $(CLEAR_VARS)
LOCAL_MODULE := noEOScom.google.android.maps.jar
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := com.google.android.maps.jar
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ BlissIconPack
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSBlissIconPack
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := BlissIconPack
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ MozillaNlpBackend
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSMozillaNlpBackend
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := MozillaNlpBackend
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ OpenWeatherMapWeatherProvider
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSOpenWeatherMapWeatherProvider
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := OpenWeatherMapWeatherProvider
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ AccountManager
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSAccountManager
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := AccountManager
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ eDrive
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSeDrive
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := eDrive
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ Notes
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSNotes
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Notes
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ Tasks
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSTasks
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Tasks
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ ESmsSync
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSESmsSync
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := ESmsSync
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ NominatimNlpBackend
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSNominatimNlpBackend
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := NominatimNlpBackend
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ DroidGuard
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSDroidGuard
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := DroidGuard
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ OpenKeychain
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSOpenKeychain
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := OpenKeychain
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ Browser
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSBrowser
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Browser
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ BrowserWebView
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSBrowserWebView
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := BrowserWebView
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ PwaPlayer
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSPwaPlayer
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := PwaPlayer
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override /e/ MagicEarth
include $(CLEAR_VARS)
LOCAL_MODULE := noEOSMagicEarth
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := MagicEarth
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)


# override graphene Vanadium
include $(CLEAR_VARS)
LOCAL_MODULE := noGOSvanadium
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := TrichromeChrome
# TrichromeWebView \
# TrichromeLibrary
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# override graphene Auditor
include $(CLEAR_VARS)
LOCAL_MODULE := noGOSauditor
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Auditor
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# override graphene Messaging
include $(CLEAR_VARS)
LOCAL_MODULE := noGOSmessaging
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := messaging
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# override graphene Dialer
include $(CLEAR_VARS)
LOCAL_MODULE := noGOSdialer
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Dialer
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# override graphene Dialer
include $(CLEAR_VARS)
LOCAL_MODULE := noGOScontacts
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Contacts
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# override graphene Updater
include $(CLEAR_VARS)
LOCAL_MODULE := noGOSupdater
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Updater
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# override graphene PdfViewer
include $(CLEAR_VARS)
LOCAL_MODULE := noGOSpdfviewer
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := PdfViewer PdfViewerGOS
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# override graphene Files
include $(CLEAR_VARS)
LOCAL_MODULE := noGOSfiles
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := DocumentsUI
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# override graphene SeedVault
include $(CLEAR_VARS)
LOCAL_MODULE := noSeedvault
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Seedvault
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# override BrowserWebView (LOS, eOS, LOS-based ones)
include $(CLEAR_VARS)
LOCAL_MODULE := noDefaultBrowserWebView
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := BrowserWebView
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override Stk (com.android.stk)
include $(CLEAR_VARS)
LOCAL_MODULE := noStk
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Stk
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# no first boot setup wizard
include $(CLEAR_VARS)
LOCAL_MODULE := noWizard
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := SetupWizard SetupWizard2
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# com.android.vending.xml permissions required by phonesky
include $(CLEAR_VARS)
LOCAL_MODULE := com.android.vending.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
# part of Phonesky - do not move to /system_ext !
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/permissions
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

# phonesky-permissions.xml permissions required by phonesky
include $(CLEAR_VARS)
LOCAL_MODULE := phonesky-permissions.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
# part of Phonesky - do not move to /system_ext !
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/default-permissions
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

# F-Droid permissions only (only needed if not building privileged module)
include $(CLEAR_VARS)
LOCAL_MODULE := permissions_org.fdroid.fdroid.privileged.xml_OR
LOCAL_OVERRIDES_PACKAGES := permissions_org.fdroid.fdroid.privileged.xml
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)/permissions
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

# required by MicrogGmsCore 
include $(CLEAR_VARS)
LOCAL_MODULE := er_microg.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_ETC)/permissions
else
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/permissions
endif
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := er_privapp-permissions-com.google.android.gms.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_ETC)/permissions
else
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/permissions
endif
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := er_sysconfig-com.google.android.gms.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_ETC)/sysconfig
else
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/sysconfig
endif
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := er_exceptions-com.google.android.gms.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_ETC)/permissions
else
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/permissions
endif
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

# F-Droid self-built/prebuilt
include $(CLEAR_VARS)
LOCAL_MODULE := F-Droid-SB
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_SRC_FILES := fdroidclient.apk
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/app
include $(BUILD_PREBUILT)

# permissions_com.aurora.services.xml permissions required by AuroraServices
include $(CLEAR_VARS)
LOCAL_MODULE := permissions_com.aurora.services.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_ETC)/permissions
else
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/permissions
endif
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

# override lineageOSnoLOSEmail
include $(CLEAR_VARS)
LOCAL_MODULE := noLOSEmail
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Email 
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override lineageOS Messaging
include $(CLEAR_VARS)
LOCAL_MODULE := noLOSMessaging
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := messaging
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override lineageOS Snap
include $(CLEAR_VARS)
LOCAL_MODULE := noLOSSnap
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Snap
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)

# override lineageOS Jelly
include $(CLEAR_VARS)
LOCAL_MODULE := noLOSJelly
LOCAL_SRC_FILES := empty.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_SUFFIX := .apk
LOCAL_OVERRIDES_PACKAGES := Jelly
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_APPS)
endif
include $(BUILD_PREBUILT)
 
# Permissions for microG FakeStore
include $(CLEAR_VARS)
LOCAL_MODULE := er_privapp-permissions-com.android.vending.xml
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/permissions
LOCAL_SRC_FILES := permissions-com.android.vending.xml
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := er_default-permissions-com.android.vending.xml
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/default-permissions
LOCAL_SRC_FILES := default-permissions-com.android.vending.xml
include $(BUILD_PREBUILT)

# Default permissions for Neo Launcher
include $(CLEAR_VARS)
LOCAL_MODULE := er_default-permissions-neolauncher.xml
LOCAL_MODULE_CLASS := ETC
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_ETC)/default-permissions
else
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/default-permissions
endif # LOCAL_MODULE_PATH
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),33), true)
LOCAL_SRC_FILES := er_default-permissions-neolauncher.xml
else
LOCAL_SRC_FILES := er_default-permissions-neolauncher_legacy.xml
endif # LOCAL_SRC_FILES
include $(BUILD_PREBUILT)

# OpenEUICC permissions
include $(CLEAR_VARS)
LOCAL_MODULE := er_privapp_whitelist_im.angry.openeuicc.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
LOCAL_MODULE_PATH := $(TARGET_OUT_SYSTEM_EXT_ETC)/permissions
else
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/permissions
endif
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)
