# AGENTS.md

## Project
BOARD GAME SORTING GAME

Godot project based on an existing reusable game template.

The template already contains:
- save system;
- Steam addon / Steam integration;
- basic skill tree logic.

## Main rules for Codex

1. Read `docs/GDD.md` before implementing gameplay features.
2. Before changing an existing system, inspect how the template already implements it.
3. Reuse the existing save, Steam and skill-tree systems. Do not create parallel replacements unless reuse is impossible.
4. Do not refactor unrelated working code.
5. Prefer small, isolated changes over large rewrites.
6. Keep gameplay systems data-driven where practical.
7. Keep static content data separate from runtime/save state.
8. Important gameplay rules must have one source of truth. Do not duplicate reward, cooldown or placement logic across scripts.
9. Multiplayer should synchronize gameplay events/state, not continuously synchronize thousands of static boxes.
10. Host owns the save and authoritative world state.
11. Gameplay must work fully in solo. Co-op extends the same systems.
12. If implementation conflicts with the GDD, follow the GDD unless the user explicitly changes the design.
13. If the current architecture conflicts with a proposed implementation, document the conflict before making a large structural change.
14. After each task, update `docs/IMPLEMENTATION_PLAN.md`.
15. Keep `docs/SYSTEMS.md` up to date when architecture changes.

## Coding priorities

- Correctness.
- Simplicity.
- Reuse of existing template systems.
- Clear ownership of state.
- Easy save/load.
- Easy multiplayer synchronization.
- Easy expansion to thousands of box instances.

## Gameplay architecture priorities

Prefer central services/functions for:
- correct placement validation;
- first-placement reward;
- 30-second anti-abuse recharge rule;
- series completion;
- franchise completion;
- skill-point rewards;
- active-skill recharge;
- save-state changes.

Hand placement, thrown placement and future placement methods must call the same placement-resolution logic.

## Performance

The final game can contain several thousand boxes.

Avoid expensive per-frame logic on every box.

Prefer:
- event-driven state;
- sleeping/static physics when possible;
- disabled processing when not needed;
- stable IDs and compact state;
- deterministic/default initial placement where useful;
- synchronizing only moved/held/placed objects when possible.

## Multiplayer

Initial target:
- Steam Invite / Join Friend;
- players can join while the game is running;
- host owns the save;
- session ends if host leaves;
- shared skill tree and shared skill points;
- active-skill cooldowns are individual per player.

Do not add host migration unless explicitly requested.

## Documentation language

Project documentation may be in Russian.
Code identifiers should be clear and consistent in English unless the existing template uses another convention.
