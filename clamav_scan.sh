#!/bin/bash

LOG_FILE="/var/log/clamav/clamav-$(date +'%Y-%m-%d').log"
SCAN_DIR="/"  # Adjust the directory you want to scan

echo "Starting ClamAV scan at $(date)" >> "$LOG_FILE"

clamscan -r "$SCAN_DIR" >> "$LOG_FILE"

echo "ClamAV scan completed at $(date)" >> "$LOG_FILE"

