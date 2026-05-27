#!/bin/bash
# /* ---- 💫 Accordion Layout Script 💫 ---- */  #
# Mimics AeroSpace accordion layout: toggle maximize mode per workspace
# and cycle through windows while keeping the focused one maximized.
#
# Usage:
#   Accordion.sh on       - enable accordion mode for current workspace
#   Accordion.sh off      - disable accordion mode for current workspace
#   Accordion.sh next     - focus next window (cycles, re-maximizes in accordion mode)
#   Accordion.sh prev     - focus prev window (cycles, re-maximizes in accordion mode)

STATE_DIR="/tmp/hypr-accordion"
mkdir -p "$STATE_DIR"

get_workspace() {
  hyprctl activeworkspace -j | jq -r '.id'
}

is_accordion() {
  local ws="$1"
  [ -f "$STATE_DIR/ws_${ws}" ]
}

set_accordion() {
  local ws="$1"
  touch "$STATE_DIR/ws_${ws}"
}

unset_accordion() {
  local ws="$1"
  rm -f "$STATE_DIR/ws_${ws}"
}

get_focused_fullscreen_state() {
  hyprctl activewindow -j | jq -r '.fullscreen'
}

ACTION="${1:-on}"
WORKSPACE=$(get_workspace)

case "$ACTION" in
  on)
    set_accordion "$WORKSPACE"
    # Always ensure focused window is maximized when turning on (or re-pressing)
    FSSTATE=$(get_focused_fullscreen_state)
    if [ "$FSSTATE" = "0" ]; then
      hyprctl dispatch fullscreen 1
    fi
    notify-send -t 2000 " Accordion On" "Workspace $WORKSPACE: accordion layout"
    ;;

  off)
    # Un-maximize the focused window if maximized
    FSSTATE=$(get_focused_fullscreen_state)
    if [ "$FSSTATE" != "0" ]; then
      hyprctl dispatch fullscreen 1
    fi
    unset_accordion "$WORKSPACE"
    notify-send -t 2000 " Accordion Off" "Workspace $WORKSPACE: tiled layout"
    ;;

  next|prev)
    if is_accordion "$WORKSPACE"; then
      # Un-maximize current window if it is maximized
      FSSTATE=$(get_focused_fullscreen_state)
      if [ "$FSSTATE" != "0" ]; then
        hyprctl dispatch fullscreen 1
      fi
      # Cycle focus
      if [ "$ACTION" = "next" ]; then
        hyprctl dispatch cyclenext
      else
        hyprctl dispatch cyclenext prev
      fi
      # Maximize the newly focused window
      hyprctl dispatch fullscreen 1
    else
      # Not in accordion mode — just cycle focus normally
      if [ "$ACTION" = "next" ]; then
        hyprctl dispatch cyclenext
      else
        hyprctl dispatch cyclenext prev
      fi
    fi
    ;;
esac
