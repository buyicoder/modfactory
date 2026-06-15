# ModFactory Platform Adapters

Adapters are thin entry points for different agent runtimes. They should not redefine ModFactory's product logic.

Each adapter must:

1. Detect a ModFactory request.
2. Read the relevant files under `core/`.
3. Map core workflows to the host platform's tools.
4. Preserve contracts, provenance rules, and QA gates.
5. Keep platform-specific syntax out of `core/`.

## Available Adapters

- `cursor/` for Cursor agent skills and IDE workflows.
- `claude-code/` for Claude Code skill packaging.
- `generic-agent/` for any AI agent that can read files, edit projects, run commands, and report QA evidence.

## Core Files To Read First

- `core/README.md`
- `core/positioning.md`
- `core/architecture.md`
- `core/contracts.md`
- `core/specialists/registry.md`
- `core/workflows/README.md`
- the workflow selected by `core/workflows/README.md`
