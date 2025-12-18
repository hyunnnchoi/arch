# Arch Linux Installation Guide for ThinkPad X1 Carbon Gen 13 (Lunar Lake)

This guide provides step-by-step instructions for installing Arch Linux on the ThinkPad X1 Carbon Gen 13 with Intel Lunar Lake processors.

## Table of Contents
- [Hardware Overview](#hardware-overview)
- [Pre-Installation](#pre-installation)
- [BIOS/UEFI Settings](#biosuefi-settings)
- [Installation](#installation)
- [Lunar Lake Specific Configuration](#lunar-lake-specific-configuration)
- [Hardware Setup](#hardware-setup)
- [Post-Installation](#post-installation)
- [Troubleshooting](#troubleshooting)

## Hardware Overview

The ThinkPad X1 Carbon Gen 13 features:
- **CPU**: Intel Core Ultra (Lunar Lake) processors
- **Graphics**: Intel Arc Graphics (integrated)
- **WiFi**: Intel BE200 (WiFi 7)
- **Audio**: Realtek/Intel HDA
- **Display**: Various options including OLED
- **Storage**: NVMe SSD
- **Biometrics**: Fingerprint reader, IR camera

### Lunar Lake Notes
Lunar Lake is Intel's latest low-power architecture requiring:
- Linux kernel 6.11+ for optimal support
- Updated firmware packages
- Intel GPU drivers for Arc Graphics

## Pre-Installation

### Requirements
1. **USB Drive**: 4GB+ for installation media
2. **Backup**: Back up all important data
3. **Internet Connection**: Ethernet adapter recommended for initial setup
4. **UEFI**: System must boot in UEFI mode (not legacy BIOS)

### Download Arch Linux ISO
```bash
# Download the latest ISO
wget https://archlinux.org/download/

# Verify the ISO signature (recommended)
gpg --keyserver-options auto-key-retrieve --verify archlinux-*.iso.sig
```

### Create Bootable USB
```bash
# Linux/macOS
dd bs=4M if=archlinux-*.iso of=/dev/sdX status=progress oflag=sync

# Or use balenaEtcher, Rufus (Windows), or Ventoy
```

## BIOS/UEFI Settings

Press **F1** during boot to enter BIOS/UEFI settings.

### Recommended Settings
1. **Security**
   - Secure Boot: Disable (or configure for Linux)
   - Virtualization: Enable (VT-x, VT-d)
   
2. **Boot**
   - Boot Mode: UEFI Only
   - USB Boot: Enable
   - Boot Order: USB First for installation
   
3. **Power**
   - Intel SpeedStep: Enable
   - CPU Power Management: Enable

4. **Advanced**
   - Thunderbolt BIOS Assist: Enable
   - Always On USB: Configure as needed

## Installation

### 1. Boot from USB
Insert USB drive and press **F12** during boot to select boot device.

### 2. Verify Boot Mode
```bash
cat /sys/firmware/efi/fw_platform_size
# Should return 64 (UEFI mode)
```

### 3. Connect to Internet

#### WiFi (if supported by live USB)
```bash
iwctl
[iwd]# device list
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect "SSID"
exit

# Test connection
ping archlinux.org
```

#### Ethernet
```bash
# Usually works automatically via DHCP
ip link
ping archlinux.org
```

### 4. Update System Clock
```bash
timedatectl set-ntp true
timedatectl status
```

### 5. Partition the Disk

#### Check Available Disks
```bash
fdisk -l
lsblk
```

#### Create Partitions (UEFI with GPT)
```bash
# Using fdisk or gdisk
gdisk /dev/nvme0n1

# Recommended layout:
# 1. EFI System Partition: 512MB (type EF00)
# 2. Swap (optional): 8-16GB (type 8200)
# 3. Root: Remaining space (type 8300)
```

Example partition scheme:
```
/dev/nvme0n1p1  512M   EFI System Partition
/dev/nvme0n1p2  16G    Linux swap
/dev/nvme0n1p3  Rest   Linux filesystem (root)
```

### 6. Format Partitions
```bash
# Format EFI partition
mkfs.fat -F32 /dev/nvme0n1p1

# Format root partition (ext4 or btrfs)
mkfs.ext4 /dev/nvme0n1p3
# Or for btrfs:
# mkfs.btrfs /dev/nvme0n1p3

# Setup swap
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
```

### 7. Mount Partitions
```bash
# Mount root
mount /dev/nvme0n1p3 /mnt

# Create and mount EFI directory
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Verify mounts
lsblk
```

### 8. Install Base System
```bash
# Update mirrors for faster downloads (optional)
reflector --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Install base packages
pacstrap /mnt base linux linux-firmware base-devel

# Include useful packages
pacstrap /mnt \
  linux-headers \
  intel-ucode \
  networkmanager \
  vim \
  git \
  sudo \
  man-db \
  man-pages
```

### 9. Generate fstab
```bash
genfstab -U /mnt >> /mnt/etc/fstab

# Verify
cat /mnt/etc/fstab
```

### 10. Chroot into New System
```bash
arch-chroot /mnt
```

### 11. Configure System

#### Set Timezone
```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
```

#### Set Locale
```bash
# Edit /etc/locale.gen and uncomment needed locales
vim /etc/locale.gen
# Uncomment: en_US.UTF-8 UTF-8

# Generate locales
locale-gen

# Set system locale
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

#### Set Hostname
```bash
echo "x1c13" > /etc/hostname

# Edit /etc/hosts
cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   x1c13.localdomain x1c13
EOF
```

#### Set Root Password
```bash
passwd
```

### 12. Install and Configure Bootloader

#### Using systemd-boot
```bash
bootctl install

# Create loader configuration
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

# Create boot entry
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=/dev/nvme0n1p3 rw
EOF
```

#### Or using GRUB
```bash
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

### 13. Enable NetworkManager
```bash
systemctl enable NetworkManager
```

### 14. Create User Account
```bash
useradd -m -G wheel,audio,video,storage -s /bin/bash username
passwd username

# Enable sudo for wheel group
EDITOR=vim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

### 15. Exit and Reboot
```bash
exit
umount -R /mnt
reboot
```

## Lunar Lake Specific Configuration

### 1. Update to Latest Kernel
```bash
# After first boot, update system
sudo pacman -Syu

# Consider linux-mainline or linux-zen for latest hardware support
# sudo pacman -S linux-mainline linux-mainline-headers
```

### 2. Install Intel Graphics Drivers
```bash
sudo pacman -S \
  mesa \
  lib32-mesa \
  vulkan-intel \
  lib32-vulkan-intel \
  intel-media-driver \
  libva-utils \
  intel-gpu-tools
```

### 3. Intel GPU Firmware
```bash
# Ensure linux-firmware is updated
sudo pacman -S linux-firmware

# Check GPU info
lspci | grep VGA
intel_gpu_top
```

### 4. Power Management
```bash
# Install TLP for laptop power management
sudo pacman -S tlp tlp-rdw

# Enable TLP
sudo systemctl enable tlp.service
sudo systemctl start tlp.service

# Optional: powertop for power monitoring
sudo pacman -S powertop
```

### 5. CPU Microcode
```bash
# Intel microcode (should already be installed)
sudo pacman -S intel-ucode

# Verify it's in bootloader config
cat /boot/loader/entries/arch.conf
# Should have: initrd /intel-ucode.img
```

## Hardware Setup

### WiFi 7 (Intel BE200)

```bash
# Install iwd (modern WiFi daemon)
sudo pacman -S iwd

# Enable and start
sudo systemctl enable iwd.service
sudo systemctl start iwd.service

# Configure NetworkManager to use iwd backend
sudo mkdir -p /etc/NetworkManager/conf.d
cat | sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf << EOF
[device]
wifi.backend=iwd
EOF

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

### Bluetooth
```bash
sudo pacman -S bluez bluez-utils
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# GUI tools (optional)
sudo pacman -S blueman  # GTK
# or
sudo pacman -S bluedevil  # KDE
```

### Audio
```bash
# PipeWire (modern audio system)
sudo pacman -S \
  pipewire \
  pipewire-alsa \
  pipewire-pulse \
  pipewire-jack \
  wireplumber \
  pavucontrol

# Enable user service
systemctl --user enable pipewire.service
systemctl --user enable pipewire-pulse.service
systemctl --user enable wireplumber.service
```

### Touchpad and TrackPoint
```bash
# Install libinput
sudo pacman -S xf86-input-libinput

# For X11, create config
sudo mkdir -p /etc/X11/xorg.conf.d
cat | sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf << EOF
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "ScrollMethod" "twofinger"
EndSection
EOF
```

### Fingerprint Reader
```bash
sudo pacman -S fprintd

# Enroll fingerprint
fprintd-enroll

# Enable for login/sudo
sudo authselect select sssd with-fingerprint

# Or edit PAM configuration manually
```

### Backlight Control
```bash
sudo pacman -S light

# Add user to video group
sudo usermod -aG video $USER

# Test brightness control
light -U 10  # Decrease 10%
light -A 10  # Increase 10%
```

### Thunderbolt
```bash
sudo pacman -S bolt

# List devices
boltctl list

# Authorize device
boltctl enroll <device-id>
```

## Post-Installation

### Install Desktop Environment

#### GNOME
```bash
sudo pacman -S gnome gnome-extra
sudo systemctl enable gdm.service
```

#### KDE Plasma
```bash
sudo pacman -S plasma plasma-wayland-session kde-applications
sudo systemctl enable sddm.service
```

#### Lightweight (i3/Sway)
```bash
# Wayland (Sway)
sudo pacman -S sway swaylock swayidle waybar

# X11 (i3)
sudo pacman -S i3-wm i3status i3lock dmenu xorg-server
```

### Install Common Applications
```bash
sudo pacman -S \
  firefox \
  kitty \
  thunar \
  vim \
  htop \
  neofetch \
  git
```

### Enable SSD TRIM
```bash
sudo systemctl enable fstrim.timer
```

### Configure Pacman
```bash
sudo vim /etc/pacman.conf
# Uncomment:
# Color
# ParallelDownloads = 5
```

### Install AUR Helper (yay)
```bash
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### Laptop Mode and Battery Optimization
```bash
# Additional power savings
sudo pacman -S laptop-mode-tools
sudo systemctl enable laptop-mode.service

# Thermald for thermal management
sudo pacman -S thermald
sudo systemctl enable thermald.service
```

## Troubleshooting

### WiFi Not Working
```bash
# Check driver status
lspci -k | grep -A 3 -i network

# Ensure firmware is loaded
dmesg | grep iwlwifi

# Try reloading module
sudo modprobe -r iwlwifi
sudo modprobe iwlwifi
```

### Graphics Issues
```bash
# Check loaded drivers
lspci -k | grep -A 3 -i vga

# Check Xorg log
cat /var/log/Xorg.0.log | grep -i error

# Test with different kernel parameters
# Edit /boot/loader/entries/arch.conf and add:
# i915.enable_guc=3 i915.enable_fbc=1
```

### Suspend/Resume Issues
```bash
# Check systemd-sleep logs
journalctl -u systemd-suspend.service

# Test suspend
systemctl suspend

# Common fix: update BIOS/UEFI firmware
```

### Audio Not Working
```bash
# Check PipeWire status
systemctl --user status pipewire pipewire-pulse

# List audio devices
pactl list sinks

# Restart audio
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Screen Brightness Control Not Working
```bash
# Check backlight devices
ls /sys/class/backlight/

# Add kernel parameter
# acpi_backlight=native or acpi_backlight=vendor

# Or use different tool
sudo pacman -S brightnessctl
brightnessctl s 50%
```

### Touchpad Not Working in Wayland
```bash
# Check libinput
libinput list-devices

# For GNOME Wayland, check settings
gsettings get org.gnome.desktop.peripherals.touchpad tap-to-click
```

## Additional Resources

- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Arch Linux Wiki - Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [ThinkPad X1 Carbon Wiki](https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Carbon)
- [Intel Graphics](https://wiki.archlinux.org/title/Intel_graphics)
- [TLP Documentation](https://linrunner.de/tlp/)
- [Reddit: r/archlinux](https://reddit.com/r/archlinux)
- [Reddit: r/thinkpad](https://reddit.com/r/thinkpad)

## Notes

This guide is maintained for personal use but shared for the community. Contributions and improvements are welcome!

**Last Updated**: December 2024
**Tested On**: ThinkPad X1 Carbon Gen 13 with Intel Core Ultra 7 (Lunar Lake)
