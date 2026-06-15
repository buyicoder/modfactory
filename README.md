# ModFactory

Platform-neutral Minecraft game-experience factory. ModFactory coordinates experience design, domain modules, shared asset services, Fabric engineering, modpack integration, contracts, and QA gates to generate or integrate complete, verifiable gameplay experiences.

## Quick Start

Use the adapter for your agent runtime.

Claude Code:

```
/mc-mod-master Create a ruby sword with lightning power
```

Cursor or generic agents should start from `adapters/` and read the platform-neutral core playbook.

The master skill automatically:
1. Parses your intended player experience
2. Chooses Original Design Mode, Modpack Author Mode, or Focused Mod Mode
3. Chooses domain modules and shared asset services
4. Produces or integrates contract-backed assets, code, configs, and resources
5. Runs closure checks before build/runtime verification

## Architecture

```
mc-mod-master (orchestrator)
+-- experience director
+-- project mode router
+-- domain modules
|   +-- entity module
|   +-- item module
|   +-- block module
|   +-- gameplay module
+-- shared asset services
|   +-- asset source
|   +-- texture material
|   +-- model rig
|   +-- animation
|   +-- technical art
+-- Fabric engineering
+-- modpack integration
+-- conflict expert
+-- contracts
+-- QA gates
```

The platform-neutral source of truth is in `core/`:

- `core/README.md`
- `core/positioning.md`
- `core/architecture.md`
- `core/contracts.md`
- `core/specialists/registry.md`
- `core/workflows/README.md`
- `core/workflows/`

Platform-specific entry points live in `adapters/`.

Legacy and implementation notes remain in `docs/`, including `docs/modfactory-positioning.md` and `docs/modfactory-architecture.md`.

System design modules are documented in `docs/system-design-modules.md`.

## Entity Pipeline

ModFactory can run a closed-loop entity pipeline:

```text
idea -> blueprint -> Blockbench assets -> asset contract -> Fabric code -> integrity check -> build -> runClient QA
```

See `docs/entity-pipeline.md` and `docs/artifact-contracts.md`.

Contract shape validation is tool-backed:

```powershell
powershell -NoProfile -File scripts\validate-contract.ps1 -ContractPath path\to\entity.contract.json
```

## Modpack Authoring

ModFactory can also design and validate integration packs:

```text
pack fantasy -> mod discovery -> compatibility graph -> conflict analysis -> integration plan -> launch QA
```

See `docs/modpack-authoring.md`.

## Phase Status

| Phase | Skills | Status |
|------|--------|--------|
| 1 | master, texture, item, block | V1.0 |
| 2 | entity | Active |
| 3 | gameplay | Planned |

## Requirements

- An AI agent, automation system, or human operator that can read files, write files, run commands, and report verification evidence
- Java 21+ (for Minecraft 1.21+)
- [GearFactory](https://github.com/buyicoder/GearFactory) engine (for texture generation)
- [fabric-mc-mod-development](https://github.com/buyicoder/modfactory) skill (API reference)

## License

MIT
