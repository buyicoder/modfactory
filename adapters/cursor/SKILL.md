---
name: modfactory-cursor
description: Use in Cursor when the user wants to design, generate, integrate, or QA Minecraft mods, entities, items, systems, or modpacks using the platform-neutral ModFactory core.
---

# ModFactory Cursor Adapter

This adapter maps ModFactory Core to Cursor's agent environment.

## Required Core Reading

Before executing a ModFactory task, read:

1. `core/README.md`
2. `core/positioning.md`
3. `core/architecture.md`
4. `core/contracts.md`
5. `core/specialists/registry.md`
6. `core/workflows/README.md`
7. The relevant workflow selected by the workflow index

## Cursor Tool Mapping

- Use repository search and file reads to inspect existing mod structure.
- Use file edits or patches to write generated files.
- Use terminal commands for build, datagen, runClient, validation scripts, and asset tooling.
- Use linter/diagnostic reads after substantive code edits.
- Record verification evidence before claiming completion.

## Adapter Rules

- Keep product logic in `core/`; this file only explains Cursor execution.
- Follow contracts and QA gates from `core/contracts.md` and `core/workflows/qa-gates.md`.
- For broad requests, start with Experience Direction.
- For focused entity work, use Entity Production.
- For modpack requests, use Modpack Authoring.
- If a feature needs assets, route through the shared asset service roles in `core/specialists/registry.md`.

## Completion

A Cursor run is complete only when the relevant QA gates have evidence or skipped gates are explicitly documented with residual risk.
