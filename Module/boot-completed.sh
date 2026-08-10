# 1. Fetch MemTotal (in kB) from /proc/meminfo
if [ -f /proc/meminfo ]; then
    MEM=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    MIN=$((MEM / 100))    # 1% of RAM
    EXTRA=$((MEM / 200))  # 0.5% of RAM
fi

sysctl -w vm.min_free_kbytes="$MIN" vm.extra_free_kbytes="$EXTRA"

sysctl -w vm.dirty_ratio=20
sysctl -w vm.dirty_background_ratio=10
sysctl -w vm.swappiness=60
sysctl -w vm.vfs_cache_pressure=100

# If the first argument passed to the script is NOT "skip_sleep", then sleep.
if [ "$1" != "skip_sleep" ]; then
    sleep 20
fi

sysctl -w vm.watermark_scale_factor=100