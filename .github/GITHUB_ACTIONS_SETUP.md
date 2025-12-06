# GitHub Actions Setup

This document explains how to configure GitHub Actions to build StorLoko images.

## Required Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description | Example |
|--------|-------------|--------|
| `AWS_ACCESS_KEY_ID` | AWS admin key for IAM creation | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS admin secret | `wJal...` |
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account ID | `123456789012` |
| `ROUTE53_ZONE_ID` | Hosted zone for your domain | `Z1234567890ABC` |
| `PUSHOVER_API_TOKEN` | (Optional) Pushover app token | `a1b2c3...` |
| `PUSHOVER_USER_KEY` | (Optional) Pushover user key | `u1v2w3...` |

## Required Variables

Go to **Settings → Secrets and variables → Actions → Variables** and add:

| Variable | Description | Default |
|----------|-------------|--------|
| `AWS_REGION` | AWS region | `ap-southeast-2` |
| `DOMAIN_SUFFIX` | Your domain suffix | `cust.storloko.com` |
| `PUSHOVER_ENABLED` | Enable notifications | `false` |

## Triggering a Build

1. Go to **Actions** tab
2. Select **Build StorLoko Image**
3. Click **Run workflow**
4. Choose:
   - **Board**: Target hardware
   - **Device serial**: Leave empty to auto-generate
   - **Release**: Ubuntu version
5. Click **Run workflow**

## Build Artifacts

After a successful build:

1. Go to the workflow run
2. Scroll to **Artifacts**
3. Download:
   - `storloko-image-sl-xxx`: The flashable image
   - `device-credentials`: AWS credentials for the device

## Self-Hosted Runners

For faster ARM64 native builds (no QEMU emulation):

1. Set up an ARM64 machine (Orange Pi, Raspberry Pi 4, etc.)
2. Install GitHub Actions runner: https://docs.github.com/en/actions/hosting-your-own-runners
3. Add labels: `self-hosted`, `arm64`
4. Modify `.github/workflows/build.yml`:
   ```yaml
   runs-on: [self-hosted, arm64]
   ```

## IAM Permissions

The AWS credentials need these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateUser",
        "iam:TagUser",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:AttachUserPolicy",
        "iam:DetachUserPolicy",
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:ListAccessKeys"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListHostedZones"
      ],
      "Resource": "*"
    }
  ]
}
```

## Troubleshooting

### Build fails with disk space error

The workflow includes disk cleanup, but GitHub-hosted runners have limited space (~14GB free). For large builds, use a self-hosted runner with more disk space.

### QEMU build is slow

Cross-compilation via QEMU can take 2-4 hours. Options:
1. Use ARM64 self-hosted runner
2. Use Armbian's Docker-based build (experimental)
3. Pre-cache toolchain in a container registry

### IAM creation fails

Check that your AWS credentials have the required IAM permissions listed above.
