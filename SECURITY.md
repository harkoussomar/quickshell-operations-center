# Security Policy

## Supported versions

Security fixes are currently provided for the latest alpha release only.

## Local data model

Operations Center reads local process, socket, systemd, package-update, memory, load, and filesystem-capacity information in order to render the panel.

It does not include telemetry and does not transmit collected data to a remote service.

### Live state

Live runtime/job state can contain:

- PID identity needed for safe process control;
- project/runtime labels;
- home-relative project paths needed for local actions;
- CPU, memory, uptime, bind address, port, and scope.

### Persisted history

Persisted job history is intentionally minimized and must not contain:

- raw command lines;
- origin command lines;
- working directories;
- project roots;
- member PID arrays;
- root PID/start-tick identity.

## Service hardening

The monitor runs as the current user with:

```ini
NoNewPrivileges=true
PrivateTmp=false
```

`PrivateTmp=false` is intentional. On affected user-service contexts, `PrivateTmp=true` prevents the monitor from reliably correlating `/proc/net` socket inodes with the current user's `/proc/<pid>/fd`, which is required to identify listener ownership.

The monitor is not a privileged/root service.

## Reporting a vulnerability

Please open a private security advisory on the repository rather than a public issue when reporting a vulnerability that could expose local data or allow unintended process control.

Include:

- affected version;
- reproduction steps;
- expected and actual behavior;
- relevant logs with secrets and personal paths removed.
