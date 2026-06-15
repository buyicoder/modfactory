# Entity Production Workflow

Use this workflow for custom mobs, bosses, pets, mounts, and creature-like content.

## Goal

Produce entities whose mechanics, model, texture, animation, code, resources, and runtime behavior stay aligned.

## Steps

1. Define entity role.
   - Combat role.
   - Progression stage.
   - Spawn context.
   - Drops and resource purpose.
   - Boss bar or special mechanics.

2. Create or update `entity.contract.json`.
   - Entity id and display name.
   - Runtime dimensions.
   - Model parts.
   - Texture dimensions.
   - Spawn egg id.
   - Loot intent.
   - Required animation states.

3. Source assets.
   - Prefer official or existing project references when adapting vanilla-shaped content.
   - Export embedded Blockbench textures when available.
   - Record source provenance.

4. Produce visual assets.
   - Entity UV textures must preserve dimensions, alpha, and UV layout.
   - Vanilla-shaped item icons should be derived from vanilla/project sources.
   - Novel generation is allowed only when no source-equivalent exists or the creator requests a new shape.

5. Produce model and rig.
   - Match geometry to texture UV layout.
   - Preserve usable part names.
   - Record dimensions and Java model expectations.

6. Produce animations.
   - Record clips, lengths, loop flags, and runtime triggers.
   - One-shot clips need runtime states or events.

7. Implement runtime.
   - Entity registration and attributes.
   - AI goals and mechanics.
   - Renderer and model layer.
   - Spawn egg, loot, language, creative tab.
   - Animation trigger binding.

8. Verify.
   - Entity contract validation.
   - Project integrity check.
   - Build.
   - Runtime startup.
   - In-game visual and behavior QA.

## Acceptance Criteria

- Model and texture dimensions match.
- Renderer references the expected texture.
- Spawn egg resources and item registration close.
- Loot table or no-drop intent exists.
- Animation triggers work for player and mob interactions.
- Runtime QA verifies scale, texture, boss bar, drops, and combat behavior.
