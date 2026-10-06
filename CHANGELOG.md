# Changelog

All notable changes to this project will be documented here.

## [0.1.0-alpha.1] - 2026-10-06

### Added

- Local runtime discovery with current-user ownership enforcement.
- `/proc/net/tcp{,6}` socket-inode fallback for reliable service-context discovery.
- Next.js, Vite, Astro, Nuxt, FastAPI, Django, Flask, Node, Python, PostgreSQL, Redis, MySQL, MongoDB, ADB, WayVNC, and Tailscale-aware runtime classification.
- Logical operation grouping for builds, tests, workflows, package work, transfers, media jobs, and coding agents.
- Runtime search and All / Local / Exposed / Pinned filters.
- Copy endpoint, open browser, open project folder, open editor, terminal, pin, and safe-stop actions.
- Configurable action providers, ignore rules, and custom detectors.
- Privacy-minimal persisted history.
- Nyvorel systemd monitor service.
- Public packaging, doctor, installer, uninstaller, security policy, and contributor documentation.

### Fixed

- Runtime Stop now stops a positively owned systemd user service instead of only terminating its listener PID, preventing `Restart=` policies from immediately recreating the runtime.
- Runtime Stop falls back to identity-checked `SIGTERM` and bounded `SIGKILL` escalation for non-service runtimes.
- Runtime detail expansion is keyed by stable runtime identity, so the five-second monitor refresh no longer collapses an open card.

### Security and privacy

- Runtime/process scope limited to the current user.
- Persistent history excludes raw commands, CWD/project roots, member PID arrays, and root process identity.
- `NoNewPrivileges=true` retained for the monitor service.
