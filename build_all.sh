#!/bin/sh
set -e
set -x
DIR=$(pwd)

git submodule update --init --recursive


cd ./Parse-SDK-iOS-OSX
# build Parse and Bolts
rake package:frameworks

cd $DIR

cp -Rf ./Parse-SDK-iOS-OSX/build/ios/* ./ParseFacebookUtils-iOS/Vendor/
cp -Rf ./Parse-SDK-iOS-OSX/build/ios/* ./ParseTwitterUtils-iOS/Vendor/