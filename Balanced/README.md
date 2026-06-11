1. If you experience lag while playing heavy games,
try lowering these values in system.prop:
ro.lmk.psi_complete_stall_ms=xxx
ro.lmk.psi_partial_stall_ms=xxx

To prevent apps from reloading too often:
`ro.lmk.psi_complete_stall_ms` is better not set lower than 700.
And `ro.lmk.psi_partial_stall_ms` is better not set lower than 200.

Example 1:
ro.lmk.psi_complete_stall_ms=750
ro.lmk.psi_partial_stall_ms=250

Example 2:
ro.lmk.psi_complete_stall_ms=700
ro.lmk.psi_partial_stall_ms=200

2. You can edit the ZRAM size using the action button or through the WebUI.
I recommend keeping the ZRAM size at 40% of your RAM. I think it provides better performance.
If you want it higher or lower, that's fine too, you can adjust it based on your needs.
