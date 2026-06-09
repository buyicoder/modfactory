---
name: fabric-mc-mod-development
description: Use when developing Minecraft mods with Fabric API and Yarn mappings, registering items/blocks/armor/tools, creating resource files (models/textures/recipes), or debugging mod compilation/runtime issues. Triggers on: Fabric, Minecraft mod, MC modding, Yarn mappings, gradle.properties minecraft_version.
---

# Fabric MC Mod Development

## Overview

Precise API patterns, file conventions, and common pitfalls for Fabric mod development with **Yarn mappings** on Minecraft 1.21+. Covers registration, resource files, and the critical differences between Yarn and Mojang mappings that cause most silent failures.

**CRITICAL: Always check which mappings the project uses.** Yarn and Mojang use entirely different package names for the same Minecraft classes.

## When to Use

```
Creating a new item/block/armor/tool? → Use Quick Templates below
Compilation error about missing packages? → Check mappings section
Armor doesn't render on player? → Check EquipmentAsset + texture layers
Tool doesn't work (hoe won't till)? → Use proper class (HoeItem, not Item)
Need resource file paths?    → Use Directory Conventions table
```

## Quick Templates

### Item Registration (1.21.2+ Yarn)

```java
// ModItems.java
public static final Item RUBY = register("ruby", Item::new, new Item.Settings());

public static Item register(String path, Function<Item.Settings, Item> factory, Item.Settings settings) {
    RegistryKey<Item> key = RegistryKey.of(RegistryKeys.ITEM, Identifier.of(MOD_ID, path));
    return Items.register(key, factory, settings);
}
```

### Block Registration (with auto BlockItem)

```java
// ModBlocks.java
public static final Block RUBY_BLOCK = register("ruby_block", Block::new,
    AbstractBlock.Settings.create().strength(5.0F, 6.0F).requiresTool());

public static Block register(String path, Function<AbstractBlock.Settings, Block> factory,
                              AbstractBlock.Settings settings) {
    RegistryKey<Block> blockKey = RegistryKey.of(RegistryKeys.BLOCK, Identifier.of(MOD_ID, path));
    Block block = Blocks.register(blockKey, factory, settings);
    // Auto-register BlockItem
    RegistryKey<Item> itemKey = RegistryKey.of(RegistryKeys.ITEM, Identifier.of(MOD_ID, path));
    Items.register(itemKey, s -> new BlockItem(block, s), new Item.Settings());
    return block;
}
```

### Armor Registration

```java
// RubyArmorMaterial.java — ToolMaterial is a Java Record, NOT an interface!
public static final RegistryKey<EquipmentAsset> ASSET_KEY =
    RegistryKey.of(EquipmentAssetKeys.REGISTRY_KEY, Identifier.of(MOD_ID, "ruby"));
    // NOT EquipmentAssetKeys.register("ruby") — that puts it in minecraft: namespace!

public static final ArmorMaterial INSTANCE = new ArmorMaterial(
    37, Map.of(EquipmentType.HELMET,3, EquipmentType.CHESTPLATE,8,
               EquipmentType.LEGGINGS,6, EquipmentType.BOOTS,3, EquipmentType.BODY,11),
    15, SoundEvents.ITEM_ARMOR_EQUIP_DIAMOND, 2.0F, 0.0F,
    RubyToolMaterial.RUBY_REPAIR, ASSET_KEY);

// ModItems.java — use Item::new with .armor(), not ArmorItem class
public static final Item RUBY_HELMET = register("ruby_helmet", Item::new,
    new Item.Settings().armor(RubyArmorMaterial.INSTANCE, EquipmentType.HELMET));
```

### Tool Registration — Use correct classes!

```java
// Sword + Pickaxe: use Item.Settings methods (1.21+)
public static final Item RUBY_SWORD   = register("ruby_sword", Item::new,
    new Item.Settings().sword(RubyToolMaterial.INSTANCE, 3.0F, -2.4F));
public static final Item RUBY_PICKAXE = register("ruby_pickaxe", Item::new,
    new Item.Settings().pickaxe(RubyToolMaterial.INSTANCE, 1.0F, -2.8F));

// Axe + Shovel + Hoe: MUST use dedicated classes for right-click behavior!
public static final Item RUBY_AXE    = register("ruby_axe",
    s -> new AxeItem(RubyToolMaterial.INSTANCE, 5.0F, -3.0F, s), new Item.Settings());
public static final Item RUBY_SHOVEL = register("ruby_shovel",
    s -> new ShovelItem(RubyToolMaterial.INSTANCE, 1.5F, -3.0F, s), new Item.Settings());
public static final Item RUBY_HOE    = register("ruby_hoe",
    s -> new HoeItem(RubyToolMaterial.INSTANCE, -3.0F, 0.0F, s), new Item.Settings());
```

### ToolMaterial — Record, not Interface!

```java
// 1.21+: ToolMaterial is a Java Record — construct directly
public static final ToolMaterial INSTANCE = new ToolMaterial(
    BlockTags.INCORRECT_FOR_DIAMOND_TOOL,  // incorrectBlocksForDrops
    1561,   // durability
    10.0F,  // speed
    4.0F,   // attackDamageBonus
    15,     // enchantmentValue
    RUBY_REPAIR_TAG                        // repairItems TagKey<Item>
);
```

## Directory Conventions

```
src/main/resources/assets/MODID/
├── items/                    ← 1.21.4+ item model mapping JSON
├── models/
│   ├── block/                ← Block 3D models
│   └── item/                 ← Item display models
├── blockstates/              ← Block state → model mapping
├── textures/
│   ├── item/                 ← Item icons (16x16 PNG)
│   ├── block/                ← Block textures (16x16 PNG)
│   └── entity/equipment/
│       ├── humanoid/         ← Armor upper body (64x32 PNG)
│       └── humanoid_leggings/← Armor leggings (64x32 PNG)
├── equipment/                ← Equipment asset JSON
└── lang/                     ← en_us.json / zh_cn.json

src/main/resources/data/MODID/
├── recipe/                   ← Crafting recipes
└── tags/item/                ← Custom item tags
```

## Yarn vs Mojang Mappings (Critical!)

Always verify which mappings the project uses (`build.gradle` → `mappings` field).

| Yarn (`net.fabricmc:yarn`) | Mojang (`loom.officialMojangMappings()`) |
|---|---|
| `net.minecraft.item.Item` | `net.minecraft.world.item.Item` |
| `net.minecraft.item.Items` | `net.minecraft.world.item.Items` |
| `net.minecraft.item.ItemGroups` | `net.minecraft.world.item.CreativeModeTabs` |
| `net.minecraft.util.Identifier` | `net.minecraft.resources.ResourceLocation` |
| `Identifier.of("ns","path")` | `ResourceLocation.fromNamespaceAndPath("ns","path")` |
| `net.minecraft.registry.RegistryKey` | `net.minecraft.resources.ResourceKey` |
| `net.minecraft.registry.RegistryKeys` | `net.minecraft.core.registries.Registries` |
| `Item.Settings` | `Item.Properties` |
| `AbstractBlock.Settings` | `BlockBehaviour.Properties` |
| `EquipmentAssetKeys` | `EquipmentAssets` |

**For full mapping reference, see mappings-reference.md**

## Equipment Asset System (Armor Textures)

### Required files for armor rendering:

```
equipment/<name>.json     ← Defines texture layers
textures/entity/equipment/humanoid/<name>.png           ← Upper body (64x32)
textures/entity/equipment/humanoid_leggings/<name>.png  ← Leggings (64x32)
```

### equipment JSON format:
```json
{ "layers": {
    "humanoid": [{"texture": "MODID:name"}],
    "humanoid_leggings": [{"texture": "MODID:name"}]
}}
```

### Common Pitfall:
`EquipmentAssetKeys.register("ruby")` internally calls `Identifier.ofVanilla("ruby")` — the key is `minecraft:ruby`, NOT `modid:ruby`. The JSON file at `assets/MODID/equipment/ruby.json` won't match. **Always use:**
```java
RegistryKey.of(EquipmentAssetKeys.REGISTRY_KEY, Identifier.of(MOD_ID, "ruby"))
```

## Recipe JSON

### Shaped:
```json
{"type":"minecraft:crafting_shaped","pattern":["###","###","###"],
 "key":{"#":"modid:ruby"},"result":{"id":"modid:ruby_block","count":1}}
```
Key values in 1.21.2+ are plain strings (`"modid:ruby"`), not objects (`{"item":"modid:ruby"}`).

### Shapeless:
```json
{"type":"minecraft:crafting_shapeless",
 "ingredients":["modid:ruby_block"],"result":{"id":"modid:ruby","count":9}}
```

## Tool Functionality Tags

Tools need item tags for proper behavior. Create in `data/minecraft/tags/item/`:

```
swords.json    → values: ["modid:ruby_sword"]
pickaxes.json  → values: ["modid:ruby_pickaxe"]
axes.json      → values: ["modid:ruby_axe"]
shovels.json   → values: ["modid:ruby_shovel"]
hoes.json      → values: ["modid:ruby_hoe"]
```

Without these, tools won't till soil / strip logs / flatten paths / get enchantments.

## Creative Inventory

```java
ItemGroupEvents.modifyEntriesEvent(ItemGroups.INGREDIENTS).register(entries -> {
    entries.add(ModItems.RUBY);    // entries.add(), not entries.accept()
});
```

Group constants: `ItemGroups.INGREDIENTS`, `BUILDING_BLOCKS`, `FOOD_AND_DRINK`, `TOOLS`, `COMBAT`

## Common Mistakes

| Symptom | Cause | Fix |
|---------|-------|-----|
| `package net.minecraft.item does not exist` | Using Mojang imports in Yarn project | Check mappings, use correct imports |
| Armor not rendering on player | `EquipmentAssetKeys.register()` namespace bug | Use `RegistryKey.of(REGISTRY_KEY, Identifier.of(MOD_ID, ...))` |
| Armor missing leggings layer | Only created `humanoid/` texture, missing `humanoid_leggings/` | Create both texture layers |
| Hoe doesn't till dirt | Using `Item::new` with `.hoe()` instead of `HoeItem` class | Use `s -> new HoeItem(...)` |
| Axe doesn't strip logs | Same — need `AxeItem` class | Use `s -> new AxeItem(...)` |
| `Item.Factory does not exist` | Yarn doesn't have `Item.Factory` inner class | Use `Function<Item.Settings, Item>` |
| `ToolMaterial` needs interface | 1.21 ToolMaterial is a Record | Construct directly with `new ToolMaterial(...)` |
| Recipe JSON parse error | Using `{"item":"..."}` format in 1.21.2+ | Use plain string values |
| `Identifier.of does not exist` | Mojang mapping uses `ResourceLocation` | Yarn: `Identifier.of(ns,path)`, Mojang: `ResourceLocation.fromNamespaceAndPath()` |

## GearFactory Integration

When the project has `forge_engine/` available, use it to generate colored equipment textures:

```powershell
.\forge_engine\forge.ps1 -PaletteName ruby           # Generate ruby set
.\forge_engine\forge.ps1 -Shape aura -PaletteName inferno  # Legendary style
.\forge_engine\forge.ps1 -ListPalettes               # Show 20 palettes
.\forge_engine\forge.ps1 -ListShapes                 # Show shape sources
```

Output goes to both `forge_engine/output/<palette>/` (library) and `src/main/resources/assets/modid/textures/` (project).
