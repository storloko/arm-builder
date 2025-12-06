# StorLoko ARM Builder

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Project Status:** StorLoko was an Australian privacy-focused homecloud hardware company (2024-2025). This repository is now open source for the community to learn from, fork, and build upon.

Automated build system for homecloud device images using Armbian and GitLab CI/CD. Generates pre-configured ARM device images with built-in DNS automation and SSL certificates.

## Full Disclosure

Copious usage was made of an LLM to clean up, generalise, and push this to GitHub for public consumption. All care has been taken but keep it in mind.

## What This Does

- Builds custom Armbian images for ARM single-board computers
- Creates per-device AWS IAM credentials scoped to a single DNS zone
- Pre-installs self-hosted apps via CasaOS (Vaultwarden, Nextcloud, Immich, Jellyfin)
- Enables zero-touch SSL certificates via DNS-01 challenge (works behind NAT)

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitLab CI/CD Pipeline                        │
├─────────────────────────────────────────────────────────────────┤
│  prepare:iam          │  build:board          │  after_script   │
│  ├─ Generate serial   │  ├─ Clone Armbian     │  ├─ Upload to   │
│  ├─ Create IAM user   │  ├─ Build image       │  │  artifact    │
│  ├─ Scope to device   │  ├─ Inject creds      │  │  server      │
│  └─ Create DNS        │  └─ Compress & hash   │  └─ Notify      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Device First Boot                            │
├─────────────────────────────────────────────────────────────────┤
│  1. Device boots with pre-baked AWS credentials                 │
│  2. Detects LAN IP, updates Route53 DNS                         │
│  3. Caddy requests Let's Encrypt cert via DNS-01                │
│  4. All services available at https://device-xxx.yourdomain.com │
└─────────────────────────────────────────────────────────────────┘
```

## Supported Boards

| Board | Tier | SoC | RAM | Recommended Apps |
|-------|------|-----|-----|------------------|
| Rock Pi 4C+ | Basic | RK3399-T | 4GB | Vaultwarden |
| Orange Pi 4 LTS | Basic | RK3399-T | 4GB | Vaultwarden |
| Orange Pi 5 Pro | Mid | RK3588S | 4GB | All apps |
| Orange Pi 5 Ultra | Premium | RK3588 | 16GB+ | All apps + ML |
| UEFI x86 | Premium | Intel N100+ | 16GB+ | All apps + ML |

See [docs/BOARDS.md](docs/BOARDS.md) for detailed hardware information.

## Per-Device IAM Credentials

Each device gets its own scoped AWS IAM credentials:

```
IAM User: device-sl-abc12345
Policy:   Can ONLY modify DNS for:
          - device-sl-abc12345.cust.yourdomain.com
          - *.device-sl-abc12345.cust.yourdomain.com
```

**Why this matters:**
- Devices can request SSL certificates via DNS-01 challenge
- Works behind NAT (no port forwarding required)
- Compromised device can't affect other customers
- Each device is cryptographically isolated

## Repository Structure

```
├── .gitlab-ci.yml      # Complete build pipeline
├── helper.sh           # Local build utilities
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

## Adapting for Your Own Use

This was designed for a commercial product but the patterns are reusable:

1. **Fork this repo**
2. **Set up your own domain** with Route53 hosted zone
3. **Configure CI/CD variables:**
   - `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (admin for IAM creation)
   - `ROUTE53_ZONE_ID` (your hosted zone)
   - `AWS_ACCOUNT_ID` (your AWS account)
4. **Modify the CI file** to use your domain instead of `cust.storloko.com`
5. **Set up a GitLab runner** with `arm64` and `docker` tags

## Key Design Decisions

### All Logic Inline in CI

The `.gitlab-ci.yml` contains all scripts as heredocs. This was intentional due to an Armbian bug where userpatches scripts are ignored if pre-existing in the repo. Everything is generated at build time.

### YAML Files Downloaded at Runtime

App YAML files are downloaded during first boot, allowing updates without rebuilding images. Device hostname is injected via `sed` replacement of the `DEVICE_HOSTNAME` placeholder.

## Requirements

- GitLab CI runner with `arm64` tag (for ARM builds)
- GitLab CI runner with `docker` tag (for notifications/IAM)
- 25GB+ disk space per build
- AWS account with Route53

## Related Projects

If you're interested in self-hosted home cloud solutions, check out:
- [Umbrel](https://github.com/getumbrel/umbrel)
- [CasaOS](https://github.com/IceWhaleTech/CasaOS)
- [Armbian](https://github.com/armbian/build)

## License

MIT License - See [LICENSE](LICENSE) file.

## Contributing

This project is archived but PRs are welcome if you want to build on it. See [CONTRIBUTING.md](CONTRIBUTING.md).

---

*Originally developed by [StorLoko Pty Ltd](https://storloko.com) for the APAC home cloud market.*
