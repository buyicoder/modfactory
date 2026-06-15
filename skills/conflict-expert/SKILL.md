---
name: conflict-expert
description: Use when checking whether Minecraft mods or modpack components are compatible, diagnosing modpack startup crashes, analyzing mixin/registry/dependency conflicts, or planning config/datapack/glue-code resolutions.
---

# Conflict Expert

## Overview

Conflict Expert is the compatibility specialist for ModFactory Modpack Author Mode. It helps pack authors avoid manual trial-and-error by building a compatibility hypothesis, checking dependency and overlap risks, inspecting logs, and producing concrete resolution actions.

Use `core/contracts.md`, `core/specialists/registry.md`, `core/workflows/modpack-authoring.md`, and `core/workflows/qa-gates.md` as the source of truth for modpack manifests, conflict reports, resolution plans, and launch QA.

Use this skill for:

- modpack compatibility checks
- startup crash analysis
- dependency graph issues
- mixin transformation conflicts
- duplicate ores/items/recipes/worldgen
- client/server side mismatches
- config conflicts
- integration planning

## Inputs

Collect:

- Minecraft version
- loader and loader version
- mod list with versions and sources
- client/server target
- crash report or log path if available
- pack fantasy and core systems
- user preference: remove mods, pin versions, configure around conflicts, or write glue code

## Analysis Checklist

### Dependency And Version

- loader mismatch
- Minecraft version mismatch
- missing dependencies
- incompatible dependency versions
- optional dependencies that enable integration
- client-only mods on dedicated server
- server-only mods expected on client

### Runtime Conflict

- mixin errors
- class transformation failures
- registry id collisions
- duplicate entry errors
- data pack validation failures
- resource reload errors
- config parse failures

### Content Conflict

- duplicate ores
- duplicate fluids
- duplicate item tiers
- duplicate machines
- recipe loops or impossible recipes
- overlapping tags
- duplicate biome/dimension ownership
- competing progression systems

### Performance Risk

- heavy worldgen
- ticking block entities
- entity density
- shader/resource pack load
- large datapacks
- excessive recipe/script reload time

## Output Format

```markdown
## Compatibility Summary

Verdict:
Confidence:

## Dependency Graph

- ...

## Conflicts

- Severity:
  Evidence:
  Cause:
  Fix:

## Resolution Plan

1. ...

## QA Matrix

- Empty launch:
- World creation:
- Progression smoke test:
- Dedicated server:
```

## Resolution Actions

Prefer concrete fixes:

- remove mod
- replace mod
- pin version
- add dependency
- split client/server mod lists
- disable duplicate worldgen
- disable duplicate recipes
- unify tags
- add datapack
- add KubeJS/CraftTweaker-style script when appropriate
- add small Fabric glue mod

## Guardrails

- Do not tell the user to test every pair manually.
- Do not guess from mod names alone when logs or metadata are available.
- Do not remove a mod if a config/datapack fix preserves the intended experience with lower cost.
- Do not write custom code when a config or datapack can solve the integration cleanly.
