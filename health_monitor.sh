#!/bin/bash

SERVICE_FILE="services.txt"
LOG_FILE="/var/log/health_monitor.log"
DRY_RUN=false

# Check for --dry-run flag
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[INFO] Running in DRY-RUN mode"
fi

# Check if services.txt exists and is not empty
if [[ ! -f "$SERVICE_FILE" || ! -s "$SERVICE_FILE" ]]; then
    echo "[ERROR] services.txt missing or empty"
    exit 1
fi

total=0
healthy=0
recovered=0
failed=0

log_event() {
    service=$1
    status=$2
    severity=$3
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $service | $status | $severity" | sudo tee -a "$LOG_FILE" > /dev/null
}

while read service
do
    # skip empty lines
    if [ -z "$service" ]; then
        continue
    fi

    total=$((total+1))

    if systemctl is-active --quiet "$service"; then
        echo "[OK] $service is running"
        healthy=$((healthy+1))
    else
        echo "[WARN] $service is down"

        if [ "$DRY_RUN" = true ]; then
            echo "[DRY-RUN] Would restart $service"
            log_event "$service" "SIMULATED_RECOVERY" "INFO"
            recovered=$((recovered+1))
            continue
        fi

        sudo systemctl restart "$service"
        sleep 5

        if systemctl is-active --quiet "$service"; then
            echo "[RECOVERED] $service restarted"
            log_event "$service" "RECOVERED" "INFO"
            recovered=$((recovered+1))
        else
            echo "[FAILED] $service failed"
            log_event "$service" "FAILED" "ERROR"
            failed=$((failed+1))
        fi
    fi

done < "$SERVICE_FILE"

echo ""
echo "========= SUMMARY ========="
echo "Total Checked : $total"
echo "Healthy       : $healthy"
echo "Recovered     : $recovered"
echo "Failed        : $failed"
echo "==========================="
