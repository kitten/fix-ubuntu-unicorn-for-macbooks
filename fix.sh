#!/bin/sh
#    Fix Ubuntu 14.10 Utopic Unicorn for MacBook Pros
#
#    Copyright (C) 2015 Phil Plückthun <phil@plckthn.me>
#
#    This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
#    Unported License: http://creativecommons.org/licenses/by-sa/3.0/

if [ `id -u` -ne 0 ]
then
  echo "Please start this script with root privileges!"
  echo "Try again with sudo."
  exit 0
fi

reboot=0

lsb_release -c | grep utopic > /dev/null
if [ "$?" = "1" ]
then
  echo "This script was designed to run on Ubuntu 14.04 Utpoic Unicorn!"
  echo "Do you wish to continue anyway?"
  while true; do
    read -p "" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 0;;
        * ) echo "Please answer with Yes or No [y|n].";;
    esac
  done
  echo ""
fi

# 1)
fixGRUB () {
  echo "Creating new GRUB hooks..."
  touch /etc/grub.d/25_pre-os-prober
  touch /etc/grub.d/35_post-os-prober
  echo "" > /etc/grub.d/25_pre-os-prober
  echo "" > /etc/grub.d/35_post-os-prober

  echo '#! /bin/sh' >> /etc/grub.d/25_pre-os-prober
  echo ' ' >> /etc/grub.d/25_pre-os-prober
  echo 'set -e' >> /etc/grub.d/25_pre-os-prober
  echo ' ' >> /etc/grub.d/25_pre-os-prober
  echo 'cat << EOF' >> /etc/grub.d/25_pre-os-prober
  echo 'set timeout_bak=${timeout}' >> /etc/grub.d/25_pre-os-prober
  echo 'set timeout_style_bak=${timeout_style}' >> /etc/grub.d/25_pre-os-prober
  echo 'EOF' >> /etc/grub.d/25_pre-os-prober

  echo '#! /bin/sh' >> /etc/grub.d/35_post-os-prober
  echo ' ' >> /etc/grub.d/35_post-os-prober
  echo 'set -e' >> /etc/grub.d/35_post-os-prober
  echo ' ' >> /etc/grub.d/35_post-os-prober
  echo 'cat << EOF' >> /etc/grub.d/35_post-os-prober
  echo 'set timeout=${timeout_bak}' >> /etc/grub.d/35_post-os-prober
  echo 'set timeout_style=${timeout_style_bak}' >> /etc/grub.d/35_post-os-prober
  echo 'EOF' >> /etc/grub.d/35_post-os-prober

  echo "Fixing file permissions to executable..."

  chmod 755 /etc/grub.d/25_pre-os-prober
  chmod 755 /etc/grub.d/35_post-os-prober

  echo "Done!"
}

# 2)
optimiseForRetina () {
  echo "Not implemented yet!"
}

# 3)
installWifiDrivers () {
  echo "Updating packages..."
  apt-get update > /dev/null
  echo "Installing BCMWL..."
  apt-get install bcmwl-kernel-source > /dev/null
  echo "Done!"
}

# 4)
upgradeKernel () {
  echo "Updating packages..."
  apt-get update > /dev/null
  echo "Upgrading packages..."
  apt-get dist-upgrade -y > /dev/null
  echo "Installing wget..."
  apt-get install wget -y > /dev/null
  echo "Downloading kernel installation files..."
  cd /tmp/
  wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.18-vivid/linux-headers-3.18.0-031800-generic_3.18.0-031800.201412071935_amd64.deb
  wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.18-vivid/linux-headers-3.18.0-031800_3.18.0-031800.201412071935_all.deb
  wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.18-vivid/linux-image-3.18.0-031800-generic_3.18.0-031800.201412071935_amd64.deb
  echo "Installing kernel 3.18..."
  dpkg -i linux-headers-3.18.0-*.deb linux-image-3.18.0-*.deb
  echo "Done!"
}

# 5)
fixMultitouchTrackpad () {
  echo "Updating packages..."
  apt-get update > /dev/null
  echo "Installing new drivers..."
  gsettings set org.gnome.settings-daemon.plugins.mouse active false
  apt-get install xserver-xorg-input-mtrack -y
  echo "Removing old drivers..."
  apt-get autoremove xserver-xorg-input-synaptics -y
  rm -rf /usr/share/X11/xorg.conf.d/50-synaptics.conf
  echo "Editing xorg.conf..."
  cat /etc/X11/xorg.conf | grep mtrack > /dev/null
  if [ "$?" = "1" ]; then
    echo "Adding the mtrack configuration..."
    echo '' >> /etc/X11/xorg.conf
    echo 'Section "InputClass"' >> /etc/X11/xorg.conf
    echo '  MatchIsTouchpad "on"' >> /etc/X11/xorg.conf
    echo '  Identifier "Touchpads"' >> /etc/X11/xorg.conf
    echo '  Driver "mtrack"' >> /etc/X11/xorg.conf
    echo '  Option "IgnoreThumb" "true"' >> /etc/X11/xorg.conf
    echo '  Option "IgnorePalm" "true"' >> /etc/X11/xorg.conf
    echo '  Option "DisableOnPalm" "true"' >> /etc/X11/xorg.conf
    echo '  Option "BottomEdge" "30"' >> /etc/X11/xorg.conf
    echo '  Option "TapDragEnable" "false"' >> /etc/X11/xorg.conf
    echo '  Option "Sensitivity" "1.2"' >> /etc/X11/xorg.conf
    echo '  Option "ButtonEnable" "true"' >> /etc/X11/xorg.conf
    echo '  Option "ButtonIntegrated" "true"' >> /etc/X11/xorg.conf
    echo '  Option "ClickFinger1" "1"' >> /etc/X11/xorg.conf
    echo '  Option "ClickFinger2" "3"' >> /etc/X11/xorg.conf
    echo '  Option "TapButton1" "0"' >> /etc/X11/xorg.conf
    echo '  Option "TapButton2" "0"' >> /etc/X11/xorg.conf
    echo '  Option "TapButton3" "0"' >> /etc/X11/xorg.conf
    echo '  Option "TapButton4" "0"' >> /etc/X11/xorg.conf
    echo '  EndSection' >> /etc/X11/xorg.conf
    echo '' >> /etc/X11/xorg.conf
    echo "pointer = 1 2 3 5 4 6 7 8 9 10 11 12" > ~/.Xmodmap
    echo "Done!"
  else
    echo "WARNING!"
    echo "Detected old mtrack configuration!"
    echo "Abort!"
  fi
}

# 6)
fixMarvellPCIeSSDBug () {
  echo "Not implemented yet!"
}

# 7)
fixFansAndSensors () {
  echo "Adding sensor modules to /etc/modules..."
  cat /etc/modules | grep coretemp > /dev/null
  if [ "$?" = "1" ]
  then
    echo 'coretemp' >> /etc/modules
    echo "Added coretemp."
  fi
  cat /etc/modules | grep applesmc > /dev/null
  if [ "$?" = "1" ]
  then
    echo 'applesmc' >> /etc/modules
    echo "Added applesmc."
  fi
  echo "Updating packages..."
  apt-get update > /dev/null
  echo "Installing Git and Build-Essentials..."
  apt-get install git build-essential -y >> /dev/null
  echo "Adding source code directory..."
  mkdir /usr/local/src
  chmod -R 755 /usr/local/src
  USER=$(logname)
  if [ "x$USER" = "x" ]; then
    echo "Couldn't determine current user..."
  else
    chown -R $USER:$USER /usr/local/src
  fi
  echo "Installing the Fan Control Daemon..."
  cd /usr/local/src/
  git clone https://github.com/dgraziotin/Fan-Control-Daemon.git Fan-Control-Daemon
  cd /usr/local/src/Fan-Control-Daemon/
  make > /dev/null
  make install > /dev/null
  cp mbpfan.upstart /etc/init/mbpfan.conf
  start mbpfan
  echo "Done!"
}

# 8)
enableAutoBacklight () {
  echo "Adding sensor modules to /etc/modules..."
  cat /etc/modules | grep coretemp > /dev/null
  if [ "$?" = "1" ]
  then
    echo 'coretemp' >> /etc/modules
    echo "Added coretemp."
  fi
  cat /etc/modules | grep applesmc > /dev/null
  if [ "$?" = "1" ]
  then
    echo 'applesmc' >> /etc/modules
    echo "Added applesmc."
  fi
  echo "Updating packages..."
  apt-get update > /dev/null
  echo "Installing Git and Build-Essentials..."
  apt-get install git build-essential libxss-dev libdbus-glib-1-dev -y >> /dev/null
  echo "Adding source code directory..."
  mkdir /usr/local/src
  chmod -R 755 /usr/local/src
  USER=$(logname)
  if [ "x$USER" = "x" ]; then
    echo "Couldn't determine current user..."
  else
    chown -R $USER:$USER /usr/local/src
  fi
  echo "Installing Lightum..."
  cd /usr/local/src/
  git clone https://github.com/poliva/lightum.git lightum
  cd /usr/local/src/lightum/
  make > /dev/null
  make install > /dev/null
  echo "Starting Lightum..."
  lightum
  echo "Configuring Lightum..."
  mkdir ~/.config/lightum
  touch ~/.config/lightum/lightum.conf
  echo "" > ~/.config/lightum/lightum.conf
  chmod 755 ~/.config/lightum/lightum.conf
  echo '' >> ~/.config/lightum/lightum.conf
  echo 'manualmode=0' >> ~/.config/lightum/lightum.conf
  echo 'ignoreuser=0' >> ~/.config/lightum/lightum.conf
  echo 'ignoresession=0' >> ~/.config/lightum/lightum.conf
  echo 'workmode=3' >> ~/.config/lightum/lightum.conf
  echo 'maxbrightness=200' >> ~/.config/lightum/lightum.conf
  echo 'minbrightness=0' >> ~/.config/lightum/lightum.conf
  echo 'polltime=1000' >> ~/.config/lightum/lightum.conf
  echo 'idleoff=5' >> ~/.config/lightum/lightum.conf
  echo 'queryscreensaver=0' >> ~/.config/lightum/lightum.conf
  echo 'maxbacklight=15' >> ~/.config/lightum/lightum.conf
  echo 'minbacklight=1' >> ~/.config/lightum/lightum.conf
  echo 'screenidle=0' >> ~/.config/lightum/lightum.conf
  echo 'fulldim=0' >> ~/.config/lightum/lightum.conf
  echo "Done!"
}

echo "---------------------------------------------"
echo " Fix Assistant"
echo " for Ubuntu 14.10 on Macbook Pros"
echo " ~ by Phil Plückthun"

while true; do
  echo "---------------------------------------------"
  if [ "$reboot" = "1" ]; then
    echo "DON'T FORGET TO REBOOT!"
  fi
  echo "Choose an action:"
  echo " 1) Fix the GRUB timeout bug"
  echo " 2) Optimise scaling for Retina displays"
  echo " 3) Install Wi-Fi drivers"
  echo " 4) Upgrade the kernel to 3.18"
  echo " 5) Fix the multitouch trackpad"
  echo " 6) Fix the Marvell PCIe SSD bug"
  echo " 7) Fix the fans and temperature sensors"
  echo " 8) Enable auto backlight"
  echo " r) Reboot"
  echo " q) Quit"
  echo "---------------------------------------------"
  read -p "> " selection
  echo ""
  case $selection in
      [1]* ) fixGRUB; reboot=1;;
      [2]* ) optimiseForRetina; reboot=1;;
      [3]* ) installWifiDrivers;;
      [4]* ) upgradeKernel; reboot=1;;
      [5]* ) fixMultitouchTrackpad; reboot=1;;
      [6]* ) fixMarvellPCIeSSDBug;;
      [7]* ) fixFansAndSensors; reboot=1;;
      [8]* ) enableAutoBacklight; rebot=1;;
      [rR]* ) reboot; exit 0;;
      [qQ]* ) exit 0;;
      * ) echo "Please answer with: [1-8|q|r].";;
  esac

  sleep 1
  echo ""
done

echo ""
sleep 2
exit 0
