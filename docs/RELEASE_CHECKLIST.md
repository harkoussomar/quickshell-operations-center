# Release Checklist

## Automated

- [ ] `python3 src/operations.py self-test` passes.
- [ ] Contract reports schema 5, UI contract 1.1.0, backend revision 6.1-runtime-control.
- [ ] `bash scripts/doctor.sh` passes required checks.
- [ ] No legacy pre-Nyvorel identifiers or personal absolute paths in the public payload.
- [ ] No secrets in the public payload.
- [ ] `qmllint` has no parser errors on the two public QML files.
- [ ] Service is current-user only and retains `NoNewPrivileges=true`.

## Manual

- [ ] Install into a clean Nyvorel checkout/profile.
- [ ] Confirm one real local listener appears.
- [ ] Runtime search/filter/copy/open/folder/editor/pin/stop work; expanded details survive monitor refreshes and stopped supervised runtimes stay stopped.
- [ ] Jobs active/history/search work.
- [ ] System health view loads.
- [ ] Sidebar open/close/pin/detach remain stable.
- [ ] Test on at least one 1920×1080 display and one scaled/secondary display if available.
- [ ] Capture README screenshots/demo.
- [ ] Review the GPL-3.0-only choice before publishing.
- [ ] Confirm the separate Nyvorel Ctrl+Super+R lifecycle hardening is merged; this repository does not own that keybind.
- [ ] Tag `v0.1.0-alpha.1`.
