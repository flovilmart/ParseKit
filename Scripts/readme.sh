CARTHAGE_IOS=Carthage/Build/iOS
cat ./BASE_README.md > README.md

for i in $(ls Carthage/Build/iOS); do
	version=$(/usr/libexec/PlistBuddy $CARTHAGE_IOS/$i/Info.plist -c 'Print CFBundleShortVersionString')
	echo - $i : $version >> README.md
done