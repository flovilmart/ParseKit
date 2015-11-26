#!/bin/sh
WORKSPACE=./ParseFacebookUtils-iOS/ParseFacebookUtils.xcworkspace
SCHEME=ParseFacebookUtilsV4-iOS
CONFIGURATION=Release
BUILD_DIR=./build

FRAMEWORK_NAME=ParseFacebookUtilsV4

SIMULATOR_LIBRARY_PATH="./ParseFacebookUtils-iOS/build/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework"
DEVICE_LIBRARY_PATH="./ParseFacebookUtils-iOS/build/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework"
UNIVERSAL_LIBRARY_DIR="./ParseFacebookUtils-iOS/build/ios"
FRAMEWORK="${UNIVERSAL_LIBRARY_DIR}/${FRAMEWORK_NAME}.framework"

export XCODE_XCCONFIG_FILE=./Configurations/iOS-module.xcconfig

xcodebuild -workspace ${WORKSPACE} -scheme ${SCHEME} -configuration ${CONFIGURATION} BUILD_DIR=${BUILD_DIR}
xcodebuild -workspace ${WORKSPACE} -scheme ${SCHEME} -configuration ${CONFIGURATION} -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.1' BUILD_DIR=${BUILD_DIR} | xcpretty

rm -rf "${UNIVERSAL_LIBRARY_DIR}"

mkdir "${UNIVERSAL_LIBRARY_DIR}"

mkdir "${FRAMEWORK}"


cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"
lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${FRAMEWORK}/${FRAMEWORK_NAME}" | echo
# For Swift framework, Swiftmodule needs to be copied in the universal framework
if [ -d "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
       cp -f ${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/*
       "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi

if [ -d "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
       cp -f ${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/* "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi

echo "${FRAMEWORK_NAME}.framework is in ./build/ios"

cd $PWD