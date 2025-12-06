# Troubleshooting Guide

Common issues and solutions for StorLoko devices.

## Build Issues

### Pipeline Fails at prepare:iam

**Symptom:** IAM credential creation fails

**Causes:**
1. AWS credentials not configured in CI/CD variables
2. Insufficient IAM permissions for CI user
3. Route53 zone ID incorrect

**Solution:**
```bash
# Verify AWS credentials are set
aws sts get-caller-identity

# Check Route53 zone exists
aws route53 list-hosted-zones | grep storloko
```

### Build Fails with Disk Space Error

**Symptom:** "No space left on device"

**Solution:**
- Armbian builds require 25GB+ free space
- Clean previous builds: `./helper.sh clean`
- Use dedicated build runner with adequate storage

### Armbian Build Hangs

**Symptom:** Build stuck at kernel compile

**Solutions:**
1. Increase runner memory (8GB+ recommended)
2. Reduce parallel jobs: Set `KERNEL_CPUS=2`
3. Check for OOM killer in dmesg

## Device Issues

### SSL Certificate Not Working

**Symptom:** Browser shows "Not Secure" warning

**Diagnosis:**
```bash
# Check Caddy status
sudo systemctl status caddy

# View Caddy logs
sudo journalctl -u caddy -f

# Test DNS resolution
dig device-sl-xxx.cust.storloko.com
```

**Common Causes:**
1. DNS not updated (IP still 1.1.1.1)
2. Port 443 blocked by router
3. AWS credentials not working on device

**Solution:**
```bash
# Manually trigger DNS update
/opt/storloko/update-dns.sh

# Force Caddy to request new cert
sudo caddy reload -config /etc/caddy/Caddyfile
```

### CasaOS Not Loading

**Symptom:** Port 81 shows nothing

**Diagnosis:**
```bash
# Check if CasaOS is running
sudo systemctl status casaos

# Check Docker
sudo docker ps
```

**Solution:**
```bash
# Restart CasaOS
sudo systemctl restart casaos

# If failed, reinstall
curl -fsSL https://get.casaos.io | sudo bash
```

### Device Not Getting IP

**Symptom:** No network connectivity

**Diagnosis:**
1. Connect HDMI monitor
2. Check if interface is up: `ip link`
3. Check DHCP: `sudo dhclient -v eth0`

**Solutions:**
1. Try different Ethernet cable
2. Verify router DHCP is enabled
3. Set static IP temporarily:
```bash
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip route add default via 192.168.1.1
```

### App Containers Failing

**Symptom:** Vaultwarden/Nextcloud not starting

**Diagnosis:**
```bash
# List all containers
sudo docker ps -a

# View specific container logs
sudo docker logs vaultwarden
```

**Common Causes:**
1. Not enough RAM (check `free -h`)
2. Storage full (check `df -h`)
3. Port conflicts

**Solution:**
```bash
# Restart container
sudo docker restart vaultwarden

# If persistent, recreate
cd /opt/storloko/apps
sudo docker-compose up -d --force-recreate vaultwarden
```

## Performance Issues

### Device Running Slow

**Diagnosis:**
```bash
# Check CPU usage
htop

# Check memory
free -h

# Check disk I/O
iotop
```

**Solutions:**
1. Upgrade to faster storage (NVMe > eMMC > SD)
2. Add swap if RAM constrained
3. Reduce running services
4. Upgrade to higher tier device

### Photo Uploads Slow (Immich)

**Causes:**
1. SD card bottleneck
2. ML processing overloading CPU
3. Network congestion

**Solutions:**
1. Use NVMe storage
2. Disable ML or use immich-light config
3. Upload during off-peak hours

## Recovery

### Factory Reset

To completely reset a device:

1. Re-flash the original image
2. All data will be lost

### Backup Before Reset

```bash
# Backup Vaultwarden
sudo docker exec vaultwarden /backup.sh
scp /opt/storloko/backups/vaultwarden/* user@backup-server:/backups/

# Backup Nextcloud
sudo docker exec nextcloud occ maintenance:mode --on
sudo tar -czf nextcloud-backup.tar.gz /opt/storloko/data/nextcloud/
sudo docker exec nextcloud occ maintenance:mode --off
```

## Getting Help

1. Check logs first: `sudo journalctl -xe`
2. Open GitHub issue with:
   - Device model
   - Image version
   - Full error output
   - Steps to reproduce
