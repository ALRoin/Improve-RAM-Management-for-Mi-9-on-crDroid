# Improve-RAM-Management-for-Mi-9-on-crDroid

## What This Module Does

### Modify Virtual Memory settings

```sh
echo 20 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 81920 > /proc/sys/vm/min_free_kbytes
echo 60 > /proc/sys/vm/swappiness
echo 100 > /proc/sys/vm/vfs_cache_pressure
echo 150 > /proc/sys/vm/watermark_scale_factor
```

### Customize How Low Memory Killer Daemon (LMKD) Works

```properties
ro.lmk.psi_complete_stall_ms=900
ro.lmk.psi_partial_stall_ms=500
ro.lmk.kill_heaviest_task=false
ro.lmk.use_psi=true
ro.lmk.use_minfree_levels=false
ro.lmk.swap_util_max=100
ro.lmk.thrashing_limit=100
ro.lmk.thrashing_limit_decay=50
ro.lmk.swap_free_low_percentage=10
```

### Change ZRAM size
