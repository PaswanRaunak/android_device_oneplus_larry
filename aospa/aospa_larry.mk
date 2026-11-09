#
# Copyright (C) 2026 The PenguinOS Project
# SPDX-License-Identifier: Apache-2.0
#
# PenguinOS (AOSPA-based, Android 17) product for OnePlus Nord CE 3 Lite 5G (larry)
# Reuses the unmodified LineageOS 24.0 device trees; only the ROM layer is PenguinOS.
#

ifeq (aospa_larry,$(TARGET_PRODUCT))

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Device layer — unmodified LineageOS trees (device.mk chains sm6375-common)
$(call inherit-product, device/oneplus/larry/device.mk)

# AOSPA's device/qcom/common (pulled by aospa-target.mk) asserts TARGET_BOARD_PLATFORM
# at product-parse time; the LOS tree defines it only in BoardConfigCommon.mk (board
# level). Re-declare the identical value here so the product-graph pre-pass passes.
# Board config later assigns the same value — no drift possible.
TARGET_BOARD_PLATFORM := holi

# Soong-tree conflict resolution for the LOS/AOSPA hybrid:
#
# 1. vendor/lineage is synced only for its raw makefiles (BoardConfigReservedSize.mk
#    is consumed via -include, which works without soong scanning). Exclude the whole
#    tree from soong: its six LOS overlay RROs are unreferenced (NcmTetheringOverlay
#    is provided by device/qcom/common) and its build/soong generator plugin
#    (soong-lineage-generator) does not compile against celerity's soong-android
#    (undefined android.PathForSourceRelaxed) and would fail soong bootstrap.
PRODUCT_SOURCE_ROOT_DIRS += -vendor/lineage/overlay

# 2. fwk-detect modules are defined by BOTH hardware/qcom-caf/common (needed for the
#    CneApp blob's CneApp.libvndfwk_detect_jni.qti_symlink) and vendor/qcom/opensource/
#    core-utils (pulled by aospa-target.mk). Exclude core-utils' copy: aospa-target's
#    module references (libvndfwk_detect_jni.qti, libqti_vndfwk_detect, +multilib)
#    resolve from the CAF definitions; core-utils' unique vndfwk-test is referenced
#    by nothing in this product.
PRODUCT_SOURCE_ROOT_DIRS += -vendor/qcom/opensource/core-utils/fwk-detect

# 2b. Additional Soong duplicate-module collisions between the LOS CAF trees and
#     celerity's AOSPA/QCOM trees, resolved by excluding the AOSPA-side copies
#     (CAF definitions are the 5.4-era ones this device uses):
#     - memtrack: CAF provides vendor.qti.hardware.memtrack-service
#     - display libs (libmemutils/libsdedrm): CAF sm8350/display provides
#     - perf client (libqti-perfd-client): CAF common provides (sm6375.mk refs)
#     - nqnfcinfo: CAF common provides (unreferenced, dup of AOSPA nfc/nq)
PRODUCT_SOURCE_ROOT_DIRS += \
    -device/qcom/vendor-common/memtrack \
    -hardware/qcom-caf/sm8350/display/libmemutils \
    -hardware/qcom-caf/sm8350/display/sde-drm \
    -hardware/qcom-caf/sm8350/display/sdm/libs/core \
    -hardware/qcom-caf/sm8350/display/qmaa \
    -vendor/qcom/common/vendor/display/4.14 \
    -vendor/qcom/common/vendor/nfc/nq \
    -vendor/qcom/common/vendor/media/5.4


# 2c. Health HAL collision: AOSPA vendor/aospa/interfaces/health re-defines
#     vendor.lineage.health_interface + vendor.lineage.health-service.default,
#     which the LOS device tree builds from hardware/lineage/interfaces (with the
#     lineage_health soong config for oplus charging). Exclude the AOSPA copies.
PRODUCT_SOURCE_ROOT_DIRS += -vendor/aospa/interfaces/health


# 2d. vendor/lineage/prebuilt/common uses LOS-only module types (prebuilt_addon_d)
#     that do not exist in celerity soong; its addon prebuilts are unused here.
PRODUCT_SOURCE_ROOT_DIRS += -vendor/lineage/prebuilt/common
PRODUCT_SOURCE_ROOT_DIRS += -vendor/lineage/bootanimation
PRODUCT_SOURCE_ROOT_DIRS += -vendor/lineage/charger


# 2e. QACS (ambient data capture telemetry) imports vendor.qti.hardware.display.config-V18
#     from the CLO display repo, which celerity does not sync; the module is unreferenced.
PRODUCT_SOURCE_ROOT_DIRS += -vendor/qcom/opensource/interfaces/qacs
# FM HAL: the OxygenOS vendor blob supplies the vendor HIDL interface.
# The larry device does not use the unreferenced commonsys FM stack.
PRODUCT_SOURCE_ROOT_DIRS += \
    -vendor/aospa/interfaces/qcom/fm \
    -vendor/qcom/opensource/commonsys/fm
# 2g. CLO QAC services (telemetry) need QAI interfaces from the unsynced CLO
#     repo tree; unreferenced by this product.
PRODUCT_SOURCE_ROOT_DIRS += -vendor/qcom/opensource/qac-services

# 2h. Power HAL: the LOS device tree references lineage-libperfmgr, which requires
#     Google Pixel power-libperfmgr repositories (powerhal_flags-aconfig-cc, libperfmgr)
#     not synced in PenguinOS/AOSPA celerity. PenguinOS utilizes Qualcomm's native
#     AIDL power HAL (vendor/qcom/opensource/power) with holi target support.
PRODUCT_SOURCE_ROOT_DIRS += \
    -hardware/lineage/interfaces/power-libperfmgr \
    -hardware/oplus/packages/Euicc

PRODUCT_PACKAGES := $(filter-out \
    android.hardware.power-service.lineage-libperfmgr, \
    $(PRODUCT_PACKAGES))

PRODUCT_SOONG_NAMESPACES := $(filter-out \
    hardware/lineage/interfaces/power-libperfmgr \
    hardware/google/pixel/power-libperfmgr, \
    $(PRODUCT_SOONG_NAMESPACES))

# Kernel prebuilts — built standalone (celerity has no source-kernel integration);
# staged from /mnt/nvme-build/kernel-out-larry-nomodversions, see
# ~/penguin-reports/larry-kernel-build-nomodversions-report.md.
# celerity consumes: PRODUCT_COPY_FILES ...:kernel (= INSTALLED_KERNEL_TARGET),
# BOARD_PREBUILT_DTBOIMAGE (source-tree input for both Soong fsgen and Make dtbo.img),
# BOARD_PREBUILT_DTBIMAGE_DIR (concatenates *.dtb -> dtb.img, consumed as --dtb by boot
# and vendor_boot), and BOARD_VENDOR_KERNEL_MODULES (soong kernel_modules_builder;
# LOAD/BLOCKLIST lists are already wired by BoardConfigCommon.mk). TARGET_PREBUILT_KERNEL
# is dead in celerity (0 references) and intentionally not used.
PRODUCT_COPY_FILES += \
    device/oneplus/larry/prebuilt/Image:kernel
BOARD_PREBUILT_DTBOIMAGE := device/oneplus/larry/prebuilt/dtbo.img
BOARD_PREBUILT_DTBIMAGE_DIR := device/oneplus/larry/prebuilt/dtb
BOARD_VENDOR_KERNEL_MODULES := $(wildcard device/oneplus/larry/prebuilt/modules/*.ko)
TARGET_PREBUILT_KERNEL := device/oneplus/larry/prebuilt/Image
TARGET_NO_KERNEL_OVERRIDE := true

# Lineage Soong variable exports for vendor/lineage/build/soong (lineage_generator)
KERNEL_ARCH ?= arm64
TARGET_KERNEL_SOURCE ?= kernel/oneplus/sm6375
EXPORT_TO_SOONG := \
    KERNEL_ARCH \
    KERNEL_BUILD_OUT_PREFIX \
    KERNEL_CROSS_COMPILE \
    KERNEL_MAKE_CMD \
    KERNEL_MAKE_FLAGS \
    KERNEL_PATH \
    PATH_OVERRIDE_SOONG \
    TARGET_KERNEL_CONFIG \
    TARGET_KERNEL_SOURCE \
    TARGET_KERNEL_PLATFORM_TARGET \
    TARGET_MAX_PAGE_SIZE_SUPPORTED \
    TARGET_PREBUILT_KERNEL_HEADERS

$(call add_soong_config_namespace,lineageVarsPlugin)
$(foreach v,$(EXPORT_TO_SOONG),$(eval $(call add_soong_config_var,lineageVarsPlugin,$(v))))

# PenguinOS ROM layer (AOSPA-style; pulls vendor/gms, overlays, device/qcom/common)
$(call inherit-product, vendor/aospa/target/product/aospa-target.mk)

PRODUCT_NAME := aospa_larry
PRODUCT_DEVICE := larry
PRODUCT_BRAND := OnePlus
PRODUCT_MODEL := CPH2467
PRODUCT_MANUFACTURER := OnePlus

PRODUCT_GMS_CLIENTID_BASE := android-oppo

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="OP5958L1-user 15 UKQ1.230924.001 T.R4T2.25dedad-3a53d-3a53e release-keys" \
    BuildFingerprint=OnePlus/CPH2467/OP5958L1:15/UKQ1.230924.001/T.R4T2.25dedad-3a53d-3a53e:user/release-keys \
    DeviceName=OP5958L1 \
    DeviceProduct=OP5958L1 \
    SystemDevice=OP5958L1 \
    SystemName=OP5958L1

endif

# Qualcomm WLAN namespaces: wpa_supplicant driver command and Wi-Fi HAL
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom/wlan/qcwcn \
    hardware/qcom/wlan/qcwcn/wpa_supplicant_8_lib \
    vendor/qcom/opensource/dataservices
