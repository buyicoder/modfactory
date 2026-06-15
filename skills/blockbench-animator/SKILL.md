---
name: blockbench-animator
description: Use when creating, editing, or verifying Minecraft entity animations in Blockbench through MCP. Triggers on: "make animation", "walking animation", "idle/attack/hurt/death animation", "Blockbench animation", or dispatched by entity-designer/entity-generator after an entity model is open.
---

# Blockbench Animator

## Overview

Creates production-ready entity animations in the currently open Blockbench model through the Blockbench MCP server. Use this after the model/rig exists and before exporting the final entity assets.

In ModFactory architecture this skill serves the Animation service. Use `core/contracts.md`, `core/specialists/registry.md`, and `core/workflows/entity-production.md` as the source of truth for animation handoff. It produces clip metadata that Fabric Engineering must bind to runtime triggers. Animation work is incomplete if the clips exist but the trigger map is missing.

## Required Setup

Blockbench MCP is expected at:

```json
{
  "url": "http://localhost:3000/bb-mcp",
  "type": "http"
}
```

Before animating:

1. Confirm MCP `initialize` succeeds.
2. Call `list_outline` to read the real bone/group names.
3. Never assume names like `right_arm` or `left_leg`; use the names returned by Blockbench.
4. If no model is open, stop and ask the user to open/create the model first.

## Animation Workflow

1. Inspect the rig with `list_outline`.
2. Identify animation bones: body/root, head, arms, legs, wings, tail, or custom parts.
3. Propose the animation style if the user has not already approved it.
4. Use `create_animation` for new clips:
   - `name`: short action name, e.g. `walk`, `idle`, `attack_slam`
   - `loop`: `true` for ambient/repeating actions, `false` for one-shot actions
   - `animation_length`: seconds
   - `bones`: per-bone keyframes using `time`, `position`, `rotation`, and optionally `scale`
5. Use `manage_keyframes` for small edits to an existing clip.
6. Verify with read-only `risky_eval` after writing:
   ```javascript
   JSON.stringify((Animation.all || []).map(a => ({
     name: a.name,
     length: a.length,
     loop: a.loop,
     animatorCount: Object.keys(a.animators || {}).length,
     keyframeCount: Object.values(a.animators || {})
       .reduce((sum, anim) => sum + (anim.keyframes ? anim.keyframes.length : 0), 0)
   })))
   ```

## Default Mob Animation Set

For a normal walking mob, aim for these clips:

| Clip | Loop | Length | Purpose |
|------|------|--------|---------|
| `idle` | yes | `2.0-3.0s` | breathing, small head movement |
| `walk` | yes | `0.8-1.4s` | locomotion cycle |
| `attack_slam` or `attack_bite` | no | `0.5-1.0s` | main attack |
| `hurt` | no | `0.25-0.45s` | impact reaction |
| `death_collapse` | no | `1.2-2.0s` | death pose/collapse |
| `look_around` | yes/optional | `1.5-2.5s` | patrol/alert flavor |
| `spawn_wake` | no/optional | `1.0-1.5s` | summon or reveal animation |

## Heavy Golem Template

Use for iron-golem-like rigs with `body`, `head`, two arms, and two legs.

### Walk

- Length: `1.2s`, loop.
- Legs: opposite pitch swings around `22°`.
- Arms: smaller opposite pitch swings around `10°`.
- Body: slight vertical bob, about `0.3-0.4` units.
- Head: tiny nod, `1-2°`.

Keyframe rhythm:

```text
0.0s  left leg forward, right leg back
0.3s  neutral, body up
0.6s  left leg back, right leg forward
0.9s  neutral, body up
1.2s  same as 0.0s
```

### Idle

- Length: `2.5s`, loop.
- Body: gentle up/down movement `0.1-0.2`.
- Head: slow yaw `3-5°`, then return.
- Arms: near-still, only tiny settling motion.

### Attack Slam

- Length: `0.8s`, one-shot.
- Anticipation: weapon/attack arm pulls back, body leans back.
- Impact: arm snaps forward/down, body dips and leans forward.
- Recovery: return to neutral by the end.

### Hurt

- Length: `0.35s`, one-shot.
- Body and head recoil backward.
- Arms flare slightly outward.
- Return quickly; heavy mobs should not bounce.

### Death Collapse

- Length: `1.5-2.0s`, one-shot.
- Body loses balance and drops.
- Head lowers.
- Arms sag.
- Legs bend or trail to sell weight.

## Style Rules

- Match the creature's mass: heavy mobs use slower anticipation and less bounce; small mobs can use faster, larger arcs.
- Keep loops seamless: first and last keyframes must match for looped clips.
- Animate around bones/groups, not individual cubes, unless the model has no rig.
- Use degrees for rotation arrays `[x, y, z]`.
- Prefer readable action names that can map to code later: `animation.walk`, `animation.idle`, `animation.attack_slam`.

## Integration with Entity Pipeline

Use this skill after `entity-designer` defines the model/animation needs and before `entity-generator` wires runtime animation state.

```text
entity-designer
  -> blockbench-mcp model/texture work
  -> blockbench-animator animation clips
  -> export model/animation assets
  -> entity-generator runtime registration/rendering
```

Record the created clip names in the entity blueprint so code generation can bind states like walking, attacking, hurt, death, and spawn.

For contract shape and stable trigger names, see `core/contracts.md`.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Guessing bone names | Always call `list_outline` first |
| Loop pops at boundary | Make first and last keyframes identical |
| Too many dramatic motions | Scale movement to entity mass |
| Only creating `walk` | Add at least `idle`, `attack`, `hurt`, and `death` for a complete mob |
| Trusting create response only | Verify with read-only animation inspection |
| Using system/file APIs in `risky_eval` | Only inspect Blockbench state; do not touch the filesystem |
