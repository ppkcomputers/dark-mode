#!/usr/bin/env bash
# -------------------------------------------------------------------------
# dark-mode.sh
#   Makes Thunar (and other GTK apps) use a dark theme on Arch + Hyprland.
#   • Installs the correct dark GTK theme package if needed.
#   • Writes GTK‑3/GTK‑4 config files.
#   • Exports GTK_THEME=Adwaita-dark for the current session.
#   • Persists the export in ~/.profile for future logins.
#   • Restarts (or launches) Thunar.
#   • Verifies that Thunar sees the dark theme and reports success.
# -------------------------------------------------------------------------

# --------------------------- Helper functions ---------------------------

prompt_install() {
    echo -e "\n⚙️  The dark theme package \"adw-gtk-theme\" is not installed."
    read -rp "Do you want me to install it now? (y/N) " ans
    [[ $ans =~ ^[Yy]$ ]] && return 0 || return 1
}

install_dark_theme() {
    if command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm adw-gtk-theme \
            || { echo "❌ Installation failed."; exit 1; }
    else
        echo "⚠️  No supported package manager found. Install a dark GTK theme manually."
        exit 1
    fi
}

# ------------------------------ Main script ------------------------------

# Ensure the Scripts directory exists
SCRIPT_DIR="/home/ppk/.config/Scripts"
mkdir -p "$SCRIPT_DIR"

# 1️⃣ Verify a dark theme is present, install if not
if ! ls /usr/share/themes/*dark* 2>/dev/null | grep -qi adwaita; then
    if prompt_install; then
        install_dark_theme
    else
        echo "⚠️  Continuing without installing a dark theme. You may need to install one manually."
    fi
fi

# 2️⃣ Write global GTK‑3 config
GTK3_CONF="/home/ppk/.config/gtk-3.0/settings.ini"
mkdir -p "$(dirname "$GTK3_CONF")"
cat > "$GTK3_CONF" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
EOF

# 3️⃣ Write global GTK‑4 config (harmless even if you don’t use GTK‑4 apps)
GTK4_CONF="/home/ppk/.config/gtk-4.0/settings.ini"
mkdir -p "$(dirname "$GTK4_CONF")"
cat > "$GTK4_CONF" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
EOF

# 4️⃣ Export the theme for the current shell
export GTK_THEME=Adwaita-dark

# 5️⃣ Persist the export for future logins
PROFILE="/home/ppk/.profile"
if ! grep -Fxq 'export GTK_THEME=Adwaita-dark' "$PROFILE" 2>/dev/null; then
    echo 'export GTK_THEME=Adwaita-dark' >> "$PROFILE"
fi

# 6️⃣ (Re)start Thunar
if pgrep -x thunar >/dev/null 2>&1; then
    echo "🔁  Restarting Thunar..."
    pkill -SIGTERM thunar
    sleep 0.5
fi
thunar &   # launch fresh instance that inherits GTK_THEME

# Give Thunar a moment to start and inherit the environment
sleep 1

# 7️⃣ Test: does the newly‑started Thunar see the dark theme?
#    We grab the PID of the most recent Thunar process and read its environment.
THUNAR_PID=$(pgrep -n -x thunar)   # newest Thunar instance
if [[ -z "$THUNAR_PID" ]]; then
    echo "❌ Could not locate a running Thunar process."
    exit 1
fi

# Inspect the environment of that process (requires /proc access, which we have)
THUNAR_THEME=$(tr '\0' '\n' < /proc/"$THUNAR_PID"/environ | grep '^GTK_THEME=' || true)

if [[ "$THUNAR_THEME" == "GTK_THEME=Adwaita-dark" ]]; then
    echo -e "\n✅ Dark theme applied successfully! Thunar is now using Adwaita‑dark."
else
    echo -e "\n⚠️  Thunar did NOT inherit the dark theme."
    echo "    You may need to log out/in or restart Hyprland for the change to propagate."
fi

# -------------------------------------------------------------------------
# End of script
# -------------------------------------------------------------------------
