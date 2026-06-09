---
name: loot-generator
description: Use when the user needs loot tables for block drops, entity drops, chest loot, or custom loot functions. Triggers on: "add loot table", "create drop", "what does it drop", "loot", "drops", or dispatched by mc-mod-master when generating blocks or entities.
---

# Loot Generator

## Overview

Generates Minecraft loot table JSONs for block drops, entity drops, chest loot, and custom loot functions.

## Loot Table Type Selection

```
What needs loot?
│
├── Block → BlockLootTableGenerator (drops when mined)
├── Entity → EntityLootTableGenerator (drops when killed)
├── Chest → ChestLootTableGenerator (structure loot)
├── Gift → GiftLootTableGenerator (cat/villager gift)
└── Fishing → FishingLootTableGenerator
```

## Quick Templates

### Block Drop (simple — silk touch aware)
```json
// data/MODID/loot_table/blocks/thunder_ore.json
{
  "type": "minecraft:block",
  "pools": [
    {
      "rolls": 1,
      "entries": [
        {
          "type": "minecraft:alternatives",
          "children": [
            {
              "type": "minecraft:item",
              "conditions": [
                {
                  "condition": "minecraft:match_tool",
                  "predicate": {
                    "predicates": {
                      "minecraft:enchantments": [
                        { "enchantment": "minecraft:silk_touch", "levels": { "min": 1 } }
                      ]
                    }
                  }
                }
              ],
              "name": "modid:thunder_ore"
            },
            {
              "type": "minecraft:item",
              "name": "modid:thunder_shard",
              "functions": [
                {
                  "function": "minecraft:set_count",
                  "count": { "type": "minecraft:uniform", "min": 1, "max": 3 }
                },
                {
                  "function": "minecraft:apply_bonus",
                  "enchantment": "minecraft:fortune",
                  "formula": "minecraft:ore_drops"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Entity Drop
```json
// data/MODID/loot_table/entities/thunder_golem.json
{
  "type": "minecraft:entity",
  "pools": [
    {
      "rolls": 1,
      "entries": [
        {
          "type": "minecraft:item",
          "name": "modid:thunder_shard",
          "functions": [
            {
              "function": "minecraft:set_count",
              "count": { "type": "minecraft:uniform", "min": 2, "max": 5 }
            },
            {
              "function": "minecraft:looting_enchant",
              "count": { "type": "minecraft:uniform", "min": 0, "max": 2 }
            }
          ]
        }
      ]
    },
    {
      "rolls": 1,
      "conditions": [
        {
          "condition": "minecraft:killed_by_player"
        }
      ],
      "entries": [
        {
          "type": "minecraft:item",
          "name": "modid:thunder_sword",
          "weight": 1
        }
      ]
    }
  ]
}
```

### Chest Loot (inject into vanilla chests)
```json
// data/MODID/loot_table/chests/inject/abandoned_mineshaft.json
{
  "type": "minecraft:chest",
  "pools": [
    {
      "rolls": { "type": "minecraft:uniform", "min": 1, "max": 3 },
      "entries": [
        {
          "type": "minecraft:item",
          "name": "modid:thunder_shard",
          "weight": 10,
          "functions": [
            {
              "function": "minecraft:set_count",
              "count": { "type": "minecraft:uniform", "min": 1, "max": 4 }
            }
          ]
        }
      ]
    }
  ]
}
```

## Loot Functions Reference

| Function | Purpose | Key Parameters |
|----------|---------|---------------|
| `set_count` | Set stack count | `count: {min, max}` |
| `looting_enchant` | Extra drops with Looting | `count: {min, max}` |
| `apply_bonus` | Fortune bonus | `enchantment`, `formula` |
| `set_damage` | Damaged item | `damage: {min, max}` |
| `set_nbt` | Set NBT tag | `tag: "{...}"` |
| `enchant_randomly` | Random enchantment | — |
| `explosion_decay` | Chance to destroy on explosion | — |
| `furnace_smelt` | Auto-smelt drop | — |

## Loot Conditions Reference

| Condition | Purpose |
|-----------|---------|
| `killed_by_player` | Only if player killed |
| `random_chance` | X% chance |
| `match_tool` | Only with specific tool |
| `survives_explosion` | Not if exploded |
| `entity_properties` | Entity-specific check |
| `weather_check` | Only in rain/thunder |

## Auto-Generated Files

| Loot Type | File Path |
|-----------|-----------|
| Block drop | `data/MODID/loot_table/blocks/<name>.json` |
| Entity drop | `data/MODID/loot_table/entities/<name>.json` |
| Chest inject | `data/MODID/loot_table/chests/<name>.json` |
| Gift | `data/MODID/loot_table/gameplay/hero_of_the_village/<name>.json` |

## Quick Rules

- **Ore blocks**: silk touch → drops itself; no silk touch → drops shards (1-3, fortune bonus)
- **Storage blocks**: always drops itself
- **Hostile mobs**: 0-2 base drops + looting bonus + rare item (1% chance)
- **Bosses**: guaranteed drops + rare item (100% if killed by player)
