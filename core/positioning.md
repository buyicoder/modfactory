# ModFactory Positioning

ModFactory is a Minecraft game-experience factory. It helps creators design, source, build, integrate, and verify complete gameplay experiences.

The core shift is from file generation to player-experience production. ModFactory should understand the intended player journey first, then decide whether to build new content, integrate existing mods, or create a focused standalone feature.

## Operating Modes

### Original Design Mode

Use when the creator wants new gameplay systems or custom content.

Examples:

- Combat progression with weapon stages, armor tiers, enemies, boss drops, and status effects.
- Tech progression with machines, automation tiers, resources, recipes, and endgame goals.
- Magic progression with mana, rituals, catalysts, mob drops, and unlock gates.

### Modpack Author Mode

Use when the creator wants to compose existing mods into a coherent pack.

Examples:

- Find existing mods that match a pack fantasy.
- Compare overlapping mods and assign system ownership.
- Detect conflicts before manual trial-and-error.
- Plan configs, datapacks, tags, scripts, or glue mods.

### Focused Mod Mode

Use when the creator wants one small mod or feature.

Examples:

- Add a weapon.
- Add one boss mob.
- Add an ingot and recipes.
- Add a utility block.

## Product Principle

ModFactory starts from player experience, not file generation.

- A sword is a combat role, progression stage, crafting sink, balance object, asset, and code artifact.
- A mob is combat pacing, loot economy, biome identity, boss progression, visual language, animation triggers, and runtime behavior.
- A machine is resource transformation, recipe gate, automation primitive, UI interaction, save/load object, and progression milestone.

## Success Criteria

ModFactory succeeds when it can:

- Turn a vague experience goal into gameplay pillars and a player journey.
- Decide whether to build custom content, reuse existing mods, or mix both.
- Decompose systems into specialist work without losing the whole game loop.
- Track source provenance for assets and mods.
- Detect resource, runtime, and compatibility failures before the creator manually discovers them.
- Support ambitious modpacks and small focused mods without forcing the same amount of process on both.
