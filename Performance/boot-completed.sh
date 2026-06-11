#!/system/bin/sh

# 1. Fetch MemTotal (in kB) from /proc/meminfo
if [ -f /proc/meminfo ]; then
    MEM_TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    MIN_FREE=$((MEM_TOTAL / 100))
    echo "$MIN_FREE" > /proc/sys/vm/min_free_kbytes
else
    # Fallback to this value if /proc/meminfo fails
    echo 55810 > /proc/sys/vm/min_free_kbytes
fi

echo 20 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 60 > /proc/sys/vm/swappiness
echo 100 > /proc/sys/vm/vfs_cache_pressure

# If the first argument passed to the script is NOT "skip_sleep", then sleep.
if [ "$1" != "skip_sleep" ]; then
    sleep 20
fi

echo 100 > /proc/sys/vm/watermark_scale_factor