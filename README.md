# Quickshell Operations Center

A focused developer/system operations panel for **Nyvorel**, built with Quickshell on Hyprland.

> Status: `v0.1.0-alpha.1` — early public release candidate.

## What it does

Operations Center gives one local place to inspect and act on:

- local development runtimes and listening ports;
- project/runtime identity, bind scope, CPU, memory, and uptime;
- local vs exposed listeners;
- active builds, tests, workflows, package operations, agents, and recent history;
- system attention items such as updates, failed user units, disk, memory, and load;
- configurable terminal/editor/file-manager actions;
- ownership-aware runtime Stop with supervised-service handling and guarded signal escalation;
- refresh-stable runtime detail expansion;
- custom runtime detectors and ignore rules.

The backend groups related process trees into logical operations instead of presenting every child process as a separate job.

## Scope

This project is currently a **Nyvorel integration module**, not a standalone Quickshell shell.

It expects an existing Nyvorel config at:

```text
~/.config/quickshell/nyvorel
```

and uses Nyvorel's common QML modules, theme services, and global state.

## Requirements

Required:

- Arch Linux or a comparable Linux userspace
- Hyprland
- Quickshell
- Python 3.11+
- `ss` from `iproute2`
- systemd user services
- `xdg-open`

Optional integrations are auto-detected when available: `kitty`, `foot`, `alacritty`, `wezterm`, `ghostty`, `zed`, `code`, `codium`, `nvim`, `dolphin`, `thunar`, `nautilus`, `pcmanfm`, and `wl-copy`.

## Install

Review the installer first, then run:

```bash
bash install.sh
```

The installer:

1. verifies the Nyvorel host exists;
2. backs up any files it will replace;
3. installs the backend and QML module;
4. creates the user config only if it does not already exist;
5. installs/enables `nyvorel-operations-monitor.service`;
6. keeps `NoNewPrivileges=true`;
7. intentionally uses `PrivateTmp=false` because runtime ownership discovery correlates `/proc/net` socket inodes with the current user's `/proc/<pid>/fd`;
8. runs the backend self-test and doctor.

The installer does **not** modify your Hyprland reload keybinds or other Nyvorel lifecycle scripts.

## Configuration

User configuration:

```text
~/.config/nyvorel/operations-center.toml
```

See [`docs/CONFIGURATION.md`](docs/CONFIGURATION.md).

## Privacy

Operations Center is local-only and has no telemetry or network reporting.

The monitor inspects the current user's process/socket state. Persistent history is deliberately minimized: raw command lines, working directories, project roots, member PID lists, and root process identity are not persisted.

Live runtime state may include a home-relative project path (for example `~/dev/my-app`) so local actions such as **Open folder** and **Open editor** can work. That live state stays on the local machine.

See [`SECURITY.md`](SECURITY.md).

## Architecture

```text
/proc + ss + systemd
        │
        ▼
 operations.py monitor
        │
        ├── live census (5 s)
        ├── privacy-minimal history
        └── runtime/action commands
        │
        ▼
 SidebarLeftContent.qml
        │
        ▼
 Nyvorel SidebarLeft host
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Uninstall

```bash
bash uninstall.sh
```

The uninstaller restores the backup created by the most recent installer run when possible. User configuration is preserved by default.

## Development checks

```bash
python3 src/operations.py self-test
python3 src/operations.py contract
bash scripts/doctor.sh
```

## License

GPL-3.0-only. See [`LICENSE`](LICENSE).
