#!/system/bin/sh

MODDIR=${0%/*}
ZRAM_DEV="/sys/block/zram0"
CONF_FILE="$MODDIR/zram_size.conf"

# Read the saved size or default to 3.5GB if file is missing
if [ -f "$CONF_FILE" ]; then
  DISKSIZE=$(cat "$CONF_FILE")
else
  DISKSIZE=3758096384
fi

# Set selected ZRAM size
echo "$DISKSIZE" > "$ZRAM_DEV/disksize"