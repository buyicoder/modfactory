# ModFactory Entity Pipeline

The entity pipeline is the Entity Module workflow inside the broader ModFactory architecture. See `docs/modfactory-architecture.md` for the module boundaries, shared asset services, contracts, and QA gates.

The Entity Module owns mob design, mechanics, runtime requirements, and `entity.contract.json`. It delegates visual and technical production to shared services:

- Asset Source: official Minecraft assets, Blockbench sources, embedded textures, provenance.
- Texture Material: UV-safe entity variants and vanilla-derived item icons.
- Model Rig: Blockbench model structure, part names, UV layout, Java model expectations.
- Animation: clips, loop flags, action naming, runtime trigger requirements.
- Technical Art and Fabric Engineering: renderer/model/render-state integration and entity code.

## Flow

1. Design blueprint with `entity-design-expert`.
2. Write `models/<entity>.contract.json` with entity mechanics, dimensions, model parts, spawn egg id, loot intent, and animation states.
3. Export official or Blockbench reference assets through Asset Source.
4. Retheme entity UV texture through Texture Material without changing UV dimensions, alpha, or layout.
5. Derive vanilla-shaped item icons through Texture Material when a close vanilla source exists.
6. Adapt model geometry and renderer integration through Model Rig and Technical Art.
7. Generate Fabric entity code, spawn egg, loot, lang, and resources through Fabric Engineering.
8. Run the entity closure gate with `scripts\validate-entity-assets.ps1`.
9. Run the project closure gate with `scripts\integrity-check.ps1`.
10. Run `gradlew build`.
11. Run `gradlew runClient`.
12. Verify the entity in-game.

## Commands

```powershell
powershell -File scripts\export-bbmodel-assets.ps1 -BbmodelPath models\iron_golem_official.bbmodel -ProjectDir . -EntityName dark_iron_golem -ModId modid
powershell -File scripts\derive-vanilla-item-texture.ps1 -MinecraftClientJar <path-to-minecraft-client.jar> -VanillaTexture iron_golem_spawn_egg -OutputPath src\main\resources\assets\modid\textures\item\dark_iron_golem_spawn_egg.png -Palette dark-iron-spawn-egg
powershell -File scripts\derive-vanilla-item-texture.ps1 -MinecraftClientJar <path-to-minecraft-client.jar> -VanillaTexture iron_ingot -OutputPath src\main\resources\assets\modid\textures\item\dark_iron_ingot.png -Palette dark-iron
powershell -File scripts\validate-entity-assets.ps1 -ProjectDir . -ContractPath models\dark_iron_golem.contract.json
powershell -File scripts\integrity-check.ps1 -ProjectDir .
```

The closure gate is a pre-build requirement: missing entity textures, renderer texture identifiers, model texture dimensions, lang keys, loot tables, spawn egg item mappings, spawn egg item models, or runtime registry dimensions must fail before `gradlew build`.

## Vanilla-Derived Item Rule

If the generated item is a themed version of an existing Minecraft item shape, do not draw it from scratch. Use `derive-vanilla-item-texture.ps1` with the closest vanilla texture, then palette-map the pixels while preserving dimensions, alpha, and silhouette. This applies to spawn eggs, ingots, nuggets, gems, sticks, rods, tools, armor item icons, and other icons where vanilla already defines the readable shape.

Entity UV sheets are different: they should come from the Blockbench/export/contract path because UV layout and model part placement are entity-specific.

## Animation Trigger Rule

Animation work is not complete when clips exist in Blockbench. Every one-shot animation must have a runtime trigger recorded in the entity or animation contract, for example:

- `attack_slam` -> successful melee attack or named special attack goal.
- `hurt` -> damage taken.
- `death_collapse` -> death state.
- `spawn_wake` -> summon/spawn event.

Technical Art and Fabric Engineering must wire those triggers through render state or tracked entity data before runtime QA.
