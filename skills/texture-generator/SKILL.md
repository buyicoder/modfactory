---
name: texture-generator
description: Use when the user needs Minecraft item textures, block textures, armor model textures, or equipment icons. Triggers on: "generate texture", "create icon", "make armor look like", "need a texture for", or when dispatched by mc-mod-master for visual asset generation.
---

# Texture Generator

## Overview

Generates Minecraft-style pixel art textures for items, blocks, and armor using the GearFactory engine. Supports 20 color palettes and multiple shape templates. Outputs standard 16x16 item icons and 64x32 armor equipment textures.

In ModFactory architecture this skill serves the Texture Material service. Use `core/contracts.md` and `core/specialists/registry.md` as the source of truth for asset provenance. When a texture has meaningful source provenance or must be derived from vanilla art, record the expected source and transform in an `asset.contract.json` or equivalent artifact.

## Entity UV Sheet Boundary

Do not use this skill as the default path for entity UV sheets. Entity textures must preserve a model-specific UV layout, texture dimensions, and alpha channel. For mobs and bosses, route texture work through:

1. `entity-design-expert` to establish the entity asset contract.
2. `scripts\export-bbmodel-assets.ps1` to extract the reference texture.
3. `scripts\texture-variant-engine.ps1` to apply deterministic theme variants.
4. `scripts\validate-entity-assets.ps1` to verify the texture still matches the contract.

Use this skill for entity work only when creating concept art or non-UV item/block/equipment assets that will not be wired directly to an entity model.

## Vanilla-Derived Asset Boundary

If a requested texture is a themed version of an existing Minecraft item shape, prefer the Asset Source + Texture Material route over drawing from scratch:

```powershell
powershell -File scripts\derive-vanilla-item-texture.ps1 -MinecraftClientJar <path-to-minecraft-client.jar> -VanillaTexture iron_ingot -OutputPath src\main\resources\assets\modid\textures\item\dark_iron_ingot.png -Palette dark-iron
```

Examples: spawn eggs, ingots, nuggets, gems, sticks, rods, tools, armor item icons, and vanilla-shaped blocks.

Only use novel generation when no close vanilla or project source exists, or when the user explicitly requests a new shape.

## GearFactory Engine

Located at `forge_engine/` in the mod project. If not present, clone from https://github.com/buyicoder/GearFactory.

### Quick Generate
```powershell
cd forge_engine
.\forge.ps1 -PaletteName ruby -Shape vanilla
```

### Parameters
| Param | Values | Default |
|------|--------|---------|
| `-PaletteName` | ruby, sapphire, emerald, amethyst, topaz, obsidian, silver, rose_gold, coral, amber, jade, crimson, ocean, forest, inferno, frost, shadow, celestial, thunder, onyx | ruby |
| `-Shape` | vanilla, copper, aura, better_weapons, amethyst, fresh | vanilla |
| `-ItemName` | sword, pickaxe, axe, shovel, hoe, helmet, chestplate, leggings, boots, all | all |
| `-OutputName` | Any string (custom item prefix) | ruby |
| `-Apply` | Flag: also write to project textures/ | (off) |

### Custom Item Names (v1.3+)
```powershell
# Generate thunder_sword.png instead of ruby_sword.png
.\forge.ps1 -PaletteName topaz -OutputName thunder -Apply
# → textures/item/thunder_sword.png (topaz/gold colored)
# → textures/item/thunder_pickaxe.png
# → ... etc

# Without -Apply: library only, safe
.\forge.ps1 -PaletteName ruby -OutputName custom_mod
# → output/ruby/item/custom_mod_sword.png (library only)
```

### Palette Selection Guide
Match palette to user's description:
- "ruby/red/blood/fire" → ruby, crimson, inferno
- "ice/frost/water/ocean" → frost, ocean, sapphire
- "nature/forest/poison" → forest, emerald, jade
- "holy/lightning" → celestial, thunder
- "dark/shadow/void" → shadow, obsidian, onyx
- "royal/magic/purple" → amethyst
- "gold/luxury" → topaz, amber
- "metal/steel" → silver, obsidian

## Texture Generation Workflow

### Step 1: Determine Style
Extract from user description:
- Color theme → map to palette
- Shape style → map to Shape source
- "legendary/epic/glowing" → aura or better_weapons
- "simple/classic" → vanilla

### Step 2: Run Engine
```powershell
cd forge_engine
.\forge.ps1 -PaletteName <chosen> -Shape <chosen>
```

### Step 3: Verify Output
Check files exist:
```
output/<palette>/item/ruby_sword.png
output/<palette>/item/ruby_helmet.png
...
output/<palette>/equipment/humanoid/ruby.png
output/<palette>/equipment/humanoid_leggings/ruby.png
```

### Step 4: Copy to Project
Engine auto-copies to `src/main/resources/assets/modid/textures/`.

## Manual Texture Generation (No Engine)
If GearFactory engine is not available, create textures programmatically using PowerShell's System.Drawing. Each texture must be:
- Items: 16x16 PNG, transparent background
- Armor equipment: 64x32 PNG (humanoid and humanoid_leggings)
- Blocks: 16x16 PNG

Use 3-4 shades of the material color for depth (outline → shadow → base → light → highlight).
