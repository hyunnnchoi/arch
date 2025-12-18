# Sample Configuration Files

This directory contains sample configuration files optimized for the ThinkPad X1 Carbon Gen 13 with Lunar Lake processors.

## Files

### `tlp.conf`
TLP power management configuration optimized for X1C Gen 13.

**Installation:**
```bash
sudo cp tlp.conf /etc/tlp.conf
sudo systemctl restart tlp
```

**Features:**
- Battery charge thresholds (75-80%) for battery longevity
- CPU scaling optimized for Lunar Lake
- Intel GPU power management
- USB autosuspend configuration
- WiFi and Bluetooth power saving

### `networkmanager-wifi.conf`
NetworkManager configuration to use iwd backend for better WiFi 7 support.

**Installation:**
```bash
sudo cp networkmanager-wifi.conf /etc/NetworkManager/conf.d/wifi_backend.conf
sudo systemctl restart NetworkManager
```

**Features:**
- iwd backend for WiFi 7 (Intel BE200)
- MAC address randomization for privacy
- Improved WiFi performance

### `kernel-parameters.txt`
Recommended kernel parameters for optimal Lunar Lake performance.

**Installation:**

For systemd-boot:
```bash
# Edit boot entry
sudo vim /boot/loader/entries/arch.conf

# Add parameters to the options line
```

For GRUB:
```bash
sudo vim /etc/default/grub
# Add parameters to GRUB_CMDLINE_LINUX_DEFAULT

sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Features:**
- Intel Graphics optimizations (GuC, FBC)
- Better suspend/resume
- Power management optimizations
- PCIe ASPM for power saving

## Usage Notes

1. **Always backup** original configuration files before replacing
2. **Review** each configuration and adjust to your needs
3. **Test** configurations one at a time
4. **Monitor** system behavior after applying changes

## Customization

These configurations are starting points. You may need to adjust based on:
- Your specific hardware configuration
- Usage patterns (desktop vs. mobile)
- Personal preferences
- Specific workloads

## Verification

After applying configurations:

```bash
# Check TLP status
sudo tlp-stat -s

# Check NetworkManager backend
nmcli -g WIFI-PROPERTIES.BACKEND general

# Check kernel parameters
cat /proc/cmdline

# Monitor power usage
sudo powertop
```

## Troubleshooting

If you experience issues after applying configurations:

1. **TLP issues**: Revert to default with `sudo tlp start`
2. **WiFi issues**: Remove NetworkManager config and restart
3. **Boot issues**: Remove kernel parameters via bootloader recovery

## Contributing

If you have improved configurations or additional optimizations, please contribute!
