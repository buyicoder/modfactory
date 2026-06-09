---
name: worldgen-generator
description: Use when the user needs ore generation, custom trees, world structures, biome modifications, or custom features. Triggers on: "generate ore in world", "add a tree", "create a structure", "spawn in biomes", "world generation", "ore generation", or dispatched by mc-mod-master.
---

# World Generation Generator

## Overview

Generates world generation features using Fabric's Biome Modification API. Covers ore generation, custom trees, placed features, configured features, and biome modifications.

## Generation Type Selection

```
What to generate in the world?
│
├── Ore → PlacedFeature + ConfiguredFeature + BiomeModification
├── Tree → TreeFeature + FoliagePlacer + TrunkPlacer + BiomeModification
├── Structure → StructureFeature + StructurePiece + biome modifier
├── Flower/Plant → SimpleBlockFeature + BiomeModification
├── Lake → LakeFeature
└── Custom Feature → Feature class + ConfiguredFeature + PlacedFeature
```

## Quick Generate: Ore Generation

### Step 1: Configure the ore feature
```java
// common/worldgen/ModConfiguredFeatures.java
public class ModConfiguredFeatures {
    public static final RegistryKey<ConfiguredFeature<?, ?>> RUBY_ORE_KEY =
        RegistryKey.of(RegistryKeys.CONFIGURED_FEATURE,
            Identifier.of(ExampleMod.MOD_ID, "ruby_ore"));

    public static final ConfiguredFeature<?, ?> RUBY_ORE = new ConfiguredFeature<>(
        Feature.ORE,
        new OreFeatureConfig(
            OreFeatureConfig.Rules.DEEPSLATE_ORE_REPLACEABLES, // what to replace
            ModBlocks.RUBY_ORE.getDefaultState(),               // what to place
            8  // vein size (max blocks per vein)
        )
    );
}
```

### Step 2: Place the ore in the world
```java
// common/worldgen/ModPlacedFeatures.java
public class ModPlacedFeatures {
    public static final RegistryKey<PlacedFeature> RUBY_ORE_PLACED_KEY =
        RegistryKey.of(RegistryKeys.PLACED_FEATURE,
            Identifier.of(ExampleMod.MOD_ID, "ruby_ore"));

    public static final PlacedFeature RUBY_ORE_PLACED = new PlacedFeature(
        RegistryEntry.of(ModConfiguredFeatures.RUBY_ORE),
        List.of(
            // CountPlacement: how many veins per chunk
            PlacedFeatures.createCountExtraModifier(4, 0.5f, 1),
            // HeightPlacement: Y-level range (triangle distribution)
            HeightRangePlacementModifier.triangle(
                VerticalAnchor.absolute(-64),  // min Y
                VerticalAnchor.absolute(32)    // max Y
            ),
            // Biome filter (done in step 3)
            BiomePlacementModifier.of()
        )
    );
}
```

### Step 3: Add to biomes
```java
// common/worldgen/ModWorldGeneration.java
public class ModWorldGeneration implements ModInitializer {
    @Override
    public void onInitialize() {
        BiomeModifications.addFeature(
            BiomeSelectors.foundInOverworld(),
            GenerationStep.Feature.UNDERGROUND_ORES,
            ModPlacedFeatures.RUBY_ORE_PLACED_KEY
        );
    }
}
```

### Step 4: Register in main mod
```java
// common/registry/ModWorldgen.java
public class ModWorldgen {
    public static void register() {
        Registry.register(
            BuiltInRegistries.CONFIGURED_FEATURE,
            ModConfiguredFeatures.RUBY_ORE_KEY.getValue(),
            ModConfiguredFeatures.RUBY_ORE
        );
        Registry.register(
            BuiltInRegistries.PLACED_FEATURE,
            ModPlacedFeatures.RUBY_ORE_PLACED_KEY.getValue(),
            ModPlacedFeatures.RUBY_ORE_PLACED
        );
    }
}
```

## Quick Generate: Custom Tree

```java
// common/worldgen/ModTreeFeatures.java
public static final TreeFeature RUBY_TREE = new TreeFeature(
    Feature.TREE,
    new TreeFeatureConfig.Builder(
        BlockStateProvider.of(ModBlocks.RUBY_LOG),        // log block
        new StraightTrunkPlacer(5, 2, 1),                  // height, variation
        BlockStateProvider.of(ModBlocks.RUBY_LEAVES),      // leaves block
        new BlobFoliagePlacer(ConstantIntProvider.create(2), ConstantIntProvider.create(0), 3),
        new TwoLayersFeatureSize(1, 0, 1)
    ).build()
);
```

## Ore Placement Reference

| Ore | Vein Size | Veins/Chunk | Y Range |
|-----|-----------|-------------|---------|
| Coal | 17 | 20 | 0 ~ 320 |
| Iron | 9 | 10 / 10 / 40 | -64 ~ 320 |
| Copper | 10 | 16 | -16 ~ 112 |
| Gold | 9 | 4 / 1 / 1 | -64 ~ 256 |
| Redstone | 8 | 4 / 8 | -64 ~ 16 |
| Diamond | 8 | 1 / 1 / 3 | -64 ~ 16 |
| Lapis | 7 | 2 / 4 | -64 ~ 64 |
| Emerald | 3 | 100 | -16 ~ 256 (mountains only!) |

## Biome Selectors

```java
BiomeSelectors.foundInOverworld()          // All overworld biomes
BiomeSelectors.foundInTheNether()          // All nether biomes
BiomeSelectors.foundInTheEnd()             // All end biomes
BiomeSelectors.tag(ModBiomeTags.IS_MOUNTAIN)     // Mountains only
BiomeSelectors.tag(BiomeTags.IS_OCEAN)           // Oceans only
BiomeSelectors.includeByKey(BiomeKeys.PLAINS)    // Specific biome
```

## Auto-Generated Files

| Feature Type | Files |
|-------------|-------|
| Ore | ModConfiguredFeatures.java + ModPlacedFeatures.java + ModWorldGeneration.java |
| Tree | Feature class + ConfiguredFeature + PlacedFeature + BiomeModification |
| Structure | Structure class + Piece class + Jigsaw/StructureFeature |
| Simple feature | ConfiguredFeature + PlacedFeature + BiomeModification |

## Architecture

Worldgen classes follow the mod's architecture pattern:

| Architecture | Worldgen location |
|-------------|-------------------|
| flat | `worldgen/` at root package |
| feature-based | `common/worldgen/` |
| registry-logic-split | `common/worldgen/` (logic) + `reg/ModWorldgen.java` (registration) |

## Common Mistakes

| Symptom | Fix |
|---------|-----|
| Ore doesn't generate | Check PlacedFeature modifiers (count + height + biome) |
| "Feature not registered" | Ensure ConfiguredFeature AND PlacedFeature are both registered in BuiltInRegistries |
| Ore generates in wrong biome | Use correct BiomeSelectors |
| Ore generates at wrong height | Adjust HeightRangePlacementModifier |
| "RegistryKey not found" | 1.21.2+ needs RegistryKey registration via datapack |
