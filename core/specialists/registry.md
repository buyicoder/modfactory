# ModFactory Specialist Registry

Specialists are role definitions. Platform adapters may implement them as agent skills, prompts, scripts, subagents, or human handoffs.

## Direction And Planning

| Specialist | Owns | Inputs | Outputs |
|---|---|---|---|
| Experience Director | Gameplay pillars, player journey, mode routing | Creator intent, constraints | Experience direction, mode, system list, contract outline |
| Project Mode Router | Original Design, Modpack Author, Focused Mod, Hybrid routing | Experience direction | Production route and required modules |
| Progression Designer | Unlock journey and stage ordering | Experience contract | Progression graph, system requirements |
| Balance Designer | Numbers and exploit checks | System contracts | Balance ranges, playtest scenarios, risks |

## System Designers

| Specialist | Owns | Inputs | Outputs |
|---|---|---|---|
| Combat System Designer | Weapons, armor, enemy roles, damage curves, boss pacing | Experience direction | Combat system contract |
| Economy And Loot Designer | Drops, recipes, resource sinks, rarity, farms | Progression graph | Economy and loot requirements |
| Tech System Designer | Machines, automation, power, fluids/items, GUIs | Experience direction | Tech system contract |
| Magic System Designer | Mana/resources, spells, rituals, catalysts | Experience direction | Magic system contract |
| Worldgen Designer | Ores, biomes, structures, dimensions, spawn rules | Progression requirements | Worldgen requirements |
| Quest And Guide Designer | Advancements, guidebooks, tutorial tasks | Progression graph | Guide and onboarding requirements |

## Domain Producers

| Specialist | Owns | Inputs | Outputs |
|---|---|---|---|
| Entity Expert | Mob identity, mechanics, AI role, spawn, drops, boss bar | System/feature contract | Entity contract |
| Weapon Expert | Weapon archetypes, stats, abilities, repair/crafting | Combat/progression contract | Weapon feature contract |
| Armor Expert | Armor tiers, set bonuses, equipment requirements | Combat/progression contract | Armor feature contract |
| Item Expert | Item behavior, recipes, registration requirements | Feature contract | Item code/resource requirements |
| Block Expert | Block behavior, loot, blockstates, models | Feature contract | Block code/resource requirements |
| Gameplay Expert | Cross-feature mechanics such as mana or cooldowns | System contract | Gameplay implementation requirements |

## Shared Asset Services

| Specialist | Owns | Inputs | Outputs |
|---|---|---|---|
| Asset Source Expert | Official assets, project assets, mod assets, Blockbench sources, provenance | Feature/entity/asset needs | Source records and asset contracts |
| Texture Material Expert | Item/block/equipment textures, vanilla-derived variants, UV-safe rethemes | Asset contract | Texture outputs and provenance |
| Model Rig Expert | Blockbench structure, dimensions, part names, UV layout | Entity/model requirements | Model assets and model contract details |
| Animation Expert | Clips, timing, loop flags, runtime trigger map | Rig and animation requirements | Animation contract |
| Technical Artist | Renderer/model binding, render state, texture identifiers, animation state mapping | Assets and runtime requirements | Runtime binding requirements |

## Engineering And Integration

| Specialist | Owns | Inputs | Outputs |
|---|---|---|---|
| Fabric Engineer | Java/Kotlin code, registration, resources, runtime bindings | Feature/entity/item/block contracts | Mod implementation |
| Datagen Engineer | Generated recipes, tags, loot, models, language, data | Feature requirements | Datagen implementation |
| Integration Expert | Configs, datapacks, tags, recipes, scripts, glue mods | Modpack manifest/conflict report | Integration plan and assets |
| Conflict Expert | Dependencies, compatibility graph, mixins/logs, duplicate content | Mod list, logs, pack fantasy | Conflict report and resolution plan |
| QA Expert | Contract validation, build/runtime evidence, playtest matrix | Contracts and outputs | QA report |

## Boundary Rules

- A specialist should not define the whole game experience unless it is the Experience Director.
- Asset specialists should not invent gameplay purpose.
- Engineering specialists should consume contracts instead of inventing missing design.
- Conflict Expert should prefer config/datapack/script fixes before custom code when that preserves the experience.
- QA Expert can reject work even if files exist.
