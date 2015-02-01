# Fix Ubuntu 14.10 Utopic Unicorn for MacBook Pros

**
A script to automatically fix some annoying bugs and quirks when using Ubuntu
14.10 on MBPs.
**

It is a wizard / utility which presents you with different options to perform. It's features are:

- Fix the GRUB timeout bug
- Optimise scaling for Retina displays (Not implemented yet!)
- Install Wi-Fi drivers
- Upgrade the kernel to 3.18
- Fix the multitouch trackpad
- Fix the Marvell PCIe SSD bug
- Fix the fans and temperature sensors
- Enable auto backlight

> Based on my article ["Ubuntu 14.10 running on my MacBook"](https://medium.com/@PhilPlckthun/ubuntu-14-10-running-on-my-macbook-18991a697ae0)

Script has been tested on:

- Macbook Pro Retina 11,1 (13")

Feel free to test it on more Macbooks and please report back to me!

## Caution!

**This script is not entirely completed and tested! It might break things!**

## Running it

```
wget https://raw.github.com/philplckthun/fix-ubuntu-unicorn-for-macbooks/master/fix.sh
sudo sh fix.sh
```

The script will lead you through the installation processes.
