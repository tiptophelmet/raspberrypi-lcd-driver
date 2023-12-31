#!/usr/bin/sh

# Fetch repositories
sudo apt update -y

# Install dependencies
sudo apt install software-properties-common cmake xserver-xorg-input-evdev xinput-calibrator -y

sudo cp -rf /usr/share/X11/xorg.conf.d/10-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
sudo cp -rf ./etc/X11/xorg.conf.d/99-fbturbo.conf /etc/X11/xorg.conf.d/99-fbturbo.conf

# Build & install Raspberry Pi Framebuffer Copy
cd ./usr/local/bin/make-fbcp/
mkdir build
cd build
cmake ..
make
chmod +x fbcp
sudo install fbcp /usr/local/bin/fbcp

# Go back to the root
cd ../../../../../

# Create backup for /etc/rc.local
if [ ! -f /etc/rc.local.rpi-lcd-backup ]; then
	# If it doesn't exist, perform the copy operation
	sudo cp /etc/rc.local /etc/rc.local.rpi-lcd-backup
else
	echo "Backup file (/etc/rc.local.rpi-lcd-backup) already exists."
fi

# Append rc.local-gpio content to /etc/rc.local
sudo cp ./etc/rc.local-gpio /etc/rc.local

sudo cp ./etc/X11/Xwrapper.config /etc/X11/Xwrapper.config

# Create backup for /boot/config.txt
if [ ! -f /boot/config.txt.rpi-lcd-backup ]; then
	# If it doesn't exist, perform the copy operation
	sudo cp /boot/config.txt /boot/config.txt.rpi-lcd-backup
else
	echo "Backup file (/boot/config.txt.rpi-lcd-backup) already exists."
fi

# Calibrate display & rotate to specific degrees
if test "$1" = "0" -o "$#" = "0" -o "$2" = "0"; then
	sudo cp -rf ./usr/share/X11/xorg.conf.d/99-calibration.conf-32 /usr/share/X11/xorg.conf.d/99-calibration.conf
	sudo cp ./boot/config-32.txt /boot/config.txt
	echo "LCD configure 0"
elif test "$1" = "90" -o "$2" = "90"; then
	sudo cp ./boot/config-32.txt-90 /boot/config.txt
	sudo cp -rf ./usr/share/X11/xorg.conf.d/99-calibration.conf-32-90 /usr/share/X11/xorg.conf.d/99-calibration.conf
	echo "LCD configure 90"
elif test "$1" = "180" -o "$2" = "180"; then
	sudo cp ./boot/config-32.txt-180 /boot/config.txt
	sudo cp -rf ./usr/share/X11/xorg.conf.d/99-calibration.conf-32-180 /usr/share/X11/xorg.conf.d/99-calibration.conf
	echo "LCD configure 180"
elif test "$1" = "270" -o "$2" = "270"; then
	sudo cp ./boot/config-32.txt-270 /boot/config.txt
	sudo cp -rf ./usr/share/X11/xorg.conf.d/99-calibration.conf-32-270 /usr/share/X11/xorg.conf.d/99-calibration.conf
	echo "LCD configure 270"
fi

# Add display overlays
sudo cp ./boot/overlays/waveshare32b-overlay.dtb /boot/overlays/waveshare32b.dtbo
sudo cp ./boot/overlays/waveshare32b-overlay.dtb /boot/overlays/

# Create backup for /boot/cmdline.txt
if [ ! -f /boot/cmdline.txt.rpi-lcd-backup ]; then
	sudo cp /boot/cmdline.txt /boot/cmdline.txt.rpi-lcd-backup
else
	echo "Backup file (/boot/cmdline.txt.rpi-lcd-backup) already exists."
fi

# Set up /boot/cmdline.txt
sudo cp ./boot/cmdline.txt /boot/

echo "--- Please, restart to finish LCD driver installation ---"
