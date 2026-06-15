# Modpack Authoring Workflow

Use this workflow when the creator wants to compose existing mods into a coherent pack.

## Goal

Replace manual trial-and-error with systematic mod discovery, compatibility analysis, integration planning, and launch QA.

## Steps

1. Define pack fantasy.
   - Player journey.
   - Core systems.
   - Minecraft version.
   - Loader.
   - Client/server target.

2. Discover candidate mods.
   - Record mod id, name, source, version, dependencies, side, features, configs, license notes, known risks.

3. Build feature coverage matrix.
   - Decide which mod owns each system: combat, tech, magic, worldgen, economy, quests, guide, performance.
   - Detect overlapping ownership.

4. Build compatibility graph.
   - Dependencies.
   - Optional dependencies.
   - Known incompatibilities.
   - Overlapping content.
   - Config coordination.
   - Performance risks.
   - Side mismatches.

5. Run conflict analysis.
   - Loader/version mismatch.
   - Missing dependencies.
   - Mixin or class transformation errors.
   - Registry collisions.
   - Duplicate ores/items/recipes/worldgen.
   - Tag conflicts.
   - Client/server split issues.

6. Produce resolution plan.
   - Remove or replace mod.
   - Pin version.
   - Add dependency.
   - Disable feature in config.
   - Add datapack/script.
   - Unify tags.
   - Split client/server lists.
   - Add small glue mod.

7. Produce integration plan.
   - Recipes.
   - Tags.
   - Loot tables.
   - Advancements.
   - Quest lines.
   - Configs.
   - Datapacks.
   - Scripts.
   - Resource pack overrides.

8. Run launch QA matrix.
   - Empty launch.
   - Core systems launch.
   - World creation.
   - Progression smoke test.
   - Conflict scenario test.
   - Performance pass.
   - Dedicated server pass if needed.

## Output

- `modpack.manifest.json` or equivalent.
- Compatibility graph.
- Conflict report.
- Integration plan.
- QA report.

## Guardrails

- Do not recommend manually testing every pair of mods.
- Do not generate custom replacements if existing mods satisfy the intended experience.
- Prefer config/datapack/script fixes before custom code when they solve the issue cleanly.
