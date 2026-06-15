# ModFactory Generic Agent Adapter

Use this adapter for any AI agent, automation system, or human operator that can:

- read files
- write project files
- run commands
- inspect command output
- report verification evidence

## Startup Procedure

1. Read `core/README.md`.
2. Read `core/positioning.md` to choose Original Design Mode, Modpack Author Mode, Focused Mod Mode, or Hybrid.
3. Read `core/architecture.md` to understand module boundaries.
4. Read `core/contracts.md` to identify required artifacts.
5. Read `core/specialists/registry.md` to assign responsibilities.
6. Read `core/workflows/README.md` to choose the workflow.
7. Read the workflow that matches the request:
   - `core/workflows/experience-direction.md`
   - `core/workflows/entity-production.md`
   - `core/workflows/modpack-authoring.md`
   - `core/workflows/qa-gates.md`

## Execution Contract

The agent must:

- state which mode and workflow it selected
- list the required contracts or equivalent markdown artifacts
- create or update implementation files
- run feasible QA gates
- report commands, results, skipped gates, and open risks

## Platform Independence Rule

If an instruction depends on a specific runtime, put it in a platform adapter. If it defines how ModFactory thinks about Minecraft design, production, contracts, assets, or QA, put it in `core/`.
