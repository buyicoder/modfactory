# ModFactory Artifact Contracts

Contracts describe what each module promised to produce. Validators should read contracts instead of inferring intent from filenames alone.

## Experience Contract

Use an experience contract when ModFactory is designing more than one isolated feature.

Recommended path:

```text
models/experience/<project>.experience.contract.json
```

Shape:

```json
{
  "schemaVersion": 1,
  "experienceId": "modid:dark_forge_rpg",
  "mode": "original_design",
  "pillars": ["heavy combat", "boss-gated progression", "dark metal crafting"],
  "target": {
    "minecraftVersion": "1.21.11",
    "loader": "fabric",
    "audience": "singleplayer_or_small_server",
    "style": "vanilla_plus_rpg"
  },
  "playerJourney": {
    "early": ["mine iron", "meet corrupted ruins", "craft first dark iron tools"],
    "mid": ["hunt dark golems", "unlock boss crafting"],
    "late": ["fight forged bosses", "craft late-tier armor"],
    "endgame": ["repeatable boss loop", "rare upgrade materials"]
  },
  "systems": [
    "models/systems/dark_combat.system.contract.json",
    "models/systems/dark_forge_progression.system.contract.json"
  ],
  "qa": ["progression_smoke", "combat_balance", "runtime_resource_closure"]
}
```

Modes:

- `original_design`
- `modpack_author`
- `focused_mod`
- `hybrid`

## System Contract

Use a system contract for combat, progression, economy/loot, tech, magic, worldgen, quest, or balance modules.

Recommended path:

```text
models/systems/<system>.system.contract.json
```

Shape:

```json
{
  "schemaVersion": 1,
  "systemId": "modid:dark_combat",
  "type": "combat",
  "ownerModule": "combat-system-designer",
  "playerStages": ["early", "mid", "late", "endgame"],
  "requirements": [
    {
      "id": "dark_iron_weapon_tier",
      "stage": "mid",
      "purpose": "First anti-golem equipment tier",
      "specialists": ["weapon", "texture-material", "fabric-engineering"],
      "contracts": ["models/features/dark_iron_weapon_tier.feature.contract.json"]
    },
    {
      "id": "dark_iron_golem_boss",
      "stage": "mid",
      "purpose": "Boss gate for dark iron cores",
      "specialists": ["entity", "model-rig", "animation", "fabric-engineering"],
      "contracts": ["models/dark_iron_golem.contract.json"]
    }
  ],
  "balance": {
    "targetTimeToKillSeconds": 45,
    "expectedPlayerArmorTier": "iron_or_dark_iron",
    "failureRisks": ["boss too slow", "loot farm too easy"]
  },
  "qa": ["combat_scenario", "loot_loop", "progression_unlock"]
}
```

## Entity Contract

Entity contracts already exist as `models/<entity>.contract.json`. They describe the entity-domain source of truth:

- entity id and display name
- reference source
- entity texture path, dimensions, and source
- Java model path, texture size, and part list
- renderer path and texture identifier
- runtime entity type field, dimensions, spawn egg, boss bar, loot intent
- required animation states

## Asset Contract

Use asset contracts when a visual asset has meaningful source provenance or transformation rules.

Recommended path:

```text
models/assets/<asset>.asset.contract.json
```

Shape:

```json
{
  "schemaVersion": 1,
  "assetId": "modid:dark_iron_golem_spawn_egg",
  "kind": "item_texture",
  "ownerModule": "entity",
  "source": {
    "type": "vanilla_texture",
    "id": "minecraft:iron_golem_spawn_egg",
    "path": "assets/minecraft/textures/item/iron_golem_spawn_egg.png"
  },
  "transform": {
    "type": "palette_map",
    "tool": "scripts/derive-vanilla-item-texture.ps1",
    "palette": "dark-iron-spawn-egg",
    "preserveDimensions": true,
    "preserveAlpha": true,
    "preserveSilhouette": true,
    "preserveUvLayout": false
  },
  "output": {
    "path": "src/main/resources/assets/modid/textures/item/dark_iron_golem_spawn_egg.png",
    "width": 16,
    "height": 16
  },
  "acceptance": {
    "requiresVanillaSource": true,
    "allowNovelGeneration": false
  }
}
```

### Source Types

| Type | Meaning |
|---|---|
| `vanilla_texture` | Extracted from Minecraft client assets, usually item/block/entity texture |
| `blockbench_embedded_texture` | Extracted from `.bbmodel` embedded texture data |
| `user_provided_file` | Supplied by the user |
| `generated_template` | Generated from a ModFactory template |
| `novel_generated` | Newly generated art, allowed only when no source-equivalent exists |

### Transform Types

| Type | Meaning |
|---|---|
| `palette_map` | Color remap while preserving shape and alpha |
| `uv_safe_variant` | Entity UV sheet retheme preserving dimensions, alpha, and UV islands |
| `template_render` | Generated from a model/template definition |
| `manual_edit` | User or artist edited output; should record source and acceptance notes |
| `novel_generation` | New shape or concept art |

## Animation Contract

Use animation contracts when entity animation has runtime behavior.

Recommended path:

```text
models/animations/<entity>.animation.contract.json
```

Shape:

```json
{
  "schemaVersion": 1,
  "entityId": "modid:dark_iron_golem",
  "rig": {
    "source": "models/dark_iron_golem.bbmodel",
    "requiredParts": ["head", "body", "right_arm", "left_arm", "right_leg", "left_leg"]
  },
  "clips": [
    {
      "name": "idle",
      "loop": true,
      "lengthSeconds": 2.5,
      "trigger": "ambient_idle",
      "requiredRuntimeState": null
    },
    {
      "name": "attack_slam",
      "loop": false,
      "lengthSeconds": 0.8,
      "trigger": "successful_melee_attack",
      "requiredRuntimeState": "ANIMATION_ATTACK_SLAM"
    },
    {
      "name": "hurt",
      "loop": false,
      "lengthSeconds": 0.35,
      "trigger": "damage_taken",
      "requiredRuntimeState": "ANIMATION_HURT"
    }
  ],
  "runtime": {
    "stateCarrier": "DataTracker",
    "renderStateClass": "DarkIronGolemRenderState",
    "modelClass": "DarkIronGolemEntityModel"
  }
}
```

### Trigger Names

Use stable trigger names so Animation and Fabric Engineering can agree on behavior:

| Trigger | Expected Runtime Binding |
|---|---|
| `ambient_idle` | Default idle pose or idle clip |
| `limb_swing` | Movement/walk state from render state |
| `successful_melee_attack` | `tryAttack` or named attack goal success |
| `damage_taken` | `damage` success path |
| `death` | death/removal state |
| `spawn` | summon/spawn initialization |
| `special_goal_start` | custom AI goal start |
| `special_goal_impact` | custom AI goal impact tick |

## Feature Contract

Feature contracts tie together all module outputs for a user request.

Recommended path:

```text
models/features/<feature>.feature.contract.json
```

Shape:

```json
{
  "schemaVersion": 1,
  "featureId": "modid:dark_iron_golem_feature",
  "summary": "Dark Iron Golem boss with derived assets and custom animations",
  "modules": ["entity", "asset-source", "texture-material", "model-rig", "animation", "fabric-engineering", "qa"],
  "entities": ["models/dark_iron_golem.contract.json"],
  "assets": [
    "models/assets/dark_iron_golem_spawn_egg.asset.contract.json",
    "models/assets/dark_iron_ingot.asset.contract.json"
  ],
  "animations": ["models/animations/dark_iron_golem.animation.contract.json"],
  "verification": [
    "scripts/validate-entity-assets.ps1",
    "scripts/integrity-check.ps1",
    "gradlew build",
    "gradlew runClient",
    "scripts/qa-runclient-check.ps1"
  ]
}
```

## Modpack Manifest

Use a modpack manifest in Modpack Author Mode.

Recommended path:

```text
models/modpacks/<pack>.modpack.manifest.json
```

Shape:

```json
{
  "schemaVersion": 1,
  "packId": "modid:tech_rpg_pack",
  "fantasy": "Tech automation with RPG boss progression",
  "target": {
    "minecraftVersion": "1.21.1",
    "loader": "fabric",
    "clientServer": "both"
  },
  "mods": [
    {
      "id": "create",
      "name": "Create",
      "version": "selected-version",
      "source": "modrinth-or-curseforge-url",
      "role": ["tech", "automation"],
      "side": "both",
      "dependencies": []
    }
  ],
  "systemOwnership": {
    "tech": "create",
    "quests": "ftb_quests",
    "bosses": "custom_or_selected_boss_mod"
  },
  "conflicts": [
    {
      "severity": "high",
      "type": "duplicate_worldgen",
      "mods": ["mod_a", "mod_b"],
      "resolution": "disable mod_b copper ore generation"
    }
  ],
  "integration": {
    "configs": [],
    "datapacks": [],
    "scripts": [],
    "glueMods": []
  },
  "qaMatrix": ["empty_launch", "world_creation", "progression_smoke", "performance_pass"]
}
```

## QA Report

QA reports capture verification evidence.

Recommended path:

```text
reports/qa/<feature-or-pack>.qa.report.json
```

Shape:

```json
{
  "schemaVersion": 1,
  "targetId": "modid:dark_forge_rpg",
  "targetType": "experience",
  "checks": [
    {
      "name": "integrity-check",
      "command": "powershell -File scripts/integrity-check.ps1 -ProjectDir .",
      "status": "pass",
      "evidence": "No failures"
    },
    {
      "name": "runClient",
      "command": "gradlew runClient",
      "status": "pass",
      "evidence": "Client reached world and no resource errors were observed"
    }
  ],
  "manualFindings": [
    {
      "area": "combat",
      "finding": "Dark Iron Golem attack animation triggers on player combat",
      "status": "verified"
    }
  ],
  "openRisks": []
}
```

## Contract Acceptance Rules

- Broad requests must produce an `experience.contract.json` or equivalent design document before specialist production.
- Multi-stage systems must produce a `system.contract.json` or equivalent system design.
- If `requiresVanillaSource` is true, novel generated textures are not acceptable.
- If `preserveDimensions` is true, output width and height must match the source.
- If `preserveAlpha` is true, transparent pixels must stay transparent.
- If `preserveUvLayout` is true, the output must not resize, crop, pad, or shift UV islands.
- One-shot animation clips must record a runtime trigger.
- Runtime animation triggers must be wired by Fabric Engineering before runClient QA.
- Modpack manifests must record selected system owners and conflict resolutions.
- Completion claims must cite QA report evidence or the exact commands run.
