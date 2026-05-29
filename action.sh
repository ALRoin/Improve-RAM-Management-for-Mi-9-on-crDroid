#!/system/bin/sh

# Set paths for action.sh
MODDIR="${0%/*}"
CONF_FILE="$MODDIR/zram_size.conf"

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
    1) echo "2.5 GB";;
    2) echo "3 GB";;
    3) echo "3.5 GB";;
    4) echo "4 GB";;
    5) echo "4.5 GB";;
    6) echo "5 GB";;
    7) echo "5.5 GB";;
    8) echo "6 GB";;
  esac
}

get_bytes() {
  case $1 in
    1) echo "2684354560";;
    2) echo "3221225472";;
    3) echo "3758096384";;
    4) echo "4294967296";;
    5) echo "4831838208";;
    6) echo "5368709120";;
    7) echo "5905580032";;
    8) echo "6442450944";;
  esac
}

MAX_ITEMS=8

echo "----------------------------------"
echo "      ZRAM SIZE CHANGER           "
echo "----------------------------------"
echo "Available sizes:"
i=1
while [ $i -le $MAX_ITEMS ]; do
  echo "  - $(get_name $i)"
  i=$((i + 1))
done
echo " I RECOMMEND CHOOSING 2.5 GB "
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

echo "- Done! ZRAM is now $SELECTED_NAME. Reboot the phone to apply the changes."
rm -f /dev/events_temp
