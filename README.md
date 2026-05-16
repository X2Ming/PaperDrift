# PAPER DRIFT

## 项目简介 Project Overview

**PAPER DRIFT** 是一个全屏 Processing Java 互动游戏，用于 Interactive Art and Design final project。项目把“高级纸质互动海报”和“鼠标控制小游戏”结合在一起，玩家控制一架手绘纸飞机，在纸面世界中漂移、收集印章、躲避墨渍敌人，并在后期进入暗黑纸质阶段。

**PAPER DRIFT** is a full-screen Processing Java game that combines a premium paper-craft poster interface with a mouse-controlled drifting game. The player guides a hand-drawn paper airplane through a paper field, collects stamp-like tokens, avoids ink enemies, and eventually enters a darker second phase.

视觉风格保持温暖、极简、纸艺感：米白纸纹、圆角纸卡、柔和阴影、纸屑拼贴、低饱和印章、陶土橙墨迹、暗黑阶段的深咖纸面，以及通关后的英文故事纸页。项目刻意避开赛博风、霓虹风、黑色 HUD 和普通街机小游戏界面。

The visual direction stays close to the reference image: warm paper texture, rounded paper cards, soft shadows, paper scraps, muted stamps, clay-orange ink blots, a dark paper phase, and a final story page written across fill-in lines. It avoids cyberpunk, neon, black arcade HUD panels, and full-image UI shortcuts.

---

## 如何运行 How To Run

1. 安装 Processing 4.x
2. 用 Processing 打开 `PaperDrift` 文件夹
3. 运行 `PaperDrift.pde`
4. 移动鼠标开始游戏

The sketch uses `fullScreen()` and does not require keyboard input during gameplay.

可选背景音乐放在：

```text
PaperDrift/data/bgm.wav
```

当前版本只使用一首背景音乐。程序会依次尝试加载 `bgm.wav`、`bgm.mp3`，再尝试 `data/` 文件夹里找到的第一个 `.wav` 或 `.mp3` 文件。Java Sound 对 `.wav` 最稳定。如果音乐不存在或格式不支持，游戏仍然可以正常运行，只会在控制台输出提示。

The current version uses one background music loop only. It first tries `bgm.wav`, then `bgm.mp3`, then the first `.wav` or `.mp3` file found in `data/`. `.wav` is the most reliable format for Java Sound. If loading fails, the game continues without music.

---

## 玩法 Gameplay

- 玩家是一架纸飞机
- 鼠标相对屏幕中心的位置控制移动方向和速度
- 纸飞机不会瞬移到鼠标位置，而是平滑加速和漂移
- 收集印章会增加分数
- 碰到墨渍敌人会减少生命
- 玩家初始有 3 条命
- 受伤后会短暂无敌
- 生命归零后进入 Game Over 纸卡界面
- Game Over 后移动鼠标重新开始
- 分数达到 24 后进入通关故事纸页

---

## 难度与阶段 Difficulty And Stages

### 普通阶段 Normal Stage

- 开局有 10 个墨渍敌人
- 敌人数每 2 秒增加 1 个
- 普通阶段敌人数上限是 18
- 敌人速度会随着游戏时间逐渐提升
- 玩家仍然保持温和漂移手感

### 暗黑纸质阶段 Dark Paper Stage

当分数达到 12 时进入第二阶段。

- 背景在约 2 秒内逐渐变暗
- 屏幕出现纸质提示 `THE PAPER DARKENS`
- 敌人变成带鬼脸的墨渍
- 敌人数量会补充到至少 20 个
- 暗黑阶段每 1 秒增加 2 个敌人
- 暗黑阶段敌人数上限是 60
- 敌人的追踪力和最大速度显著提高
- 玩家速度也同步提升，保证仍然可操作
- 两个阶段使用同一首背景音乐

---

## 通关故事 Completion Story

当分数达到 24 时，游戏不再无限继续，而是切换到通关故事纸页。

When the score reaches 24, the game enters a completion story page instead of continuing forever.

- 背景出现填字用的横线
- 英文故事像文字蛇一样从上到下快速写满横线
- 文字全部出现后，玩家点击一次
- 故事会按照句子拆开
- 每个句子在重力效果下向下坠落并逐渐消失
- 句子越长，基础下落速度和重力越大
- 所有句子消失后再次点击可以重新开始游戏

Story text:

```text
The page remembers every fold.
Some marks sleep where the light cannot reach.
When the stamps drift apart, the quiet begins to tear.
Ink gathers under the paper skin.
A small plane carries the scattered pieces home.
Line by line, the page learns how to breathe again.
```

---

## 项目架构 Project Architecture

项目由多个 Processing 标签页和一个普通 Java 辅助类组成。这样安排方便展示课程要求里的类、数组、函数、循环、条件判断、碰撞检测、鼠标交互和音频处理。

The project is organized into Processing tabs/classes plus one plain Java helper class.

```text
PaperDrift/
  PaperDrift.pde       主草图，游戏状态，setup/draw 循环，难度，阶段，故事模式
  Player.pde           纸飞机玩家，鼠标漂移，旋转，受伤，无敌
  Stamp.pde            印章收集物，碰撞检测，重生逻辑
  InkEnemy.pde         墨渍敌人，追踪玩家，速度增长，碰撞检测
  PaperScrap.pde       背景纸屑，漂浮移动，纸质装饰
  StoryPiece.pde       通关故事句子，重力下落，透明度消失
  UI.pde               纸质 UI，HUD，卡片，飞机，印章，墨渍，鬼脸，故事横线
  AudioManager.java    Java Sound 音乐加载，循环播放，失败降级
  data/                可选的单首背景音乐文件
```

### `PaperDrift.pde`

主控制文件，负责游戏大流程。

Main controller for the sketch.

Responsibilities:

- 定义 `START`、`PLAYING`、`GAME_OVER`、`STORY` 四个状态
- 创建全屏画布
- 初始化字体、纸张纹理、暗黑纸纹、音乐、玩家、印章、敌人、纸屑
- 管理分数、生命、游戏时间、阶段状态
- 普通阶段和暗黑阶段的敌人数量增长
- 分数到 12 触发暗黑阶段
- 分数到 24 触发故事结算
- 使用 `darkBlend` 让暗黑切换更平滑
- 调用 `AudioManager` 播放背景音乐
- 准备故事文本并控制写入与下落状态

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
- `prepareStoryText()`
- `startStoryMode()`
- `updateStory()`
- `storyPiecesGone()`
- `generatePaperTexture()`
- `generateDarkPaperTexture()`

### `Player.pde`

玩家类实现鼠标控制的平滑漂移。

Fields:

- `PVector pos`
- `PVector vel`
- `float angle`
- `float radius`
- `int invincibleTimer`

Key behavior:

- 读取屏幕中心到鼠标位置的向量
- 用 `PVector.lerp()` 平滑速度
- 根据移动方向旋转纸飞机
- 限制玩家不离开屏幕
- 受伤后短暂无敌并闪烁

### `Stamp.pde`

印章类代表可收集对象。

Fields:

- `PVector pos`
- `float size`
- `int type`
- `boolean collected`
- `float wobbleSeed`

Key behavior:

- 随世界风向轻微漂动
- 与玩家做圆形碰撞检测
- 被收集后加分
- 在远离玩家的位置重生

### `InkEnemy.pde`

敌人类控制墨渍移动与碰撞。

Fields:

- `PVector pos`
- `PVector vel`
- `float size`
- `int type`
- `float blotSeed`

Key behavior:

- 慢慢朝玩家转向
- 从主草图接收 `difficulty`
- 难度越高，追踪力和最大速度越高
- 暗黑阶段外观会变大并出现鬼脸
- 使用圆形距离判断碰撞

### `PaperScrap.pde`

纸屑类用于背景装饰和纸面漂浮感。

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

- 在屏幕上缓慢漂浮
- 超出边界后从另一侧回绕
- 暗黑阶段移动更快
- 用程序图形画撕纸矩形

### `StoryPiece.pde`

故事句子碎片类用于通关后的下坠动画。

Fields:

- `String textLine`
- `PVector pos`
- `PVector vel`
- `float gravity`
- `float baseFallSpeed`
- `float alphaValue`
- `float angle`
- `float spin`

Key behavior:

- 保存一整句英文故事
- 点击后从原本横线位置开始下坠
- 句子长度影响下落速度和重力
- 下落时轻微旋转并逐渐透明
- 消失后允许重新开始

### `UI.pde`

视觉系统文件，负责大部分纸质界面绘制。

Responsibilities:

- 绘制纸卡和柔和阴影
- 绘制开始界面
- 绘制游戏 HUD
- 绘制右下角提示卡
- 绘制 Game Over 界面
- 绘制方向引导线
- 绘制纸飞机
- 绘制印章贴纸
- 绘制不规则墨渍
- 暗黑阶段绘制鬼脸
- 绘制暗黑纸张覆盖层
- 绘制故事横线、故事写入文字和提示文字

Important functions:

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
- `drawStoryGuideLines()`
- `drawStoryScreen()`
- `drawStoryWritingText()`

### `AudioManager.java`

音频单独放在普通 Java 文件中，是为了避免 Processing PDE 预处理器误判 Java Sound 的方法调用。

Responsibilities:

- 从 `data/` 文件夹加载一个可选音乐文件
- 优先尝试 `bgm.wav`
- 再尝试 `bgm.mp3`
- 再尝试其他 `.wav` 或 `.mp3`
- 游戏开始时循环播放
- Game Over 时停止
- 文件缺失或格式不支持时安全跳过

---

## 使用到的 Processing 概念 Processing Concepts

- Classes and objects
- `ArrayList`
- `PVector`
- Functions
- Loops
- Conditional statements
- Collision detection
- Mouse interaction
- Game state management
- Procedural drawing with `beginShape()`, `vertex()`, `ellipse()`, `rect()`, and `line()`
- Procedural paper texture generation using `noise()`
- Time-based difficulty growth
- Phase transition with gradual visual blending
- Java Sound audio integration
- Text animation and gravity effects

---

## 设计说明 Design Notes

这个项目的重点不是把图片贴到屏幕上，而是用 Processing 的图形函数画出纸质海报感。大部分 UI、玩家、敌人、印章、纸屑和故事文字都由代码生成。唯一可选外部资源是一首背景音乐。

The project focuses on procedural drawing rather than placing a full-image UI on the canvas. Most UI objects, the player, enemies, stamps, scraps, and story text are generated with Processing shapes and logic. The only optional external asset is one background music file.

整体风格关键词：

- warm paper
- minimal poster UI
- soft shadow
- muted color
- handcrafted shapes
- dark paper horror phase
- serif story ending

---

## 编译检查 Build Check

This project has been checked with Processing 4.5.2 CLI:

```powershell
processing-java --sketch="D:\Code\iad\finalProject\PaperDrift" --output="D:\Code\iad\finalProject\.processing-build\PaperDrift" --force --build
```

Expected output:

```text
Finished.
```
