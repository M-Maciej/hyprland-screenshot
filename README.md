# hyprland-screenshot

📸 A fast, flexible screenshot tool for Hyprland using grim, slurp, wl-copy, and hyprctl.
https://aur.archlinux.org/packages/hyprland-screenshot
## Features

- Area selectable, window, monitor, or full-all-monitor screenshots
- Notifications with preview and actions
- Clipboard copy
- Shutter sound
- Quiet mode and filename override

## Installation

### From source

```bash
sudo pacman -S \
  grim \
  slurp \
  wl-clipboard \
  wl-copy \
  hyprland \
  jq \
  libnotify \
canberra-gtk-play
git clone https://github.com/yourusername/hyprland-screenshot.git
cd hyprland-screenshot
makepkg -si
```
