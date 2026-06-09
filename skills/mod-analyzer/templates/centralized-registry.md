# Centralized Registry Pattern (Farmer's Delight style)

## When to Use
When your mod has 20+ items/blocks/entities that need clean organization and easy discoverability.

## Structure
```
common/registry/
├── ModItems.java          ← All item registration
├── ModBlocks.java         ← All block registration
├── ModBlockEntityTypes.java
├── ModEffects.java
├── ModEntityTypes.java
├── ModRecipeTypes.java
├── ModCreativeTabs.java
└── ModSounds.java
```

## Core Pattern

```java
// ModItems.java
public class ModItems {
    public static LinkedHashSet<Supplier<Item>> CREATIVE_TAB_ITEMS = Sets.newLinkedHashSet();

    // Registration with auto creative-tab addition
    public static Supplier<Item> registerWithTab(String name, Supplier<Item> supplier) {
        Supplier<Item> item = regItem(name, supplier);
        CREATIVE_TAB_ITEMS.add(item);
        return item;
    }

    // Each item = one line
    public static final Supplier<Item> KNIFE = registerWithTab("knife",
        () -> new KnifeItem(basicItem().stacksTo(1)));

    public static final Supplier<Item> COOKING_POT = registerWithTab("cooking_pot",
        () -> new CookingPotItem(ModBlocks.COOKING_POT.get(), basicItem().stacksTo(16)));
}
```

## Key Decisions
- **Supplier pattern**: Items are created lazily via `Supplier<Item>`, not eagerly as `static final Item`
- **Creative tab auto-add**: `registerWithTab()` adds to a set, later processed by `ModCreativeTabs`
- **One file per registry type**: 24 files in the registry package, each with one concern

## When NOT to Use
- Small mods (<10 items): Too much boilerplate. Use static init pattern instead.
- Need tight control over registration order: Supplier pattern adds complexity.
