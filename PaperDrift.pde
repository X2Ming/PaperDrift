// ============================================================
// main game file for Paper Drift
// ============================================================

// game states
int START = 0;
int PLAYING = 1;
int GAME_OVER = 2;
int STORY = 3;

// origin state
int gameState = START;
int score = 0;
int lives = 3;
int gameOverFrame = -1000;
int playFrames = 0;
int lastEnemyAddFrame = -1000;

// difficulty & pacing
int START_ENEMY_COUNT = 10;
int MAX_ENEMY_COUNT = 18;
int DARK_MAX_ENEMY_COUNT = 60;
int NORMAL_ENEMY_SECONDS_PER_EXTRA = 2;

// second phase trigger
// when player reaches this score, the world starts drifting into darkness and enemies spawn much faster
int PHASE_TWO_SCORE = 12;

// when entering the dark phase, the number of enemies at least jumps to this value. 
// If the current enemies are less than 20, they will be quickly replenished to this number.
int PHASE_TWO_MIN_ENEMIES = 20;

// frames for the game
int PHASE_NOTICE_FRAMES = 180;

// smoothly transition to the dark phase frames, larger values result in slower transition
int PHASE_BLEND_FRAMES = 120;




// enemy speed increase steps (every X seconds, speed increases by a certain amount, see enemyDifficulty())
int NORMAL_SPEED_STEP_SECONDS = 12;
// dark mode will increase speed more aggressively, so a separate step is defined for better tuning
int DARK_SPEED_STEP_SECONDS = 5;
// if player reaches this score, the story starts and the game enters the "ending" 
// state where the remaining enemies are just background ambience and the story text is revealed
int STORY_SCORE = 24;
// how many characters of the story text to reveal per frame before the player clicks to drop the story pieces
int STORY_WRITE_STEP = 3;

// after winning, the story text is revealed line by line and then drops away in pieces when the player clicks.
String[] storyLines = {
  "Congratulations — you have driven back the ink creatures",
  "and restored light to the paper world.",
  "The torn scraps have folded themselves back into place,",
  "the stamps rest quietly on the page once more.",
  "Every crease and stain now tells a gentler story,",
  "and the paper sky drifts on, unshadowed and whole."
};
String storyText = "";
int storyStartFrame = 0;
int storyVisibleChars = 0;
boolean storyDropStarted = false;
StoryPiece[] storyPieces;

// turning point for phase two (darkness) and story mode
int phase = 1;
int phaseTransitionTimer = 0;
int phaseTwoFrames = 0;
float darkBlend = 0;
boolean phase2Started = false;

// background ambience scraps
boolean musicActive = false;
AudioManager audioManager;

// user player, collectibles, enemies, and background scraps
Player player;
ArrayList<Stamp> stamps;
ArrayList<InkEnemy> enemies;
ArrayList<PaperScrap> scraps;

// wind effect for drifting ambience, also affects enemy 
// movement direction to create a sense of being blown around on the paper world
PVector worldWind = new PVector(0, 0);

// font
PFont titleFont;
PFont bodyFont;
PFont smallFont;
PFont storyFont;

// colors
int COL_BG = 0xFFF3EFE6;
int COL_CARD = 0xFFFFFDF7;
int COL_TEXT = 0xFF2F302B;
int COL_SAGE = 0xFFA7B89A;
int COL_YELLOW = 0xFFD8B75D;
int COL_PINK = 0xFFCFA6A0;
int COL_INK = 0xFFC9825A;
int COL_TAPE = 0xFFE6DCC5;

// ============================================================
// Processing setup and main loop
// ============================================================

void settings() {
  fullScreen();
  smooth(4);
}

void setup() {
  frameRate(60);

  titleFont = createFont("SansSerif", 56, true);
  bodyFont = createFont("SansSerif", 20, true);
  smallFont = createFont("SansSerif", 14, true);
  storyFont = createFont("Serif", 24, true);

  loadMusic();
  loadUiAssets();
  prepareStoryText();
  initGame();
  gameState = START;
}

void draw() {
  if (gameState == START) {
    drawPaperBackground();
    updateAmbientScraps();
    drawStartScreen();
  } else if (gameState == PLAYING) {
    updateGame();
    drawGame();
  } else if (gameState == GAME_OVER) {
    drawPaperBackground();
    updateAmbientScraps();
    drawGameOverScreen();
  } else if (gameState == STORY) {
    updateStory();
    drawStoryScreen();
  }
}

// ============================================================
// 游戏初始化
// ============================================================

void initGame() {
  score = 0;
  lives = 3;
  playFrames = 0;
  lastEnemyAddFrame = -1000;
  phase = 1;
  phaseTransitionTimer = 0;
  phaseTwoFrames = 0;
  darkBlend = 0;
  phase2Started = false;
  worldWind.set(0, 0);

  player = new Player(new PVector(width * 0.36, height * 0.58));

  stamps = new ArrayList<Stamp>();
  for (int i = 0; i < 20; i++) {
    stamps.add(new Stamp(randomPlayablePosition(90), random(42, 62), i % 3));
  }

  enemies = new ArrayList<InkEnemy>();
  for (int i = 0; i < START_ENEMY_COUNT; i++) {
    addEnemyFarFromPlayer(false);
  }

  scraps = new ArrayList<PaperScrap>();
  int scrapCount = int(constrain((width * height) / 42000.0, 22, 44));
  for (int i = 0; i < scrapCount; i++) {
    scraps.add(new PaperScrap(random(width), random(height), random(34, 118), random(18, 78)));
  }
}

// ============================================================
// 主游戏循环
// ============================================================

void updateGame() {
  playFrames++;
  player.update(playerSpeedBoost());

  // 世界风反向于玩家速度，制造漂流感
  worldWind.set(player.vel);
  worldWind.mult(phase == 2 ? -0.18 : -0.07);

  for (PaperScrap scrap : scraps) {
    scrap.update();
  }

  // 收集邮票：加分 + 重生
  for (Stamp stamp : stamps) {
    stamp.update();
    if (stamp.checkCollected(player)) {
      score++;
      stamp.respawn();
    }
  }

  checkPhaseTransition();
  if (score >= STORY_SCORE) {
    startStoryMode();
    updateMusic();
    return;
  }

  updateEnemyCount();

  // 敌人追击 + 伤害判定
  for (InkEnemy enemy : enemies) {
    enemy.update(player, enemyDifficulty());
    if (enemy.hits(player) && !player.isInvincible()) {
      player.damage();
      lives--;
      if (lives <= 0) {
        lives = 0;
        gameState = GAME_OVER;
        gameOverFrame = frameCount;
        stopGameplayMusic();
      }
    }
  }

  // 暗黑模式淡入淡出
  if (phaseTransitionTimer > 0) {
    phaseTransitionTimer--;
  }
  if (phase == 2) {
    phaseTwoFrames++;
    darkBlend = min(1, darkBlend + 1.0 / PHASE_BLEND_FRAMES);
  } else {
    darkBlend = max(0, darkBlend - 1.0 / PHASE_BLEND_FRAMES);
  }
  updateMusic();
}

// ============================================================
// 敌人数管理
// ============================================================

int targetEnemyCount() {
  int seconds = playFrames / 60;

  if (phase == 2) {
    int darkSeconds = phaseTwoFrames / 60;
    int target = PHASE_TWO_MIN_ENEMIES + darkSeconds * 2;
    if (target > DARK_MAX_ENEMY_COUNT) {
      target = DARK_MAX_ENEMY_COUNT;
    }
    return target;
  }

  int target = START_ENEMY_COUNT + seconds / NORMAL_ENEMY_SECONDS_PER_EXTRA;
  if (target > MAX_ENEMY_COUNT) {
    target = MAX_ENEMY_COUNT;
  }
  return target;
}

void updateEnemyCount() {
  int addDelay = phase == 2 ? 10 : 20;
  if (enemies.size() < targetEnemyCount() && frameCount - lastEnemyAddFrame >= addDelay) {
    addEnemyFarFromPlayer(true);
  }
}

void addEnemyFarFromPlayer(boolean markTime) {
  PVector p = randomPlayablePosition(120);
  int attempts = 0;

  while (dist(p.x, p.y, player.pos.x, player.pos.y) < 260 && attempts < 80) {
    p = randomPlayablePosition(120);
    attempts++;
  }

  enemies.add(new InkEnemy(p, random(44, 72), enemies.size() % 3));
  if (markTime) {
    lastEnemyAddFrame = frameCount;
  }
}

// ============================================================
// 阶段切换（普通 → 暗黑）
// ============================================================

void checkPhaseTransition() {
  if (!phase2Started && score >= PHASE_TWO_SCORE) {
    startPhaseTwo();
  }
}

void startPhaseTwo() {
  phase = 2;
  phase2Started = true;
  phaseTransitionTimer = PHASE_NOTICE_FRAMES;
  phaseTwoFrames = 0;
}

// ============================================================
// 通关故事
// ============================================================

void prepareStoryText() {
  storyText = "";
  for (int i = 0; i < storyLines.length; i++) {
    storyText += storyLines[i];
  }
}

void startStoryMode() {
  gameState = STORY;
  storyStartFrame = frameCount;
  storyVisibleChars = 0;
  storyDropStarted = false;
  resetStoryPieces();
}

void updateStory() {
  worldWind.set(0.10 * sin(frameCount * 0.014), 0.08 * cos(frameCount * 0.011));
  for (PaperScrap scrap : scraps) {
    scrap.update();
  }

  if (!storyDropStarted) {
    int elapsed = frameCount - storyStartFrame;
    storyVisibleChars = min(storyText.length(), elapsed * STORY_WRITE_STEP);
    return;
  }

  for (int i = 0; i < storyPieces.length; i++) {
    storyPieces[i].update();
  }
}

void resetStoryPieces() {
  storyPieces = new StoryPiece[storyLines.length];
  float lineX = width / 2;
  for (int i = 0; i < storyLines.length; i++) {
    float lineY = storyTextTop() + i * storyLineGap();
    storyPieces[i] = new StoryPiece(storyLines[i], lineX, lineY, i);
  }
}

boolean storyFinishedWriting() {
  return storyVisibleChars >= storyText.length();
}

float storyTextLeft() {
  return width * 0.16;
}

float storyTextRight() {
  return width * 0.84;
}

float storyTextTop() {
  return height / 2 - (storyLines.length - 1) * storyLineGap() / 2;
}

float storyLineGap() {
  return min(64, height * 0.075);
}

float storyTextSize() {
  return constrain(width * 0.017, 18, 25);
}

boolean storyPiecesGone() {
  if (storyPieces == null) {
    return false;
  }
  for (int i = 0; i < storyPieces.length; i++) {
    if (!storyPieces[i].gone()) {
      return false;
    }
  }
  return true;
}

// ============================================================
// 难度与速度
// ============================================================

float enemyDifficulty() {
  float normalTimePressure = min(2.20, (playFrames / 60.0) / NORMAL_SPEED_STEP_SECONDS * 0.22);

  if (phase == 2) {
    float darkTimePressure = min(4.80, (phaseTwoFrames / 60.0) / DARK_SPEED_STEP_SECONDS * 0.70);
    return normalTimePressure + 0.70 + darkBlend * 2.20 + darkTimePressure;
  }
  return normalTimePressure;
}

float playerSpeedBoost() {
  if (phase == 2) {
    return 1.0 + darkBlend * 0.32;
  }
  return 1.0;
}

// ============================================================
// 游戏画面绘制
// ============================================================

void drawGame() {
  drawPaperBackground();

  for (PaperScrap scrap : scraps) {
    scrap.display();
  }

  drawDirectionGuide();

  for (Stamp stamp : stamps) {
    stamp.display();
  }

  for (InkEnemy enemy : enemies) {
    enemy.display();
  }

  player.display();
  drawHUD();
  drawInstructionCard();
  drawPhaseTransitionNotice();
}

// ============================================================
// 开始 / 结束界面动画
// ============================================================

void updateAmbientScraps() {
  worldWind.set(0.06 * sin(frameCount * 0.011), 0.04 * cos(frameCount * 0.009));
  for (PaperScrap scrap : scraps) {
    scrap.update();
    scrap.display();
  }
}

// ============================================================
// 输入（只用鼠标）
// ============================================================

void mouseMoved() {
  if (gameState == START) {
    initGame();
    gameState = PLAYING;
    startGameplayMusic();
  } else if (gameState == GAME_OVER && frameCount - gameOverFrame > 35) {
    initGame();
    gameState = PLAYING;
    startGameplayMusic();
  }
}

void mouseClicked() {
  if (gameState == STORY && storyFinishedWriting() && !storyDropStarted) {
    storyDropStarted = true;
    resetStoryPieces();
  } else if (gameState == STORY && storyDropStarted && storyPiecesGone()) {
    initGame();
    gameState = PLAYING;
    startGameplayMusic();
  }
}

// ============================================================
// 音乐控制（实际播放逻辑在 AudioManager.java）
// ============================================================

void loadMusic() {
  audioManager = new AudioManager(dataPath(""));
  audioManager.load();
}

void startGameplayMusic() {
  musicActive = true;
  if (audioManager != null) {
    audioManager.start();
  }
}

void stopGameplayMusic() {
  musicActive = false;
  if (audioManager != null) {
    audioManager.stop();
  }
}

void updateMusic() {
  if (musicActive && audioManager != null) {
    audioManager.update(phase, phaseTwoFrames);
  }
}

// ============================================================
// 背景
// ============================================================

void drawPaperBackground() {
  background(COL_BG);
  drawUiImage(paperBackground, 0, 0, width, height);
  if (darkAmount() > 0) {
    drawDarkPaperOverlay();
  }
  if (gameState == PLAYING || gameState == STORY) {
    drawStoryGuideLines();
  }
}

// ============================================================
// 工具函数
// ============================================================

PVector randomPlayablePosition(float margin) {
  margin = max(margin, 48);
  return new PVector(random(margin, width - margin), random(margin, height - margin));
}

void wrapPosition(PVector p, float margin) {
  if (p.x < -margin) p.x = width + margin;
  if (p.x > width + margin) p.x = -margin;
  if (p.y < -margin) p.y = height + margin;
  if (p.y > height + margin) p.y = -margin;
}

float lerpAngle(float current, float target, float amount) {
  float diff = atan2(sin(target - current), cos(target - current));
  return current + diff * amount;
}

String scoreText(int value) {
  return nf(value, 3);  // 格式化为 3 位数字，如 "001"
}
