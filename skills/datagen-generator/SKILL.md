---
name: datagen-generator
description: Use when the user needs automatic JSON generation for models, recipes, tags, or language files. Triggers on: "generate JSON automatically", "auto-generate models", "data generation", "datagen", "I don't want to write JSON by hand", or dispatched by mc-mod-master.
---

# Data Generation Generator

## Overview

Generates Fabric Data Generation code that automatically produces model JSONs, recipes, loot tables, block tags, item tags, and language files. Uses vanilla's DataGenerator system to eliminate manual JSON writing.

## DataGen Type Selection

```
What to auto-generate?
│
├── Item models → ModelProvider (generated + handheld)
├── Block models → BlockStateProvider + ModelProvider
├── Recipes → RecipeProvider (shaped/shapeless/smelting)
├── Loot tables → LootTableProvider (block drops, entity drops)
├── Tags → ItemTagProvider + BlockTagProvider
├── Language → English/Chinese language provider
└── Advancements → AdvancementProvider
```

## Quick Template: Complete DataGen Setup

```java
// data/ModDataGenerator.java — Main entry point
public class ModDataGenerator implements DataGeneratorEntrypoint {
    @Override
    public void onInitializeDataGenerator(FabricDataGenerator fabricDataGenerator) {
        FabricDataGenerator.Pack pack = fabricDataGenerator.createPack();

        pack.addProvider(ModModelProvider::new);
        pack.addProvider(ModRecipeProvider::new);
        pack.addProvider(ModLootTableProvider::new);
        pack.addProvider(ModBlockTagProvider::new);
        pack.addProvider(ModItemTagProvider::new);
        pack.addProvider(ModEnglishLanguageProvider::new);
        pack.addProvider(ModChineseLanguageProvider::new);
    }
}
```

```java
// data/ModModelProvider.java — Item + Block models
public class ModModelProvider extends FabricModelProvider {
    public ModModelProvider(FabricDataOutput output) {
        super(output);
    }

    @Override
    public void generateBlockStateModels(BlockStateModelGenerator generator) {
        // Simple cube-all block (one texture on all faces)
        generator.registerSimpleCubeAll(ModBlocks.RUBY_BLOCK);
    }

    @Override
    public void generateItemModels(ItemModelGenerator generator) {
        // Handheld model for tools (renders 3D in hand)
        generator.register(ModItems.RUBY_SWORD, Models.HANDHELD);
        generator.register(ModItems.RUBY_PICKAXE, Models.HANDHELD);
        generator.register(ModItems.RUBY_AXE, Models.HANDHELD);
        generator.register(ModItems.RUBY_SHOVEL, Models.HANDHELD);
        generator.register(ModItems.RUBY_HOE, Models.HANDHELD);

        // Generated model for items (flat 2D)
        generator.register(ModItems.RUBY, Models.GENERATED);
        generator.register(ModItems.RUBY_HELMET, Models.GENERATED);
        // ... etc
    }
}
```

```java
// data/ModRecipeProvider.java — Crafting recipes
public class ModRecipeProvider extends FabricRecipeProvider {
    public ModRecipeProvider(FabricDataOutput output, CompletableFuture<RegistryWrapper.WrapperLookup> registries) {
        super(output, registries);
    }

    @Override
    public void generate(RecipeExporter exporter) {
        // 3x3 compression: 9 ruby -> ruby block
        ShapedRecipeJsonBuilder.create(RecipeCategory.BUILDING_BLOCKS, ModBlocks.RUBY_BLOCK)
            .pattern("###").pattern("###").pattern("###")
            .input('#', ModItems.RUBY)
            .criterion(FabricRecipeProvider.hasItem(ModItems.RUBY),
                FabricRecipeProvider.conditionsFromItem(ModItems.RUBY))
            .offerTo(exporter);

        // Decompression: ruby block -> 9 ruby
        ShapelessRecipeJsonBuilder.create(RecipeCategory.MISC, ModItems.RUBY, 9)
            .input(ModBlocks.RUBY_BLOCK)
            .criterion(FabricRecipeProvider.hasItem(ModBlocks.RUBY_BLOCK),
                FabricRecipeProvider.conditionsFromItem(ModBlocks.RUBY_BLOCK))
            .offerTo(exporter, Identifier.of(ExampleMod.MOD_ID, "ruby_from_block"));

        // Sword recipe
        ShapedRecipeJsonBuilder.create(RecipeCategory.COMBAT, ModItems.RUBY_SWORD)
            .pattern("#").pattern("#").pattern("/")
            .input('#', ModItems.RUBY)
            .input('/', Items.STICK)
            .criterion(FabricRecipeProvider.hasItem(ModItems.RUBY),
                FabricRecipeProvider.conditionsFromItem(ModItems.RUBY))
            .offerTo(exporter);
    }
}
```

```java
// data/ModBlockTagProvider.java — Block tags
public class ModBlockTagProvider extends FabricTagProvider.BlockTagProvider {
    public ModBlockTagProvider(FabricDataOutput output, CompletableFuture<RegistryWrapper.WrapperLookup> registries) {
        super(output, registries);
    }

    @Override
    protected void configure(RegistryWrapper.WrapperLookup arg) {
        getOrCreateTagBuilder(BlockTags.PICKAXE_MINEABLE)
            .add(ModBlocks.RUBY_BLOCK);
        getOrCreateTagBuilder(BlockTags.NEEDS_DIAMOND_TOOL)
            .add(ModBlocks.RUBY_BLOCK);
    }
}
```

```java
// data/ModItemTagProvider.java — Item tags
public class ModItemTagProvider extends FabricTagProvider.ItemTagProvider {
    public ModItemTagProvider(FabricDataOutput output, CompletableFuture<RegistryWrapper.WrapperLookup> registries) {
        super(output, registries);
    }

    @Override
    protected void configure(RegistryWrapper.WrapperLookup arg) {
        getOrCreateTagBuilder(ItemTags.SWORDS).add(ModItems.RUBY_SWORD);
        getOrCreateTagBuilder(ItemTags.PICKAXES).add(ModItems.RUBY_PICKAXE);
        getOrCreateTagBuilder(ItemTags.AXES).add(ModItems.RUBY_AXE);
        getOrCreateTagBuilder(ItemTags.SHOVELS).add(ModItems.RUBY_SHOVEL);
        getOrCreateTagBuilder(ItemTags.HOES).add(ModItems.RUBY_HOE);
    }
}
```

## DataGen Setup in build.gradle

```groovy
loom {
    runs {
        datagen {
            inherit server
            name "Data Generation"
            vmArg "-Dfabric-api.datagen"
            vmArg "-Dfabric-api.datagen.output-dir=${file("src/main/generated")}"
            vmArg "-Dfabric-api.datagen.modid=${modid}"
            runDir "build/datagen"
        }
    }
}

// Add generated sources to main sourceSet
sourceSets {
    main {
        resources {
            srcDirs += ['src/main/generated']
        }
    }
}
```

## fabric.mod.json Entry

```json
"entrypoints": {
    "fabric-datagen": ["com.example.data.ModDataGenerator"]
}
```

## Architecture

DataGen classes go in the `data/` package (Farmer's Delight pattern). One class per generation type.

| Architecture | DataGen location |
|-------------|-----------------|
| flat | `data/` at root |
| feature-based | `data/` at root (like Farmer's Delight) |
| registry-logic-split | `data/` at root |

## Benefits Over Manual JSON

| Manual JSON | DataGen |
|-------------|---------|
| 12 recipe files × 20 palettes = 240 files | 1 RecipeProvider generates all |
| Easy to typo item IDs | Compile-time safety |
| Hard to maintain across MC versions | API updates handle changes |
| Must remember JSON format | IDE autocomplete |
