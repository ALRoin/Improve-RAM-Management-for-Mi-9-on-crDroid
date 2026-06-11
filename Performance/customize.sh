#!/sbin/sh

ui_print "-----------------------------------------"
ui_print "CHANGING THE ZRAM SIZE TO 30% OF YOUR RAM"
ui_print "-----------------------------------------"

# 1. Detect total RAM in kilobytes from /proc/meminfo
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')

# Fallback check in case the read fails
if [ -z "$TOTAL_RAM_KB" ]; then
  ui_print "! Error: Could not detect RAM size."
  exit 1
fi

# 2. Calculate 30% of Total RAM
ZRAM_KB=$((TOTAL_RAM_KB * 30 / 100))

# 3. Convert to bytes
ZRAM_BYTES=$((ZRAM_KB * 1024))

TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
ZRAM_MB=$((ZRAM_KB / 1024))

ui_print "- Detected Total RAM     : ${TOTAL_RAM_MB} MB"
ui_print "- ZRAM Size (30% of RAM) : ${ZRAM_MB} MB"
ui_print "----------------------------------"

echo "$ZRAM_BYTES" > "$MODPATH/zram_size.conf"

ui_print "- Done! Reboot your phone to apply the changes."