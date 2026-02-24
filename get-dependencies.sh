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
npm run build
if [ "$ARCH" = "aarch64" ]; then
	mv -v dist/linux-arm64-unpacked/* ../AppDir/bin
else
	mv -v dist/linux-unpacked/* ../AppDir/bin
fi
