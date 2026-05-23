// PAPER DRIFT 主程序
// 这是整个游戏的入口我把状态分数难度音乐背景纹理都放在这里统一管理
// 草图需要用 Processing Java mode 打开 PaperDriftpde 来运行

// 状态索引 开始界面游戏中结束界面
int START = 0;
int PLAYING = 1;
int GAME_OVER = 2;
int STORY = 3;

// 当前游戏状态和基础数值
int gameState = START;
int score = 0;
int lives = 3;
int gameOverFrame = -1000;
int playFrames = 0;
int lastEnemyAddFrame = -1000;

// 难度参数敌人数量会按时间越来越多暗黑阶段上限更高
int START_ENEMY_COUNT = 10;
int MAX_ENEMY_COUNT = 18;
int DARK_MAX_ENEMY_COUNT = 60;
int NORMAL_ENEMY_SECONDS_PER_EXTRA = 2;

// 第二阶段参数达到 12 分进入暗黑模式
int PHASE_TWO_SCORE = 12;
int PHASE_TWO_MIN_ENEMIES = 20;
int PHASE_NOTICE_FRAMES = 180;
int PHASE_BLEND_FRAMES = 120;
int MUSIC_FADE_FRAMES = 120;

// 敌人速度也会随着时间增加这两个参数控制增长节奏
int NORMAL_SPEED_STEP_SECONDS = 12;
int DARK_SPEED_STEP_SECONDS = 5;
int STORY_SCORE = 24;
int STORY_WRITE_STEP = 3;

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

// phase1 是普通阶段phase2 是暗黑阶段phaseTransitionTimer 用来控制阶段切换时的过渡效果darkBlend 用来视觉上慢慢变暗
int phase = 1;
int phaseTransitionTimer = 0;
int phaseTwoFrames = 0;
float darkBlend = 0;
boolean phase2Started = false;

// 音乐由 AudioManagerjava 负责这里只保存对象和开关
boolean musicActive = false;
AudioManager audioManager;

// 游戏对象列表
Player player;
ArrayList<Stamp> stamps;
ArrayList<InkEnemy> enemies;
ArrayList<PaperScrap> scraps;

// 世界风用于背景物体轻微漂移
PVector worldWind = new PVector(0, 0);

// 字体
PFont titleFont;
PFont bodyFont;
PFont smallFont;
PFont storyFont;

// 主要配色尽量保持纸质暖色低饱和
int COL_BG = 0xFFF3EFE6;
int COL_CARD = 0xFFFFFDF7;
int COL_TEXT = 0xFF2F302B;
int COL_SAGE = 0xFFA7B89A;
int COL_YELLOW = 0xFFD8B75D;
int COL_PINK = 0xFFCFA6A0;
int COL_INK = 0xFFC9825A;
int COL_TAPE = 0xFFE6DCC5;

void settings() {
  // 全屏是项目要求smooth 让纸飞机和 UI 边缘更柔和
  fullScreen();
  smooth(4);
}

void setup() {
  // 固定 60 帧方便用 frameCount 计算秒数
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
  // draw 只根据状态分发不把所有逻辑塞在一起
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

void initGame() {
  // 每次开始或重开都重置所有游戏数据
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

  // 生成 20 个邮票收集物
  stamps = new ArrayList<Stamp>();
  for (int i = 0; i < 20; i++) {
    stamps.add(new Stamp(randomPlayablePosition(90), random(42, 62), i % 3));
  }

  // 生成初始敌人后面会按时间继续增加
  enemies = new ArrayList<InkEnemy>();
  for (int i = 0; i < START_ENEMY_COUNT; i++) {
    addEnemyFarFromPlayer(false);
  }

  // 背景纸片数量根据屏幕大小自动调整
  scraps = new ArrayList<PaperScrap>();
  int scrapCount = int(constrain((width * height) / 42000.0, 22, 44));
  for (int i = 0; i < scrapCount; i++) {
    scraps.add(new PaperScrap(random(width), random(height), random(34, 118), random(18, 78)));
  }
}

void updateGame() {
  // 游戏进行时的核心更新函数
  playFrames++;
  player.update(playerSpeedBoost());

  // worldWind 用玩家速度反方向制造一点世界漂移感
  worldWind.set(player.vel);
  worldWind.mult(phase == 2 ? -0.18 : -0.07);

  // 更新背景纸片
  for (PaperScrap scrap : scraps) {
    scrap.update();
  }

  // 邮票被收集后加分并重生
  for (Stamp stamp : stamps) {
    stamp.update();
    if (stamp.checkCollected(player)) {
      score++;
      stamp.respawn();
    }
  }

  // 分数够了就进入第二阶段同时根据时间补充敌人
  checkPhaseTransition();
  if (score >= STORY_SCORE) {
    startStoryMode();
    updateMusic();
    return;
  }

  updateEnemyCount();

  // 更新敌人并做伤害判定
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

  // 暗黑过渡不是瞬间切换而是用 darkBlend 慢慢变暗
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

int targetEnemyCount() {
  // 根据游戏时间计算当前应该有多少敌人
  int seconds = playFrames / 60;

  if (phase == 2) {
    // 暗黑阶段增加很快每秒 2 个上限 60
    int darkSeconds = phaseTwoFrames / 60;
    int target = PHASE_TWO_MIN_ENEMIES + darkSeconds * 2;
    if (target > DARK_MAX_ENEMY_COUNT) {
      target = DARK_MAX_ENEMY_COUNT;
    }
    return target;
  }

  // 普通阶段每 2 秒增加 1 个到 18 个为止
  int target = START_ENEMY_COUNT + seconds / NORMAL_ENEMY_SECONDS_PER_EXTRA;
  if (target > MAX_ENEMY_COUNT) {
    target = MAX_ENEMY_COUNT;
  }
  return target;
}

void updateEnemyCount() {
  // 不在同一帧一次性生成很多敌人避免突然卡顿
  int addDelay = phase == 2 ? 10 : 20;
  if (enemies.size() < targetEnemyCount() && frameCount - lastEnemyAddFrame >= addDelay) {
    addEnemyFarFromPlayer(true);
  }
}

void addEnemyFarFromPlayer(boolean markTime) {
  // 新敌人尽量生成在离玩家远一点的位置避免突然贴脸
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

void checkPhaseTransition() {
  // 第二阶段只允许触发一次
  if (!phase2Started && score >= PHASE_TWO_SCORE) {
    startPhaseTwo();
  }
}

void startPhaseTwo() {
  // 进入暗黑模式只设置状态视觉和速度由 darkBlend 慢慢过渡
  phase = 2;
  phase2Started = true;
  phaseTransitionTimer = PHASE_NOTICE_FRAMES;
  phaseTwoFrames = 0;
}

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

float enemyDifficulty() {
  // 敌人难度包含两部分普通阶段随时间增加暗黑阶段再额外增强
  float normalTimePressure = min(2.20, (playFrames / 60.0) / NORMAL_SPEED_STEP_SECONDS * 0.22);

  if (phase == 2) {
    float darkTimePressure = min(4.80, (phaseTwoFrames / 60.0) / DARK_SPEED_STEP_SECONDS * 0.70);
    return normalTimePressure + 0.70 + darkBlend * 2.20 + darkTimePressure;
  }
  return normalTimePressure;
}

float playerSpeedBoost() {
  // 暗黑阶段玩家也稍微提速否则敌人太快会不公平
  if (phase == 2) {
    return 1.0 + darkBlend * 0.32;
  }
  return 1.0;
}

void drawGame() {
  // 游戏画面的绘制顺序背景 装饰 物体 玩家 UI
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

void updateAmbientScraps() {
  // 开始和结束界面也让纸片轻微飘动不然画面会太静
  worldWind.set(0.06 * sin(frameCount * 0.011), 0.04 * cos(frameCount * 0.009));
  for (PaperScrap scrap : scraps) {
    scrap.update();
    scrap.display();
  }
}

void mouseMoved() {
  // 按项目要求不用键盘只用鼠标移动开始和重开
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

void loadMusic() {
  // 音乐是可选资源没有 wav 文件也不会影响游戏运行
  audioManager = new AudioManager(dataPath(""));
  audioManager.load();
}

void startGameplayMusic() {
  // 游戏开始时启动音乐循环
  musicActive = true;
  if (audioManager != null) {
    audioManager.start();
  }
}

void stopGameplayMusic() {
  // Game Over 时停止音乐避免结束界面还一直播放
  musicActive = false;
  if (audioManager != null) {
    audioManager.stop();
  }
}

void updateMusic() {
  // 每帧根据阶段更新音乐音量第二阶段淡入暗黑音乐
  if (musicActive && audioManager != null) {
    audioManager.update(phase, phaseTwoFrames);
  }
}

void drawPaperBackground() {
  // 背景和暗黑纸纹都从 PNG 加载，darkBlend 控制暗黑阶段平滑淡入。
  background(COL_BG);
  drawUiImage(paperBackground, 0, 0, width, height);
  if (darkAmount() > 0) {
    drawDarkPaperOverlay();
  }
  if (gameState == PLAYING || gameState == STORY) {
    drawStoryGuideLines();
  }
}

PVector randomPlayablePosition(float margin) {
  // 生成一个不会太靠近屏幕边缘的位置
  margin = max(margin, 48);
  return new PVector(random(margin, width - margin), random(margin, height - margin));
}

void wrapPosition(PVector p, float margin) {
  // 背景物体飘出屏幕后从另一边回来
  if (p.x < -margin) p.x = width + margin;
  if (p.x > width + margin) p.x = -margin;
  if (p.y < -margin) p.y = height + margin;
  if (p.y > height + margin) p.y = -margin;
}

float lerpAngle(float current, float target, float amount) {
  // 平滑旋转角度避免从 PI 到 PI 时突然转一大圈
  float diff = atan2(sin(target - current), cos(target - current));
  return current + diff * amount;
}

String scoreText(int value) {
  // 分数显示成 001012 这种海报 UI 的感觉
  return nf(value, 3);
}
