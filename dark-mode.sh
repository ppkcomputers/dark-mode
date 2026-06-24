#!/usr/bin/env bash
# -------------------------------------------------------------------------
# dark-mode.sh
#   Makes Thunar (and other GTK apps) use a dark theme on Arch + Hyprland.
# -------------------------------------------------------------------------

# Use $HOME for portability
SCRIPT_DIR="$HOME/.config/Scripts"
mkdir -p "$SCRIPT_DIR"

# 1. Verify a dark theme is present, install if not
if ! ls /usr/share/themes/*dark* 2>/dev/null | grep -qi adwaita; then
    echo -e "\n⚙️  The dark theme package \"adw-gtk-theme\" is not installed."
    read -rp "Do you want me to install it now? (y/N) " ans
    if [[ $ans =~ ^[Yy]$ ]]; then
        if command -v pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm adw-gtk-theme || { echo "❌ Installation failed."; exit 1; }
        else
            echo "⚠️  No supported package manager found."
            exit 1
        fi
    fi
fi

# 2. Write global GTK-3 config
GTK3_CONF="$HOME/.config/gtk-3.0/settings.ini"
mkdir -p "$(dirname "$GTK3_CONF")"
cat > "$GTK3_CONF" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
EOF

# 3. Write global GTK-4 config
GTK4_CONF="$HOME/.config/gtk-4.0/settings.ini"
mkdir -p "$(dirname "$GTK4_CONF")"
cat > "$GTK4_CONF" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
EOF

# 4. Export the theme for the current shell
export GTK_THEME=Adwaita-dark

# 5. Persist the export for future logins
PROFILE="$HOME/.profile"
if ! grep -Fxq 'export GTK_THEME=Adwaita-dark' "$PROFILE" 2>/dev/null; then
    echo 'export GTK_THEME=Adwaita-dark' >> "$PROFILE"
fi

# 6. (Re)start Thunar
if pgrep -x thunar >/dev/null 2>&1; then
    echo "🔁  Restarting Thunar..."
    pkill -SIGTERM thunar
    sleep 0.5
fi
thunar &

# 7. Verification
sleep 1
THUNAR_PID=$(pgrep -n -x thunar)
if [[ -n "$THUNAR_PID" ]]; then
    THUNAR_THEME=$(tr '\0' '\n' < /proc/"$THUNAR_PID"/environ | grep '^GTK_THEME=' || true)
    if [[ "$THUNAR_THEME" == "GTK_THEME=Adwaita-dark" ]]; then
        echo -e "\n✅ Dark theme applied successfully!"
    else
        echo -e "\n⚠️  Thunar did NOT inherit the dark theme."
    fi
fi
