#!/bin/bash
#
# Arch Linux Installation Script for ThinkPad X1 Carbon Gen 13 (Lunar Lake)
# 
# WARNING: This script will partition and format drives!
# Use at your own risk and review the script before running.
#
# Usage: ./install.sh
#

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running in UEFI mode
check_uefi() {
    info "Checking UEFI boot mode..."
    if [ ! -d /sys/firmware/efi/efivars ]; then
        error "Not booted in UEFI mode. Please enable UEFI in BIOS."
    fi
    info "UEFI mode confirmed"
}

# Get user configuration
get_config() {
    info "Starting configuration..."
    
    # Disk selection
    echo ""
    lsblk -d -o NAME,SIZE,MODEL
    echo ""
    read -p "Enter target disk (e.g., nvme0n1): " DISK
    DISK="/dev/${DISK}"
    
    if [ ! -b "$DISK" ]; then
        error "Disk $DISK does not exist"
    fi
    
    warn "WARNING: All data on $DISK will be destroyed!"
    read -p "Are you sure you want to continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        error "Installation cancelled"
    fi
    
    # Hostname
    read -p "Enter hostname [x1c13]: " HOSTNAME
    HOSTNAME=${HOSTNAME:-x1c13}
    
    # Username
    read -p "Enter username: " USERNAME
    while [ -z "$USERNAME" ]; do
        read -p "Username cannot be empty. Enter username: " USERNAME
    done
    
    # Timezone
    read -p "Enter timezone (e.g., America/New_York) [UTC]: " TIMEZONE
    TIMEZONE=${TIMEZONE:-UTC}
    
    # Locale
    read -p "Enter locale [en_US.UTF-8]: " LOCALE
    LOCALE=${LOCALE:-en_US.UTF-8}
    
    # Swap size
    read -p "Enter swap size in GB [16]: " SWAP_SIZE
    SWAP_SIZE=${SWAP_SIZE:-16}
    
    # Desktop environment
    echo ""
    echo "Desktop Environment options:"
    echo "1) GNOME"
    echo "2) KDE Plasma"
    echo "3) None (minimal)"
    read -p "Select desktop environment [3]: " DE_CHOICE
    DE_CHOICE=${DE_CHOICE:-3}
    
    info "Configuration complete"
}

# Update system clock
sync_time() {
    info "Synchronizing system clock..."
    timedatectl set-ntp true
    sleep 2
}

# Partition disk
partition_disk() {
    info "Partitioning disk $DISK..."
    
    # Wipe disk
    wipefs -af "$DISK"
    sgdisk --zap-all "$DISK"
    
    # Create partitions
    sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" "$DISK"
    sgdisk -n 2:0:+${SWAP_SIZE}G -t 2:8200 -c 2:"SWAP" "$DISK"
    sgdisk -n 3:0:0 -t 3:8300 -c 3:"ROOT" "$DISK"
    
    # Inform kernel of partition changes
    partprobe "$DISK"
    sleep 2
    
    info "Partitioning complete"
}

# Format partitions
format_partitions() {
    info "Formatting partitions..."
    
    # Determine partition names
    if [[ "$DISK" == *"nvme"* ]]; then
        PART_EFI="${DISK}p1"
        PART_SWAP="${DISK}p2"
        PART_ROOT="${DISK}p3"
    else
        PART_EFI="${DISK}1"
        PART_SWAP="${DISK}2"
        PART_ROOT="${DISK}3"
    fi
    
    # Format EFI partition
    mkfs.fat -F32 "$PART_EFI"
    
    # Setup swap
    mkswap "$PART_SWAP"
    swapon "$PART_SWAP"
    
    # Format root partition
    mkfs.ext4 -F "$PART_ROOT"
    
    info "Formatting complete"
}

# Mount partitions
mount_partitions() {
    info "Mounting partitions..."
    
    mount "$PART_ROOT" /mnt
    mkdir -p /mnt/boot
    mount "$PART_EFI" /mnt/boot
    
    info "Partitions mounted"
}

# Install base system
install_base() {
    info "Installing base system..."
    
    # Update mirrors
    info "Updating mirrors..."
    reflector --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || true
    
    # Install base packages
    pacstrap /mnt base linux linux-firmware base-devel \
        linux-headers \
        intel-ucode \
        networkmanager \
        vim \
        git \
        sudo \
        man-db \
        man-pages \
        htop
    
    info "Base system installed"
}

# Generate fstab
generate_fstab() {
    info "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
}

# Configure system
configure_system() {
    info "Configuring system..."
    
    # Timezone
    arch-chroot /mnt ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    arch-chroot /mnt hwclock --systohc
    
    # Locale
    echo "${LOCALE} UTF-8" >> /mnt/etc/locale.gen
    arch-chroot /mnt locale-gen
    echo "LANG=${LOCALE}" > /mnt/etc/locale.conf
    
    # Hostname
    echo "$HOSTNAME" > /mnt/etc/hostname
    cat > /mnt/etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF
    
    info "System configured"
}

# Install bootloader
install_bootloader() {
    info "Installing bootloader (systemd-boot)..."
    
    arch-chroot /mnt bootctl install
    
    # Create loader configuration
    cat > /mnt/boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF
    
    # Get root partition UUID
    ROOT_UUID=$(blkid -s UUID -o value "$PART_ROOT")
    
    # Create boot entry
    cat > /mnt/boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=UUID=${ROOT_UUID} rw quiet splash
EOF
    
    info "Bootloader installed"
}

# Setup users and passwords
setup_users() {
    info "Setting up users..."
    
    # Root password
    info "Set root password:"
    arch-chroot /mnt passwd
    
    # Create user
    arch-chroot /mnt useradd -m -G wheel,audio,video,storage,power -s /bin/bash "$USERNAME"
    
    info "Set password for $USERNAME:"
    arch-chroot /mnt passwd "$USERNAME"
    
    # Enable sudo for wheel group
    echo "%wheel ALL=(ALL:ALL) ALL" >> /mnt/etc/sudoers.d/wheel
    chmod 440 /mnt/etc/sudoers.d/wheel
    
    info "Users configured"
}

# Enable essential services
enable_services() {
    info "Enabling services..."
    
    arch-chroot /mnt systemctl enable NetworkManager
    arch-chroot /mnt systemctl enable fstrim.timer
    
    info "Services enabled"
}

# Install Lunar Lake specific packages
install_lunar_lake() {
    info "Installing Lunar Lake specific packages..."
    
    arch-chroot /mnt pacman -S --noconfirm \
        mesa \
        vulkan-intel \
        intel-media-driver \
        libva-utils \
        intel-gpu-tools \
        tlp \
        powertop \
        thermald
    
    # Enable TLP
    arch-chroot /mnt systemctl enable tlp.service
    arch-chroot /mnt systemctl enable thermald.service
    
    info "Lunar Lake packages installed"
}

# Install WiFi and Bluetooth
install_wireless() {
    info "Installing WiFi and Bluetooth support..."
    
    arch-chroot /mnt pacman -S --noconfirm \
        iwd \
        bluez \
        bluez-utils
    
    arch-chroot /mnt systemctl enable iwd.service
    arch-chroot /mnt systemctl enable bluetooth.service
    
    # Configure NetworkManager to use iwd
    mkdir -p /mnt/etc/NetworkManager/conf.d
    cat > /mnt/etc/NetworkManager/conf.d/wifi_backend.conf << EOF
[device]
wifi.backend=iwd
EOF
    
    info "Wireless support installed"
}

# Install audio
install_audio() {
    info "Installing audio (PipeWire)..."
    
    arch-chroot /mnt pacman -S --noconfirm \
        pipewire \
        pipewire-alsa \
        pipewire-pulse \
        pipewire-jack \
        wireplumber \
        pavucontrol
    
    info "Audio installed"
}

# Install desktop environment
install_desktop() {
    case $DE_CHOICE in
        1)
            info "Installing GNOME..."
            arch-chroot /mnt pacman -S --noconfirm gnome gnome-extra
            arch-chroot /mnt systemctl enable gdm.service
            ;;
        2)
            info "Installing KDE Plasma..."
            arch-chroot /mnt pacman -S --noconfirm plasma plasma-wayland-session kde-applications
            arch-chroot /mnt systemctl enable sddm.service
            ;;
        3)
            info "Skipping desktop environment installation"
            ;;
        *)
            warn "Invalid desktop environment choice, skipping"
            ;;
    esac
}

# Configure pacman
configure_pacman() {
    info "Configuring pacman..."
    
    # Enable color and parallel downloads
    sed -i 's/^#Color/Color/' /mnt/etc/pacman.conf
    sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /mnt/etc/pacman.conf
    
    info "Pacman configured"
}

# Main installation
main() {
    clear
    echo "================================================"
    echo "Arch Linux Installation for ThinkPad X1C Gen 13"
    echo "              (Lunar Lake)                      "
    echo "================================================"
    echo ""
    
    check_uefi
    get_config
    
    echo ""
    warn "Starting installation in 5 seconds... Press Ctrl+C to cancel"
    sleep 5
    
    sync_time
    partition_disk
    format_partitions
    mount_partitions
    install_base
    generate_fstab
    configure_system
    install_bootloader
    setup_users
    enable_services
    install_lunar_lake
    install_wireless
    install_audio
    configure_pacman
    install_desktop
    
    info "Installation complete!"
    echo ""
    info "You can now reboot into your new system"
    info "After reboot, don't forget to:"
    echo "  - Configure your desktop environment"
    echo "  - Install additional software"
    echo "  - Set up an AUR helper (yay)"
    echo "  - Review the INSTALL.md guide for post-installation steps"
    echo ""
    read -p "Reboot now? (yes/no): " REBOOT
    if [ "$REBOOT" == "yes" ]; then
        umount -R /mnt
        reboot
    fi
}

# Run main installation
main
