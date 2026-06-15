# ModFactory Architecture

ModFactory is organized as a production studio:

```text
Experience Director
  -> Project Mode Router
    -> System Design Modules
      -> Domain Modules
        -> Shared Asset Services
        -> Engineering And Integration
          -> Contracts And Manifests
            -> QA Gates
```

## Experience Director

Owns the top-level question:

```text
What game experience are we creating?
```

Responsibilities:

- Define gameplay pillars.
- Define player journey.
- Choose operating mode.
- Define progression loops.
- Record constraints.
- Decide which systems need specialist design.

## Project Mode Router

Chooses the operating mode:

| Mode | Use When | Output |
|---|---|---|
| Original Design Mode | New gameplay systems or custom content | System contracts, progression graph, specialist tasks |
| Modpack Author Mode | Existing mods should be composed into a pack | Modpack manifest, compatibility graph, conflict report |
| Focused Mod Mode | One small mod or feature | Narrow feature contract, assets, code/resources, QA gates |
| Hybrid Mode | Existing mods plus custom glue/content | Modpack manifest plus custom feature contracts |

## System Design Modules

Design gameplay systems before production:

- Combat
- Progression
- Economy and Loot
- Tech
- Magic
- Worldgen
- Quest and Guide
- Balance

## Domain Modules

Own feature meaning and closure:

- Entity Module
- Item Module
- Block Module
- Gameplay Module
- Integration Module

## Shared Asset Services

Serve all domains:

- Asset Source
- Texture Material
- Model Rig
- Animation
- Technical Art

## Engineering And Integration

Turns contracts into working outputs:

- Mod code and resources.
- Configs and datapacks.
- Tags, recipes, loot tables.
- Scripts or glue code when appropriate.
- Runtime bindings.

## Contracts And Manifests

Contracts are the shared language between designers, specialists, engineers, and QA. See `contracts.md`.

## QA Gates

QA gates prove that outputs satisfy intent:

- Contract shape validation.
- Resource closure.
- Source provenance.
- Build or packaging.
- Runtime startup.
- Visual and gameplay QA.
- Modpack launch matrix.
