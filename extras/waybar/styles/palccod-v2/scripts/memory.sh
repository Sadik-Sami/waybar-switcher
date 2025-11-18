#!/bin/bash

# Get memory info from /proc/meminfo
TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

# Calculate used memory in GB
USED=$((($TOTAL - $AVAILABLE) / 1024 / 1024))

# Calculate percentage used
PERCENT=$(awk "BEGIN {printf \"%.0f\", (($TOTAL - $AVAILABLE) / $TOTAL) * 100}")

# Output with memory icon (nerd font)
echo -e "\uf538 ${USED}GB (${PERCENT}%)"
