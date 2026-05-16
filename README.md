```markdown name=README.md
# PAPER DRIFT ✈️📄

**PAPER DRIFT** 是一个全屏的 Processing（Java）游戏 🎮，用于互动艺术与设计课程的期末项目 🎓。项目把温暖的纸艺海报式界面 🧻🧡 和“鼠标控制的漂移玩法”🖱️💨 结合在一起。

整体视觉方向刻意做成“纸”的感觉：偏米白的纸张纹理 🤍📜、圆角纸卡 🟨🟧、柔和阴影 🌥️、纸屑拼贴 🧩、低饱和印章 🪭、陶土橙色墨迹 🧡🖋️，以及第二阶段的深色纸张模式 🌑📄。风格上刻意避开赛博朋克与冷硬科技感 🚫🤖。

---

## 如何运行 ▶️🛠️

1. 安装 Processing 4.x ✅
2. 用 Processing 打开 `PaperDrift` 文件夹 📂
3. 运行 `PaperDrift.pde` ▶️
4. 移动鼠标即可开始 🖱️✨

该草图使用 `fullScreen()` 🖥️，游戏过程中不需要键盘操作 ⌨️🚫。

可选音乐可以放在这里 🎵📁：

```text
PaperDrift/data/bgm.wav
```

代码也会尝试加载 `data/` 目录下找到的第一个 `.wav` 或 `.mp3` 文件 🔎🎶，但对 Processing 的 Java Sound 来说 `.wav` 通常最稳定 ✅。如果音乐无法加载，游戏仍然可以正常运行 👍🎮。

---

## 玩法说明 🕹️📌

- 玩家是一架纸飞机 ✈️📄
- 鼠标位置相对“屏幕中心”的方向与距离，决定移动方向与速度 🖱️🎯
- 纸飞机不会瞬移到鼠标位置 🚫✨，而是会平滑加速并带漂移感地移动 💨🌊
- 收集“印章”会增加分数 🪭➕🔢
- “墨迹敌人”会对玩家造成伤害 🖋️👾💥
- 玩家初始有 3 条命 ❤️❤️❤️
- 受伤后会短暂无敌 🛡️⏳
- 生命归零后会显示 Game Over 纸卡 🪧😵
- Game Over 后移动鼠标可重新开始 🔄🖱️

---

## 难度与阶段 📈🌓

### 普通阶段 ☀️📄

- 开始时有 10 个墨迹敌人 👾×10
- 敌人数每 2 秒增加 1 个 ⏱️➕1
- 普通阶段敌人数上限为 18 👾🔒
- 敌人移动速度会随时间逐渐增加 🏃‍♂️💨📈

### 深色纸张阶段 🌑📄

当分数达到 **12** 时进入第二阶段 🎯12➡️🌑。

- 背景会在 2 秒内逐渐变暗 🌒⏳
- 出现提示纸卡：`THE PAPER DARKENS` 🪧🖤
- 敌人变成带“幽灵脸”的墨迹斑点 👻🖋️
- 敌人数会跃升到至少 20 个 👾⬆️20
- 敌人数每 1 秒增加 2 个 ⏱️➕2
- 深色阶段敌人数上限为 60 👾🔒60
- 敌人的追踪能力与速度大幅增强 🧠⚡💨
- 玩家速度也会增加，保证仍然可控 ✈️💨✅
- 两个阶段使用同一段背景音乐 🎵🔁

---

## 项目架构 🧩🏗️

项目由多个 Processing 标签页/类 + 1 个纯 Java 辅助类组成 👇

```text
PaperDrift/
  PaperDrift.pde       主草图：游戏状态、setup/draw循环、难度、阶段系统
  Player.pde           纸飞机移动/旋转/显示、受伤与无敌
  Stamp.pde            印章：收集、碰撞、重生逻辑
  InkEnemy.pde         墨迹敌人：移动、追踪、碰撞、显示接口
  PaperScrap.pde       背景纸屑：环境漂浮与装饰
  UI.pde               纸质UI、HUD、卡片、印章、墨迹、幽灵脸、暗色覆盖层
  AudioManager.java    Java Sound 音乐加载/循环/失败处理
  data/                可选的 WAV 音乐资源
```

---

### `PaperDrift.pde` 🧠🎮（主控制器）

这是草图的主控制文件。

**职责：**
- 定义游戏状态：`START`、`PLAYING`、`GAME_OVER` 🧾➡️🎮➡️💀
- 创建全屏画布 🖥️
- 初始化字体、程序生成纸张纹理、音频、玩家、印章、敌人、纸屑等 🎨🔊✨
- 更新游戏循环 🔁
- 记录分数、生命、游戏时间与阶段状态 🧮❤️⏱️
- 控制敌人数随时间增长 👾📈
- 分数到 12 触发深色纸张阶段 🎯🌑
- 管理 `darkBlend`（让过渡更平滑，不是瞬间切换）🌗➡️🌑
- 通过 `AudioManager` 调用兼容 `processing-java` 的 Java Sound 音频逻辑 🔊✅

**重要函数：**
- `setup()` 🛠️
- `draw()` 🎨
- `initGame()` 🔄
- `updateGame()` 🔁
- `drawGame()` 🖼️
- `targetEnemyCount()` 🎯👾
- `updateEnemyCount()` 👾➕
- `checkPhaseTransition()` 🌓🔎
- `startPhaseTwo()` 🌑🚀
- `enemyDifficulty()` 👾📈
- `playerSpeedBoost()` ✈️⚡
- `generatePaperTexture()` 📄🧪
- `generateDarkPaperTexture()` 🌑📄🧪

---

### `Player.pde` ✈️🖱️（玩家：平滑漂移）

玩家类实现“鼠标驱动的平滑漂移”。

**字段：**
- `PVector pos` 📍
- `PVector vel` 💨
- `float angle` 🧭
- `float radius` ⭕
- `int invincibleTimer` 🛡️⏳

**关键行为：**
- 读取从屏幕中心指向鼠标的向量 🎯
- 用 `PVector.lerp()` 将向量变成平滑的速度变化 🌊
- 纸飞机朝移动方向旋转 🔄✈️
- 限制移动不越界 🧱🚫
- 无敌期间闪烁提示 ✨🛡️

---

### `Stamp.pde` 🪭✨（印章：可收集物）

印章类代表可收集对象。

**字段：**
- `PVector pos` 📍
- `float size` 📏
- `int type` 🏷️
- `boolean collected` ✅/❌
- `float wobbleSeed` 🌿

**关键行为：**
- 随世界移动轻微漂动 🍃
- 与玩家做碰撞检测 💥
- 被收集时通过主草图增加分数 ➕🔢
- 在远离玩家的位置重生 🔄📍

---

### `InkEnemy.pde` 🖋️👾（敌人：墨迹斑点）

敌人类控制墨迹斑点移动与碰撞。

**字段：**
- `PVector pos` 📍
- `PVector vel` 💨
- `float size` 📏
- `int type` 🏷️
- `float blotSeed` 🌑

**关键行为：**
- 缓慢转向追踪玩家 🧲👤
- 从主草图接收 `difficulty` 难度值 📈
- 用难度增强：牵引力、游走运动、最大速度 ⚡🏃‍♂️
- 深色阶段通过 `darkBlend` 视觉上变大 🌑➡️⬆️
- 使用圆形碰撞检测对玩家造成伤害 ⭕💥

---

### `PaperScrap.pde` 🧻🍂（纸屑：背景装饰粒子）

纸屑是让海报界面更有生命感的装饰粒子。

**字段：**
- `PVector pos` 📍
- `PVector vel` 💨
- `float w` 📏
- `float h` 📏
- `float angle` 🧭
- `float spin` 🌀
- `float alpha` 🌫️
- `float seed` 🌱
- `int style` 🎭

**关键行为：**
- 在屏幕上漂浮移动 🌬️
- 到边缘后从另一侧回绕 ♻️
- 深色模式下移动更快 🌑💨
- 用程序化形状函数画“撕裂纸片矩形”✂️📄

---

### `UI.pde` 🎨🪧（主要视觉系统）

该标签页包含大部分视觉表现。

**职责：**
- 画纸卡与柔和阴影 🧾🌥️
- 绘制开始界面、游戏 HUD、说明卡、Game Over 界面 🪧📌💀
- 绘制纸飞机 ✈️
- 绘制带波浪贴纸边缘的印章 🪭🧷
- 绘制墨迹敌人 🖋️👾
- 深色模式绘制幽灵脸 👻
- 从屏幕中心到鼠标绘制方向引导线 🧭➡️🖱️
- 绘制预渲染的深色纸覆盖层 🌑🖼️

**重要视觉函数：**
- `drawPaperCard()` 🧾
- `drawSoftShadow()` 🌥️
- `drawHUD()` 📌
- `drawStartScreen()` 🚀
- `drawGameOverScreen()` 💀
- `drawDirectionGuide()` 🧭
- `drawPaperAirplane()` ✈️
- `drawStamp()` 🪭
- `drawInkBlot()` 🖋️
- `drawGhostFace()` 👻
- `drawDarkPaperOverlay()` 🌑
- `drawPhaseTransitionNotice()` 🪧🌓

---

### `AudioManager.java` 🔊🎵（音频管理）

音频放在纯 Java 文件里，而不是 `.pde` 标签页，是因为 Processing 的 PDE 预处理器可能会误解析某些 Java Sound 调用 💥🧩。放在 `AudioManager.java` 可以避免这些语法问题 ✅🧠。

**职责：**
- 从 `data/` 里加载可选 WAV 文件 📂🎶
- 启动背景音乐循环 🔁
- 深色阶段音乐在第二阶段前保持静音 🌑🔇
- 播放一条背景音乐循环 🎵
- 若缺少或不支持音频，安全降级不崩溃 🧯✅

---

## 展示的 Processing 概念 🧪📚

- 类与对象 🧱
- `ArrayList` 📋
- `PVector` 📍💨
- 函数 🧩
- 循环 🔁
- 条件逻辑 🔀
- 碰撞检测 💥
- 程序化绘制：`beginShape()`、`vertex()`、`ellipse()`、`rect()`、`line()` 🎨🖊️
- 使用 `noise()` 与随机点/线生成纸张纹理 🌫️📄
- 鼠标交互 🖱️
- 游戏状态管理 🧾
- 难度随时间推进 📈⏱️
- 通过 Java Sound 集成音频 🔊☕️

---

## 设计说明 🧡🧻

项目采用“纸质海报界面”而不是标准街机 UI 🪧🎮。大多数视觉元素都用 Processing 程序化绘制 ✍️🎨。唯一可选的外部资源是两段 WAV 背景音乐 🎵📁。

---

## 构建检查 ✅🧪

该项目已使用 Processing 4.5.2 CLI 检查通过：

```powershell
processing-java --sketch="D:\Code\iad\finalProject\PaperDrift" --output="D:\Code\iad\finalProject\.processing-build\PaperDrift" --force --build
```

期望输出：

```text
Finished.
```
```
