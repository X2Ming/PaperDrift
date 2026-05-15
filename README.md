# PAPER DRIFT

PAPER DRIFT is a full-screen Processing Java game for an Interactive Art and Design final project. The project combines a warm paper-craft poster interface with a mouse-controlled drifting game. The player guides a hand-drawn paper airplane through a paper field, collects stamp-like tokens, and avoids ink enemies that become more numerous and more aggressive over time.

The visual direction is intentionally paper-based: off-white texture, rounded paper cards, soft shadows, scraps, muted stamps, clay-orange ink, and a second-stage dark paper mode. It avoids cyberpunk, neon, arcade panels, and imported full-screen UI images.

## How To Run

1. Install Processing 4.x.
2. Open the `PaperDrift` folder in Processing.
3. Run `PaperDrift.pde`.
4. Move the mouse to begin.

The sketch uses `fullScreen()` and does not require keyboard input during gameplay.

Optional music files can be placed in:

```text
PaperDrift/data/paper_drift_normal.wav
PaperDrift/data/paper_drift_dark.wav
```

If these files are missing, the game still runs normally and prints a console message.

## Gameplay

- The player is a paper airplane.
- Mouse position relative to the screen center controls movement direction and speed.
- The airplane does not teleport to the cursor; it accelerates and drifts smoothly.
- Stamp collectibles increase the score.
- Ink enemies damage the player.
- The player starts with 3 lives.
- After damage, the player is temporarily invincible.
- When lives reach 0, the game shows a Game Over paper card.
- Moving the mouse after Game Over restarts the game.

## Difficulty And Stages

### Normal Stage

- Starts with 10 ink enemies.
- Enemy count increases by 1 every 2 seconds.
- Normal-stage enemy count is capped at 18.
- Enemy movement speed gradually increases over time.

### Dark Paper Stage

The second stage begins when the score reaches 12.

- The background gradually darkens over 2 seconds.
- A paper notice appears: `THE PAPER DARKENS`.
- Enemies become ghost-faced ink blots.
- Enemy count jumps toward at least 20.
- Enemy count increases by 2 every second.
- Dark-stage enemy count is capped at 60.
- Enemy tracking and speed increase strongly over time.
- Player speed also increases so the game remains controllable.
- The dark music loop fades in while the normal loop fades out.

## Project Architecture

The project is organized as Processing tabs/classes plus one plain Java helper class.

```text
PaperDrift/
  PaperDrift.pde       Main sketch, game states, setup/draw loop, difficulty, phase system
  Player.pde           Paper airplane movement, rotation, display, damage, invincibility
  Stamp.pde            Collectible stamps, collision, respawn behavior
  InkEnemy.pde         Ink enemy movement, chasing logic, collision, display hook
  PaperScrap.pde       Background paper scraps and ambient drift
  UI.pde               Paper UI, HUD, cards, stamps, ink blots, ghost faces, dark overlay
  AudioManager.java    Java Sound music loading, looping, fading, and failure handling
  data/                Optional WAV music assets
```

### `PaperDrift.pde`

This is the main controller for the sketch.

Responsibilities:

- Defines game states: `START`, `PLAYING`, `GAME_OVER`.
- Creates the full-screen canvas.
- Initializes fonts, procedural paper textures, audio, player, stamps, enemies, and scraps.
- Updates the game loop.
- Tracks score, lives, play time, and phase state.
- Controls enemy count growth over time.
- Triggers the dark paper phase at score 12.
- Manages `darkBlend`, which makes the dark stage transition gradual instead of abrupt.
- Calls `processing-java` compatible Java Sound handling through `AudioManager`.

Important functions:

- `setup()`
- `draw()`
- `initGame()`
- `updateGame()`
- `drawGame()`
- `targetEnemyCount()`
- `updateEnemyCount()`
- `checkPhaseTransition()`
- `startPhaseTwo()`
- `enemyDifficulty()`
- `playerSpeedBoost()`
- `generatePaperTexture()`
- `generateDarkPaperTexture()`

### `Player.pde`

The player class implements smooth mouse-driven drift.

Fields:

- `PVector pos`
- `PVector vel`
- `float angle`
- `float radius`
- `int invincibleTimer`

Key behavior:

- Reads the vector from screen center to mouse position.
- Converts that vector into smooth velocity using `PVector.lerp()`.
- Rotates the airplane toward movement direction.
- Clamps movement to the screen bounds.
- Flashes during invincibility.

### `Stamp.pde`

The stamp class represents collectible objects.

Fields:

- `PVector pos`
- `float size`
- `int type`
- `boolean collected`
- `float wobbleSeed`

Key behavior:

- Drifts slightly with world movement.
- Checks collision with the player.
- Increases score through the main sketch when collected.
- Respawns away from the player.

### `InkEnemy.pde`

The enemy class controls ink blot movement and collision.

Fields:

- `PVector pos`
- `PVector vel`
- `float size`
- `int type`
- `float blotSeed`

Key behavior:

- Slowly steers toward the player.
- Receives a `difficulty` value from the main sketch.
- Uses difficulty to increase pull force, wandering motion, and maximum speed.
- Becomes visually larger during the dark stage through `darkBlend`.
- Uses circular collision against the player.

### `PaperScrap.pde`

Paper scraps are decorative particles that keep the poster alive.

Fields:

- `PVector pos`
- `PVector vel`
- `float w`
- `float h`
- `float angle`
- `float spin`
- `float alpha`
- `float seed`
- `int style`

Key behavior:

- Float across the screen.
- Wrap at screen edges.
- Move faster during dark mode.
- Draw torn paper rectangles using procedural shape functions.

### `UI.pde`

This tab contains most of the visual system.

Responsibilities:

- Draws paper cards and soft shadows.
- Draws start, gameplay HUD, instruction card, and game over screen.
- Draws the paper airplane.
- Draws stamps with scalloped sticker edges.
- Draws ink blot enemies.
- Draws ghost faces in dark mode.
- Draws the direction guide from screen center toward the mouse.
- Draws the pre-rendered dark paper overlay.

Important visual functions:

- `drawPaperCard()`
- `drawSoftShadow()`
- `drawHUD()`
- `drawStartScreen()`
- `drawGameOverScreen()`
- `drawDirectionGuide()`
- `drawPaperAirplane()`
- `drawStamp()`
- `drawInkBlot()`
- `drawGhostFace()`
- `drawDarkPaperOverlay()`
- `drawPhaseTransitionNotice()`

### `AudioManager.java`

Audio is kept in a plain Java file instead of a `.pde` tab because Processing's PDE preprocessor can misread some Java Sound method calls. Keeping audio in `AudioManager.java` avoids those syntax issues.

Responsibilities:

- Loads optional WAV files from `data/`.
- Starts both music loops.
- Keeps dark music silent until phase two.
- Fades normal music out and dark music in.
- Fails safely if audio files are missing or unsupported.

## Processing Concepts Demonstrated

- Classes and objects
- `ArrayList`
- `PVector`
- Functions
- Loops
- Conditional logic
- Collision detection
- Procedural drawing with `beginShape()`, `vertex()`, `ellipse()`, `rect()`, and `line()`
- Procedural paper texture generation using `noise()` and random dots/lines
- Mouse interaction
- Game state management
- Difficulty progression over time
- Audio integration through Java Sound

## Design Notes

The project follows a paper poster interface rather than a standard arcade UI. Most visual elements are drawn procedurally in Processing. The only optional external assets are the two WAV music files. The interface uses muted warm colors, subtle shadows, handmade forms, and negative space to stay close to the original paper UI reference.

## Build Check

This project has been checked with Processing 4.5.2 CLI:

```powershell
processing-java --sketch="D:\Code\iad\finalProject\PaperDrift" --output="D:\Code\iad\finalProject\.processing-build\PaperDrift" --force --build
```

Expected output:

```text
Finished.
```

