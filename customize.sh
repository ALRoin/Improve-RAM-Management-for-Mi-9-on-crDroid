#!/sbin/sh

check_key() {
  local delay=${1:-10}
  rm -f $TMPDIR/events
  timeout $delay getevent -lqc 1 > $TMPDIR/events 2>/dev/null
  if grep -q "KEY_VOLUMEUP *DOWN" $TMPDIR/events; then
      return 0
  elif grep -q "KEY_VOLUMEDOWN *DOWN" $TMPDIR/events; then
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

ui_print "----------------------------------"
ui_print "      ZRAM SIZE CHANGER           "
ui_print "----------------------------------"
ui_print "Available sizes:"
i=1
while [ $i -le $MAX_ITEMS ]; do
  ui_print "  - $(get_name $i)"
  i=$((i + 1))
done
ui_print " I RECOMMEND CHOOSING 2.5 GB "
ui_print "----------------------------------"
ui_print " PRESS VOLUME DOWN TO BEGIN SETUP "
ui_print "----------------------------------"

# Wait for Vol Down to start
while true; do
  check_key 60
  [ $? -eq 1 ] && break
done

ui_print ""
ui_print "ENTERING SELECTION MODE"
ui_print "  Vol UP   = Confirm Selection"
ui_print "  Vol DOWN = Next Option"
ui_print ""

POS=1
ui_print "Current Choice: [ $(get_name $POS) ]"

while true; do
  check_key 300
  INPUT=$?
  
  if [ $INPUT -eq 0 ]; then
    # CONFIRM SELECTION
    SELECTED_NAME=$(get_name $POS)
    SELECTED_BYTES=$(get_bytes $POS)
    ui_print ""
    ui_print "**********************************"
    ui_print " SELECTED: $SELECTED_NAME"
    ui_print "**********************************"
    break
    
  elif [ $INPUT -eq 1 ]; then
    # NEXT OPTION
    POS=$((POS + 1))
    [ $POS -gt $MAX_ITEMS ] && POS=1
    ui_print "Current Choice: [ $(get_name $POS) ]"
  fi
done

# Save selection to config file for post-fs-data.sh to read on boot
echo "$SELECTED_BYTES" > "$MODPATH/zram_size.conf"

ui_print "- Done! ZRAM is now $SELECTED_NAME. Reboot the phone to apply the changes."