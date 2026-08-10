MODDIR=${0%/*}
ZRAM_DEV="/sys/block/zram0"
CONF_FILE="$MODDIR/zram_size.conf"

echo zstd > /sys/block/zram0/comp_algorithm
# Read the saved size or default to 2.7 GB if file is missing
if [ -f "$CONF_FILE" ]; then
  DISKSIZE=$(cat "$CONF_FILE")
else
  DISKSIZE=2856726528  
fi

# Set selected ZRAM size
echo "$DISKSIZE" > "$ZRAM_DEV/disksize"