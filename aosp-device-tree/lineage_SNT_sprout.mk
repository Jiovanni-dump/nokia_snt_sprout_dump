#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from SNT_sprout device
$(call inherit-product, device/hmd/SNT_sprout/device.mk)

PRODUCT_DEVICE := SNT_sprout
PRODUCT_NAME := lineage_SNT_sprout
PRODUCT_BRAND := Nokia
PRODUCT_MODEL := Nokia XR21
PRODUCT_MANUFACTURER := hmd

PRODUCT_GMS_CLIENTID_BASE := android-hmd

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="Sentry_00WW-user 13 TKQ1.220807.001 00WW_2_210 release-keys"

BUILD_FINGERPRINT := Nokia/Sentry_00WW/SNT_sprout:13/TKQ1.220807.001/00WW_2_210:user/release-keys
