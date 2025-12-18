# Arch Linux for ThinkPad X1 Carbon Gen 13 (Lunar Lake)

Personal repository for Arch Linux installation and configuration on the ThinkPad X1 Carbon Gen 13 with Intel Lunar Lake processors.

## 📚 Documentation

- **[Installation Guide](INSTALL.md)** - Complete step-by-step installation instructions
- **[Hardware Compatibility](HARDWARE.md)** - Hardware component status and compatibility information
- **[Installation Script](install.sh)** - Automated installation script (use with caution!)

## 🚀 Quick Start

### Manual Installation
Follow the comprehensive [Installation Guide](INSTALL.md) for detailed step-by-step instructions.

### Automated Installation (Advanced)
```bash
# Download the installation script
curl -O https://raw.githubusercontent.com/hyunnnchoi/arch/main/install.sh
chmod +x install.sh

# Review the script first!
less install.sh

# Run the installation (WARNING: This will format your disk!)
./install.sh
```

## ⚠️ Important Notes

- This is a personal project shared for the community
- **Always backup your data** before installation
- The automated script will **format your disk** - use with extreme caution
- Review all scripts and documentation before running
- Lunar Lake requires Linux kernel 6.11+ for optimal support

## 🖥️ Hardware Specifications

**Tested Configuration:**
- Model: ThinkPad X1 Carbon Gen 13
- CPU: Intel Core Ultra 7 (Lunar Lake)
- RAM: 32GB LPDDR5X
- Storage: 1TB NVMe SSD
- Display: 2.8K OLED
- WiFi: Intel BE200 (WiFi 7)

See [HARDWARE.md](HARDWARE.md) for detailed component compatibility.

## 📋 Features

This repository includes:
- ✅ Complete installation guide with Lunar Lake specific optimizations
- ✅ Hardware compatibility matrix
- ✅ Automated installation script
- ✅ Power management configuration
- ✅ WiFi 7 setup instructions
- ✅ Audio (PipeWire) configuration
- ✅ Graphics (Intel Arc) setup
- ✅ Post-installation optimization tips

## 🤝 Contributing

Contributions are welcome! If you:
- Found a better configuration
- Tested additional hardware components
- Have improvements to the installation process
- Want to add troubleshooting tips

Please open an issue or submit a pull request.

## 📝 License

MIT License - Feel free to use and modify for your own purposes.

## 🔗 Useful Resources

- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [ThinkPad X1 Carbon Wiki](https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Carbon)
- [r/archlinux](https://reddit.com/r/archlinux)
- [r/thinkpad](https://reddit.com/r/thinkpad)

## ⚡ Status

- **Last Updated**: December 2024
- **Kernel Tested**: 6.11.x, 6.12.x
- **Status**: Active development

---

**Disclaimer**: This repository is for educational and personal use. Always review and understand scripts before running them on your system.
