#!/bin/bash

# Get disk usage for root (/) partition
DISK_USAGE=$(df -h / | awk 'NR==2 {print $4}')

# Output the free space with home icon (nerd font)
echo -e "\uf015 ${DISK_USAGE}"
