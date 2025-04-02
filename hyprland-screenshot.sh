#!/bin/bash

VERSION="1.0.0"
DEFAULT_MODE="area"
DEFAULT_PREFIX="Screenshot"
DEFAULT_LOCATION="$HOME/Screenshots"
LOGFILE="$HOME/.cache/hyprland-screenshot.log"

mkdir -p "$(dirname "$LOGFILE")"
echo -e "\n=== $(date '+%F %T.%3N') - Starting screenshot ===" >> "$LOGFILE"

# === Get PID ===
SCRIPT_IDENTIFIER="hyprland-screenshot"
current_pid=$$
echo "Current PID: $current_pid" >> "$LOGFILE"
for pid in $(pgrep -f "$SCRIPT_IDENTIFIER"); do
  if [ "$pid" != "$current_pid" ]; then
    echo "Killing previous instance: $pid" >> "$LOGFILE"
    kill "$pid"
  fi
done

# === Default config ===
MODE="$DEFAULT_MODE"
LOCATION="$DEFAULT_LOCATION"
PREFIX="$DEFAULT_PREFIX"
FILENAME_OVERRIDE=""
SOUND_ENABLED="true"
QUIET="false"

# === Dependency check ===
REQUIRED_COMMANDS=(grim slurp wl-copy hyprctl jq notify-send canberra-gtk-play)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "⚠️  Required command '$cmd' not found. Please install it before running this script."
  fi
done

# === Help ===
print_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -m, --mode       MODE        Screenshot mode: area, window, monitor, all"
  echo "  -l, --location   PATH        Output directory"
  echo "  -p, --prefix     PREFIX      Prefix before timestamp (default: Screenshot)"
  echo "  -n, --name       NAME        Full custom filename (no timestamp)"
  echo "  -s, --sound      on|off      Enable or disable shutter sound (default: on)"
  echo "  -q, --quiet                  Suppress notifications"
  echo "  -v, --version                Print version and exit"
  echo "  -h, --help                   Show this help message and exit"
  exit 0
}

# === Parse CLI args ===
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -m|--mode) MODE="$2"; shift ;;
    -l|--location) LOCATION="$2"; shift ;;
    -p|--prefix) PREFIX="$2"; shift ;;
    -n|--name) FILENAME_OVERRIDE="$2"; shift ;;
    -s|--sound)
      case "$2" in
        on|enable) SOUND_ENABLED="true" ;;
        off|disable) SOUND_ENABLED="false" ;;
        *) echo "❌ Invalid sound option: $2" && print_help ;;
      esac
      shift ;;
    -q|--quiet) QUIET="true" ;;
    -v|--version) echo "gs-screenshot v$VERSION"; exit 0 ;;
    -h|--help) print_help ;;
    *) echo "Unknown option: $1"; print_help ;;
  esac
  shift
done

echo "Sound enabled: $SOUND_ENABLED" >> "$LOGFILE"

# === Determine filename ===
mkdir -p "$LOCATION"
if [[ -n "$FILENAME_OVERRIDE" ]]; then
  FILENAME="$LOCATION/$FILENAME_OVERRIDE"
else
  TIMESTAMP=$(date '+%F_%H-%M-%S-%3N')
  FILENAME="$LOCATION/${PREFIX}-$TIMESTAMP.png"
fi
echo "Saving to: $FILENAME" >> "$LOGFILE"

# === Take screenshot ===
case "$MODE" in
  area)
    GEOM=$(slurp)
    if [[ -z "$GEOM" ]]; then
      [[ "$QUIET" == "false" ]] && notify-send -u critical -a Screenshot "❌ Screenshot cancelled" "No area selected"
      exit 1
    fi
    if ! echo "$GEOM" | grep -Eq '[0-9]+,[0-9]+ [1-9][0-9]*x[1-9][0-9]*'; then
      [[ "$QUIET" == "false" ]] && notify-send -u critical -a Screenshot "❌ Invalid region" "$GEOM"
      exit 1
    fi
    grim -g "$GEOM" - | tee "$FILENAME" | wl-copy
    ;;
  window)
    GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    grim -g "$GEOM" - | tee "$FILENAME" | wl-copy
    ;;
  monitor)
    MONITOR_INDEX=$(hyprctl activewindow -j | jq -r '.monitor')
    MONITOR=$(hyprctl monitors -j | jq -r ".[$MONITOR_INDEX].name")
    grim -o "$MONITOR" "$FILENAME"
    wl-copy < "$FILENAME"
    ;;
  all)
    grim "$FILENAME"
    wl-copy < "$FILENAME"
    ;;
  *)
    [[ "$QUIET" == "false" ]] && notify-send -u critical -a Screenshot "❌ Invalid screenshot mode: $MODE"
    exit 1
    ;;
esac

# === Notification ===
if [[ "$QUIET" == "false" && -f "$FILENAME" ]]; then
  notify-send -u normal -a Screenshot -i "$FILENAME" \
    --action=open:"Open Image" \
    --action=folder:"Show Folder" \
    "📸 Screenshot ($MODE) saved!" "$(basename "$FILENAME")" &>/dev/null &
elif [[ "$QUIET" == "false" ]]; then
  notify-send -u critical -a Screenshot "❌ Screenshot failed" "No file created"
  exit 1
fi

# === Play shutter sound ===
play_sound() {
  if command -v canberra-gtk-play &>/dev/null; then
    canberra-gtk-play -i camera-shutter -d "screenshot" &
  fi
}

if [[ "$SOUND_ENABLED" == "true" ]]; then
  play_sound
fi

echo "✅ Done!" >> "$LOGFILE"

