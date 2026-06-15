---
name: modfactory
description: Use when the user wants to design, generate, integrate, or QA Minecraft mods, entities, items, systems, or modpacks using the platform-neutral ModFactory core.
---

# ModFactory Claude Code Adapter

This adapter exposes ModFactory Core as a Claude Code skill.

## Required Core Reading

Before executing a ModFactory task, read:

1. `core/README.md`
2. `core/positioning.md`
3. `core/architecture.md`
4. `core/contracts.md`
5. `core/specialists/registry.md`
6. `core/workflows/README.md`
7. The relevant workflow selected by the workflow index

## Claude Code Mapping

- Use Read/Edit/Write tools to inspect and update project files.
- Use Bash for Gradle, validation scripts, datagen, asset generation, and runClient.
- Use subagents only when a task can be split by specialist boundaries without shared state conflicts.
- Store platform-specific prompt and tool instructions in this adapter or sibling Claude Code skills, not in `core/`.

## Adapter Rules

- Treat `core/` as the source of truth.
- Do not let Claude Code-specific tool names leak into core workflow files.
- Preserve asset provenance, contract closure, and QA evidence.
- Use existing specialized skills as implementation helpers when available, but keep their output aligned with the core contracts.

## Completion

Do not claim a mod, asset, entity, or pack is complete until the relevant QA gates have evidence or skipped gates are documented with risk.
