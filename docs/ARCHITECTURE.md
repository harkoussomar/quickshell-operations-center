# Architecture

## Components

### `src/operations.py`

The Python backend owns expensive process/socket/system inspection. A long-running user service refreshes a live census on a five-second interval.

Major responsibilities:

- current-user process discovery;
- listening socket ownership;
- runtime classification;
- project identity;
- operation/process-tree grouping;
- recent history lifecycle;
- system health/attention;
- local actions such as open/copy/terminal/editor/stop.

### `src/SidebarLeft.qml`

Always-loaded Nyvorel host/controller.

It owns:

- panel surface/window behavior;
- pin/detach lifecycle;
- stable IPC targets;
- lazy content creation.

### `src/SidebarLeftContent.qml`

Heavy Operations Center content. It is lazy-loaded only while needed.

It owns the Overview, Runtime, Jobs, and System views and talks to the Python backend through Quickshell process primitives.

## Runtime discovery

Listener discovery has two paths:

1. `ss` owner metadata when available;
2. `/proc/net/tcp` and `/proc/net/tcp6` socket inode correlation to current-user `/proc/<pid>/fd`.

The second path is required because process ownership metadata may be incomplete in a long-running systemd user-service context.

## Runtime lifecycle control

Runtime actions are bound to current-user process identity using PID plus `/proc` start ticks. Stop requests also carry the stable runtime `pin_key`, preventing stale UI actions from being applied to a replacement process.

When the listener is positively proven to be the `MainPID` of a systemd user `.service` and its cgroup matches that unit, Operations Center uses `systemctl --user stop` so a `Restart=` policy cannot simply recreate the listener. It deliberately does not stop generic `.scope` units. Other runtimes receive `SIGTERM` first and only receive `SIGKILL` if the exact same PID/start identity survives the bounded grace period.

The monitor owns the expensive five-second census, so its cached `snapshot` can briefly lag live process state after an action. Stop verification therefore distinguishes direct live discovery from monitor-cache convergence.

Runtime-card expansion is UI-local state keyed by stable runtime identity rather than delegate lifetime. Replacing the runtime array during a monitor refresh therefore does not collapse an open card.

## Privacy boundary

The backend has separate live and persisted representations.

Live data may retain short-lived local identity needed for actions. History is sanitized before persistence.

## Service model

`nyvorel-operations-monitor.service` runs continuously and owns the expensive census. The UI reads the fresh cache rather than independently re-running the whole discovery pipeline every few seconds.
