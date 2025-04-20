#!/bin/bash

echo "🧹 Removing old QCOM hardware directory..."
rm -rf hardware/qcom-caf/common

echo "📦 Cloning device trees..."
git clone -b 15_qpr2_axion git@github.com:skwel-private/device_xiaomi_topaz.git device/xiaomi/topaz
git clone -b fifteen git@github.com:skwel-stuffs/device_xiaomi_topaz-kernel.git device/xiaomi/topaz-kernel
git clone -b fifteen git@github.com:skwel-stuffs/android_device_xiaomi_sepolicy.git device/xiaomi/sepolicy
git clone -b lineage-22.2-micam git@github.com:skwel-private/device_xiaomi_miuicamera-topaz.git device/xiaomi/miuicamera-topaz

echo "📦 Cloning vendor trees..."
git clone -b 15_qpr2 git@github.com:skwel-private/vendor_xiaomi_topaz.git vendor/xiaomi/topaz
git clone -b v1.2 git@github.com:skwel-private/vendor_xiaomi_dolby-atmos.git vendor/xiaomi/dolby-atmos
git clone -b lineage-22.2-micam git@gitea.com:skwel/new_vendor_xiaomi_miuicamera-topaz.git vendor/xiaomi/miuicamera-topaz

echo "📦 Cloning hardware trees..."
git clone -b fifteen git@github.com:skwel-stuffs/android_hardware_xiaomi.git hardware/xiaomi
git clone -b fifteen git@github.com:skwel-stuffs/hardware_qcom-caf_common.git hardware/qcom-caf/common

echo "✅ All done!"
