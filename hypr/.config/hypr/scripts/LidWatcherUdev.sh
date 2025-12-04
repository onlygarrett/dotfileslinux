#!/bin/bash
# /* ---- 💫 Lid Event Watcher (udev method) 💫 ---- */  #
# More reliable lid detection using udev monitoring

# Monitor for drm and lid events
stdbuf -oL udevadm monitor --udev --subsystem-match=drm --subsystem-match=input | while read -r line; do
  if echo "$line" | grep -qi "lid\|drm"; then
    echo "$(date): Event detected: $line" >>/tmp/monitor-switch.log
    sleep 0.5
    ~/. config/hypr/scripts/MonitorSwitch.sh
  fi
done
