#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

ROOT="${NYVOREL_ROOT:-$HOME/.config/quickshell/nyvorel}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/nyvorel/operations-center"
CURRENT="$STATE/current-install"
SERVICE="nyvorel-operations-monitor.service"
SERVICE_FILE="$HOME/.config/systemd/user/$SERVICE"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nyvorel/operations-center.toml"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ -f "$CURRENT" ]] || die "no installer backup marker found"
BACKUP="$(cat "$CURRENT")"
[[ -d "$BACKUP" && -f "$BACKUP/manifest" ]] || die "installer backup is missing"

systemctl --user disable --now "$SERVICE" >/dev/null 2>&1 || true

restore_one() {
  local target="$1" key="$2"
  local existed
  existed="$(awk -F= -v k="$key" '$1==k{print $2}' "$BACKUP/manifest")"
  if [[ "$existed" == "1" ]]; then
    cp -a "$BACKUP/$key" "$target"
  else
    rm -f "$target"
  fi
}

restore_one "$ROOT/scripts/operations-center/operations.py" operations.py
restore_one "$ROOT/modules/nyvorel/sidebarLeft/SidebarLeft.qml" SidebarLeft.qml
restore_one "$ROOT/modules/nyvorel/sidebarLeft/SidebarLeftContent.qml" SidebarLeftContent.qml
restore_one "$SERVICE_FILE" service.unit

systemctl --user daemon-reload

if grep -q '^service.unit=1$' "$BACKUP/manifest"; then
  systemctl --user enable --now "$SERVICE" >/dev/null 2>&1 || true
fi

# User configuration is preserved intentionally.
rm -f "$CURRENT"

echo "Operations Center uninstalled/restored from:"
echo "  $BACKUP"
echo "User config preserved:"
echo "  $CONFIG"
