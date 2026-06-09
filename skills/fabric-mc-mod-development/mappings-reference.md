# Yarn ↔ Mojang Mapping Reference

Complete API name mapping table for Minecraft 1.21.x.

## Package Prefixes

| Package | Yarn | Mojang |
|---------|------|--------|
| Items | `net.minecraft.item.*` | `net.minecraft.world.item.*` |
| Blocks | `net.minecraft.block.*` | `net.minecraft.world.level.block.*` |
| Registry | `net.minecraft.registry.*` | `net.minecraft.core.registries.*` + `net.minecraft.resources.*` |
| Util | `net.minecraft.util.*` | `net.minecraft.resources.*` (Identifier → ResourceLocation) |
| World | `net.minecraft.world.*` | `net.minecraft.world.level.*` |

## Core Classes

| Yarn | Mojang |
|------|--------|
| `net.minecraft.item.Item` | `net.minecraft.world.item.Item` |
| `net.minecraft.item.Items` | `net.minecraft.world.item.Items` |
| `net.minecraft.item.Item.Settings` | `net.minecraft.world.item.Item.Properties` |
| `net.minecraft.item.ItemGroups` | `net.minecraft.world.item.CreativeModeTabs` |
| `net.minecraft.item.BlockItem` | `net.minecraft.world.item.BlockItem` |
| `net.minecraft.block.Block` | `net.minecraft.world.level.block.Block` |
| `net.minecraft.block.Blocks` | `net.minecraft.world.level.block.Blocks` |
| `net.minecraft.block.AbstractBlock` | `net.minecraft.world.level.block.state.BlockBehaviour` |
| `net.minecraft.block.AbstractBlock.Settings` | `net.minecraft.world.level.block.state.BlockBehaviour.Properties` |
| `net.minecraft.util.Identifier` | `net.minecraft.resources.ResourceLocation` |
| `net.minecraft.util.ActionResult` | `net.minecraft.world.InteractionResult` |
| `net.minecraft.registry.RegistryKey` | `net.minecraft.resources.ResourceKey` |
| `net.minecraft.registry.RegistryKeys` | `net.minecraft.core.registries.Registries` |
| `net.minecraft.registry.Registry` | `net.minecraft.core.Registry` |
| `net.minecraft.registry.tag.TagKey` | `net.minecraft.tags.TagKey` |
| `net.minecraft.registry.tag.BlockTags` | `net.minecraft.tags.BlockTags` |

## Equipment & Armor

| Yarn | Mojang |
|------|--------|
| `net.minecraft.item.equipment.ArmorMaterial` | `net.minecraft.world.item.equipment.ArmorMaterial` |
| `net.minecraft.item.equipment.EquipmentType` | `net.minecraft.world.item.equipment.EquipmentType` |
| `net.minecraft.item.equipment.EquipmentAsset` | `net.minecraft.world.item.equipment.EquipmentAsset` |
| `net.minecraft.item.equipment.EquipmentAssetKeys` | `net.minecraft.world.item.equipment.EquipmentAssets` |
| `net.minecraft.item.equipment.ArmorMaterials` | `net.minecraft.world.item.equipment.ArmorMaterials` |

## Tool Classes

| Yarn | Mojang | Status |
|------|--------|--------|
| `net.minecraft.item.ToolMaterial` | `net.minecraft.world.item.ToolMaterial` | Record class |
| `net.minecraft.item.SwordItem` | — | REMOVED in 1.21 |
| `net.minecraft.item.PickaxeItem` | — | REMOVED in 1.21 |
| `net.minecraft.item.AxeItem` | `net.minecraft.world.item.AxeItem` | Still exists |
| `net.minecraft.item.ShovelItem` | `net.minecraft.world.item.ShovelItem` | Still exists |
| `net.minecraft.item.HoeItem` | `net.minecraft.world.item.HoeItem` | Still exists |

## Method Signatures

| Yarn | Mojang |
|------|--------|
| `Identifier.of("ns", "path")` | `ResourceLocation.fromNamespaceAndPath("ns", "path")` |
| `RegistryKey.of(RegistryKeys.ITEM, id)` | `ResourceKey.create(Registries.ITEM, id)` |
| `Items.register(key, factory, settings)` | `BuiltInRegistries.ITEM.register(key, factory, settings)` or `Items.registerItem()` |
| `Item.Settings.food(FoodComponent)` | `Item.Properties.food(FoodProperties)` |
| `Item.Settings.armor(mat, type)` | `Item.Properties.humanoidArmor(mat, type)` |
| `Item.Settings.sword(mat, dmg, spd)` | `Item.Properties.sword(mat, dmg, spd)` |
| `EquipmentAssetKeys.register("name")` | `EquipmentAssets.register("name")` |

## Sound Events

| Yarn | Mojang |
|------|--------|
| `SoundEvents.ITEM_ARMOR_EQUIP_DIAMOND` | Same in both |

## Food Component

| Yarn | Mojang |
|------|--------|
| `net.minecraft.component.type.FoodComponent` | `net.minecraft.world.food.FoodProperties` |
| `new FoodComponent.Builder().nutrition(8).saturationModifier(1.2F).build()` | `new FoodProperties.Builder().nutrition(8).saturationModifier(1.2F).build()` |

## Key Differences Summary

1. **Yarn uses `net.minecraft.item.*`** while Mojang uses `net.minecraft.world.item.*` for items
2. **Yarn `RegistryKey`** = Mojang `ResourceKey` — very different naming
3. **Yarn `RegistryKeys`** = Mojang `Registries` — constants holder
4. **Yarn `Identifier`** = Mojang `ResourceLocation`
5. **Yarn `Item.Settings`** = Mojang `Item.Properties`
6. **ToolMaterial is a Record** in both mappings (1.21+), not an interface
7. **SwordItem/PickaxeItem removed** in 1.21 — use `.sword()` and `.pickaxe()` on Settings
8. **EquipmentAssetKeys.register()** uses `Identifier.ofVanilla()` → namespace is `minecraft:`, not mod ID
