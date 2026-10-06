# Configuration

Operations Center reads:

```text
~/.config/nyvorel/operations-center.toml
```

## Actions

```toml
[actions]
terminal = ""
editor = ""
file_manager = ""
```

Blank values use automatic discovery.

You may set an executable or command supported by your environment.

## Runtime ignore rules

```toml
[runtime]
ignore_ports = [54321]
ignore_processes = ["some-helper"]
```

Use these for listeners that are valid but not useful in the Operations Center.

## Custom detectors

```toml
[[detectors]]
name = "Local API"
kind = "API"
icon = "api"
protocol = "http"
ports = [8787]
process_contains = "my-server"
cwd_contains = ""
```

All non-empty constraints must match.

A custom detector changes classification/display behavior; it does not grant extra permissions.

## Notes

- Keep configuration local. Do not store credentials here.
- Detector matching is intended for local runtime identity, not authentication.
- The monitor reloads configuration during normal census work; restart the service if you need immediate confirmation after a large configuration change.
