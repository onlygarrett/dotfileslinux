#!/bin/bash
# /* ---- 💫 Lid Event Watcher 💫 ---- */  #
# Monitors lid events and triggers monitor switching

# Monitor acpi events for lid
acpi_listen | while read -r event; do
  case "$event" in
  *"button/lid"*)
    echo "$(date): Lid event detected: $event" >>/tmp/monitor-switch.log
    # Small delay to allow hardware to settle
    sleep 1
    # Run the monitor switch script
    ~/.config/hypr/scripts/MonitorSwitch. sh
    ;;
  esac
done
