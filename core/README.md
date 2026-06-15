# ModFactory Core

ModFactory Core is a platform-neutral playbook for designing, sourcing, building, integrating, and verifying Minecraft gameplay experiences.

It is not tied to Claude Code, Cursor, Codex, OpenClaw, or any specific agent runtime. Platform-specific agent skills should act as thin adapters that read and follow this core.

## What ModFactory Does

ModFactory supports three operating modes:

- Original Design Mode: design and build new gameplay systems or custom content.
- Modpack Author Mode: compose existing mods into a coherent pack and resolve conflicts.
- Focused Mod Mode: produce one small mod or feature with minimal process and strong QA.

## Core Structure

```text
core/
├── README.md
├── positioning.md
├── architecture.md
├── contracts.md
├── workflows/
│   ├── README.md
│   ├── experience-direction.md
│   ├── entity-production.md
│   ├── modpack-authoring.md
│   └── qa-gates.md
└── specialists/
    └── registry.md
```

Platform entry points live outside the core:

```text
adapters/
├── cursor/
├── claude-code/
└── generic-agent/
```

## How Platform Adapters Should Use This Core

An adapter should:

1. Detect when a user request matches ModFactory.
2. Read `workflows/README.md` to select the relevant workflow.
3. Map generic operations to the host agent's tools.
4. Preserve core contracts and QA gates.
5. Avoid copying platform-specific behavior into core files.

## Non-Goals

- Core does not define how a specific agent reads files, edits files, runs shell commands, or asks users questions.
- Core does not depend on one skill frontmatter format.
- Core does not assume a single mod loader unless a workflow explicitly sets one.
