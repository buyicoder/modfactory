---
name: recipe-generator
description: Use when the user needs crafting recipes, smelting recipes, smithing recipes, or custom recipe types. Triggers on: "add a recipe", "create a crafting recipe", "make it craftable", "how to craft", "furnace recipe", or dispatched by mc-mod-master.
---

# Recipe Generator

## Overview

Generates all Minecraft recipe types: shaped crafting, shapeless crafting, smelting/blasting, smithing, campfire, stonecutting, and custom recipe types with serializers.

## Recipe Type Selection

```
What kind of recipe?
│
├── Shaped crafting → shaped JSON (3x3 pattern)
├── Shapeless crafting → shapeless JSON (any position)
├── Smelting/Blasting → furnace JSON (input→output+timer)
├── Smithing → smithing JSON (template+base+addition→result)
├── Stonecutting → stonecutting JSON (input→output)
├── Campfire → campfire JSON (input→output+timer)
└── Custom type → Java class + serializer + JSON (complex)
```

## Quick Templates

### Shaped Crafting Recipe
```json
// data/MODID/recipe/<name>.json
{
  "type": "minecraft:crafting_shaped",
  "pattern": ["###", "###", "###"],
  "key": { "#": "modid:ruby" },
  "result": { "id": "modid:ruby_block", "count": 1 }
}
```

### Shapeless Crafting Recipe
```json
{
  "type": "minecraft:crafting_shapeless",
  "ingredients": ["modid:ruby_block"],
  "result": { "id": "modid:ruby", "count": 9 }
}
```

### Smelting Recipe
```json
{
  "type": "minecraft:smelting",
  "ingredient": { "item": "modid:ruby_ore" },
  "result": { "id": "modid:ruby", "count": 1 },
  "experience": 1.0,
  "cookingtime": 200
}
```
Also: `"type": "minecraft:blasting"` (2x faster) for blast furnace.

### Smithing Recipe (1.20+)
```json
{
  "type": "minecraft:smithing_transform",
  "template": { "item": "minecraft:netherite_upgrade_smithing_template" },
  "base": { "item": "modid:ruby_sword" },
  "addition": { "item": "minecraft:netherite_ingot" },
  "result": { "id": "modid:netherite_ruby_sword", "count": 1 }
}
```

### Stonecutting Recipe
```json
{
  "type": "minecraft:stonecutting",
  "ingredient": { "item": "modid:ruby_block" },
  "result": { "id": "modid:ruby_bricks", "count": 4 }
}
```

### Campfire Cooking Recipe
```json
{
  "type": "minecraft:campfire_cooking",
  "ingredient": { "item": "modid:raw_ruby_meat" },
  "result": { "id": "modid:cooked_ruby_meat", "count": 1 },
  "experience": 0.35,
  "cookingtime": 600
}
```

## Version-Specific Format

| Version | Key value format |
|---------|-----------------|
| 1.21.2+ | `"key": {"#": "modid:ruby"}` (plain string) |
| 1.21.1- | `"key": {"#": {"item": "modid:ruby"}}` (object with item key) |
| All versions | `"result": {"id": "modid:...", "count": N}` |

## Common Recipe Patterns

| Pattern | Layout | Example |
|---------|--------|---------|
| 3×3 full | `["###","###","###"]` | 9 items → block |
| Helmet | `["###","# #"]` | 5 items |
| Chestplate | `["# #","###","###"]` | 8 items |
| Leggings | `["###","# #","# #"]` | 7 items |
| Boots | `["# #","# #"]` | 4 items |
| Sword | `["#","#","/"]` | 2 material + stick |
| Pickaxe | `["###"," / "," / "]` | 3 material + 2 sticks |
| Axe | `["##","#/"," /"]` | 3 material + 2 sticks |
| Shovel | `["#","/","/"]` | 1 material + 2 sticks |
| Hoe | `["##"," /"," /"]` | 2 material + 2 sticks |

## Custom Recipe Types (Advanced)

For complex machines like Farmer's Delight cooking pot:

```java
// common/crafting/<Name>Recipe.java
public class CookingRecipe implements Recipe<SimpleInventory> {
    // Custom recipe matching logic
}

// common/registry/ModRecipeTypes.java
public static final RecipeType<CookingRecipe> COOKING =
    RecipeType.register("modid:cooking");

// common/registry/ModRecipeSerializers.java
public static final RecipeSerializer<CookingRecipe> COOKING_SERIALIZER =
    RecipeSerializer.register("modid:cooking", new CookingRecipe.Serializer());
```

This requires: Recipe class + Type registration + Serializer + matching JSON recipe files.

## Auto-Generated Files

| Recipe Type | Files |
|------------|-------|
| Shaped/Shapeless | `data/MODID/recipe/<name>.json` |
| Smelting/Blasting | `data/MODID/recipe/<name>_smelting.json` |
| Smithing | `data/MODID/recipe/<name>_smithing.json` |
| Custom type | Recipe.java + Serializer.java + recipe JSON + ModRecipeTypes.java + ModRecipeSerializers.java |

## Common Mistakes

| Symptom | Fix |
|---------|-----|
| "Couldn't parse data file" | 1.21.2+ uses plain strings for key values |
| Pattern doesn't match in game | Check pattern dimensions — each string must be same length |
| Shapeless doesn't work | Use `"ingredients": [...]` not `"key": {...}` |
| Recipe doesn't show in recipe book | Add advancement JSON for recipe unlock |
