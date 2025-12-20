#!/bin/bash
# /* ---- 💫 Monitor Switching Script 💫 ---- */  #
# Automatically switch between laptop and external monitor based on lid state

# CONFIGURATION - Set your desired scale for external monitor here
EXTERNAL_SCALE="1.6" # Change this value (1.0 = 100%, 1.5 = 150%, 2.0 = 200%, etc.)
LAPTOP_SCALE="1.0"   # Scale for laptop screen

# Function to get lid state
get_lid_state() {
  local lid_state=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null | awk '{print $2}')
  if [ -z "$lid_state" ]; then
    lid_state=$(cat /proc/acpi/button/lid/LID/state 2>/dev/null | awk '{print $2}')
  fi
  if [ -z "$lid_state" ] && [ -e /sys/class/power_supply/AC/online ]; then
    lid_state="open"
  fi
  echo "$lid_state"
}

# Function to log messages
log_message() {
  local message="$1"
  echo "$(date): $message" >>/tmp/monitor-switch.log
}

# Get lid state
LID_STATE=$(get_lid_state)

# Check if external monitor is connected
EXTERNAL_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.name=="HDMI-A-1") | .name' 2>/dev/null)

log_message "Lid State: $LID_STATE, External Monitor: $EXTERNAL_MONITOR"

if [ "$LID_STATE" = "closed" ] && [ -n "$EXTERNAL_MONITOR" ]; then
  # Lid is closed and external monitor is connected
  # Disable laptop screen, enable external monitor as primary with custom scale
  hyprctl keyword monitor "eDP-1,disable"
  hyprctl keyword monitor "HDMI-A-1,2560x1440@144,auto,$EXTERNAL_SCALE"
  log_message "Switched to external monitor (lid closed) with scale $EXTERNAL_SCALE"

elif [ "$LID_STATE" = "open" ] && [ -n "$EXTERNAL_MONITOR" ]; then
  # Lid is open and external monitor is connected
  # Enable both displays, laptop as primary, external as secondary with custom scale
  hyprctl keyword monitor "eDP-1,preferred,auto,$LAPTOP_SCALE"
  hyprctl keyword monitor "HDMI-A-1,2560x1440@144,auto,$EXTERNAL_SCALE"
  log_message "Both monitors enabled (lid open) - laptop scale: $LAPTOP_SCALE, external scale: $EXTERNAL_SCALE"

elif [ "$LID_STATE" = "open" ] && [ -z "$EXTERNAL_MONITOR" ]; then
  # Lid is open, no external monitor
  # Just use laptop screen
  hyprctl keyword monitor "eDP-1,preferred,auto,$LAPTOP_SCALE"
  log_message "Only laptop screen (lid open, no external) with scale $LAPTOP_SCALE"

else
  # Lid is closed but no external monitor - keep laptop screen on (safety)
  hyprctl keyword monitor "eDP-1,preferred,auto,$LAPTOP_SCALE"
  log_message "Fallback to laptop screen with scale $LAPTOP_SCALE"
fi
