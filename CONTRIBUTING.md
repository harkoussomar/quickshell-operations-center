# Contributing

Contributions are welcome, especially around detector quality, privacy, accessibility, and portability.

## Principles

- Keep Operations Center focused on developer/system operations.
- Do not add unrelated dashboard features.
- Prefer positive evidence over port-only ownership guesses.
- Preserve current-user process scope.
- Never persist raw commands or private filesystem paths in history.
- Keep process-stop behavior identity-safe.
- Avoid hard-coded terminal/editor/file-manager choices.
- Avoid personal absolute paths.

## Validation

Before submitting a change:

```bash
python3 src/operations.py self-test
python3 src/operations.py contract
bash scripts/doctor.sh
```

When changing QML, also run `qmllint` when available and manually verify the panel in Nyvorel.

## Pull requests

Keep changes narrowly scoped and explain:

- the problem;
- the chosen behavior;
- privacy/security implications;
- how the change was tested.
