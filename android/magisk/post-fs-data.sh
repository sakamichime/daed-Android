#!/system/bin/sh

# Magisk post-fs-data: prepare daed config directory

# Create config directory
mkdir -p /data/adb/daed

# Set directory permissions
chmod 0755 /data/adb/daed
