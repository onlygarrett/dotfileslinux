#!/bin/bash
# /* ---- 💫 Accordion Layout Watcher 💫 ---- */  #
# Listens for Hyprland window events and auto-maximizes new windows
# when the active workspace is in accordion mode.
# Run once at startup via Startup_Apps.conf.

STATE_DIR="/tmp/hypr-accordion"
mkdir -p "$STATE_DIR"

SOCKET="/run/user/$(id -u)/hypr/$(ls /run/user/$(id -u)/hypr/)/.socket2.sock"

is_accordion() {
  local ws="$1"
  [ -f "$STATE_DIR/ws_${ws}" ]
}

handle_event() {
  local event="$1"

  # openwindow>>address,workspace,class,title
  if [[ "$event" == openwindow* ]]; then
    local ws
    ws=$(hyprctl activeworkspace -j | jq -r '.id')
    if is_accordion "$ws"; then
      # Small delay to let the window finish opening before maximizing
      sleep 0.2
      hyprctl dispatch fullscreen 1
    fi
  fi
}

socat -U - "UNIX-CONNECT:$SOCKET" | while read -r line; do
  handle_event "$line"
done
