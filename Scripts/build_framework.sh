#!/bin/sh
ROOT_DIR=$1
WORKSPACE_NAME=$2
SCHEME=$3
FRAMEWORK_NAME=$4

WORKSPACE=$ROOT_DIR/$WORKSPACE_NAME.xcworkspace
CONFIGURATION=Release
BUILD_DIR=${ROOT_DIR}/build


SIMULATOR_LIBRARY_PATH="${ROOT_DIR}/build/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework"
DEVICE_LIBRARY_PATH="${ROOT_DIR}/build/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework"
UNIVERSAL_LIBRARY_DIR="${ROOT_DIR}/build/ios"
FRAMEWORK="${UNIVERSAL_LIBRARY_DIR}/${FRAMEWORK_NAME}.framework"

export XCODE_XCCONFIG_FILE=./Configurations/iOS-module.xcconfig


xctool clean -workspace ${WORKSPACE} -scheme ${SCHEME} -configuration ${CONFIGURATION} BUILD_DIR=${BUILD_DIR}

xctool build -workspace ${WORKSPACE} -scheme ${SCHEME} -configuration ${CONFIGURATION} BUILD_DIR=${BUILD_DIR}
xctool build -workspace ${WORKSPACE} -scheme ${SCHEME} -configuration ${CONFIGURATION} -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.1' BUILD_DIR=${BUILD_DIR}

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

echo "${FRAMEWORK_NAME}.framework is in ${BUILD_DIR}/ios"

cd $PWD