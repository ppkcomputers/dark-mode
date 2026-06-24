# Arch dark-mode
Turns your arch into dark mode like thunar etc.  

Run from your terminal
curl -s https://raw.githubusercontent.com/ppkcomputers/dark-mode/refs/heads/main/dark-mode.sh | bash

Here is a breakdown of what the script does, step by step:

1. Installation Check
It checks if the adw-gtk-theme package is installed. If it is missing, the script interacts with you via the terminal to ask if it should install it using pacman.

2. GTK Configuration Files
It automatically creates (or overwrites) the necessary configuration files for both GTK-3 and GTK-4 in your user directory (~/.config/gtk-3.0/settings.ini and ~/.config/gtk-4.0/settings.ini).

It sets the property gtk-application-prefer-dark-theme=1 in both files, which tells compatible applications to use their dark variant by default.

3. Environment Persistence
It immediately exports the environment variable GTK_THEME=Adwaita-dark for your current session.

It appends this export command to your ~/.profile file. This ensures that every time you log in, your system environment is correctly configured to force the Adwaita-dark theme.

4. Application Refresh
It checks if Thunar is currently running. If it is, it kills the process (pkill) and launches a fresh instance in the background (thunar &) so the new settings take effect immediately.

5. Verification
Finally, the script inspects the environment variables of the newly launched Thunar process by reading its /proc/[PID]/environ file.

It confirms whether the GTK_THEME variable was correctly applied and prints a success message or a warning if the theme change did not register as expected.
