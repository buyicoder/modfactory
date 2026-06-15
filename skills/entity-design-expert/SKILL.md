---
name: entity-design-expert
description: Use when designing a polished custom Minecraft mob, boss, pet, or creature and coordinating its entity contract, mechanics, asset requirements, animation states, Fabric implementation requirements, and QA gates.
---

# Entity Design Expert

## Overview

Entity Design Expert is the Entity Module lead in ModFactory. It owns the entity concept, mechanics, runtime requirements, and entity contract. It coordinates shared asset services and Fabric engineering, but does not personally own texture creation, model editing, animation authoring, or implementation code.

**Required collaborators:** `entity-designer`, Asset Source, Texture Material, Model Rig, Animation, Technical Art, `entity-generator`, `integrity-checker`, `auto-fix`.

Use `core/architecture.md`, `core/contracts.md`, `core/specialists/registry.md`, and `core/workflows/entity-production.md` as the source of truth. Legacy docs can provide implementation history, but core owns the module boundaries.

## Core Rule

Do not let model, texture, animation, and code drift apart.

Every entity must have a single source-of-truth asset contract:

```text
entity identity + mechanics + reference entity + texture size + UV layout + part names + animation states + runtime triggers + entity dimensions
```

If any one changes, re-check all others before running the game.

For the complete contract schema, see `core/contracts.md`.

## Workflow

### 1. Design the Entity Contract

Start with `entity-designer`. The blueprint must include:

- Vanilla reference entity or explicit custom shape.
- Texture size and UV layout, e.g. `64x64`, `128x128`, `128x64`.
- Exact runtime size: `EntityType.Builder.dimensions(width, height)`.
- Model part list: head, body, arms, legs, wings, tail, etc.
- Required clips: idle, walk, attack, hurt, death, special, spawn.
- Runtime features: spawn egg, boss bar, drops, biome spawning, summon method.

### 2. Assign Asset Source Work

Prefer official Minecraft assets when adapting a vanilla-shaped mob. Entity Design Expert records what sources are required; Asset Source performs lookup/export and records provenance.

Search order:

1. Project `models/` and existing `.bbmodel` references.
2. Existing `src/main/resources/assets/<modid>/textures/entity/`.
3. Minecraft/client source or asset cache when available.
4. Blockbench model library or a user-provided `.bbmodel`.

When a `.bbmodel` has embedded textures, Asset Source should export the embedded texture directly instead of regenerating it:

```powershell
$json = Get-Content -Raw model.bbmodel | ConvertFrom-Json
$tex = $json.textures | Where-Object { $_.name -eq "entity_texture" } | Select-Object -First 1
$src = [string]$tex.source
if ($src -match ",") { $src = $src.Substring($src.IndexOf(",") + 1) }
[IO.File]::WriteAllBytes("src/main/resources/assets/modid/textures/entity/name.png",
  [Convert]::FromBase64String($src))
```

### 3. Assign Texture Material Work

Entity Design Expert sets the visual direction and acceptance criteria. Texture Material performs the actual retheme. Never resize a texture to hide UV bugs. Retexture in the same dimensions and same UV layout as the model.

Good transformations:

- Brightness remap to a new palette.
- Hue shift while preserving alpha.
- Add emissive accents inside existing painted regions.
- Preserve transparent pixels and all image dimensions.

Bad transformations:

- `128x128` -> `64x64` to match a simplified model.
- Repainting from scratch without checking UV islands.
- Exporting a texture from one `.bbmodel` while using Java geometry from another.

### 4. Assign Model Rig Work

Model Rig owns Blockbench structure, part names, dimensions, UV layout, and Java model expectations. Entity Design Expert records the required geometry and accepts/rejects the result.

For vanilla-shaped entities:

- Use the official part proportions and UV offsets.
- Keep `TexturedModelData.of(data, textureWidth, textureHeight)` equal to the texture.
- Set `EntityType.Builder.dimensions(width, height)` to match the in-game body size.
- In Yarn 1.21.11 use `EntityModel<LivingEntityRenderState>`, `ModelTransform.origin`, and do not override `render()`.

When converting Blockbench coordinates:

- Compare total model height against the intended entity height.
- Verify head/body/limb origins support animation.
- If a model looks tiny, check both Java cuboid heights and entity dimensions.
- If a model has holes, check UV size/layout before changing the texture.

### 5. Assign Animation Work

Use the Animation service through `blockbench-animator` after the model is open. Entity Design Expert defines the required action set and runtime trigger requirements; Animation authors clips and reports clip metadata.

Required verification:

- Call `list_outline` and use real part names.
- Create clips with stable names and record them in the blueprint.
- Loop only idle/walk/look clips.
- One-shot attack/hurt/death/spawn clips.
- Verify keyframe counts and clip lengths after writing.

For heavy golems, request:

- Walk: slow, weighty, opposite legs, small arm swing.
- Idle: minimal breathing and subtle head motion.
- Attack: anticipation -> impact -> recovery.
- Death: heavy collapse, no floaty bounce.

### 6. Assign Fabric Engineering Work

Use `entity-generator` only after the entity contract and required asset/animation outputs are stable.

Fabric Engineering generates the full closure:

- `EntityType` registration and attributes.
- Entity AI/mechanics class.
- Spawn egg item using custom `ModSpawnEggItem` for custom entities.
- Client renderer and model layer registration.
- Entity model code from the agreed geometry.
- Texture at `textures/entity/<name>.png`.
- Lang keys for entity and spawn egg.
- Loot table or explicit no-drop decision.
- Creative tab entry.
- Optional boss bar, biome spawn rules, summon item, sounds, particles.
- Runtime animation triggers, e.g. successful melee attack, damage taken, death, spawn, and named special goals.

### 7. Verify Runtime, Not Just Build

Validation order:

1. `integrity-checker`: static resource closure.
2. `gradlew build`: compile/resources.
3. `gradlew runClient`: actual startup.
4. Spawn the entity in-game.
5. Verify appearance, scale, spawn egg, boss bar, loot, and animations.

If `build` passes but `runClient` fails, treat it as incomplete. Entity rendering and spawn eggs often fail only at runtime.

## ModFactory Dispatch Protocol

For a complex entity request:

```text
mc-mod-master
  -> entity-design-expert: entity concept, mechanics, contract, acceptance criteria
  -> Asset Source: official/Blockbench source discovery and provenance
  -> Texture Material: UV-safe entity texture variants and vanilla-derived item icons
  -> Model Rig: model structure, part names, dimensions, UV layout
  -> Animation: clips plus runtime trigger map
  -> Technical Art: render state, model binding, texture identifiers, animation state mapping
  -> entity-generator: Fabric code/resources
  -> integrity-checker: contract/resource closure
  -> auto-fix: compile/runtime errors
  -> runClient: final verification
```

## Common Mistakes

| Symptom | Root Cause | Fix |
|---|---|---|
| Texture looks different from Blockbench | Game texture was regenerated instead of exported from `.bbmodel` | Export embedded Blockbench texture directly |
| Entity has transparent holes | Java model UV size/layout does not match texture | Match `TexturedModelData` size and UV offsets to source texture |
| Entity looks too small | Simplified Java cuboids or small entity dimensions | Match official/reference geometry and `dimensions()` |
| Spawn egg crashes on startup | `SpawnEggItem.forEntity(customType)` returned null | Use custom `ModSpawnEggItem` |
| Build passes but game crashes | Missing renderer/model layer/spawn egg runtime binding | Run `runClient` and fix runtime closure |
| Animations do not affect parts | Assumed bone names | Inspect Blockbench outline and bind real names |

## Acceptance Checklist

- [ ] Blueprint approved and complete.
- [ ] Entity contract records mechanics, runtime dimensions, spawn egg id, loot intent, and required animation states.
- [ ] Official/reference asset source and provenance are recorded by Asset Source.
- [ ] Texture Material output records whether each texture is UV-safe, vanilla-derived, or novel generated.
- [ ] Texture dimensions match model texture size.
- [ ] Model Rig output confirms Java model geometry matches reference proportions.
- [ ] Entity dimensions match intended in-game scale.
- [ ] Animation clip names, loop flags, and runtime triggers are recorded and verified.
- [ ] Technical Art confirms render state, model part names, texture identifiers, and animation state mapping.
- [ ] Spawn egg works for custom entity.
- [ ] Renderer, model layer, texture, lang, loot, creative tab all exist.
- [ ] `gradlew build` passes.
- [ ] `gradlew runClient` opens and entity is visually verified in-game.
