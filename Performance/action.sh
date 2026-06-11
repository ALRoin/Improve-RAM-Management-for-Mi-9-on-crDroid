#!/system/bin/sh

MODDIR="${0%/*}"
CONF_FILE="$MODDIR/zram_size.conf"

# 1. Detect Total RAM in KB and convert to MB
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')

if [ -z "$TOTAL_RAM_KB" ]; then
  echo "! Error: Could not detect RAM size."
  exit 1
fi

TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))

# 2. Calculate KB for each percentage
KB_30=$((TOTAL_RAM_KB * 30 / 100))
KB_40=$((TOTAL_RAM_KB * 40 / 100))
KB_50=$((TOTAL_RAM_KB * 50 / 100))
KB_70=$((TOTAL_RAM_KB * 70 / 100))

# 3. Calculate MB
MB_30=$((KB_30 / 1024))
MB_40=$((KB_40 / 1024))
MB_50=$((KB_50 / 1024))
MB_70=$((KB_70 / 1024))

# 4. Calculate final Bytes for the config file
BYTES_30=$((KB_30 * 1024))
BYTES_40=$((KB_40 * 1024))
BYTES_50=$((KB_50 * 1024))
BYTES_70=$((KB_70 * 1024))

check_key() {
  local delay=${1:-10}
  rm -f /dev/events_temp
  timeout $delay getevent -lqc 1 > /dev/events_temp 2>/dev/null
  if grep -q "KEY_VOLUMEUP *DOWN" /dev/events_temp; then
      return 0
  elif grep -q "KEY_VOLUMEDOWN *DOWN" /dev/events_temp; then
      return 1
  fi
  return 2
}

get_name() {
  case $1 in
    1) echo "30% (${MB_30} MB)";;
    2) echo "40% (${MB_40} MB)";;
    3) echo "50% (${MB_50} MB)";;
    4) echo "70% (${MB_70} MB)";;
  esac
}

get_bytes() {
  case $1 in
    1) echo "$BYTES_30";;
    2) echo "$BYTES_40";;
    3) echo "$BYTES_50";;
    4) echo "$BYTES_70";;
  esac
}

MAX_ITEMS=4

echo "----------------------------------------"
echo "         ZRAM SIZE CHANGER              "
echo "----------------------------------------"
echo " Detected Total RAM: ${TOTAL_RAM_MB} MB "
echo "----------------------------------------"
echo "Available sizes:"
i=1
while [ $i -le $MAX_ITEMS ]; do
  echo "  - Choice $i: $(get_name $i)"
  i=$((i + 1))
done
echo "----------------------------------"
echo " PRESS VOLUME DOWN TO BEGIN SETUP "
echo "----------------------------------"

# Wait for Vol Down to start
while true; do
  check_key 60
  [ $? -eq 1 ] && break
done

echo ""
echo "ENTERING SELECTION MODE"
echo "  Vol UP   = Confirm Selection"
echo "  Vol DOWN = Next Option"
echo ""

POS=1
echo "Current Choice: [ $(get_name $POS) ]"

while true; do
  check_key 300
  INPUT=$?

  if [ $INPUT -eq 0 ]; then
    # CONFIRM SELECTION
    SELECTED_NAME=$(get_name $POS)
    SELECTED_BYTES=$(get_bytes $POS)
    echo ""
    echo "**********************************"
    echo " SELECTED: $SELECTED_NAME"
    echo "**********************************"
    break

  elif [ $INPUT -eq 1 ]; then
    # NEXT OPTION
    POS=$((POS + 1))
    [ $POS -gt $MAX_ITEMS ] && POS=1
    echo "Current Choice: [ $(get_name $POS) ]"
  fi
done

# Save selection to config file
echo "$SELECTED_BYTES" > "$CONF_FILE"

echo "- Done! ZRAM is now set to $SELECTED_NAME. Reboot the phone to apply the changes."
rm -f /dev/events_temp
