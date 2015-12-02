#!/bin/sh

DIR=$(pwd)

CARTHAGE_IOS=Carthage/Build/iOS

git submodule update --init --recursive

mkdir -p ${CARTHAGE_IOS}

# cleanup the directory
rm -rf ${CARTHAGE_IOS}/*

echo "travis_fold:start:Parse-SDK-iOS-OSX\r"

cd ./Parse-SDK-iOS-OSX
# build Parse and Bolts
bundle install
bundle exec rake package:framework:ios_dynamic

cd $DIR

# # # Copy the Parse SDK + Bolts
unzip Parse-SDK-iOS-OSX/build/release/Parse-iOS-Dynamic.zip -d ${CARTHAGE_IOS}

echo "travis_fold:end:Parse-SDK-iOS-OSX\r"

echo "travis_fold:start:Facebook-SDK-iOS\r"

export XCODE_XCCONFIG_FILE=$(pwd)/Configurations/iOS-module.xcconfig
# build the Facebook iOS toolchain
facebook-ios-sdk/scripts/build_framework.sh -n -c Release

unset XCCODE_XCCONFIG_FILE

echo "travis_fold:end:Facebook-SDK-iOS\r"
# copy the FBSDK frameworks

FB_SDK_CORE_KIT_VERSION=$(cat facebook-ios-sdk/FBSDKCoreKit.podspec | grep s.version | sed s/^.*=\ //g | sed s/\"//g)
FB_SDK_SHARE_KIT_VERSION=$(cat facebook-ios-sdk/FBSDKShareKit.podspec | grep s.version | sed s/^.*=\ //g | sed s/\"//g)
FB_SDK_LOGIN_KIT_VERSION=$(cat facebook-ios-sdk/FBSDKLoginKit.podspec | grep s.version | sed s/^.*=\ //g | sed s/\"//g)

cp -R facebook-ios-sdk/build/FBSDKLoginKit.framework \
	facebook-ios-sdk/build/FBSDKCoreKit.framework \
	facebook-ios-sdk/build/FBSDKShareKit.framework \
	Carthage/Build/iOS/

function setVersion() {
	/usr/libexec/PlistBuddy -c "Set:CFBundleVersion $1" $2
	/usr/libexec/PlistBuddy -c "Set:CFBundleShortVersionString $1" $2
}
setVersion $FB_SDK_CORE_KIT_VERSION Carthage/Build/iOS/FBSDKCoreKit.framework/Info.plist
setVersion $FB_SDK_SHARE_KIT_VERSION Carthage/Build/iOS/FBSDKLoginKit.framework/Info.plist
setVersion $FB_SDK_LOGIN_KIT_VERSION Carthage/Build/iOS/FBSDKShareKit.framework/Info.plist

# # Cleanup the vendor
rm -rf ParseFacebookUtils-iOS/Vendor/*.framework
rm -rf ParseTwitterUtils-iOS/Vendor/*.framework

cp -R ${CARTHAGE_IOS}/* ParseFacebookUtils-iOS/Vendor/
cp -R ${CARTHAGE_IOS}/* ParseTwitterUtils-iOS/Vendor/

echo "travis_fold:start:ParseTwitterUtils-iOS\r"
sh Scripts/build_framework.sh ParseTwitterUtils-iOS ParseTwitterUtils ParseTwitterUtils-iOS ParseTwitterUtils
cp -R ParseTwitterUtils-iOS/build/ios/ParseTwitterUtils.framework ${CARTHAGE_IOS}/
echo "travis_fold:end:ParseTwitterUtils-iOS\r"

echo "travis_fold:start:ParseFacebookUtils-iOS\r"
sh Scripts/build_framework.sh ParseFacebookUtils-iOS ParseFacebookUtils ParseFacebookUtilsV4-iOS ParseFacebookUtilsV4
cp -R ParseFacebookUtils-iOS/build/ios/ParseFacebookUtilsV4.framework ${CARTHAGE_IOS}/
echo "travis_fold:end:ParseFacebookUtils-iOS\r"

for i in $(ls $CARTHAGE_IOS); do
	$(/usr/libexec/PlistBuddy $CARTHAGE_IOS/$i/Info.plist -c "Set:DTXcode 0711")
	$(/usr/libexec/PlistBuddy $CARTHAGE_IOS/$i/Info.plist -c "Set:DTXcodeBuild 7B1005")
done

zip -r ParseKit.framework.zip Carthage

