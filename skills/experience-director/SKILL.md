---
name: experience-director
description: Use when the user wants to design an overall Minecraft gameplay experience, progression, combat/tech/magic system, modpack concept, or broad mod direction before generating individual content. Routes work into Original Design Mode, Modpack Author Mode, or Focused Mod Mode.
---

# Experience Director

## Overview

Experience Director is ModFactory's top-level game design layer. It owns the player experience before any specialist generates assets, code, configs, or modpack glue.

Use `core/positioning.md`, `core/architecture.md`, `core/contracts.md`, `core/specialists/registry.md`, and `core/workflows/experience-direction.md` as the source of truth.

Use this skill when the request is about:

- overall gameplay experience
- combat systems
- progression arcs
- tech trees
- magic systems
- boss progression
- modpack concepts
- "what should this mod/modpack be?"
- broad feature sets with multiple systems

Do not use this skill for tiny scoped requests like "add one ruby sword" unless the user asks for design direction.

## Core Responsibility

Answer this before production starts:

```text
What player journey are we designing, and which production mode should ModFactory use?
```

## Operating Modes

### Original Design Mode

Use when ModFactory should design and build new content or systems.

Output:

- gameplay pillars
- early/mid/late game journey
- system modules needed
- progression graph
- specialist task breakdown
- contracts and QA gates

### Modpack Author Mode

Use when ModFactory should reuse existing mods and integrate them into a coherent pack.

Output:

- pack fantasy and player journey
- candidate mod categories
- mod discovery plan
- compatibility graph
- conflict analysis plan
- config/datapack/script/glue-code plan
- QA launch matrix

### Focused Mod Mode

Use when the request is one small mod or one focused feature.

Output:

- narrow feature contract
- required specialists
- resource/code closure gates
- minimal QA plan

## Workflow

### 1. Interpret Creator Intent

Extract:

- fantasy: vanilla-plus, RPG, tech automation, horror survival, adventure, total conversion
- player goal: combat mastery, automation, exploration, collection, bosses, creativity
- scope: focused feature, system, full mod, modpack
- constraints: Minecraft version, loader, multiplayer, performance, visual style
- preference: build custom content, reuse existing mods, or hybrid

### 2. Pick Project Mode

Use this decision rule:

```text
Single feature with clear output -> Focused Mod Mode
Multiple new mechanics or progression stages -> Original Design Mode
Existing mod reuse or pack composition -> Modpack Author Mode
Both custom systems and existing mods -> Hybrid: Original Design + Modpack Author
```

### 3. Define Player Journey

Break the experience into stages:

- Early game: first tools, first threat, first resource loop.
- Mid game: specialization, automation, stronger enemies, meaningful crafting.
- Late game: rare resources, bosses, complex machines, powerful gear.
- Endgame: optional mastery, repeatable goals, prestige, dimensions, raids, megaprojects.

### 4. Define System Modules

Choose only the modules needed:

- Combat System
- Progression
- Economy and Loot
- Tech System
- Magic System
- Worldgen
- Quest and Guide
- Balance
- Modpack Integration

### 5. Produce Contract Outline

Produce a contract outline before dispatching specialists:

```text
experience.contract.json
  -> system.contract.json
    -> feature.contract.json
      -> entity/item/block/asset/animation contracts
```

### 6. Dispatch To Production

Dispatch to `mc-mod-master` with:

- selected mode
- required system modules
- specialist list
- expected contracts
- QA gates

## Output Format

For every broad request, provide:

```markdown
## Experience Direction

Fantasy:
Player Journey:
Project Mode:
Core Loops:

## Required Systems

- System:
  - Purpose:
  - Player-facing outcome:
  - Required specialists:
  - Contracts:

## Production Plan

1. ...

## QA Gates

- ...
```

## Guardrails

- Do not start by generating a weapon, mob, block, or texture for a broad system request.
- Do not let a specialist define the whole game loop by accident.
- Do not over-plan tiny Focused Mod Mode requests.
- Prefer reusing existing mods when the user is acting as a modpack author.
- Prefer original production when the user wants unique mechanics, identity, or learnable systems.

## Examples

### Combat System

Request: "Design a combat system."

Correct route:

```text
Experience Director
  -> Combat System Designer
  -> Progression Designer
  -> Economy and Loot Designer
  -> Entity Expert
  -> Weapon Expert
  -> Armor Expert
  -> Asset services
  -> Fabric Engineering
  -> QA
```

### Tech System

Request: "Design a tech system."

Correct route:

```text
Experience Director
  -> Tech System Designer
  -> Progression Designer
  -> Worldgen Designer
  -> Economy and Loot Designer
  -> Asset services
  -> Fabric Engineering
  -> QA
```

### Modpack

Request: "Make a tech RPG modpack around existing mods."

Correct route:

```text
Experience Director
  -> Modpack Author Mode
  -> Mod Discovery
  -> Conflict Expert
  -> Integration Expert
  -> QA Matrix
```
