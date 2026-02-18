#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm  \
	dbus-broker			 \
 	nodejs 				 \
 	libappindicator-gtk3 \
	libxcrypt-compat	 \
	libnotify 			 \
	npm 				 \
	nss      	         \
	nspr		     	 \
	pipewire-audio 		 \
	pipewire-jack
	#ruby

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME
if [ "$ARCH" = "aarch64" ]; then
	#gem install fpm
	#export USE_SYSTEM_FPM=true
	make-aur-package electron39-bin
fi
# If the application needs to be manually built that has to be done down here
echo "Making nightly build of WhatsDesk..."
echo "---------------------------------------------------------------"
REPO="https://gitlab.com/zerkc/whatsdesk.git"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone "$REPO" ./whatsdesk
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./whatsdesk
if [ "$ARCH" = "aarch64" ]; then
rm -f pnpm-lock.yaml
ELECTRON_VER=$(cat /usr/lib/electron39/version | sed 's/v//')
npx electron-builder --linux --arm64 \
  -c.electronDist=/usr/lib/electron39 \
  -c.electronVersion=$ELECTRON_VER
sed -i 's/"build": {/"build": {\n    "npmRebuild": true,\n    "nodeGypRebuild": false,/' package.json
sed -i 's/"main": .*/"main": "electron-build\/src\/index.js",/' package.json
sed -i '/"files": \[/,/\]/c\    "files": ["**/*", "electron-build/**/*"],' package.json
sed -i 's/await CleanBuildDir();/\/\/ await CleanBuildDir();/g' build.js
fi
npm install
#else
npm run build
#fi
mv -v dist/linux-unpacked/* ../AppDir/bin
