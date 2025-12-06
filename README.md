# StorLoko ARM Builder

Automated build system for StorLoko homecloud device images using Armbian and GitLab CI/CD.

## Overview

This repository builds custom ARM device images with:
- **Per-device IAM credentials** for DNS-01 SSL certificate automation
- **Pre-installed applications** via CasaOS (Vaultwarden, Nextcloud, Immich, Jellyfin)
- **Zero-touch provisioning** - Factory provision → Customer deployment
- **Tiered deployment** based on device hardware capability

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitLab CI/CD Pipeline                        │
├─────────────────────────────────────────────────────────────────┤
│  prepare:iam          │  build:board          │  after_script   │
│  ├─ Generate serial   │  ├─ Clone Armbian     │  ├─ Upload to   │
│  ├─ Create IAM user   │  ├─ Inject creds      │  │  repo1.ac7   │
│  ├─ Scope to device   │  ├─ Build image       │  └─ Notify      │
│  └─ Create DNS (1.1.1)│  └─ Compress & hash   │                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Device First Boot                            │
├─────────────────────────────────────────────────────────────────┤
│  Factory Provision        │  Customer Deployment               │
│  ├─ Set hostname          │  ├─ Detect LAN IP                  │
│  ├─ Inject AWS creds      │  ├─ Update Route53 DNS             │
│  ├─ Configure Caddy       │  ├─ Install CasaOS                 │
│  └─ Create customer card  │  ├─ Deploy apps (tier-based)       │
│                           │  └─ Start Caddy → Let's Encrypt    │
└─────────────────────────────────────────────────────────────────┘
```

## Supported Boards

| Board | Tier | SoC | RAM | Apps |
|-------|------|-----|-----|------|
| Rock Pi 4C+ | Basic | RK3399-T | 4GB | Vaultwarden |
| Orange Pi 5 Pro | Mid | RK3588S | 16GB | All apps |
| Orange Pi 5 Ultra | Premium | RK3588 | 16GB+ | All apps + ML |
| UEFI x86 | Premium | Intel N100+ | 16GB+ | All apps + ML |

## Per-Device IAM Credentials

Each device gets its own scoped AWS IAM credentials:

```
IAM User: storloko-device-sl-abc12345
Policy:   Can ONLY modify DNS for:
          - device-sl-abc12345.cust.storloko.com
          - *.device-sl-abc12345.cust.storloko.com
```

**Why?** 
- Devices can request SSL certificates via DNS-01 challenge
- No port forwarding required (works behind NAT)
- Compromised device can't affect other customers

## DNS & SSL Flow

1. **Build time**: DNS records created pointing to `1.1.1.1` (placeholder)
2. **Customer boot**: Device detects its LAN IP and updates Route53
3. **Caddy starts**: Requests Let's Encrypt cert via DNS-01
4. **Result**: Valid SSL on `https://device-sl-xxx.cust.storloko.com`

## Device URLs

After deployment, customers access their device via:

| Service | DNS URL | IP Fallback |
|---------|---------|-------------|
| Main Portal | `https://device-sl-xxx.cust.storloko.com` | `https://192.168.x.x:443` |
| Vaultwarden | `https://vaultwarden.device-sl-xxx.cust.storloko.com` | `https://192.168.x.x:8443` |
| Nextcloud | `https://nextcloud.device-sl-xxx.cust.storloko.com` | `https://192.168.x.x:8444` |
| Immich | `https://immich.device-sl-xxx.cust.storloko.com` | `https://192.168.x.x:8445` |
| Jellyfin | `https://jellyfin.device-sl-xxx.cust.storloko.com` | `https://192.168.x.x:8446` |

## Repository Structure

```
├── .gitlab-ci.yml      # Complete build pipeline (all logic inline)
├── yaml/               # CasaOS app manifests
│   ├── vaultwarden.yaml
│   ├── nextcloud.yaml
│   ├── immich-full.yaml
│   ├── immich-light.yaml
│   └── jellyfin.yaml
└── docs/
    ├── BOARDS.md       # Supported hardware details
    ├── FLASHING.md     # Image flashing guide
    └── TROUBLESHOOTING.md
```

## Key Design Decisions

### All Logic Inline in CI

The `.gitlab-ci.yml` contains all scripts as heredocs. This is intentional:
- **Armbian bug**: userpatches scripts are ignored if pre-existing
- **Workaround**: Generate everything at build time within CI file
- **Benefit**: Single source of truth, no sync issues

### YAML Files Downloaded at Runtime

App YAML files are downloaded from `repo.storloko.com/yaml/` during customer deployment:
- Allows updates without rebuilding images
- Device hostname injected via `sed` replacement
- `DEVICE_HOSTNAME` placeholder in all YAMLs

## Pipeline Triggers

Trigger a build via GitLab API:

```bash
curl -X POST \
  -F "token=$CI_TRIGGER_TOKEN" \
  -F "ref=simple" \
  -F "variables[BOARD]=rockpi-4cplus" \
  -F "variables[DEVICE_SERIAL]=sl-custom123" \
  https://gh1.ac7.top/api/v4/projects/25/trigger/pipeline
```

## Requirements

### GitLab Runner
- `arm64` tagged runner for ARM builds
- `docker` tagged runner for notifications
- 25GB+ disk space per build

### CI/CD Variables
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` - Admin credentials for IAM
- `ROUTE53_ZONE_ID` - Hosted zone for `cust.storloko.com`
- `CI_PROVISION_TOKEN` - StorLoko API token
- `CI_PUSHOVER_API_TOKEN` / `CI_PUSHOVER_USER_KEY` - Notifications

## License

MIT License - See LICENSE file

## Support

- **Documentation**: See `docs/` folder
- **Issues**: GitLab Issues
- **Email**: support@storloko.com
