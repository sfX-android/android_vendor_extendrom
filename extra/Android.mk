LOCAL_PATH := $(call my-dir)

ifeq ($(FDROID_EXTRA_REPOS),true)

include $(CLEAR_VARS)
LOCAL_MODULE := additional_repos.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/org.fdroid.fdroid
LOCAL_SRC_FILES := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

endif
