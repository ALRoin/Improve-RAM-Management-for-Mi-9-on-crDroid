# A KernelSU module to Improve RAM Management for Mi 9 on crDroid
> ⚠️ **IMPORTANT:** This module is designed specifically for the **Xiaomi Mi 9 running crDroid**. Don't expect the same functionality, performance, or results on other devices or ROMs.


## What This Module Does

### ⚖️BALANCED :
Designed for better multitasking performance.
#### Modify Virtual Memory settings

```sh
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
```

#### Customize How Low Memory Killer Daemon (LMKD) Works

```properties
ro.lmk.psi_complete_stall_ms=800
ro.lmk.psi_partial_stall_ms=300
ro.lmk.kill_heaviest_task=false
ro.lmk.use_psi=true
ro.lmk.use_minfree_levels=false
ro.lmk.swap_util_max=100
ro.lmk.thrashing_limit=100
ro.lmk.thrashing_limit_decay=50
ro.lmk.swap_free_low_percentage=10
```

#### Change ZRAM size
The default size is 40% of your RAM.

---

### 🚀PERFORMANCE :
More aggressive at freeing RAM.
#### Modify Virtual Memory settings

```sh
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
```

#### Customize How Low Memory Killer Daemon (LMKD) Works

```properties
ro.lmk.psi_complete_stall_ms=700
ro.lmk.psi_partial_stall_ms=200
ro.lmk.kill_heaviest_task=false
ro.lmk.use_psi=true
ro.lmk.use_minfree_levels=false
ro.lmk.swap_util_max=100
ro.lmk.thrashing_limit=100
ro.lmk.thrashing_limit_decay=50
ro.lmk.swap_free_low_percentage=10
```

#### Change ZRAM size
The default size is 30% of your RAM.
