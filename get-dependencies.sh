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

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME
if [ "$ARCH" = "aarch64" ]; then
	make-aur-package fpm
	export USE_SYSTEM_FPM=true
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
npm install
if [ "$ARCH" = "aarch64" ]; then
USE_SYSTEM_FPM=true npm run build
else
npm run build
fi
mv -v dist/linux-unpacked/* ../AppDir/bin
