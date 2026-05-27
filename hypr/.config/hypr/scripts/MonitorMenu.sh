#!/usr/bin/env bash
# /* ---- 💫 Monitor Mode Menu 💫 ---- */  #
# Rofi menu to view and switch monitor configuration.
# Shows the current active mode and allows switching.

if pidof rofi > /dev/null; then
  pkill rofi
  exit 0
fi

SCRIPTSDIR="$HOME/.config/hypr/scripts"

# --- Detect current state ---
MONITORS_JSON=$(hyprctl monitors -j 2>/dev/null)

EDP_ACTIVE=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.name=="eDP-1") | .name' 2>/dev/null)
HDMI_ACTIVE=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.name=="HDMI-A-1") | .name' 2>/dev/null)

if [ -n "$EDP_ACTIVE" ] && [ -n "$HDMI_ACTIVE" ]; then
  CURRENT="both"
elif [ -n "$HDMI_ACTIVE" ]; then
  CURRENT="external"
elif [ -n "$EDP_ACTIVE" ]; then
  CURRENT="laptop"
else
  CURRENT="unknown"
fi

# --- Build menu entries (prefix active with a checkmark) ---
mark() { [ "$CURRENT" = "$1" ] && echo "  " || echo "    "; }

OPT_EXTERNAL="$(mark external)External Only   (2560x1440 @ 60Hz)"
OPT_LAPTOP="$(mark laptop)Laptop Only"
OPT_BOTH="$(mark both)Both Monitors"
OPT_AUTO="    Auto-detect (lid state)"

MENU=$(printf "%s\n%s\n%s\n%s" "$OPT_EXTERNAL" "$OPT_LAPTOP" "$OPT_BOTH" "$OPT_AUTO")

# --- Show rofi menu ---
CHOSEN=$(echo "$MENU" | rofi -dmenu \
  -i \
  -p "Monitor Mode" \
  -mesg "Current: <b>$(echo $CURRENT | sed 's/external/External Only/;s/laptop/Laptop Only/;s/both/Both Monitors/;s/unknown/Unknown/')</b>" \
  -theme-str 'window { width: 520px; } listview { lines: 4; }')

[ -z "$CHOSEN" ] && exit 0

# --- Apply chosen mode ---
case "$CHOSEN" in
  *"External Only"*)
    hyprctl keyword monitor "eDP-1,disable"
    hyprctl keyword monitor "HDMI-A-1,2560x1440@60,auto,1.6"
    notify-send -t 2000 " Monitor" "External only"
    ;;
  *"Laptop Only"*)
    hyprctl keyword monitor "HDMI-A-1,disable"
    hyprctl keyword monitor "eDP-1,preferred,auto,1.6"
    notify-send -t 2000 " Monitor" "Laptop only"
    ;;
  *"Both Monitors"*)
    hyprctl keyword monitor "eDP-1,preferred,auto,1.6"
    hyprctl keyword monitor "HDMI-A-1,2560x1440@60,auto,1.6"
    notify-send -t 2000 " Monitor" "Both monitors enabled"
    ;;
  *"Auto-detect"*)
    "$SCRIPTSDIR/MonitorSwitch.sh"
    notify-send -t 2000 " Monitor" "Auto-detected lid state"
    ;;
esac
