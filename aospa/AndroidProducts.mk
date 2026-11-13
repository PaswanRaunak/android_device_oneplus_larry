# PenguinOS (AOSPA-based) product registration for OnePlus larry.
# This directory is a NEW, isolated addition — it does not modify any
# upstream LineageOS file in device/oneplus/larry.
PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/aospa_larry.mk

COMMON_LUNCH_CHOICES := \
    aospa_larry-userdebug \
    aospa_larry-eng
