#!/usr/bin/env bash
set -ex

if [ ! -d "linux-lin" ]; then
	git clone https://github.com/lin-bus/linux-lin.git
fi
git -C linux-lin checkout 690f3b868273b146c722364a5377c4b70c85e8fa
source dkms.conf
sudo mkdir -p "/usr/src/${PACKAGE_NAME}-${PACKAGE_VERSION}"
sudo cp -r dkms.conf linux-lin/sllin/* "/usr/src/${PACKAGE_NAME}-${PACKAGE_VERSION}"

sudo dkms remove sllin/"$PACKAGE_VERSION" --all || true

sudo dkms add -m "$PACKAGE_NAME" -v "$PACKAGE_VERSION"
sudo dkms build -m "$PACKAGE_NAME" -v "$PACKAGE_VERSION"
sudo dkms install -m "$PACKAGE_NAME" -v "$PACKAGE_VERSION"
