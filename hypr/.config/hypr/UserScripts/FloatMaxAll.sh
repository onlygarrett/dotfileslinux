#!/bin/bash

# Get current workspace ID
workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Get screen resolution for full-size positioning
monitor_width=$(hyprctl activeworkspace -j | jq -r '.monitor' | xargs -I{} hyprctl monitors -j | jq -r ".[] | select(.name == \"{}\") | .width")
monitor_height=$(hyprctl activeworkspace -j | jq -r '.monitor' | xargs -I{} hyprctl monitors -j | jq -r ".[] | select(.name == \"{}\") | .height")

# Get all window addresses in the current workspace
window_addresses=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $workspace) | .address")

for addr in $window_addresses; do
  # Set window to floating
  hyprctl dispatch setfloating address:$addr

  # Resize to full monitor size
  hyprctl dispatch resizewindowpixel exact ${monitor_width} ${monitor_height},address:$addr

  # Move to top-left corner (0,0)
  hyprctl dispatch movewindowpixel exact 0 0,address:$addr
done
