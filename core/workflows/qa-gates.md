# QA Gates Workflow

Use this workflow to verify ModFactory outputs before claiming completion.

## Gate Stack

1. Contract shape.
   - Required fields exist.
   - IDs and paths are valid.
   - References point to expected contracts or artifacts.
   - Run `scripts\validate-contract.ps1` for supported contract files.

2. Resource closure.
   - Registered content has required assets and data files.
   - Entity, item, block, recipe, loot, lang, model, and texture links close.

3. Provenance closure.
   - Source-sensitive assets record source and transform.
   - Vanilla-derived assets preserve dimensions, alpha, and silhouette.
   - Entity UV sheets preserve dimensions, alpha, and UV layout.

4. Build or package.
   - Project compiles.
   - Resources process.
   - No packaging errors.

5. Runtime startup.
   - Client/server launches.
   - Resource reload succeeds.
   - No crash reports or fatal log errors.

6. Behavior QA.
   - Feature works in-game.
   - Progression is reachable.
   - Combat or machine behavior matches design.
   - Animations trigger under correct runtime events.

7. Modpack launch matrix when applicable.
   - Empty launch.
   - World creation.
   - Conflict scenarios.
   - Performance.
   - Multiplayer or dedicated server.

## QA Report

Record verification evidence in `qa.report.json` or a markdown equivalent:

- target id
- commands run
- exit codes
- evidence summary
- manual findings
- open risks

When using `qa.report.json`, validate it with:

```powershell
powershell -NoProfile -File scripts\validate-contract.ps1 -ContractPath path\to\qa.report.json
```

## Completion Rule

Do not claim completion without QA evidence. If a gate was skipped, state why and record the residual risk.
