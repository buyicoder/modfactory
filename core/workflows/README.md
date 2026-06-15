# ModFactory Workflow Index

Use this index to choose the right platform-neutral workflow before producing files.

## Workflow Selector

| User Intent | Mode | Read Next |
|---|---|---|
| "Make a complete mod", "design a game loop", "create an RPG/tech/magic experience" | Original Design Mode | `experience-direction.md` |
| "Add one item/block/entity/system" | Focused Mod Mode | relevant domain workflow, then `qa-gates.md` |
| "Create or fix a custom mob/entity" | Focused Mod Mode or Original Design Mode | `entity-production.md` |
| "Build a modpack from existing mods" | Modpack Author Mode | `modpack-authoring.md` |
| "Check conflicts, launch failures, mod compatibility" | Modpack Author Mode | `modpack-authoring.md`, then `qa-gates.md` |
| "Verify this is complete" | Any mode | `qa-gates.md` |

## Required Pre-Reads

Before using a workflow, read:

1. `../positioning.md`
2. `../architecture.md`
3. `../contracts.md`
4. `../specialists/registry.md`

## Selection Rules

- If the request defines a player fantasy or progression arc, start with Experience Direction.
- If the request is a narrow feature with known scope, use Focused Mod Mode.
- If existing mods are part of the solution, use Modpack Authoring.
- If assets are source-sensitive, require asset provenance before production.
- If runtime behavior matters, include QA Gates from the start.

## Output Rule

Every workflow should end with either:

- generated or updated artifacts plus QA evidence, or
- a documented blocker with missing inputs, skipped gates, and residual risk.
