#!/bin/bash

# Get disk usage for /smssd partition
DISK_USAGE=$(df -h /smssd | awk 'NR==2 {print $4}')

# Output the free space with folder icon (nerd font)
echo -e "\uf07c ${DISK_USAGE}"
