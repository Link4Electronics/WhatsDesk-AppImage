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
#if [ "${ARCH}" = x86_64 ]; then
#echo "Getting app..."
#echo "---------------------------------------------------------------"
#DEB_LINK="https://zerkc.gitlab.io/whatsdesk/whatsdesk_0.3.12_amd64.deb"
#echo "$DEB_FILENAME" | sed -E "s/whatsdesk_(.*)_amd64\.deb/\1/" > ~/version
#if ! wget --retry-connrefused --tries=30 "$DEB_LINK" -O /tmp/app.deb 2>/tmp/download.log; then
#	cat /tmp/download.log
#	exit 1
#fi

#ar xvf /tmp/app.deb
#tar -xvf ./data.tar.xz
#rm -f ./*.xz
#rm -rf ./usr/share
#mv -v ./opt/whatsdesk ./AppDir/bin
#make-aur-package whatsdesk-bin
#else
    echo "Making nightly build of WhatsDesk for aarch64..."
    echo "---------------------------------------------------------------"
    REPO="https://gitlab.com/zerkc/whatsdesk.git"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone "$REPO" ./whatsdesk
    echo "$VERSION" > ~/version
    
    mkdir -p ./AppDir/bin
    cd ./whatsdesk
    npm install
    npm run build
	mv -v dist/linux-unpacked/* ../AppDir/bin
#fi
