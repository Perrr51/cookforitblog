---
title: Reuse Instead of Discarding How I Turned an Old MacBook into a Debian Server
date: 2025-04-21
---
I recently bought a new computer, a Lenovo P15 G2, but I’ll talk about that in another post. Today, I want to focus on something essential: **reusing devices instead of throwing them away or leaving them forgotten in a drawer**.

For years, my MacBook—with a Core i5 processor, 8GB of RAM, and 175GB SSD—was my daily driver. However, the last macOS update I could install was Big Sur, and as we know, proprietary software quickly drops support for older versions. Instead of discarding it, I decided to give it a second life as a Debian server.

**Why Debian and why LXDE?**  
I chose Debian for its stability, and specifically the lightweight LXDE desktop version to make the most of the device’s resources. The process requires a USB drive and downloading the Debian ISO you want to install. At first, I installed Debian 12, but encountered a problem: the BCM4360 network card driver (Broadcom) is not compatible with the 6.10 kernel that Debian 12 uses. The proprietary broadcom-sta driver only supports up to kernel 5.10.

**The solution?**  
Install Debian 11, which comes with the right kernel, and then manually add the necessary dependencies. Here’s the complete list of packages you need to download and save in a folder (preferably not on the desktop):

## List of packages to download

- **Perl and system dependencies:**  
    perl-base, perl-modules-5.32, libperl5.32, libfile-fcntllock-perl, liblocale-gettext-perl, dpkg, libdpkg-perl, distro-info-data, lsb-release
    
- **Build tools:**  
    gcc, make, dpkg-dev
    
- **Kernel headers and tools:**  
    linux-headers-<version>-common, linux-headers-<version>-amd64, linux-kbuild-5.10, libc6, libelf1, libssl1.1
    
- **Wireless tools:**  
    wireless-tools, libiw30
    
- **Broadcom STA driver:**  
    broadcom-sta-dkms
    

Save all packages in a folder and, from the terminal, use `cd` to access it and install them in this order:

# Basic Perl and system dependencies
sudo dpkg -i perl-base_*.deb
sudo dpkg -i perl-modules-5.32_*.deb
sudo dpkg -i libperl5.32_*.deb
sudo dpkg -i libfile-fcntllock-perl_*.deb
sudo dpkg -i liblocale-gettext-perl_*.deb
sudo dpkg -i dpkg_*.deb
sudo dpkg -i libdpkg-perl_*.deb
sudo dpkg -i distro-info-data_*.deb
sudo dpkg -i lsb-release_*.deb

# Build tools
sudo dpkg -i gcc_*.deb
sudo dpkg -i make_*.deb
sudo dpkg -i dpkg-dev_*.deb

# Kernel headers and tools
sudo dpkg -i libc6_*.deb
sudo dpkg -i libelf1_*.deb
sudo dpkg -i libssl1.1_*.deb
sudo dpkg -i linux-kbuild-5.10_*.deb
sudo dpkg -i linux-headers-`<version>`-common_*.deb
sudo dpkg -i linux-headers-`<version>`-amd64_*.deb

# Wireless tools
sudo dpkg -i libiw30_*.deb
sudo dpkg -i wireless-tools_*.deb

# Broadcom STA driver
sudo dpkg -i broadcom-sta-dkms_*.deb

# If there are dependency errors
sudo apt-get install -f

# Load the Broadcom STA module
sudo modprobe wl

# If the module does not load automatically after reboot
echo "wl" | sudo tee /etc/modules-load.d/wl.conf

# To avoid conflicts with other modules
echo -e "blacklist b43\nblacklist b43legacy\nblacklist ssb\nblacklist brcmsmac\nblacklist bcma" | sudo tee /etc/modprobe.d/blacklist-broadcom.conf

This process took me almost eight hours of research and trial-and-error. I hope this guide helps you give new life to a computer you thought was obsolete. See you in the next post!