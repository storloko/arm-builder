# Image Flashing Guide

How to flash StorLoko images to your device.

## Prerequisites

- StorLoko image file (`.img.xz`)
- Target storage media (SD card or eMMC)
- Flashing software (see below)

## Download Your Image

Images are available from:
- Build artifacts (if self-hosting)
- `repo.storloko.com/images/` (official releases)

## Flashing Tools

### Recommended: balenaEtcher

1. Download from [balena.io/etcher](https://balena.io/etcher)
2. Select the `.img.xz` file (no need to decompress)
3. Select target drive
4. Flash!

### Alternative: dd (Linux/macOS)

```bash
# Identify your SD card
lsblk

# Decompress and flash (replace sdX with your device)
xz -dc storloko-device-sl-xxx.img.xz | sudo dd of=/dev/sdX bs=4M status=progress

# Sync and eject
sync
```

**Warning:** Double-check the target device. `dd` will overwrite without confirmation.

### Alternative: Raspberry Pi Imager

1. Download from [raspberrypi.com/software](https://www.raspberrypi.com/software/)
2. Choose OS → Use custom → Select your image
3. Choose storage → Select SD card
4. Write

## eMMC Flashing

### Method 1: USB Boot Mode

Some boards (Rock Pi, Orange Pi) support USB boot mode:

1. Hold the MASKROM/BOOT button while connecting USB
2. Use `rkdeveloptool` (Rockchip) or board-specific tool
3. Flash directly to eMMC

### Method 2: Boot from SD, Copy to eMMC

1. Flash image to SD card
2. Boot the device from SD
3. Run: `sudo armbian-install`
4. Select eMMC as target
5. Remove SD card and reboot

## Post-Flash Steps

### First Boot

1. Connect Ethernet cable
2. Power on device
3. Wait 2-3 minutes for initial setup
4. Find device IP via router or: `arp -a | grep -i "rock\|orange"`

### Initial Access

- **SSH:** `ssh storloko@<device-ip>` (password: `storloko`)
- **Web UI:** `https://<device-ip>` (after SSL setup)

### Change Default Password

```bash
passwd
```

## Troubleshooting

### Device Doesn't Boot

1. Verify image SHA256 checksum
2. Try a different SD card (Class 10 minimum)
3. Re-flash the image
4. Check power supply (3A minimum)

### Can't Find Device on Network

1. Ensure Ethernet is connected before power-on
2. Check router DHCP leases
3. Try direct connection with static IP
4. Connect HDMI monitor to see boot messages

### SSH Connection Refused

1. Wait longer (first boot can take 3-5 minutes)
2. Check if device has finished setup: look for steady LED
3. Verify you're using the correct IP
