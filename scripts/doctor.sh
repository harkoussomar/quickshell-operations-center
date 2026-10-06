#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${NYVOREL_ROOT:-$HOME/.config/quickshell/nyvorel}"
BACKEND="$ROOT/scripts/operations-center/operations.py"
SERVICE="nyvorel-operations-monitor.service"
FAIL=0

ok() { printf 'PASS  %s\n' "$*"; }
bad() { printf 'FAIL  %s\n' "$*"; FAIL=1; }

for cmd in python3 systemctl ss; do
  command -v "$cmd" >/dev/null 2>&1 && ok "$cmd available" || bad "$cmd missing"
done

[[ -f "$BACKEND" ]] && ok "backend installed" || bad "backend missing"

if [[ -f "$BACKEND" ]]; then
  python3 "$BACKEND" self-test >/dev/null 2>&1 && ok "backend self-test" || bad "backend self-test"
  contract="$(python3 "$BACKEND" contract 2>/dev/null || true)"
  python3 - "$contract" <<'PY' >/dev/null 2>&1
import json, sys
p=json.loads(sys.argv[1])
assert p["schema_version"] == 5
assert p["ui_contract"] == "1.1.0"
assert p["backend_revision"] == "6.1-runtime-control"
assert p["history_privacy"] == "minimal"
assert p["process_scope"] == "current-user"
assert p["runtime_command_exposed"] is False
PY
  [[ $? -eq 0 ]] && ok "backend contract" || bad "backend contract"
fi

if systemctl --user is-active --quiet "$SERVICE"; then
  ok "$SERVICE active"
else
  bad "$SERVICE inactive"
fi

priv="$(systemctl --user show "$SERVICE" -p PrivateTmp --value 2>/dev/null || true)"
nnp="$(systemctl --user show "$SERVICE" -p NoNewPrivileges --value 2>/dev/null || true)"
[[ "${priv,,}" == "no" || "${priv,,}" == "false" ]] && ok "PrivateTmp=false" || bad "PrivateTmp must be false"
[[ "${nnp,,}" == "yes" || "${nnp,,}" == "true" ]] && ok "NoNewPrivileges=true" || bad "NoNewPrivileges must be true"

if command -v qs >/dev/null 2>&1; then
  if qs -c nyvorel list -j 2>/dev/null | grep -q "$ROOT/shell.qml"; then
    ok "Nyvorel Quickshell registered"
    ipc="$(qs -c nyvorel ipc show 2>/dev/null || true)"
    grep -Fxq 'target operationsCenter' <<<"$ipc" && ok "operationsCenter IPC" || bad "operationsCenter IPC missing"
    grep -Fxq 'target sidebarLeft' <<<"$ipc" && ok "sidebarLeft IPC" || bad "sidebarLeft IPC missing"
  else
    printf 'INFO  Nyvorel Quickshell is not running; IPC checks skipped\n'
  fi
fi

exit "$FAIL"
