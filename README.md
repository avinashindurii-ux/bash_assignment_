# Bash Service Health Monitor

## Description
This script monitors system services, restarts failed services, and logs events.

## Features
- Reads services from services.txt
- Checks service status using systemctl
- Auto-restarts failed services
- Logs events to /var/log/health_monitor.log
- Summary report
- Dry-run mode supported

## Usage
```bash
sudo bash health_monitor.sh
sudo bash health_monitor.sh --dry-run
