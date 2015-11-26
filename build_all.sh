#!/bin/sh
#set -e
set -x
DIR=$(pwd)

git submodule update --init --recursive


cd ./Parse-SDK-iOS-OSX
# build Parse and Bolts
bundle install
bundle exec rake package:frameworks

cd $DIR

export XCODE_XCCONFIG_FILE=$(pwd)/Configurations/iOS-module.xcconfig

# build the Facebook iOS toolchain
facebook-ios-sdk/scripts/build_framework.sh -n -c Release || die

mkdir -p Carthage/Build/iOS

# cleanup the directory
rm -rf Carthage/Build/iOS/*

# # copy the FBSDK frameworks
cp -av facebook-ios-sdk/build/FBSDKLoginKit.framework \
	facebook-ios-sdk/build/FBSDKCoreKit.framework \
	facebook-ios-sdk/build/FBSDKShareKit.framework \
	Carthage/Build/iOS/

# # Copy the Parse SDK + Bolts
unzip Parse-SDK-iOS-OSX/build/release/Parse-iOS-Dynamic.zip -d Carthage/Build/iOS

# # Cleanup the vendor
rm -rf ParseFacebookUtils-iOS/Vendor/*.framework
rm -rf ParseTwitterUtils-iOS/Vendor/*.framework

cp -av Carthage/Build/iOS/* ParseFacebookUtils-iOS/Vendor/
cp -av Carthage/Build/iOS/* ParseTwitterUtils-iOS/Vendor/
unset XCCODE_XCCONFIG_FILE

sh Scripts/build_framework.sh ParseTwitterUtils-iOS ParseTwitterUtils ParseTwitterUtils-iOS ParseTwitterUtils
cp -av build/ios/ParseTwitterUtils.framework Carthage/Build/iOS/

sh Scripts/build_framework.sh ParseFacebookUtils-iOS ParseFacebookUtils ParseFacebookUtilsV4-iOS ParseFacebookUtilsV4
cp -av build/ios/ParseFacebookUtilsV4.framework Carthage/Build/iOS/

zip build/ParseToolchain.framework.zip ./Carthage/*
