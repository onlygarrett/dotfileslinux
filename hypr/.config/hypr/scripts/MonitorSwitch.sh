#!/bin/bash
# /* ---- 💫 Monitor Switching Script 💫 ---- */  #
# Automatically switch between laptop and external monitor based on lid state

# CONFIGURATION - Set your desired scale for external monitor here
EXTERNAL_SCALE="1.6" # Change this value (1.0 = 100%, 1.5 = 150%, 2.0 = 200%, etc.)
LAPTOP_SCALE="1.0"   # Scale for laptop screen

# Get lid state
LID_STATE=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null | awk '{print $2}')

# Alternative method if the above doesn't work
if [ -z "$LID_STATE" ]; then
  LID_STATE=$(cat /proc/acpi/button/lid/LID/state 2>/dev/null | awk '{print $2}')
fi

# Another fallback method using systemd
if [ -z "$LID_STATE" ]; then
  if [ -e /sys/class/power_supply/AC/online ]; then
    LID_STATE="open"
  fi
fi

# Check if external monitor is connected
EXTERNAL_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.name=="HDMI-A-1") | .name')

# Log for debugging
echo "$(date): Lid State: $LID_STATE, External Monitor: $EXTERNAL_MONITOR" >>/tmp/monitor-switch.log

if [ "$LID_STATE" = "closed" ] && [ -n "$EXTERNAL_MONITOR" ]; then
  # Lid is closed and external monitor is connected
  # Disable laptop screen, enable external monitor as primary with custom scale
  hyprctl keyword monitor "eDP-1,disable"
  hyprctl keyword monitor "HDMI-A-1,2560x1440@144,auto,$EXTERNAL_SCALE"
  echo "$(date): Switched to external monitor (lid closed) with scale $EXTERNAL_SCALE" log >>/tmp/monitor-switch.

elif [ "$LID_STATE" = "open" ] && [ -n "$EXTERNAL_MONITOR" ]; then
  # Lid is open and external monitor is connected
  # Enable both displays, laptop as primary, external as secondary with custom scale
  hyprctl keyword monitor "eDP-1,preferred,auto,$LAPTOP_SCALE"
  hyprctl keyword monitor "HDMI-A-1,2560x1440@144,auto,$EXTERNAL_SCALE"
  echo "$(date): Both monitors enabled (lid open) - laptop scale: $LAPTOP_SCALE, external scale: $EXTERNAL_SCALE" >>/tmp/monitor-switch.log

elif [ "$LID_STATE" = "open" ] && [ -z "$EXTERNAL_MONITOR" ]; then
  # Lid is open, no external monitor
  # Just use laptop screen
  hyprctl keyword monitor "eDP-1,preferred,auto,$LAPTOP_SCALE"
  echo "$(date): Only laptop screen (lid open, no external) with scale $LAPTOP_SCALE" log >>/tmp/monitor-switch.

else
  # Lid is closed but no external monitor - keep laptop screen on (safety)
  hyprctl keyword monitor "eDP-1,preferred,auto,$LAPTOP_SCALE"
  echo "$(date): Fallback to laptop screen with scale $LAPTOP_SCALE" log >>/tmp/monitor-switch.
fi
