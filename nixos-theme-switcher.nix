#!/usr/bin/env bash
# This script switches themes for your NixOS setup, now with icons!

set -euo pipefail

# The location of your NixOS configuration flake.
FLAKE_DIR="/etc/nixos"

# Directory containing the theme folders.
THEME_DIR="$FLAKE_DIR/theming"

# Path to the file that stores the current theme name.
CURRENT_THEME_FILE="/home/zombie/.config/current-theme"

# --- Generate entries for wofi with icons ---
# Each line will be in the format: <img>/path/to/icon.png</img>\tThemeName
wofi_entries=""
for theme_dir in "$THEME_DIR"/*/; do
    # Ensure it's a directory before processing
    if [ -d "$theme_dir" ]; then
        theme_name=$(basename "$theme_dir")
        icon_path="${theme_dir}icon.png"

        # Check if the icon file actually exists
        if [ -f "$icon_path" ]; then
            # Use Pango markup to add the image and the theme name
            wofi_entries+=$(printf "<img>%s</img>\t%s\n" "$icon_path" "$theme_name")
        else
            # Provide a fallback emoji if no icon is found
            wofi_entries+=$(printf "🎨\t%s\n" "$theme_name")
        fi
    fi
done

# Use wofi to present the themes. Wofi automatically parses the pango markup.
chosen_line=$(echo -e "$wofi_entries" | wofi --dmenu --prompt "Select Theme:")

# Exit if no theme was chosen (e.g., user pressed Esc).
if [[ -z "$chosen_line" ]]; then
    exit 0
fi

# The output is "<img>...</img>\tThemeName", so we extract the part after the tab.
chosen=$(echo "$chosen_line" | cut -f2)

# Write the chosen theme to the file, which the flake will read on the next build.
echo "$chosen" > "$CURRENT_THEME_FILE"

# Notify the user and apply the new configuration.
notify-send "🎨 Theme Changed" "Applying the '$chosen' theme..."
sudo nixos-rebuild switch --flake "$FLAKE_DIR#laptop"
