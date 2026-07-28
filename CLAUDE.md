# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

Roadmap **Phases 0 through 4 are done in code**. Phase 0: Flutter project scaffolded (Android only, org `com.extremefocus`), theme (light/dark), Riverpod wiring, l10n skeleton (es/en). Phase 1: `lib/features/game/domain/` is a complete, pure-Dart game engine (SRS rotation + wall kicks, 7-bag, board/line-clear, T-Spin detection, scoring, level curve, hold, hard drop, the lock→resolve→spawn pipeline). Phase 2: `lib/features/game/presentation/` renders it — a `CustomPainter` board (with ghost piece), a `GameController` Riverpod notifier driving gravity/lock-delay off a widget-owned `Ticker`, next-queue/hold widgets, touch controls (DAS/ARR, held soft drop, single-tap rotate/hold/hard-drop). Phase 3: `AudioService`/`HapticService` wired to every game event via a `LockResult` (`{state, outcome}`) that `LockActivePiece.call`/`HardDrop.call` return instead of plain `GameState` — check that signature before touching either use case. Phase 4: real Splash/Home/Settings/Statistics/About screens and `go_router` navigation (`createAppRouter()` — see the important note below), with Pause/Game Over as overlays inside `GameScreen`, not routes.

All five phases pass `flutter analyze`/`flutter test` (73 tests, including 4 real navigation widget tests in `test/widget/navigation_test.dart`). Phases 0–2 were additionally verified live on an Android emulator; **Phases 3 and 4 were not** — touch input on the emulator broke at the system level partway through Phase 3's testing (not this codebase's fault: even tapping launcher icons stopped working, and it survived an `adb` restart, force-stop, and a full cold-boot-without-snapshot). Get a live device/emulator confirmation of Phases 3–4 before trusting them beyond what the automated tests cover.

`AGENT.md`'s "Estado del repositorio" has full file-by-file detail. Things worth knowing before touching this code:
- Domain entities are hand-written immutable classes, not `freezed` (Phase 1).
- Starting a game (or anything that mutates provider state) from a widget's `initState` must be deferred (e.g. `Future.microtask`), or Riverpod throws (Phase 2).
- **`createAppRouter()` in `core/routing/app_router.dart` is a factory, not a top-level singleton** — `ExtremeFocusTetrisApp` (a `ConsumerStatefulWidget`) builds one instance in a `late final` field of its `State`. Making it a global singleton again would leak navigation location across widget tests run in the same process (this actually happened and broke 2 of the 4 navigation tests until fixed).
- Never call `ref.read(...)` inside a `State.dispose()` — Riverpod forbids reading a provider after its element is disposed, and during a full widget-tree teardown `dispose()` can run after that point. Capture whatever you need (e.g. a service instance) in `initState` instead. This was a real bug in `GameScreen.dispose()`, caught by the navigation widget tests.
- The bundled `.ogg` audio assets are synthesized placeholder tones for wiring purposes, not final sound design.
- A `GameScreen`'s `Ticker` runs indefinitely — widget tests touching it must use bounded `tester.pump(duration)` instead of `pumpAndSettle()`, and unmount the tree at the end (`tester.pumpWidget(const SizedBox.shrink())`) so `dispose()` stops the ticker before the test ends.

Everything under `lib/features/game/data/`, other features' `data/domain` layers beyond what Settings/Statistics needed for their in-memory placeholders, and Hive persistence (`core` services for it, all three boxes) doesn't exist yet — that's Phase 5.

- **`spec.md`** — the complete functional and technical specification (Specification Driven Development). This is the **single source of truth** for the project: architecture, art direction, gameplay rules, screens, dependencies, roadmap, requirements, and acceptance criteria. Any implementation decision must trace back to it; if something isn't specified there, treat it as out of scope for v1.0.
- **`AGENT.md`** — a condensed, actionable operational summary of `spec.md` (commands, architecture cheat-sheet, non-negotiable constraints, key technical decisions, roadmap-phase-to-agent-role mapping) meant for AI coding agents. Read it first for day-to-day work; fall back to `spec.md` for full detail or when something is ambiguous.

If `spec.md` and this file ever disagree, `spec.md` wins — update it first, then bring this file and `AGENT.md` in line.

## What this project is

**Extreme Focus Tetris**: a personal-use Android app (Flutter/Dart) that reframes Tetris as a deep-focus concentration tool. No ads, no IAP, no accounts, no network access, no telemetry, no background music — see `spec.md` sections 1–2 for the full product philosophy.

## Non-negotiable constraints

- **Zero network**, even on first launch (e.g. fonts must be bundled as local assets, not fetched via `google_fonts`'s runtime mode).
- **Zero telemetry/ads/IAP/accounts** — no cloud analytics or crash-reporting SDKs.
- **No background music**, ever — only the ambient "tic-toc" loop + SFX.
- **No third-party physics engine** — movement is grid-based and deterministic; particle effects use a simple manual simulation.
- **60 FPS stable** and **playable within 5 seconds of launch** are acceptance requirements, not aspirations.
- Don't add out-of-scope features (multiplayer, backend, push notifications) without updating `spec.md` first.

## Commands

```bash
flutter pub get                                                    # install dependencies
flutter pub run build_runner build --delete-conflicting-outputs    # codegen (freezed, riverpod_generator, hive_generator)
flutter analyze                                                    # lint
flutter test                                                       # full unit + widget suite
flutter test test/unit/game/srs_rotation_test.dart                 # run a single test file
flutter test --plain-name "detecta T-Spin"                         # run a single test by name
flutter test integration_test/app_test.dart                        # integration test (device/emulator required)
flutter run                                                        # run on connected device/emulator
flutter build apk --obfuscate --split-debug-info=build/symbols     # release build
```

## Architecture (summary)

Clean Architecture + Feature-First + MVVM, with **Riverpod** for state management and as the DI container (see `spec.md` 3.1 for the justification vs. Provider/Bloc). Dependency rule: `presentation → domain ← data`; `domain` is pure Dart (no `package:flutter`, no Hive).

- `lib/core/` — theme, constants, routing (`go_router`), cross-cutting services (`AudioService`, `HapticService`, `GameTickerService`), root DI.
- `lib/features/<feature>/domain|data|presentation/` — one folder per feature: `game`, `settings`, `statistics`, `home`, `splash`, `game_over`, `about`.
- `lib/shared/widgets/` — widgets reused across features.

Full folder tree: `spec.md` section 3.4. Key technical decisions to respect when implementing (persistence via Hive with domain entities kept framework-agnostic, board rendered via a single `CustomPainter`/`RepaintBoundary` rather than a widget per cell, game loop driven by a decoupled `Ticker`, fixed-size `ParticlePool`, SRS rotation with the exact wall-kick tables, 7-bag piece generator, exact scoring/level tables): see the decision table in `AGENT.md` and `spec.md` section 8 (gameplay), 13 (persistence), 15–16 (performance/memory), 24 (dependencies).

## Testing

Unit tests for all `domain/game` logic (SRS rotation + wall kicks, collisions, line clears, T-Spin, Perfect Clear, scoring, level curve, 7-bag distribution) must exist from the first commit of the game engine (roadmap Phase 1), not bolted on later. Widget tests for HUD/Settings/controls, golden tests for board/HUD/Game Over in both themes, and an integration test for the full splash → game → pause → game over → resume flow round out the suite. Full strategy and the manual QA checklist: `spec.md` section 21.
