# Quick Reference Guide

Quick commands and tips for ThinkPad X1 Carbon Gen 13 with Arch Linux.

## Essential Commands

### System Information
```bash
# System info
neofetch
uname -r

# Hardware info
lspci
lsusb
lscpu
lsblk
```

### Package Management
```bash
# Update system
sudo pacman -Syu

# Install package
sudo pacman -S package-name

# Remove package
sudo pacman -R package-name

# Remove package and dependencies
sudo pacman -Rns package-name

# Search for package
pacman -Ss search-term

# Clean package cache
sudo pacman -Sc
```

### Network Management
```bash
# List network devices
nmcli device

# WiFi connect
nmcli device wifi connect "SSID" password "password"

# Show connection status
nmcli connection show

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

### Power Management
```bash
# Check battery status
cat /sys/class/power_supply/BAT0/capacity
upower -i /org/freedesktop/UPower/devices/battery_BAT0

# Suspend
systemctl suspend

# Hibernate
systemctl hibernate

# TLP status
sudo tlp-stat

# Power statistics
powertop
```

### Audio
```bash
# List audio devices
pactl list sinks

# Set volume
pactl set-sink-volume @DEFAULT_SINK@ +5%
pactl set-sink-volume @DEFAULT_SINK@ -5%

# Mute/unmute
pactl set-sink-mute @DEFAULT_SINK@ toggle

# Restart audio
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Bluetooth
```bash
# Start bluetoothctl
bluetoothctl

# In bluetoothctl:
power on
scan on
devices
pair <MAC>
connect <MAC>
```

### Display/Brightness
```bash
# Show backlight devices
ls /sys/class/backlight/

# Increase brightness
light -A 10

# Decrease brightness
light -U 10

# Set specific brightness
light -S 50
```

### System Services
```bash
# Start service
sudo systemctl start service-name

# Enable service (start on boot)
sudo systemctl enable service-name

# Check service status
systemctl status service-name

# View logs
journalctl -u service-name
```

### Disk Management
```bash
# Check disk usage
df -h

# Check directory sizes
du -sh *

# TRIM SSD
sudo fstrim -v /

# Check TRIM status
sudo systemctl status fstrim.timer
```

## Keyboard Shortcuts (Desktop Dependent)

### GNOME
- `Super`: Activities overview
- `Super + L`: Lock screen
- `Super + Tab`: Switch applications
- `Alt + Tab`: Switch windows
- `Ctrl + Alt + T`: Terminal (may need to enable)

### KDE Plasma
- `Alt + F2`: Run command
- `Ctrl + Esc`: System monitor
- `Meta + L`: Lock screen
- `Alt + Tab`: Switch windows

## ThinkPad Specific

### Function Keys
- `F1`: Mute/unmute
- `F2`: Volume down
- `F3`: Volume up
- `F4`: Microphone mute
- `F5`: Brightness down
- `F6`: Brightness up
- `F7`: Display toggle
- `F8`: WiFi/Airplane mode
- `F9`: Settings
- `F10`: Bluetooth
- `F11`: Keyboard light
- `F12`: Favorites

### TrackPoint
```bash
# Adjust TrackPoint speed (temporary)
echo 255 | sudo tee /sys/devices/platform/i8042/serio1/serio2/speed

# Adjust TrackPoint sensitivity
echo 200 | sudo tee /sys/devices/platform/i8042/serio1/serio2/sensitivity
```

## Troubleshooting Commands

### WiFi Issues
```bash
# Check WiFi device
ip link show

# Restart WiFi
sudo systemctl restart iwd NetworkManager

# Check WiFi driver
lspci -k | grep -A 3 -i network
```

### Audio Issues
```bash
# Check audio devices
aplay -l

# Test audio
speaker-test -c 2

# Check PipeWire
systemctl --user status pipewire
```

### Graphics Issues
```bash
# Check graphics driver
lspci -k | grep -A 3 -i vga

# Check OpenGL
glxinfo | grep "OpenGL renderer"

# Monitor GPU
intel_gpu_top
```

### System Logs
```bash
# Recent boot logs
journalctl -b

# Follow system log
journalctl -f

# Check errors
journalctl -p err -b

# Kernel messages
dmesg | less
```

## Performance Monitoring

```bash
# CPU usage
htop

# Disk I/O
iotop

# Network usage
nethogs

# System resources
btop

# Temperature
sensors
```

## Useful Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# System updates
alias update='sudo pacman -Syu'

# List packages by size
alias pacsize='expac -H M "%m\t%n" | sort -h'

# System cleanup
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

# Quick edit configs
alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.bashrc'

# Safer rm
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Better ls
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
```

## AUR Helper (yay)

```bash
# Install package from AUR
yay -S package-name

# Update AUR packages
yay -Sua

# Update all packages
yay -Syu

# Search AUR
yay -Ss search-term

# Remove package
yay -R package-name
```

## Backup Commands

```bash
# Backup package list
pacman -Qqe > pkglist.txt

# Restore packages
sudo pacman -S --needed - < pkglist.txt

# Backup home directory
rsync -av --progress /home/username /backup/location

# System backup (excludes)
sudo rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /backup/location
```

## WiFi 7 Specific

```bash
# Check WiFi capabilities
iw list | grep -A 10 "Supported interface modes"

# Check current connection
iw dev wlan0 link

# Scan networks
sudo iw dev wlan0 scan | grep SSID

# Connect with iwd
iwctl station wlan0 connect "SSID"
```

## Intel GPU Specific

```bash
# Check GPU frequency
cat /sys/class/drm/card0/gt_cur_freq_mhz

# Check GPU usage
intel_gpu_top

# Force GPU reset (if frozen)
sudo sh -c 'echo 1 > /sys/kernel/debug/dri/0/i915_wedged'
```

## Battery Optimization

```bash
# Battery information
upower -i /org/freedesktop/UPower/devices/battery_BAT0

# TLP configuration
sudo vim /etc/tlp.conf

# Apply TLP changes
sudo tlp start

# Show battery statistics
tlp-stat -b
```

## Quick Fixes

### Fix WiFi not connecting
```bash
sudo systemctl restart iwd NetworkManager
sudo rfkill unblock wifi
```

### Fix audio not working
```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Fix brightness control
```bash
# Install alternative tool
sudo pacman -S brightnessctl
brightnessctl s 50%
```

### Clear package cache
```bash
sudo pacman -Sc
# Or keep last 3 versions
sudo paccache -r
```

## Recovery Mode

If system doesn't boot:
1. Boot from Arch USB
2. Mount partitions:
   ```bash
   mount /dev/nvme0n1p3 /mnt
   mount /dev/nvme0n1p1 /mnt/boot
   ```
3. Chroot:
   ```bash
   arch-chroot /mnt
   ```
4. Fix issue and regenerate boot:
   ```bash
   bootctl update
   ```

## Additional Resources

- Man pages: `man command-name`
- Arch Wiki: https://wiki.archlinux.org/
- Command help: `command-name --help`
- Package info: `pacman -Si package-name`

---

**Tip**: Use `tldr` for simplified man pages:
```bash
sudo pacman -S tldr
tldr command-name
```
