#!/system/bin/sh

echo 20 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 81920 > /proc/sys/vm/min_free_kbytes
echo 60 > /proc/sys/vm/swappiness
echo 100 > /proc/sys/vm/vfs_cache_pressure

# If the first argument passed to the script is NOT "skip_sleep", then sleep.
if [ "$1" != "skip_sleep" ]; then
    sleep 20
fi

echo 150 > /proc/sys/vm/watermark_scale_factor