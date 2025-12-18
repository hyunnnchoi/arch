# Hardware Compatibility - ThinkPad X1 Carbon Gen 13 (Lunar Lake)

This document tracks the hardware compatibility status for various components of the ThinkPad X1 Carbon Gen 13 with Arch Linux.

## System Information

**Model**: Lenovo ThinkPad X1 Carbon Gen 13  
**Processor**: Intel Core Ultra (Lunar Lake)  
**Architecture**: x86_64  
**BIOS/UEFI**: Lenovo UEFI

## Kernel Requirements

- **Minimum**: Linux 6.11+ (for Lunar Lake support)
- **Recommended**: Linux 6.12+ or latest mainline
- **Tested**: Linux 6.11.x, 6.12.x

## Component Status

### ✅ Fully Working

#### CPU
- **Component**: Intel Core Ultra (Lunar Lake)
- **Driver**: Built-in kernel support
- **Status**: Full support with kernel 6.11+
- **Notes**: 
  - All P-cores and E-cores detected
  - Power management working
  - Frequency scaling functional
  - Install `intel-ucode` for microcode updates

#### Graphics
- **Component**: Intel Arc Graphics (integrated)
- **Driver**: i915 (kernel), mesa
- **Status**: Fully functional
- **Packages**: `mesa`, `vulkan-intel`, `intel-media-driver`
- **Notes**:
  - Wayland recommended for best performance
  - Hardware acceleration working
  - Multiple displays supported

#### Storage
- **Component**: NVMe SSD
- **Driver**: nvme (kernel)
- **Status**: Fully functional
- **Notes**: 
  - TRIM support available
  - Enable with `systemctl enable fstrim.timer`

#### USB
- **Component**: USB 3.x / USB-C ports
- **Driver**: xhci_hcd (kernel)
- **Status**: All ports working
- **Notes**: Thunderbolt 4 support available

#### Keyboard
- **Component**: ThinkPad Keyboard
- **Driver**: atkbd (kernel)
- **Status**: Fully functional
- **Notes**: All keys including function keys working

#### TrackPoint
- **Component**: TrackPoint pointing stick
- **Driver**: psmouse, libinput
- **Status**: Fully functional
- **Package**: `xf86-input-libinput`
- **Notes**: Middle button scrolling works

#### Touchpad
- **Component**: Precision Touchpad
- **Driver**: libinput
- **Status**: Fully functional
- **Package**: `xf86-input-libinput`
- **Notes**: 
  - Multi-touch gestures work
  - Palm detection functional
  - Tap-to-click supported

#### Audio
- **Component**: Realtek ALC/Intel HDA
- **Driver**: snd_hda_intel
- **Status**: Fully functional
- **Package**: `pipewire`, `pipewire-pulse`, `wireplumber`
- **Notes**: 
  - Speakers working
  - Headphone jack working
  - Microphone working

#### Ethernet (via USB-C adapter)
- **Component**: Various USB-C Ethernet adapters
- **Driver**: Varies by adapter
- **Status**: Generally working
- **Notes**: Most common adapters work out of box

#### Battery
- **Component**: Internal battery
- **Driver**: ACPI
- **Status**: Fully functional
- **Package**: `tlp`, `powertop`
- **Notes**: 
  - Battery status reporting accurate
  - Charge thresholds configurable with TLP

#### Power Management
- **Component**: ACPI, Intel P-state
- **Driver**: intel_pstate
- **Status**: Fully functional
- **Package**: `tlp`, `thermald`
- **Notes**: 
  - Suspend/resume working
  - Hibernate working (with swap)
  - CPU frequency scaling working

#### Display
- **Component**: Various (FHD, 2K, OLED)
- **Driver**: i915
- **Status**: Fully functional
- **Notes**: 
  - Brightness control working
  - Fractional scaling supported (Wayland)

### ⚠️ Partially Working

#### WiFi 7
- **Component**: Intel BE200 (WiFi 7)
- **Driver**: iwlwifi
- **Status**: Working with caveats
- **Package**: `linux-firmware`, `iwd`
- **Notes**: 
  - WiFi 6E/7 support requires kernel 6.11+
  - May need updated firmware from `linux-firmware-git` (AUR)
  - Some WiFi 7 features may not be available yet
  - Falls back to WiFi 6E on older kernels
- **Workaround**: Use `iwd` instead of `wpa_supplicant` for better support

#### Bluetooth
- **Component**: Intel Bluetooth (WiFi combo chip)
- **Driver**: btusb, btintel
- **Status**: Working with occasional issues
- **Package**: `bluez`, `bluez-utils`
- **Notes**: 
  - Basic functionality working
  - May require firmware updates
  - Some users report connection stability issues
- **Workaround**: Update to latest `linux-firmware`

#### Fingerprint Reader
- **Component**: Various (Goodix/Synaptics)
- **Driver**: fprintd
- **Status**: Model dependent
- **Package**: `fprintd`, `libfprint`
- **Notes**: 
  - Some models working, others need specific drivers
  - Check [fprintd supported devices](https://fprint.freedesktop.org/supported-devices.html)
  - May need proprietary drivers from AUR

#### IR Camera (Windows Hello)
- **Component**: Infrared camera
- **Driver**: uvcvideo
- **Status**: Limited support
- **Package**: `howdy` (AUR)
- **Notes**: 
  - Camera detected but IR functionality limited in Linux
  - Howdy can be used as alternative to Windows Hello
  - Not as reliable as native Windows Hello

#### Thunderbolt 4
- **Component**: Thunderbolt 4 ports
- **Driver**: thunderbolt
- **Status**: Working with manual authorization
- **Package**: `bolt`
- **Notes**: 
  - Requires authorization with `boltctl`
  - Some devices may need manual setup
  - Security levels configurable

### ❌ Not Working / Not Tested

#### Smart Card Reader (if equipped)
- **Component**: Smart card reader
- **Status**: Not tested
- **Notes**: May require additional drivers

#### Mobile Broadband (WWAN)
- **Component**: 5G/LTE modem (optional)
- **Status**: Not tested
- **Package**: `modemmanager`
- **Notes**: Should work with ModemManager but untested

## Known Issues

### Issue 1: WiFi Performance
- **Description**: WiFi 7 features not fully available
- **Workaround**: Use WiFi 6E mode or wait for kernel/firmware updates
- **Status**: Tracking upstream development

### Issue 2: Suspend Battery Drain
- **Description**: Some battery drain during suspend
- **Workaround**: 
  - Use hibernate instead
  - Enable deep sleep: Add `mem_sleep_default=deep` to kernel parameters
- **Status**: Common Linux laptop issue, improving

### Issue 3: Fingerprint Reader Compatibility
- **Description**: Not all fingerprint reader models supported
- **Workaround**: Check specific model compatibility first
- **Status**: Depends on manufacturer support

## Testing Checklist

Use this checklist to verify hardware after installation:

```bash
# CPU
lscpu
cat /proc/cpuinfo | grep "model name"

# Graphics
lspci | grep -i vga
glxinfo | grep "OpenGL renderer"

# WiFi
lspci | grep -i network
ip link
nmcli device

# Bluetooth
lsusb | grep -i bluetooth
bluetoothctl show

# Audio
pactl list sinks
speaker-test -c2

# Touchpad/Keyboard
libinput list-devices

# Battery
cat /sys/class/power_supply/BAT0/status
upower -i /org/freedesktop/UPower/devices/battery_BAT0

# Backlight
ls /sys/class/backlight/
cat /sys/class/backlight/*/brightness

# Thunderbolt
boltctl list

# Storage
lsblk
nvme list
```

## Performance Tuning

### CPU Performance
```bash
# Check current governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set performance mode (temporary)
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### Graphics Performance
```bash
# Check GPU info
intel_gpu_top

# Enable GuC/HuC firmware
# Add to kernel parameters: i915.enable_guc=3
```

### Power Saving
```bash
# Install TLP
sudo pacman -S tlp

# Check TLP status
sudo tlp-stat

# Optimize with powertop
sudo powertop --auto-tune
```

## Firmware Updates

### BIOS/UEFI Update
1. Download latest BIOS from Lenovo support website
2. Create bootable USB with BIOS update
3. Boot and follow on-screen instructions
4. **Recommended**: Keep BIOS updated for hardware compatibility

### Linux Firmware
```bash
# Update firmware packages
sudo pacman -S linux-firmware

# For latest firmware (AUR)
yay -S linux-firmware-git
```

## Benchmarks

### Graphics
```bash
# Install benchmark tools
sudo pacman -S glmark2

# Run benchmark
glmark2 --fullscreen
```

### CPU
```bash
# Install sysbench
sudo pacman -S sysbench

# Run CPU benchmark
sysbench cpu --threads=16 run
```

### Disk
```bash
# Install fio
sudo pacman -S fio

# Run disk benchmark
fio --name=random-write --ioengine=libaio --rw=randwrite --bs=4k --size=1g --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1
```

## Contributing

If you have a ThinkPad X1 Carbon Gen 13 and can test additional hardware components or configurations, please contribute your findings!

### How to Contribute
1. Test a component not listed or marked as "Not Tested"
2. Document your results (working/not working/partially working)
3. Include relevant package names and configuration
4. Submit a pull request or open an issue

## References

- [Arch Linux Wiki - Lenovo ThinkPad X1 Carbon](https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Carbon)
- [Intel Lunar Lake Documentation](https://www.intel.com/content/www/us/en/products/docs/processors/core-ultra/)
- [Kernel.org - Hardware Support](https://www.kernel.org/)
- [r/thinkpad - X1 Carbon Gen 13 Discussions](https://reddit.com/r/thinkpad)

## Changelog

- **2024-12**: Initial hardware compatibility documentation
- Status based on Linux kernel 6.11+ and Arch Linux testing

---

**Note**: Hardware compatibility is continually improving with kernel and firmware updates. Check back regularly for updates.
