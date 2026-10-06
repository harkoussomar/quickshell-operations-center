#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

ROOT="${NYVOREL_ROOT:-$HOME/.config/quickshell/nyvorel}"
PKG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/nyvorel/operations-center"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$STATE/installs/$STAMP"
SERVICE="nyvorel-operations-monitor.service"
SERVICE_FILE="$HOME/.config/systemd/user/$SERVICE"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nyvorel/operations-center.toml"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
ok() { printf '✓ %s\n' "$*"; }

for cmd in python3 systemctl ss cp install mkdir; do
  command -v "$cmd" >/dev/null 2>&1 || die "missing dependency: $cmd"
done

[[ -f "$ROOT/shell.qml" ]] || die "Nyvorel shell not found at $ROOT"
[[ -d "$ROOT/modules/common" ]] || die "Nyvorel common modules not found; this package is not standalone"

mkdir -p "$BACKUP"
mkdir -p "$ROOT/scripts/operations-center" "$ROOT/modules/nyvorel/sidebarLeft"
mkdir -p "$(dirname "$SERVICE_FILE")" "$(dirname "$CONFIG")"

manifest="$BACKUP/manifest"
: > "$manifest"

backup_one() {
  local path="$1" key="$2"
  if [[ -e "$path" ]]; then
    printf '%s=1\n' "$key" >> "$manifest"
    cp -a "$path" "$BACKUP/$key"
  else
    printf '%s=0\n' "$key" >> "$manifest"
  fi
}

backup_one "$ROOT/scripts/operations-center/operations.py" operations.py
backup_one "$ROOT/modules/nyvorel/sidebarLeft/SidebarLeft.qml" SidebarLeft.qml
backup_one "$ROOT/modules/nyvorel/sidebarLeft/SidebarLeftContent.qml" SidebarLeftContent.qml
backup_one "$SERVICE_FILE" service.unit

install -m 0755 "$PKG/src/operations.py" "$ROOT/scripts/operations-center/operations.py"
install -m 0644 "$PKG/src/SidebarLeft.qml" "$ROOT/modules/nyvorel/sidebarLeft/SidebarLeft.qml"
install -m 0644 "$PKG/src/SidebarLeftContent.qml" "$ROOT/modules/nyvorel/sidebarLeft/SidebarLeftContent.qml"
install -m 0644 "$PKG/systemd/nyvorel-operations-monitor.service" "$SERVICE_FILE"

if [[ ! -f "$CONFIG" ]]; then
  install -m 0600 "$PKG/config/operations-center.toml.example" "$CONFIG"
  printf 'config_created=1\n' >> "$manifest"
else
  printf 'config_created=0\n' >> "$manifest"
fi

printf '%s\n' "$BACKUP" > "$STATE/current-install"

python3 "$ROOT/scripts/operations-center/operations.py" self-test >/dev/null
python3 "$ROOT/scripts/operations-center/operations.py" contract >/dev/null

systemctl --user daemon-reload
systemctl --user enable --now "$SERVICE"

sleep 1
systemctl --user is-active --quiet "$SERVICE" || die "$SERVICE failed to start"

"$PKG/scripts/doctor.sh"

ok "Operations Center installed"
echo "Backup: $BACKUP"
echo "Reload/start Nyvorel using your normal lifecycle mechanism."
