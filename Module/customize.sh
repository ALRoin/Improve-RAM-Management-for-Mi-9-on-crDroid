# ====================================================
# 1. DETECT RAM & CALCULATE ZRAM SIZES
# ====================================================

TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')

if [ -z "$TOTAL_RAM_KB" ]; then
  abort "! Error: Could not detect RAM size."
fi

TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))

# Calculate KB for each percentage option
KB_30=$((TOTAL_RAM_KB * 30 / 100))
KB_40=$((TOTAL_RAM_KB * 40 / 100))
KB_50=$((TOTAL_RAM_KB * 50 / 100))
KB_70=$((TOTAL_RAM_KB * 70 / 100))

# Calculate MB for display
MB_30=$((KB_30 / 1024))
MB_40=$((KB_40 / 1024))
MB_50=$((KB_50 / 1024))
MB_70=$((KB_70 / 1024))

# Calculate Bytes for configuration
BYTES_30=$((KB_30 * 1024))
BYTES_40=$((KB_40 * 1024))
BYTES_50=$((KB_50 * 1024))
BYTES_70=$((KB_70 * 1024))


TMP_EVENT="$TMPDIR/events_temp"

check_key() {
  local delay=${1:-10}
  rm -f "$TMP_EVENT"
  timeout $delay getevent -lqc 1 > "$TMP_EVENT" 2>/dev/null
  if grep -q "KEY_VOLUMEUP *DOWN" "$TMP_EVENT"; then
      return 0
  elif grep -q "KEY_VOLUMEDOWN *DOWN" "$TMP_EVENT"; then
      return 1
  fi
  return 2
}

get_zram_name() {
  case $1 in
    1) echo "30% (${MB_30} MB)" ;;
    2) echo "40% (${MB_40} MB)" ;;
    3) echo "50% (${MB_50} MB)" ;;
    4) echo "70% (${MB_70} MB)" ;;
  esac
}

get_zram_bytes() {
  case $1 in
    1) echo "$BYTES_30" ;;
    2) echo "$BYTES_40" ;;
    3) echo "$BYTES_50" ;;
    4) echo "$BYTES_70" ;;
  esac
}

get_profile_name() {
  case $1 in
    1) echo "Balanced" ;;
    2) echo "Performance" ;;
  esac
}

# ====================================================
# STEP 1: ZRAM SIZE SELECTION
# ====================================================

MAX_ZRAM_ITEMS=4

ui_print "----------------------------------------"
ui_print "         SELECT ZRAM SIZE               "
ui_print "----------------------------------------"
ui_print " Detected Total RAM: ${TOTAL_RAM_MB} MB "
ui_print "----------------------------------------"
ui_print "Available sizes:"

i=1
while [ $i -le $MAX_ZRAM_ITEMS ]; do
  ui_print "  - Choice $i: $(get_zram_name $i)"
  i=$((i + 1))
done

ui_print "----------------------------------------"
ui_print " PRESS VOLUME DOWN TO BEGIN SETUP "
ui_print "----------------------------------------"

while true; do
  check_key 60
  [ $? -eq 1 ] && break
done

ui_print " "
ui_print "ENTERING SELECTION MODE"
ui_print "  Vol UP   = Confirm Selection"
ui_print "  Vol DOWN = Next Option"
ui_print " "

POS=1
ui_print "Current Choice: [ $(get_zram_name $POS) ]"

while true; do
  check_key 300
  INPUT=$?

  if [ $INPUT -eq 0 ]; then
    SELECTED_ZRAM_NAME=$(get_zram_name $POS)
    SELECTED_ZRAM_BYTES=$(get_zram_bytes $POS)
    ui_print " "
    ui_print "**********************************"
    ui_print " SELECTED ZRAM: $SELECTED_ZRAM_NAME"
    ui_print "**********************************"
    break

  elif [ $INPUT -eq 1 ]; then
    POS=$((POS + 1))
    [ $POS -gt $MAX_ZRAM_ITEMS ] && POS=1
    ui_print "Current Choice: [ $(get_zram_name $POS) ]"
  fi
done

echo "$SELECTED_ZRAM_BYTES" > "$MODPATH/zram_size.conf"

# ====================================================
# STEP 2: LMKD PROFILE SELECTION
# ====================================================

MAX_PROFILES=2

ui_print "----------------------------------------"
ui_print "        SELECT LMKD PROFILE              "
ui_print "----------------------------------------"
ui_print "Available profiles:"
ui_print "  - Choice 1: Balanced"
ui_print "  - Choice 2: Performance"
ui_print "----------------------------------------"
ui_print " PRESS VOLUME DOWN TO CONTINUE "
ui_print "----------------------------------------"

while true; do
  check_key 60
  [ $? -eq 1 ] && break
done

ui_print " "
ui_print "ENTERING SELECTION MODE"
ui_print "  Vol UP   = Confirm Selection"
ui_print "  Vol DOWN = Next Option"
ui_print " "

POS=1
ui_print "Current Choice: [ $(get_profile_name $POS) ]"

while true; do
  check_key 300
  INPUT=$?

  if [ $INPUT -eq 0 ]; then
    SELECTED_PROFILE=$(get_profile_name $POS)
    ui_print " "
    ui_print "**********************************"
    ui_print " SELECTED PROFILE: $SELECTED_PROFILE"
    ui_print "**********************************"
    break

  elif [ $INPUT -eq 1 ]; then
    POS=$((POS + 1))
    [ $POS -gt $MAX_PROFILES ] && POS=1
    ui_print "Current Choice: [ $(get_profile_name $POS) ]"
  fi
done

if [ $POS -eq 1 ]; then
  PSI_COMPLETE=800
  PSI_PARTIAL=300
else
  PSI_COMPLETE=700
  PSI_PARTIAL=200
fi

cat <<EOF > "$MODPATH/system.prop"
ro.lmk.psi_complete_stall_ms=$PSI_COMPLETE
ro.lmk.psi_partial_stall_ms=$PSI_PARTIAL
ro.lmk.low=1001
ro.lmk.medium=800
ro.lmk.critical=0
ro.lmk.lowmem_min_oom_score=701
ro.lmk.kill_heaviest_task=false
ro.lmk.use_psi=true
ro.lmk.use_minfree_levels=false
ro.lmk.swap_util_max=100
ro.lmk.thrashing_limit=100
ro.lmk.thrashing_limit_decay=50
ro.lmk.swap_free_low_percentage=10
EOF

rm -f "$TMP_EVENT"

ui_print "----------------------------------"
ui_print "- Done! Reboot your phone to apply the changes."