# ModFactory Contracts

Contracts describe intent and handoff requirements. Agents and tools should validate contracts instead of trusting that files merely exist.

## Contract Types

| Contract | Purpose |
|---|---|
| `experience.contract.json` | Overall gameplay pillars, player journey, mode, target version/loader, systems |
| `system.contract.json` | Combat, progression, economy, tech, magic, worldgen, quest, or balance requirements |
| `feature.contract.json` | Feature-level closure across specialists |
| `entity.contract.json` | Entity mechanics, resources, runtime dimensions, renderer/model/loot/spawn egg closure |
| `asset.contract.json` | Asset source provenance, transform method, dimensions, alpha/silhouette/UV rules |
| `animation.contract.json` | Clip names, loop flags, lengths, runtime triggers |
| `modpack.manifest.json` | Mods, versions, dependencies, system ownership, conflicts, integrations, QA matrix |
| `qa.report.json` | Verification evidence and open risks |

## Executable Schemas

The first tool-backed schema set lives in `schemas/contracts/`:

| Schema | Validates |
|---|---|
| `entity.contract.schema.json` | `entity.contract.json` |
| `asset.contract.schema.json` | `asset.contract.json` |
| `animation.contract.schema.json` | `animation.contract.json` |
| `qa.report.schema.json` | `qa.report.json` |

Validate a contract with:

```powershell
powershell -NoProfile -File scripts\validate-contract.ps1 -ContractPath path\to\entity.contract.json
```

The validator infers schema from filenames like `entity.contract.json`, `asset.contract.json`, `animation.contract.json`, and `qa.report.json`. For custom names, pass `-SchemaPath`.

## Acceptance Rules

- Broad requests need an experience contract or equivalent design document.
- Multi-stage systems need a system contract or equivalent design.
- Source-sensitive assets need asset contracts.
- Vanilla-shaped assets should be derived from a vanilla or project source unless the creator requests a novel shape.
- Entity UV sheets must preserve dimensions, alpha, and UV layout unless the model changes with them.
- One-shot animations need runtime triggers.
- Modpack manifests must record selected system owners and conflict resolutions.
- Completion claims must cite QA evidence.

## Minimal Contract Flow

```text
experience.contract.json
  -> system.contract.json
    -> feature.contract.json
      -> entity/item/block/asset/animation contracts
        -> qa.report.json
```

Focused Mod Mode can skip the upper layers when the feature is truly isolated, but it should still use contracts for assets, runtime-sensitive behavior, or resource closure.
