# AGENT.md

Guía operativa para agentes de IA (Claude Code, Cursor, Aider, Copilot, etc.) que trabajen en este repositorio. Este archivo es un **resumen accionable**; la especificación completa y vinculante es [`spec.md`](./spec.md) — ante cualquier duda o conflicto, `spec.md` prevalece.

## Estado del repositorio

**Fase 0 (Setup y arquitectura base) completada.** El proyecto Flutter está scaffolded (Android only, org `com.extremefocus`), con `flutter analyze` y `flutter test` en verde y una corrida real confirmada en un emulador Android (Pixel 3a API 34). Lo que existe hoy:

- `lib/main.dart` / `lib/app.dart` — `ProviderScope` + `MaterialApp` con tema claro/oscuro y l10n wireados.
- `lib/core/constants/` — `app_dimens.dart`, `app_durations.dart`.
- `lib/core/theme/` — `app_colors.dart`, `app_text_styles.dart`, `app_theme_light.dart`, `app_theme_dark.dart`.
- `lib/core/di/providers.dart` — `ThemeModeController` y `LocaleController` (Riverpod, `@riverpod` codegen), en memoria hasta que la Fase 5 los respalde con Hive.
- `lib/core/l10n/` — ARB es/en + `AppLocalizations` generado (`l10n.yaml`).
- Dependencias fijadas en la generación 2.x de Riverpod (`flutter_riverpod`/`riverpod_annotation`/`riverpod_generator` — ver nota de versiones más abajo).

**Fase 1 (Motor de juego, dominio puro) completada.** `lib/features/game/domain/` es Dart puro (sin `package:flutter`, sin Hive) e incluye:

- `entities/`: `tetromino_type.dart`, `rotation_state.dart`, `grid_position.dart`, `tetromino_shapes.dart` (datos SRS de las 7 piezas), `srs_wall_kick_data.dart` (tablas JLSTZ e I ya convertidas de la convención (x,y) del spec a (row,col) — ver comentario en el archivo sobre el flip de signo), `tetromino.dart`, `board.dart` (grid tipado `List<int>`, 10×22), `game_state.dart`, `game_status.dart`, `t_spin_type.dart`, `line_clear_outcome.dart`, `seven_bag_generator.dart`.
- `usecases/`: `move_piece.dart`, `rotate_piece.dart`, `hold_piece.dart`, `hard_drop.dart`, `lock_active_piece.dart` (pipeline Locking→Resolving→LineClear→Spawning), `resolve_line_clears.dart`, `detect_tspin.dart`, `calculate_score.dart`, `level_curve.dart`, `start_new_game.dart`.
- **Decisión de diseño (ajuste sobre lo previsto):** el dominio usa clases inmutables escritas a mano (`copyWith` manual), **no `freezed`**, para esta fase. `Board` necesita un array tipado (`List<int>`, spec.md §16) con el que `freezed` no combina bien, y por consistencia el resto de entidades siguen el mismo estilo. `freezed` sigue siendo válido para fases futuras (p. ej. DTOs de Hive en la Fase 5) si conviene ahí — no se agregó como dependencia todavía (YAGNI).
- **Gap de spec corregido:** la tabla de puntaje (`spec.md` §8.5) no tenía filas para T-Spin Mini Single/Double (200×nivel / 400×nivel), que sí ocurren en juego real — se agregaron.
- **Testing:** `test/unit/game/` cubre rotación SRS + wall kicks, colisiones/clear de líneas de `Board`, detección de T-Spin (full/mini/none), 7-bag (permutación + gap máximo de 12 piezas), curva de nivel/velocidad (incluyendo tope de Modo Concentración), scoring completo (combo, back-to-back, perfect clear, soft/hard drop), hold, y el pipeline hard-drop→lock→resolve→spawn (incluye game over). 65 tests, todos en verde; `flutter analyze` sin issues.

**Fase 2 (Renderizado e input) completada.** Verificado de punta a punta en el emulador Android (build, HUD, gravedad, ghost piece, stack, Game Over).

- `lib/core/services/game_ticker_service.dart` — wrapper de `Ticker` (requiere un `vsync` de un widget; el service en sí es agnóstico de widget).
- `lib/features/game/presentation/viewmodels/game_controller.dart` — `Notifier<GameState?>` (Riverpod codegen) que orquesta gravedad (según `LevelCurve`, con multiplicador ×20 mientras se mantiene soft drop), el presupuesto de lock delay (500ms, tope de 15 resets ya validado por el dominio), y delega cada acción a los use cases de la Fase 1. `focusMode` es un campo simple en memoria por ahora (se conectará a Settings en fases futuras).
- `lib/features/game/presentation/widgets/`: `board_painter.dart` (`CustomPainter` de una sola pasada: grid + celdas fijas + ghost + pieza activa, `shouldRepaint` por identidad de `GameState`), `tetromino_colors.dart` (mapeo color↔tipo compartido), `next_queue_widget.dart`, `hold_widget.dart`, `touch_controls.dart` (DAS 170ms/ARR 30ms en izquierda-derecha, soft drop como "press and hold", rotar/hold/hard-drop de un solo tap).
- `lib/features/game/presentation/game_screen.dart` — `ConsumerStatefulWidget` con `SingleTickerProviderStateMixin` que arranca partida y ticker.
- **Adiciones al dominio que exigió esta fase:** `MovePiece.gravityStep` (caída automática sin puntaje, distinta de `softDrop`) y `HardDrop.ghostPiece` (posición de aterrizaje sin mutar estado, reutilizando la lógica de `HardDrop.call`). Ambas con tests nuevos en `test/unit/game/`.
- **Bug real encontrado y corregido en el emulador:** llamar `startNewGame()` directamente en `initState()` viola la regla de Riverpod de no modificar un provider mientras el árbol de widgets está construyéndose (`Tried to modify a provider while the widget tree was building`). Se resolvió difiriendo la llamada con `Future.microtask(...)`. Si se agregan más pantallas que arrancan un provider al montar, replicar este patrón (o usar `ref.listenManual`/`addPostFrameCallback`).
- Acceso temporal: `_HomePlaceholder` en `app.dart` tiene un botón "Jugar (debug)" con `Navigator.push` directo a `GameScreen` — se reemplaza por la navegación real de `go_router` en la Fase 4.
- **Testing:** 69 tests en verde (65 de la Fase 1 + 4 nuevos), `flutter analyze` sin issues.

**Fase 3 (Audio y háptica) completada en código; verificación en emulador bloqueada por el entorno (ver nota abajo).**

- `assets/audio/ambient/tic_toc_loop.ogg` + `assets/audio/sfx/*.ogg` (13 archivos) — generados con `ffmpeg` (tonos sintetizados simples) como **placeholders funcionales para poder cablear e integrar el `AudioService` real**; no son diseño de sonido final. Reemplazar cuando exista un Game/Sound Designer real trabajando el carácter sonoro de spec.md §6. El script que los generó no se conserva en el repo (fue un script de un solo uso en el scratchpad de la sesión); si hace falta regenerarlos, cualquier tono corto en .ogg sirve como placeholder mientras tanto.
- `lib/core/services/audio_service.dart` — `SfxEvent` enum (13 valores → 13 assets), un `AudioPlayer` dedicado al loop ambiental (`ReleaseMode.loop`) + pool round-robin de 4 para SFX solapables, volumen independiente ambiente/SFX, toggle general.
- `lib/core/services/haptic_service.dart` — `HapticFeedback` nativo mapeado 1:1 a la tabla de spec.md §6.4 (sin el paquete `vibration`).
- `lib/core/di/providers.dart` — `audioServiceProvider`/`hapticServiceProvider`, ambos `@Riverpod(keepAlive: true)` (deben sobrevivir aunque nada los esté observando).
- `GameController` dispara sonido+háptica en cada acción exitosa (move/rotate/hold) y en el resultado de cada bloqueo (línea/T-Spin/nivel/game over) vía el nuevo tipo `LockResult` (`{state, outcome}`) que ahora devuelven `LockActivePiece.call` y `HardDrop.call` — antes devolvían solo `GameState`; si tocas esos dos use cases, ten presente esta firma.
- `GameScreen` observa `AppLifecycleState` (`WidgetsBindingObserver`) para pausar/reanudar el loop ambiental en segundo plano, por spec.md §6.2.
- **Bug real encontrado y corregido antes de siquiera llegar al emulador:** en el primer borrador de `hardDrop()` en `GameController` se llamaba `LockActivePiece.call` una segunda vez sobre el resultado de `HardDrop.call` (que ya bloquea internamente) — habría bloqueado instantáneamente la pieza siguiente también. Detectado por inspección de código antes de correr nada.
- Configuración/volumen (activar sonido, volumen ambiente/SFX, vibración) vivía en Fase 3 solo como campos mutables en los servicios; la Fase 4 le agregó un `SettingsController` real y una pantalla — ver más abajo. Persistencia real llega en la Fase 5 (Hive).
- **Testing:** `flutter analyze`/`flutter test` siguen en verde (69 tests); no se agregaron tests unitarios para `AudioService`/`HapticService` en sí (dependen de plugins de plataforma vía method channels — mockearlos con sentido pertenece a la Fase 9, no a esta).

### Nota: verificación visual en emulador bloqueada (entorno, no código)

Al probar la Fase 3 en el emulador Android, el input táctil (`adb shell input tap`/`swipe`) dejó de llegar a la app — confirmado que **no es un bug de este proyecto**: ni siquiera gestos a nivel de sistema (abrir la bandeja de notificaciones, tocar un ícono del launcher) funcionaban, incluso después de reiniciar `adb`, forzar el cierre de la app, y hacer un **cold boot completo del emulador sin snapshot** (`emulator -no-snapshot-load`). `flutter analyze` y los 69 tests automatizados sí pasan. Antes de continuar a la Fase 4, alguien debe: (a) probar en un emulador nuevo/dispositivo físico, o (b) revisar la configuración de aceleración gráfica/input del AVD `Pixel_3a_API_34_extension_level_7_arm64-v8a`. No asumir que el código de audio/háptica está "sin probar en dispositivo real" — sí lo está, solo que no pudo confirmarse visualmente en esta sesión.

**Actualización (Fase 8, cold boot posterior):** el mismo AVD, en una sesión posterior, arrancó con input táctil funcionando normalmente (confirmado con una captura real del swipe abriendo la bandeja de notificaciones antes de instalar nada) — el bloqueo de la Fase 3 fue puntual a esa sesión/imagen del emulador, no un problema estructural del proyecto ni del AVD en sí. Dos notas operativas para la próxima vez que se necesite el emulador:
- El binario `emulator` en `PATH` (`$ANDROID_HOME/tools/emulator`) es el shim **legacy** y calcula rutas relativas a bibliotecas usando el *working directory* del shell en vez de su propia ubicación — falla con `Could not launch '.../qemu-system-aarch64': No such file or directory` si se invoca desde fuera de la carpeta del SDK. Usa el binario moderno directamente: `$ANDROID_HOME/emulator/emulator -avd <nombre>` (o `cd "$ANDROID_HOME/emulator" && ./emulator -avd <nombre>`).
- Del mismo modo, `flutter devices`/`flutter run` a veces no detectan el emulador recién arrancado en el primer intento aunque `adb devices` ya lo liste — un segundo `flutter devices` (o simplemente reintentar `flutter run -d <device-id>`) lo resuelve sin reiniciar nada.

**Fase 4 (Pantallas y navegación) completada en código.** No se pudo verificar en emulador/dispositivo (mismo bloqueo de entorno de la Fase 3, todavía sin resolver), pero el flujo de navegación completo quedó cubierto por widget tests reales usando `go_router` de punta a punta.

- `lib/core/routing/`: `routes.dart` (paths) + `app_router.dart` — **importante:** `createAppRouter()` es una **factory**, no un singleton top-level. `ExtremeFocusTetrisApp` (ahora `ConsumerStatefulWidget`) construye la instancia una sola vez en un campo `late final` de su `State`, no en `build()`. Si conviertes esto de nuevo en un singleton global, cada widget test que reutilice el mismo proceso Dart heredará la ubicación de navegación del test anterior — así se manifestó este bug (`find` no encontraba el botón "About" porque el router seguía en `/statistics` de un test previo).
- Pausa y Game Over **no son rutas** — son overlays (`Stack` + scrim semitransparente) dentro de `GameScreen`, tal como los describe spec.md §10.2 (el diagrama de flujo del §10.1 los dibuja como cajas separadas solo a nivel conceptual).
- `features/splash`, `features/home`, `features/settings` (`domain/entities/settings_state.dart` + `presentation/viewmodels/settings_controller.dart` + `presentation/settings_screen.dart`), `features/statistics` (mismo patrón, placeholder en cero — sin Hive todavía), `features/about` (versión real vía `package_info_plus`).
- `SettingsController` aplica sonido/volumen/vibración **inmediatamente** llamando a `AudioService`/`HapticService` desde sus propios setters (no hace falta que nadie más escuche los cambios). Ghost piece y Modo Concentración se leen directamente donde se necesitan (`GameScreen`/`GameController`).
- **ARB ampliado** con todas las claves nuevas de Home/Settings/Statistics/About/Game (pausa, game over) en `es`/`en` — ninguna pantalla nueva tiene strings hardcodeados.
- **Dos bugs reales encontrados por los widget tests de navegación** (no hubiera aparecido con solo `flutter analyze`):
  1. El `GoRouter` como singleton top-level filtraba su ubicación actual entre tests (y, en producción, habría sido inofensivo, pero la corrección — moverlo a una factory creada una vez por `State` — es la práctica correcta de cualquier forma).
  2. `GameScreen.dispose()` llamaba `ref.read(audioServiceProvider)` — Riverpod prohíbe leer providers luego de que el elemento se dispone, y durante un desmontaje completo del árbol `dispose()` puede correr después de ese punto. Solución: capturar el `AudioService` una vez en `initState` (campo `late final`) y usarlo directamente en `dispose()`, sin tocar `ref`.
- **Testing:** 73 tests en verde (69 previos + 4 de navegación en `test/widget/navigation_test.dart`, cubriendo Home→Settings→volver, Home→Statistics, Home→About, Home→Jugar). `flutter analyze` sin issues. Nota para quien escriba tests de `GameScreen`: su `Ticker` corre indefinidamente, así que usar `tester.pump(duración)` acotado en vez de `pumpAndSettle()`, y desmontar el árbol al final del test (`tester.pumpWidget(const SizedBox.shrink())`) para que `dispose()` detenga el ticker antes de que termine el test.

**Fase 5 (Persistencia) completada en código.** Las tres cajas de Hive de spec.md §13 existen y están cableadas; no se pudo verificar en emulador/dispositivo (mismo bloqueo de entorno de la Fase 3/4).

- **`hive_generator` no se usa** — su última versión depende de `source_gen ^1.0.0`, incompatible con el `source_gen ^2.0.0` que exige `riverpod_generator` (version solving falla si agregas `hive_generator` al pubspec, no lo intentes de nuevo sin resolver esto primero). Los `TypeAdapter` de `SettingsModel`/`StatisticsModel`/`GameSessionModel` están **escritos a mano**, con exactamente la forma que `hive_generator` habría producido — es 100% API pública soportada de Hive, no un hack.
- `lib/core/constants/hive_box_names.dart` centraliza los nombres de las 3 cajas. `lib/main.dart` ahora es `async`: `Hive.initFlutter()`, registra los 3 adapters, y abre las 3 cajas **antes** de `runApp` — cualquier código que lea `settingsControllerProvider`/`statisticsControllerProvider`/`gameRepositoryProvider` (o las implementaciones de repo directamente) asume que esto ya ocurrió.
- **`ThemeModeController`/`LocaleController` (de `core/di/providers.dart`) fueron eliminados** — `tema` e `idioma` ahora viven dentro de `SettingsState`/`SettingsController` junto con el resto de preferencias, en un solo registro de `settings_box`, tal como pide spec.md §13 ("`settings_box`: sonido, volumen, vibración, tema, idioma, modo concentración, ghost piece"). `app.dart` y `settings_screen.dart` leen/escriben `themeMode`/`locale` a través de `settingsControllerProvider`, no de providers separados.
- `GameController` ahora: (a) lleva contadores de sesión (tetrises/T-Spins/Perfect Clears/tiempo jugado) — **no** viven en `GameState` del dominio, para no tocar la firma que usan ~10 archivos de test de la Fase 1; (b) guarda la sesión (`GameRepository.saveSession`) al pausar y al pasar a segundo plano; (c) al terminar la partida, llama `StatisticsController.recordFinishedGame(...)` y limpia la sesión guardada; (d) `resumeSession()` carga la sesión guardada en vez de `startNewGame()`. `HomeScreen` decide "Continuar" vs "Jugar" con `gameRepository.hasSavedSession()`.
- `Board` ganó `toCellList()`/`fromCellList()` (solo para serialización) — es la única forma soportada de reconstruir un `Board` guardado, ya que `_cells` es privado a propósito.
- **Importante para tests:** cualquier test (widget o unitario) que toque `settingsControllerProvider`, `statisticsControllerProvider`, `gameRepositoryProvider`, o instancie las implementaciones de repositorio directamente, necesita que las cajas de Hive estén abiertas — usa `setUpHiveForTesting()` de `test/test_helpers/hive_test_setup.dart` (abre cajas en un directorio temporal vía `setUpAll`, limpia con `tearDown` para que un test no filtre datos al siguiente dentro del mismo archivo — el mismo tipo de bug que ya mordió a `createAppRouter()` en la Fase 4 —, y borra todo en `tearDownAll`).
- **Testing:** 81 tests en verde (74 previos + 7 nuevos de `test/unit/persistence/repositories_test.dart` cubriendo round-trip de cada repositorio + acumulación de estadísticas). `flutter analyze` sin issues.

**Fase 6 (Modo Concentración) completada en código.** No se pudo verificar en emulador/dispositivo (mismo bloqueo de entorno de la Fase 3/4/5).

- **La curva de velocidad topada (spec.md §8.6) ya estaba implementada desde la Fase 2** (`GameController.focusMode` + `LevelCurve.dropInterval(..., focusMode: ...)`) — esta fase no tocó eso, solo lo que faltaba: HUD, paleta, sonido.
- `colorForTetromino(type, {focusMode})` en `tetromino_colors.dart` aplica -10% de saturación (vía `HSLColor`) cuando `focusMode` es true; `BoardPainter` y `NextQueueWidget` reciben `focusMode` y lo propagan a cada celda/swatch que dibujan.
- `AudioService.playSfx` ahora acepta `volumeMultiplier`; `GameController._playSfx(event)` es el único punto que debe usarse para reproducir SFX de juego (aplica ×0.5 ≈ -6dB cuando `focusMode` es true) — **no** llames `ref.read(audioServiceProvider).playSfx(...)` directamente desde `GameController` para SFX de juego, o te saltas la atenuación de Modo Concentración. El loop ambiental (tic-toc) no se toca, por diseño (spec.md §9.2: debe volverse más prominente *en relación* al resto, no subir su propio volumen).
- `GameScreen` recibe `focusMode` (ya existía desde la Fase 4, ahora se usa de verdad): oculta el panel de Hold, next queue baja de 3 a 1 pieza, el score se muestra en tamaño reducido, se agrega una fila de Líneas/Combo/Timer que en Modo Concentración se reduce a solo un timer discreto. Nivel no se muestra en el HUD superior en Modo Concentración (no está en la lista "solo..." de spec.md §9.2).
- **Subida de nivel**: Clásico muestra un banner (`AppDurations.levelUpEnter/Hold/Exit`, ya existían desde la Fase 0 esperando exactamente este uso); Concentración muestra un fade de borde de 400ms (`AppDurations.focusLevelUpBorderFade`, nueva) en vez del banner — implementado con `ref.listen(gameControllerProvider, ...)` dentro de `build()` comparando `previous.level` vs `next.level`.
- **Alcance recortado a propósito, documentado para no perderlo de vista:** el "popup de combo x N" grande (Clásico) y el "glow" de borde que lo reemplaza en Concentración (spec.md §9.2) **no** se implementaron esta fase — son efectos animados/partículas que pertenecen mejor a la Fase 7 ("Pulido visual"), que ya tiene ese alcance explícito. Por ahora Clásico solo muestra un contador de texto persistente "Combo x{n}" (no un popup transitorio) cuando `combo >= 1`.
- **Simplificación documentada:** el timer visible en el HUD (`_displayedElapsed` en `GameScreen`) siempre arranca en 0:00 al montar la pantalla, incluso al reanudar una sesión guardada — es puramente de despliegue. El tiempo jugado que sí importa (el que se acumula para `StatisticsController.recordFinishedGame`) vive en `GameController._sessionPlayTime` y ese sí seguía correctamente desde la Fase 5. Spec.md marca el timer de Concentración como "opcional, activable", así que esta es una simplificación intencional, no un olvido.
- **Testing:** 85 tests en verde (81 previos + 1 de desaturación de paleta + 2 de `NextQueueWidget.visibleCount` + 1 de navegación verificando que Hold desaparece en Concentración). `flutter analyze` sin issues.

**Fase 7 (Pulido visual) completada en código y parcialmente verificada en vivo en la Fase 8** (ver nota de verificación en vivo más abajo: tablero, HUD, highlight diagonal, ghost piece, hold/next-queue y hard-drop/lock se confirmaron funcionando en un emulador real; los efectos específicos de esta fase — ráfaga de partículas, flash+shake de línea, popup de combo, game-over shake, scale pulses — **no** se llegaron a disparar en esa sesión, porque requieren completar una línea/combo/game over, algo que no ocurrió durante la verificación). Implementa spec.md §7/§16/§18 (partículas, flash+shake de línea, highlight diagonal, glow de borde, scale pulses, y el popup/glow de combo diferido de la Fase 6).

- `lib/features/game/domain/entities/line_clear_outcome.dart` ganó `clearedRowIndices` (índices de fila en coordenadas completas del tablero, incluyendo las 2 filas ocultas), poblado por `LockActivePiece.call` desde `resolved.clearedRows`. Es el dato que conecta "qué se limpió" con "dónde emitir partículas/flash".
- **Nuevo evento reactivo** (patrón separado de `GameState`, spec.md §18): `lib/features/game/presentation/viewmodels/line_clear_event.dart` (`LineClearEvent` — filas limpiadas, cantidad, `sequence` incremental) + `line_clear_event_controller.dart` (`@riverpod` `Notifier<LineClearEvent?>`, expone `emit(...)`). `GameController._reactToLockOutcome` llama `ref.read(lineClearEventControllerProvider.notifier).emit(outcome.clearedRowIndices)` cada vez que `linesCleared > 0` (cubre tanto el branch de T-Spin como el de línea normal). **Por qué un evento aparte y no un campo en `GameState`:** un campo persistente se re-dispararía en cada rebuild que comparta ese estado; un evento con `sequence` le permite a `GameScreen` distinguir "ya reaccioné a este clear" de "nuevo clear, mismo número de líneas".
- `lib/features/game/presentation/effects/particle.dart` (`Particle`: posición/velocidad/vida, `spawn()`/`step()`) + `particle_pool.dart` (`ParticlePool`, tamaño fijo 300, reutilización circular — **nunca asigna un `Particle` nuevo en runtime**, spec.md §16; `ParticleCounts.perCellFor` interpola 8/cel en Single hasta 16/cel en Tetris, únicos puntos que fija spec.md §18). 13 tests unitarios en `test/unit/game/particle_test.dart`.
- `lib/features/game/presentation/widgets/board_geometry.dart` — `BoardGeometry.of(Size)` centraliza el cálculo cellSize/offset que antes vivía solo dentro de `BoardPainter.paint()`; ahora también lo usa `GameScreen` para traducir `clearedRowIndices`/columnas a coordenadas de píxel al emitir partículas, sin duplicar la fórmula.
- `BoardPainter` ahora acepta `flashRows`/`flashOpacity` (rectángulo semitransparente `AppColors.fxSpecialStart` sobre las filas limpiadas, fase 1 del clear) y `particles` (círculos `AppColors.particles`, alpha = `particle.life`); `_paintCell` suma un gradiente diagonal sutil blanco→transparente (look "caramelo" de spec.md §18) sobre piezas activas y celdas fijas (no sobre el ghost). `shouldRepaint` ahora también compara `flashOpacity`/`flashRows` y repinta siempre que haya partículas vivas en cualquiera de los dos delegates.
- `GameScreen` pasó de `SingleTickerProviderStateMixin` a `TickerProviderStateMixin` (necesita 3 tickers: el loop de juego + 2 `AnimationController`). Nuevo estado: `ParticlePool _particlePool` (se actualiza cada tick del `GameTickerService` existente, con `setState` solo mientras haya partículas vivas), `_lineClearEffectController` (120ms, arranca en `value: 1` para que `1 - value` dé opacidad 0 en reposo — importante si tocas este controller: no lo reinicies a `value: 0` por defecto o el flash aparecerá fijo antes del primer clear) y `_gameOverShakeController` (300ms, `AppDurations.gameOverShake`). Ambos comparten la misma `TweenSequence` de shake (±3px, 2 ciclos) evaluada dentro de un `AnimatedBuilder` que envuelve el `CustomPaint` del tablero con `Transform.translate`.
- **Combo popup (Clásico) + glow de borde (Concentración)** — el punto pendiente explícito de la Fase 6: `ref.listen(gameControllerProvider, ...)` ahora también compara `previous.combo` vs `next.combo` y dispara `_onComboIncrease`. Reutiliza los mismos patrones ya existentes (banner tipo level-up para Clásico con `AppDurations.levelUpEnter/Hold/Exit`, fade de borde tipo Concentración con `AppDurations.focusLevelUpBorderFade`, solo que con `AppColors.primary` en vez de `secondary` para distinguirlo visualmente del level-up).
- **Scale pulses** (spec.md §18: score y combo, 1.0→1.15→1.0 en 120ms): nueva constante `AppDurations.scalePulseUp` (60ms, cada mitad del pulso) + `AnimatedScale` envolviendo los `Text` de score y combo, activado por `ref.listen` comparando `previous.score`/`combo` vs `next`.
- **Game Over shake**: mismo `ref.listen(gameControllerProvider, ...)` dispara `_gameOverShakeController.forward(from: 0)` al detectar la transición a `GameStatus.gameOver`.
- **Alcance recortado a propósito, documentado para no perderlo de vista:** (a) el colapso vertical animado de las filas superiores tras un clear (fase 2 de la animación de spec.md §7, 120–320ms) **no** se implementó — el tablero se actualiza de forma discreta/instantánea como el resto del movimiento de piezas, consistente con la filosofía "debe sentirse precisa" del propio spec.md §7; (b) el glow alrededor de la pieza activa (spec.md §18, "glow... alrededor de piezas activas") se omitió por redundante con el highlight diagonal + el stroke ya existente; (c) los gradientes de fondo de pantalla y del botón primario (spec.md §18) siguen diferidos — sin arte final, su valor es bajo y no están bloqueando nada.
- **Testing:** 103 tests en verde (98 previos + 3 de `test/widget/board_geometry_test.dart` + 2 de `test/widget/board_painter_test.dart`, cubriendo el letterboxing de la geometría del tablero y que `BoardPainter.paint()`/`shouldRepaint` no truenen con partículas/flash activos). `flutter analyze` sin issues. No se agregó un test dedicado para `GameController`/`LineClearEventController` en sí — ningún controller de Riverpod tiene test unitario propio en este proyecto (se verifican indirectamente vía widget tests), consistente con fases anteriores.

**Fase 8 (Accesibilidad) completada en código y verificada en vivo en un emulador Android real** (spec.md §14: modo daltónico, escalado de texto, alto contraste, reducción de movimiento).

- `SettingsState`/`SettingsModel`/`SettingsRepositoryImpl`/`SettingsController` ganaron 4 campos: `colorblindModeEnabled` (bool), `textScale` (double, clamped 0.85–1.3 en el setter), `highContrast` (bool), `reduceMotion` (bool). El `TypeAdapter` de `SettingsModel` los agrega como campos Hive 8–11 con fallback (`fields[8] as bool? ?? false`, etc.) para que un registro guardado antes de esta fase siga cargando con los defaults correctos.
- **Paleta daltónica**: `tetromino_colors.dart` gana `_colorblindPalette(type)` — la paleta Okabe-Ito (Okabe & Ito, 2008), elegida porque sus 8 colores se mantienen distinguibles simultáneamente bajo protanopia/deuteranopia/tritanopia (spec.md pide una sola paleta validada para las tres, no una por condición). `colorForTetromino(type, {focusMode, colorblindMode})` la usa como base cuando `colorblindMode` es true, y sigue aplicando la desaturación de Focus Mode encima si ambos están activos.
- **Refuerzo de textura (no solo color)**: nuevo `lib/features/game/presentation/widgets/cell_texture.dart` — `CellTexture` (7 valores: rayas horizontales/verticales, diagonales en ambos sentidos, cross-hatch, puntos, tablero de ajedrez) + `textureForTetromino(type)` (mapeo 1:1, cada pieza un patrón distinto) + `paintCellTexture(canvas, rect, texture)` (dibuja el patrón recortado al rect de la celda) + `CellTexturePainter` (wrapper `CustomPainter` para los swatches pequeños). `BoardPainter._paintCell` lo invoca cuando `colorblindMode` es true (solo sobre celdas opacas, igual que el highlight diagonal); `NextQueueWidget`/`HoldWidget` ganaron un parámetro `colorblindMode` y hacen lo mismo sobre sus swatches de 40×40.
- **Alto contraste**: `core/theme/app_theme_high_contrast_light.dart`/`app_theme_high_contrast_dark.dart` (nuevos) — variantes de "Day/Night Focus" con fondo/texto en blanco/negro puro y borde visible en cards/botones. `app.dart` elige `theme`/`darkTheme` según `settings.highContrast` **ortogonal** a `themeMode` (light/dark/system se siguen respetando; alto contraste es un cuarto interruptor que se le monta encima, no un cuarto valor de `ThemeMode`, que Flutter no soporta nativamente). `BoardPainter` dobla el grosor del stroke de bloque cuando `highContrast` es true; el scrim de Pausa/Game Over (`_OverlayScrim` en `game_screen.dart`) pierde su transparencia (`alpha: 1` en vez de `0.92`) bajo alto contraste.
- **Escalado de texto**: `app.dart` envuelve `MaterialApp.router` en un `builder` que reemplaza el `MediaQuery.textScaler` por `TextScaler.linear(settings.textScale)` app-wide — deliberadamente **reemplaza** en vez de multiplicar sobre la escala del sistema, ya que el slider de Settings (0.85×–1.3×) es el único control que spec.md pide para esto.
- **Reducción de movimiento**: `GameScreen` gana un getter `_reduceMotion` (`settings.reduceMotion || MediaQuery.of(context).disableAnimations`) que se consulta en dos puntos: (a) `_onLineClear` no emite partículas si es true (pero sigue marcando `_flashRows` y disparando `_lineClearEffectController`, porque el flash de color es una señal de estado, no "movimiento" — spec.md nombra específicamente "partículas, shake" como los efectos a atenuar); (b) el cálculo de `shakeDx` en el `AnimatedBuilder` del tablero se fuerza a `0.0`. Los scale-pulses de score/combo **no** se atenúan (spec.md no los nombra explícitamente y son un pulso muy sutil).
- `settings_screen.dart` gana una sección "Accessibility"/"Accesibilidad" (`Padding`+`Text` de encabezado, sin traducción de `ListTile` porque no es una fila interactiva) con 4 controles nuevos, siguiendo el mismo patrón que el resto de la pantalla (aplican inmediato, sin botón "Guardar"). Claves ARB nuevas en `app_en.arb`/`app_es.arb`: `settingsAccessibilitySection`, `settingsColorblindMode`, `settingsTextScale`, `settingsHighContrast`, `settingsReduceMotion`.
- **Bug real encontrado y corregido durante la verificación en vivo de esta fase (no relacionado con accesibilidad en sí):** el `ListTile` de "Tema" tenía `trailing: SegmentedButton<ThemeMode>(...)` — un `SegmentedButton` de 3 segmentos es demasiado ancho para vivir en `trailing`, así que `ListTile` le daba al `title` tan poco espacio que "Theme"/"Tema" se renderizaba una letra por línea (verticalmente). Solución: mover el `SegmentedButton` a `subtitle` (mismo patrón que ya usan los sliders de volumen — título en su propia línea, control debajo a todo el ancho). Si agregas otro `ListTile` con un control ancho (`SegmentedButton`, `DropdownButton` largo), no lo pongas en `trailing` sin probarlo primero.
- **Testing:** 111 tests en verde (103 previos + `test/widget/tetromino_colors_test.dart` [paleta daltónica da 7 colores distintos, cambia respecto a la paleta estándar, compone con Focus Mode; `textureForTetromino` da 7 texturas distintas] + `test/widget/cell_texture_test.dart` [`paintCellTexture` no truena con ningún patrón] + 2 tests nuevos en `test/widget/board_painter_test.dart` [pinta sin truenos con `colorblindMode`/`highContrast`; `shouldRepaint` detecta el cambio de cualquiera de los dos] + el round-trip de `repositories_test.dart` ampliado con los 4 campos nuevos). `flutter analyze` sin issues.
- **Hallazgo real de infraestructura de testing (no bloqueante, documentado para la Fase 9):** un widget test que hace `tester.tap()` sobre cualquier `SwitchListTile` de `SettingsScreen` (incluso uno preexistente como "Sound", no solo los nuevos de esta fase) y luego deja que `setUpHiveForTesting()`'s `tearDown()` corra, **cuelga indefinidamente en `Hive.box(...).clear()`** — un `.put()` disparado por `SettingsController._persist()` (fire-and-forget, sin `await`) sigue en vuelo, y llamar `.clear()` sobre la misma caja mientras ese `.put()` no ha resuelto genera un deadlock real de Hive (confirmado con prints de diagnóstico: `TEARDOWN: start clear` imprime, `TEARDOWN: settings cleared` nunca llega). **No es un bug de esta fase** — ningún test anterior había tocado un switch de Settings, por eso nunca se manifestó. Por ahora, evita tests de widget que interactúen con switches de `SettingsScreen`; la corrección de fondo (`await`ar `_persist()` explícitamente, o rediseñar `setUpHiveForTesting()` para no reusar cajas entre tests) queda para la Fase 9 (Testing integral).
- **Verificación en vivo (emulador Android, Fase 8):** con el bloqueo de la Fase 3 resuelto (ver nota de esa sección), se instaló y ejecutó la app real en el AVD `Pixel_3a_API_34_extension_level_7_arm64-v8a`. Confirmado con capturas reales: Home → Settings → Game (Play), tablero con grid/ghost piece/next queue/hold panel, HUD (nivel/score/líneas/timer), hard drop + lock de pieza, overlay de Pausa (Resume/Restart/Exit), navegación de vuelta a Home, paleta daltónica + texturas simultáneas sobre piezas activas/next-queue/hold, tema de alto contraste (fondo/texto blanco puro), y persistencia de `colorblindModeEnabled`/`highContrast` sobreviviendo un **reinicio completo de la app** (Hive real, no el de test). **No verificado en esta pasada:** audio/háptica (no auditable por captura de pantalla), y los efectos específicos de la Fase 7 (partícula/flash/shake de línea, combo popup, pulses, game-over shake), que requieren completar una línea/combo/game over.

**Pendiente aún:** `core/error`/`core/utils`, y todas las demás carpetas bajo `lib/features/` — se crean/amplían cuando su fase respectiva lo pida. La siguiente fase del roadmap es la **Fase 9** (Testing integral: widget tests, golden tests, integration tests, checklist QA manual de spec.md §21), que también debería resolver el hallazgo de Hive/`tearDown` documentado arriba.

### Nota de versiones (importante para no repetir el error)

Al hacer `flutter pub add` sin fijar versión, `flutter_riverpod`/`riverpod_annotation` resolvieron a una generación 3.x/4.x que **no es compatible entre sí** para generar código (`riverpod_generator` entra en conflicto de versiones con `test`/`matcher` del SDK). Hay que seguir fijando explícitamente `^2.x` en los tres paquetes del stack Riverpod (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`) tal como indica la tabla de dependencias de `spec.md` §24, en vez de dejar que `pub` tome la última mayor disponible.

## Qué es este proyecto

**Extreme Focus Tetris**: app Android en Flutter/Dart, de uso estrictamente personal, que reinterpreta Tetris como herramienta de concentración profunda. Sin ads, sin IAP, sin cuentas, sin red, sin recolección de datos, sin música de fondo. Detalle completo en `spec.md` secciones 1–2.

## Restricciones no negociables

Estas reglas gobiernan cualquier cambio, incluso si no se repiten explícitamente en cada tarea:

- **Cero red**: ninguna dependencia ni código puede requerir conexión a Internet, ni siquiera en el primer arranque (esto descarta, por ejemplo, usar `google_fonts` en modo runtime-fetch — las fuentes van empaquetadas como assets locales).
- **Cero telemetría/ads/IAP/cuentas**: no añadir SDKs de analítica, crash-reporting en la nube, publicidad ni compras.
- **Sin música de fondo**: decisión de producto irrevocable (sección 6.1). Solo el loop ambiental "tic-toc" + SFX.
- **Sin motor de física de terceros**: el movimiento es grid-based determinístico; las partículas usan una simulación manual simple (sección 19).
- **60 FPS estables** e **inicio jugable en < 5 segundos** son requisitos de aceptación, no aspiraciones (secciones 15, RNF-01, RNF-02).
- **No añadir features fuera de alcance** (multiplayer, backend, notificaciones push) sin antes actualizar `spec.md`.

## Comandos

Una vez scaffolded el proyecto Flutter en la raíz del repo:

```bash
flutter pub get                          # instalar dependencias
flutter pub run build_runner build --delete-conflicting-outputs   # codegen (freezed, riverpod_generator, hive_generator)
flutter analyze                          # lint (flutter_lints + reglas en analysis_options.yaml)
flutter test                             # correr toda la suite (unit + widget)
flutter test test/unit/game/rotation_test.dart   # correr un único archivo de test
flutter test --plain-name "detecta T-Spin"       # correr un test por nombre
flutter test integration_test/app_test.dart      # integration test (requiere dispositivo/emulador)
flutter run                              # ejecutar en dispositivo/emulador conectado
flutter build apk --obfuscate --split-debug-info=build/symbols   # build de release (sección 22)
dart run flutter_native_splash:create    # regenerar splash nativo tras cambios de assets
dart run flutter_launcher_icons          # regenerar íconos de launcher
```

## Arquitectura (resumen)

Clean Architecture + Feature-First + MVVM, con **Riverpod** como estado y contenedor de DI (justificación completa en `spec.md` 3.1). Regla de dependencia: `presentation → domain ← data`; `domain` es Dart puro (sin `package:flutter`, sin Hive).

- `lib/core/` — theme, constantes, routing (`go_router`), servicios transversales (`AudioService`, `HapticService`, `GameTickerService`), DI raíz.
- `lib/features/<feature>/domain|data|presentation/` — una carpeta por feature (`game`, `settings`, `statistics`, `home`, `splash`, `game_over`, `about`).
- `lib/shared/widgets/` — widgets de UI reutilizables entre features.

Árbol de carpetas completo y detalle de cada capa: `spec.md` sección 3.

### Puntos técnicos clave a respetar al implementar

| Tema | Decisión | Sección de spec.md |
|---|---|---|
| Estado/DI | Riverpod (`Notifier`/`AsyncNotifier`, `riverpod_generator`) | 3.1 |
| Navegación | `go_router` | 24 |
| Persistencia | Hive (`settings_box`, `stats_box`, `session_box`); DTOs con `HiveType` mapeados a entidades `freezed` del dominio, nunca al revés | 13, 24 |
| Renderizado del tablero | `CustomPainter` en un único `RepaintBoundary`, capa estática cacheada + capa dinámica; **no** un widget por celda | 15 |
| Game loop | `Ticker` desacoplado de la UI vía `GameTickerService`, paso lógico fijo | 15 |
| Partículas | `ParticlePool` de tamaño fijo, reutilizado por índice circular; nunca instanciar/destruir `Particle` en el loop | 16, 18 |
| Audio | `audioplayers`; una instancia dedicada al loop ambiental + pool pequeño de instancias para SFX solapables | 6, 16, 24 |
| Vibración | `HapticFeedback` nativo de Flutter (no el paquete `vibration`) | 6.4 |
| Rotación de piezas | SRS estándar con tablas de wall kick (JLSTZ e I) tal como están tabuladas | 8.2 |
| Generador de piezas | 7-bag | 8.3 |
| Puntaje/nivel/velocidad | Tablas exactas de la sección 8.5/8.6 — no aproximar | 8.5, 8.6 |
| Fuentes | Fredoka + Nunito empaquetadas como assets locales (`pubspec.yaml` → `fonts:`), **no** `google_fonts` en modo runtime | 5, 24 |
| i18n | ARB + `flutter gen-l10n`, español por defecto, inglés incluido desde v1.0 | 20 |

## Fases de desarrollo y agentes requeridos

El roadmap de `spec.md` sección 26 define **13 fases (0–12)**. Esta sección traduce ese roadmap en un plan de asignación: qué **rol de agente** debe liderar cada fase, qué **skills** necesita, y qué agentes de apoyo intervienen. Sirve tanto para un equipo humano como para orquestar sub-agentes de IA sobre este repositorio.

### Catálogo de roles y skills

| Rol | Skills clave |
|---|---|
| **Software Architect / Tech Lead** | Clean Architecture, Flutter/Dart, Riverpod, patrones DI/Repository, definición y revisión de estructura de carpetas, code review, custodia de coherencia arquitectónica |
| **Flutter Game Engine Developer** | Dart puro (sin dependencia de `package:flutter`), diseño de algoritmos de grid/colisión, SRS y tablas de wall kick, TDD estricto, estructuras de datos eficientes (`Int8List`, arrays tipados) |
| **Flutter UI/Rendering Developer** | `CustomPainter`/`Canvas`, `Ticker` y loops de animación, gestos táctiles (`GestureDetector`, DAS/ARR), optimización de rebuilds con Riverpod (`.select`), composición de widgets responsive |
| **Audio/Haptics Developer** | `audioplayers` (loop + pool de instancias), `HapticFeedback`, gestión de ciclo de vida de la app (`AppLifecycleState`), mezcla y balance de volumen |
| **Flutter Navigation & Screens Developer** | `go_router`, theming claro/oscuro, layouts responsive, integración de `flutter_native_splash`/`flutter_launcher_icons` |
| **Persistence/Data Developer** | Hive (`Box`, `TypeAdapter`), mapeo DTO ↔ entidad de dominio, versionado de esquema, serialización con `freezed`/`json_serializable` |
| **UX/UI Designer** | Wireframing, sistemas de diseño (spacing, color, tipografía), diseño de estética cartoon original, diseño de HUD mínimo para Modo Concentración |
| **Game/Sound Designer** | Balance de reglas de Tetris (curvas de dificultad, scoring, T-Spin/Perfect Clear), diseño de carácter sonoro (tic-toc, SFX no ansiogénicos) |
| **Accessibility Specialist** | WCAG (contraste AA/AAA), modos de daltonismo, escalado de texto, `Semantics` de Flutter, revisión de targets táctiles (48×48dp) |
| **QA/Test Engineer** | `flutter_test`, `mocktail`, `golden_toolkit`, `integration_test`, diseño y ejecución de checklist QA manual, testing exploratorio |
| **Mobile Performance Engineer** | Flutter DevTools (Performance/Timeline), gestión de memoria y GC, object pooling, warm-up de shaders (`--cache-sksl`), benchmarking de FPS |
| **Release/Build Engineer** | `flutter build` (obfuscación, `--split-debug-info`), firma de AAB/APK, generación de íconos/splash, checklist de privacidad pre-release |
| **Product Owner / Spec Custodian** | Mantenimiento de `spec.md` como fuente de verdad, control de alcance (anti scope-creep), priorización de roadmap y del backlog (sección 33) |

### Mapeo de fases → agentes

| Fase | Objetivo (spec.md §26) | Agente principal | Agentes de apoyo | Entregable clave |
|---|---|---|---|---|
| **0** | Setup y arquitectura base | Software Architect / Tech Lead | Product Owner / Spec Custodian, Flutter Navigation & Screens Developer | Proyecto Flutter inicializado, estructura Feature-First, wiring de Riverpod/tema/l10n |
| **1** | Motor de juego (dominio puro) | Flutter Game Engine Developer | QA/Test Engineer (unit tests desde el día uno), Game/Sound Designer (validación de reglas) | `domain/game` completo con SRS, 7-bag, scoring, T-Spin, Perfect Clear + suite de unit tests |
| **2** | Renderizado e input | Flutter UI/Rendering Developer | Mobile Performance Engineer (revisión temprana de `CustomPainter`), UX/UI Designer (game feel) | `BoardPainter`, `GameTickerService`, controles táctiles, ghost piece, next/hold |
| **3** | Audio y háptica | Audio/Haptics Developer | Game/Sound Designer (mezcla y carácter sonoro), QA/Test Engineer | `AudioService`/`HapticService` integrados a eventos de juego, controles de volumen independientes |
| **4** | Pantallas y navegación | Flutter Navigation & Screens Developer | UX/UI Designer (wireframes → UI real), Accessibility Specialist (revisión temprana) | Splash, Home, Settings, Statistics, About + `go_router` |
| **5** | Persistencia | Persistence/Data Developer | Software Architect (revisión de mapeo Clean Architecture), QA/Test Engineer (test de resume) | Cajas Hive, repositorios de datos, lógica de "continuar partida" |
| **6** | Modo Concentración | UX/UI Designer + Game/Sound Designer | Flutter UI/Rendering Developer, Audio/Haptics Developer | HUD mínimo, curva de velocidad topada, paleta desaturada, atenuación de SFX |
| **7** | Pulido visual | Flutter UI/Rendering Developer | UX/UI Designer, Mobile Performance Engineer (partículas) | `ParticlePool`, glow, gradientes especiales, animaciones de transición/Game Over |
| **8** | Accesibilidad | Accessibility Specialist | UX/UI Designer, QA/Test Engineer | Modo daltónico, escalado de texto, alto contraste, reducción de movimiento |
| **9** | Testing integral | QA/Test Engineer | Todos los developers de feature (fixes), Mobile Performance Engineer | Cobertura de widget/golden/integration tests, checklist QA manual ejecutado |
| **10** | Optimización de rendimiento y memoria | Mobile Performance Engineer | Flutter Game Engine Developer, Flutter UI/Rendering Developer, Audio/Haptics Developer | Perfil DevTools sin jank, auditoría de pooling, tamaño de APK/AAB verificado |
| **11** | Preparación de release | Release/Build Engineer | Product Owner / Spec Custodian, QA/Test Engineer | Build de producción firmado, íconos/splash nativos, checklist final de privacidad |
| **12** | Backlog post-lanzamiento | Product Owner / Spec Custodian | Software Architect (viabilidad técnica) | Priorización de ideas de `spec.md` sección 33, sin compromiso de fecha |

### Reglas de coordinación entre fases

- Cada agente debe leer, antes de empezar su fase, la(s) sección(es) correspondiente(s) de `spec.md` referenciadas en la tabla del roadmap (§26) y la tabla de "Puntos técnicos clave" de este documento — no debe re-derivar decisiones ya tomadas.
- Las fases son mayormente **secuenciales** (cada una depende de la anterior), salvo: **Fase 3** (Audio) puede avanzar en paralelo a **Fase 2** (Renderizado) una vez cerrada la Fase 1, ya que ambas consumen el mismo motor de dominio pero no dependen entre sí; y la preparación de assets de **UX/UI Designer** y **Game/Sound Designer** (paleta, wireframes, carácter sonoro) puede adelantarse desde la Fase 0 en paralelo al trabajo del Software Architect.
- Una fase se considera **cerrada** solo cuando su entregable clave existe **y** los tests correspondientes (unit/widget/golden/integration según aplique, sección "Testing" de este documento) pasan — no basta con "código escrito".
- El **QA/Test Engineer** no actúa solo en la Fase 9: revisa continuamente desde la Fase 1 (unit tests del motor) y debe poder bloquear el cierre de cualquier fase si el entregable no cumple los criterios de aceptación de `spec.md` sección 30.
- Si un agente detecta durante su fase que necesita desviarse de `spec.md`, aplica la regla de la sección ["Cuando la implementación diverja de spec.md"](#cuando-la-implementación-diverja-de-specmd) antes de continuar.

### Nota sobre subagentes de Claude Code

Este entorno no expone un subagente especializado en Flutter/Dart. Para orquestar las fases anteriores con el `Agent` tool de Claude Code:

- Usar `Plan` para la fase de arquitectura/planificación (Fase 0) y para decisiones de diseño técnico que requieran comparar alternativas antes de escribir código.
- Usar `general-purpose` (o `fork`, si la tarea puede reutilizar el contexto ya cargado en la conversación) para los roles de implementación (Game Engine, UI/Rendering, Audio, Navigation, Persistence, Release).
- Usar `Explore` para localizar código una vez el proyecto crezca (ej. "dónde está la lógica de detección de T-Spin"), no para revisión ni auditoría.
- Los roles de diseño puro (UX/UI Designer, Game/Sound Designer, Accessibility Specialist, Product Owner) no requieren un subagente de código: son criterios que el agente implementador debe aplicar directamente desde `spec.md`, o revisiones que puede hacer el propio orquestador (tú) sin delegar.

## Convenciones de código

- SOLID/DRY/KISS/YAGNI aplicados vía las capas descritas arriba (sección 23) — no introducir abstracciones o dependencias no justificadas en `spec.md`.
- Comentarios de documentación (`///`) solo en clases públicas de `domain` para reglas de negocio no evidentes (ej. condición exacta de T-Spin); evitar comentar lo obvio.
- `const` constructors en widgets estáticos; evitar `setState` de árboles anchos, usar `.select` de Riverpod para rebuilds granulares.
- No hardcodear strings de UI: todo texto pasa por `AppLocalizations`.

## Testing

- **Unit tests** (Dart puro, sin widgets) para toda la lógica de `domain/game`: rotación SRS + wall kicks, colisiones, líneas completas, T-Spin, Perfect Clear, scoring, curva de nivel, distribución del 7-bag. Estos deben existir **desde el primer commit del motor de juego** (Fase 1 del roadmap), no añadirse después.
- **Widget tests** para HUD (clásico/focus), Settings, controles táctiles.
- **Golden tests** (`golden_toolkit`) para tablero, HUD, Game Over, ambos temas.
- **Integration tests** (`integration_test`) para el flujo completo splash → partida → pausa → game over → resume.
- Detalle y checklist QA manual: `spec.md` sección 21.

## Antes de dar por terminada una tarea de UI/gameplay

Sigue la guía general de "para cambios de UI, levanta el emulador y prueba el golden path" — en este proyecto eso significa como mínimo: iniciar una partida, mover/rotar/hacer hold/hard-drop una pieza, completar al menos una línea, pausar/reanudar, y verificar que no haya jank visible (overlay de performance de Flutter). Reportar explícitamente si algo no pudo probarse en un dispositivo/emulador real.

## Cuando la implementación diverja de spec.md

Si durante el desarrollo surge una razón técnica válida para desviarse de algo especificado (ej. una tabla de wall kick, una dependencia, una estructura de carpeta), **actualiza `spec.md` primero** y luego implementa — nunca al revés. `spec.md` es la única fuente de verdad (ver su nota de cierre).
