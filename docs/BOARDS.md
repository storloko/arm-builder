# Supported Boards

This document details the hardware platforms supported by StorLoko ARM Builder.

## Board Tiers

StorLoko devices are categorized into tiers based on processing capability:

### Basic Tier

Entry-level devices suitable for single-user deployments with lightweight services.

| Board | SoC | RAM | Storage | Use Case |
|-------|-----|-----|---------|----------|
| Rock Pi 4C+ | RK3399-T | 4GB | eMMC/SD | Password manager, light file sync |
| Rock Pi 4B | RK3399 | 2-4GB | eMMC/SD | Same as 4C+ |
| Orange Pi 4 LTS | RK3399 | 4GB | eMMC/SD | Budget option |

**Recommended Apps:** Vaultwarden only

### Mid Tier

Family/small office deployments with photo backup and media streaming.

| Board | SoC | RAM | Storage | Use Case |
|-------|-----|-----|---------|----------|
| Orange Pi 5 Pro | RK3588S | 16GB | NVMe/eMMC | Full app suite |
| Orange Pi 5 | RK3588S | 4-16GB | NVMe/eMMC | Flexible option |

**Recommended Apps:** Vaultwarden, Nextcloud, Immich (light), Jellyfin

### Premium Tier

Power users, ML workloads, multi-user environments.

| Board | SoC | RAM | Storage | Use Case |
|-------|-----|-----|---------|----------|
| Orange Pi 5 Ultra | RK3588 | 16-32GB | NVMe | Full ML, 4K transcoding |
| UEFI x86 (Intel N100) | N100 | 16-32GB | NVMe | Maximum compatibility |

**Recommended Apps:** All apps + Immich ML, hardware transcoding

## Hardware Selection Guide

### For Personal Use (1-2 users)
- **Budget:** Rock Pi 4C+ ($60-80)
- **Best Value:** Orange Pi 5 Pro ($150)

### For Family (3-5 users)
- **Recommended:** Orange Pi 5 Pro 16GB ($150)
- **With ML:** Orange Pi 5 Ultra ($200+)

### For Small Office (5-10 users)
- **Recommended:** Intel N100 mini PC ($200-300)
- **With redundancy:** Proxmox cluster with x86

## SoC Capabilities

### RK3399 Series
- 6 cores (2x A72 + 4x A53)
- Mali-T860 GPU
- 4K@60 decode, 1080p encode
- USB 3.0, PCIe 2.1

### RK3588/S Series  
- 8 cores (4x A76 + 4x A55)
- Mali-G610 GPU + 6 TOPS NPU
- 8K decode, 8K encode
- USB 3.1, PCIe 3.0, 2.5GbE

### Intel N100
- 4 E-cores @ 3.4GHz
- Intel UHD Graphics (24 EU)
- AV1/HEVC/VP9 decode
- Thunderbolt, 2.5GbE native

## Peripheral Requirements

### Storage
- **Minimum:** 32GB Class 10 SD card
- **Recommended:** 128GB+ NVMe SSD
- **For media:** Add USB 3.0 external drive

### Power Supply
- RK3399 boards: 5V 3A USB-C
- RK3588 boards: 5V 4A USB-C or 12V barrel
- x86: Standard ATX or 12V DC

### Networking
- Gigabit Ethernet required
- 2.5GbE recommended for NAS use
- WiFi optional (Ethernet preferred)
