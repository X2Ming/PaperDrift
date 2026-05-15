// UI 和所有视觉绘制函数。
// 这个文件比较长，因为我尽量不用图片，而是用 Processing 图形函数画纸质界面。

boolean darkPaperMode() {
  // darkBlend 大于一点点时，就开始把 UI 当成暗黑模式来画。
  return darkBlend > 0.12;
}

float darkAmount() {
  // 限制在 0~1，方便后面做颜色渐变。
  return constrain(darkBlend, 0, 1);
}

int uiInkColor() {
  // 普通阶段是深灰墨水，暗黑阶段变成浅米色墨水。
  return lerpColor(COL_TEXT, 0xFFEDE1C8, darkAmount());
}

void fillUiInk(float alphaValue) {
  // 封装一下 fill，这样暗黑模式不用到处改颜色。
  int c = uiInkColor();
  fill(red(c), green(c), blue(c), alphaValue);
}

void strokeUiInk(float alphaValue) {
  // 和 fillUiInk 类似，用于线条颜色。
  int c = uiInkColor();
  stroke(red(c), green(c), blue(c), alphaValue);
}

void drawSoftShadow(float x, float y, float w, float h, float r) {
  // 纸卡阴影：普通阶段轻，暗黑阶段更重。
  noStroke();
  float d = darkAmount();
  fill(72, 52, 28, 10 * (1 - d));
  rect(x + 9, y + 11, w, h, r);
  fill(72, 52, 28, 7 * (1 - d));
  rect(x + 5, y + 6, w, h, r);

  fill(10, 7, 5, 54 * d);
  rect(x + 12, y + 14, w, h, r);
  fill(10, 7, 5, 34 * d);
  rect(x + 6, y + 7, w, h, r);
}

void drawPaperCard(float x, float y, float w, float h, float r) {
  // 所有 UI 卡片都用这个函数，保持风格统一。
  drawSoftShadow(x, y, w, h, r);
  float d = darkAmount();

  stroke(lerpColor(color(114, 100, 77, 32), color(236, 221, 193, 42), d));
  strokeWeight(1);
  fill(lerpColor(color(255, 253, 247, 228), color(54, 45, 38, 232), d));
  rect(x, y, w, h, r);

  noStroke();
  fill(lerpColor(color(255, 255, 251, 34), color(126, 95, 67, 24), d));
  rect(x + 6, y + 6, w - 12, h - 12, max(2, r - 4));
}

void drawHUD() {
  // 左上角 HUD 纸卡，显示标题、分数、生命和提示。
  float m = max(24, min(width, height) * 0.035);
  float w = 254;
  float h = 128;

  drawPaperCard(m, m, w, h, 14);

  fill(uiInkColor());
  textAlign(LEFT, TOP);
  textFont(smallFont);
  textSize(13);
  text("PAPER DRIFT", m + 22, m + 18);

  textSize(14);
  fillUiInk(172);
  text("Score", m + 22, m + 48);
  text("Lives", m + 132, m + 48);

  fill(uiInkColor());
  textFont(bodyFont);
  textSize(31);
  text(scoreText(score), m + 22, m + 65);

  drawLifeDots(m + 140, m + 76);

  textFont(smallFont);
  textSize(13);
  fillUiInk(160);
  if (phase == 2) {
    text("The paper darkens", m + 22, m + 103);
  } else {
    text("Move mouse to drift", m + 22, m + 103);
  }
}

void drawLifeDots(float x, float y) {
  // 生命值用三个小纸点表示，比普通游戏血条更符合参考图。
  for (int i = 0; i < 3; i++) {
    float dx = x + i * 24;
    noStroke();
    if (darkPaperMode()) {
      fill(9, 6, 4, 40);
    } else {
      fill(72, 52, 28, 15);
    }
    ellipse(dx + 2, y + 3, 17, 17);
    if (darkPaperMode()) {
      stroke(236, 221, 193, 48);
    } else {
      stroke(116, 101, 77, 38);
    }
    strokeWeight(1);
    if (i < lives) {
      if (darkPaperMode()) {
        fill(205, 171, 127, 230);
      } else {
        fill(230, 216, 194, 235);
      }
    } else {
      if (darkPaperMode()) {
        fill(64, 51, 42, 150);
      } else {
        fill(255, 253, 247, 98);
      }
    }
    ellipse(dx, y, 17, 17);
  }
}

void drawInstructionCard() {
  // 右下角操作提示卡，文字在暗黑阶段会换成更紧张的版本。
  float w = min(460, width * 0.46);
  float h = 74;
  float x = width - w - max(28, width * 0.035);
  float y = height - h - max(26, height * 0.04);

  drawPaperCard(x, y, w, h, 12);

  pushMatrix();
  translate(x + 31, y + h / 2);
  strokeUiInk(165);
  strokeWeight(1.5);
  noFill();
  rect(-8, -16, 16, 30, 8);
  line(0, -16, 0, -4);
  line(26, -24, 26, 24);
  popMatrix();

  fill(uiInkColor());
  textFont(smallFont);
  textSize(14);
  textAlign(LEFT, CENTER);
  String msg = phase == 2 ? "Survive the dark paper  \u00b7  Collect stamps  \u00b7  Avoid ghost ink" : "Move mouse to drift  \u00b7  Collect stamps  \u00b7  Avoid ink pieces";
  float tx = x + 76;
  if (textWidth(msg) < w - 94) {
    text(msg, tx, y + h / 2);
  } else {
    if (phase == 2) {
      text("Survive the dark paper", tx, y + 20);
      text("Collect stamps  \u00b7  Avoid ghost ink", tx, y + 43);
    } else {
      text("Move mouse to drift", tx, y + 20);
      text("Collect stamps  \u00b7  Avoid ink pieces", tx, y + 43);
    }
  }
}

void drawStartScreen() {
  // 开始界面：中心偏左的纸卡，参考图里的第一张 UI。
  drawPosterScraps();

  float cardW = min(455, width * 0.44);
  float cardH = min(570, height * 0.68);
  float x = width * 0.12;
  if (width < 900) x = (width - cardW) / 2;
  float y = (height - cardH) / 2 + height * 0.02;

  drawPaperCard(x, y, cardW, cardH, 18);

  float planeY = y + cardH * 0.27;
  drawDottedCurve(x + cardW * 0.58, planeY + 6, x + cardW * 0.77, planeY - 64, x + cardW * 0.69, planeY - 100);
  drawPaperAirplane(x + cardW * 0.45, planeY, 86, -0.52, false);

  fill(COL_TEXT);
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  textSize(min(42, cardW * 0.105));
  text("PAPER DRIFT", x + cardW / 2, y + cardH * 0.48);

  textFont(bodyFont);
  textSize(18);
  fill(47, 48, 43, 184);
  text("A gentle game of movement", x + cardW / 2, y + cardH * 0.56);
  text("and collection.", x + cardW / 2, y + cardH * 0.61);

  stroke(47, 48, 43, 82);
  strokeWeight(1);
  line(x + cardW * 0.41, y + cardH * 0.68, x + cardW * 0.59, y + cardH * 0.68);

  fill(47, 48, 43, 178);
  textFont(smallFont);
  textSize(16);
  text("Move mouse to begin", x + cardW / 2, y + cardH * 0.79);

  noStroke();
  fill(214, 199, 170, 135);
  ellipse(x + cardW * 0.86, y + cardH * 0.88, 58, 58);

  drawPosterLabel();
}

void drawGameOverScreen() {
  // 游戏结束界面：居中的纸卡，显示最终分数。
  drawPosterScraps();

  float cardW = min(435, width * 0.58);
  float cardH = min(485, height * 0.62);
  float x = (width - cardW) / 2;
  float y = (height - cardH) / 2;

  drawPaperCard(x, y, cardW, cardH, 18);
  drawTornPaperLip(x + 16, y - 6, cardW - 32, 30);

  drawSmallTrophy(x + cardW / 2, y + cardH * 0.18);

  fill(uiInkColor());
  textAlign(CENTER, CENTER);
  textFont(titleFont);
  textSize(min(36, cardW * 0.09));
  text("PAPER DRIFT", x + cardW / 2, y + cardH * 0.35);

  textFont(bodyFont);
  textSize(17);
  fillUiInk(174);
  if (phase == 2) {
    text("The dark paper goes quiet.", x + cardW / 2, y + cardH * 0.44);
  } else {
    text("The paper field is still.", x + cardW / 2, y + cardH * 0.44);
  }

  strokeUiInk(72);
  strokeWeight(1);
  line(x + cardW * 0.25, y + cardH * 0.51, x + cardW * 0.75, y + cardH * 0.51);

  textFont(smallFont);
  textSize(15);
  fillUiInk(165);
  text("Final Score", x + cardW / 2, y + cardH * 0.60);

  textFont(bodyFont);
  textSize(36);
  fill(uiInkColor());
  text(scoreText(score), x + cardW / 2, y + cardH * 0.69);

  fillUiInk(176);
  textFont(smallFont);
  textSize(16);
  text("Move mouse to restart", x + cardW / 2, y + cardH * 0.83);
}

void drawDirectionGuide() {
  // 中心方向线：让玩家知道鼠标方向正在控制飞机移动。
  float cx = width / 2.0;
  float cy = height / 2.0;
  PVector d = new PVector(mouseX - cx, mouseY - cy);
  float mag = d.mag();

  noStroke();
  fillUiInk(205);
  ellipse(cx, cy, 8, 8);

  if (mag > 18) {
    d.normalize();
    float lineLen = min(mag, min(width, height) * 0.22);
    float ex = cx + d.x * lineLen;
    float ey = cy + d.y * lineLen;
    strokeUiInk(116);
    strokeWeight(1.7);
    dashedLine(cx + d.x * 17, cy + d.y * 17, ex, ey, 9, 11);
    noStroke();
    fillUiInk(205);
    ellipse(ex, ey, 7, 7);
  }
}

void drawPaperAirplane(float x, float y, float s, float a, boolean invincible) {
  // 用 shape 和 line 画纸飞机，不用图片，这样更能体现 Processing 绘图。
  pushMatrix();
  translate(x, y);
  rotate(a);

  if (invincible) {
    noStroke();
    fill(167, 184, 154, 52);
    ellipse(0, 0, s * 1.18, s * 0.82);
  }

  strokeJoin(ROUND);
  strokeCap(ROUND);
  noStroke();
  fill(61, 48, 34, 26);
  beginShape();
  vertex(s * 0.58 + 5, 5);
  vertex(-s * 0.52 + 5, -s * 0.31 + 5);
  vertex(-s * 0.18 + 5, 0.03 * s + 5);
  vertex(-s * 0.38 + 5, s * 0.35 + 5);
  endShape(CLOSE);

  stroke(COL_TEXT);
  strokeWeight(max(1.3, s * 0.022));
  fill(255, 253, 247, 242);
  beginShape();
  vertex(s * 0.58, 0);
  vertex(-s * 0.52, -s * 0.31);
  vertex(-s * 0.17, s * 0.04);
  vertex(-s * 0.38, s * 0.35);
  endShape(CLOSE);

  fill(239, 232, 216, 236);
  beginShape();
  vertex(s * 0.58, 0);
  vertex(-s * 0.17, s * 0.04);
  vertex(-s * 0.38, s * 0.35);
  endShape(CLOSE);

  line(s * 0.58, 0, -s * 0.17, s * 0.04);
  line(s * 0.58, 0, -s * 0.52, -s * 0.31);
  line(-s * 0.17, s * 0.04, -s * 0.29, s * 0.31);

  stroke(47, 48, 43, 110);
  strokeWeight(max(0.8, s * 0.011));
  line(-s * 0.07, -s * 0.03, -s * 0.34, -s * 0.24);

  popMatrix();
}

void drawStamp(float x, float y, float s, int type, float rotation) {
  // 邮票收集物，有圆形和方形两种纸贴感觉。
  pushMatrix();
  translate(x, y);
  rotate(rotation);

  int baseCol = COL_SAGE;
  if (type == 1) baseCol = COL_YELLOW;
  if (type == 2) baseCol = COL_PINK;
  if (phase == 2) {
    baseCol = 0xFF78806C;
    if (type == 1) baseCol = 0xFF9B8144;
    if (type == 2) baseCol = 0xFF9C6F69;
  }

  noStroke();
  if (type == 1) {
    drawScallopedSquare(4, 6, s, 0xFF41301D, 25);
  } else {
    drawScallopedCircle(4, 6, s, 0xFF41301D, 25);
  }

  if (type == 1) {
    drawScallopedSquare(0, 0, s, baseCol, 220);
  } else {
    drawScallopedCircle(0, 0, s, baseCol, 220);
  }

  if (phase == 2) {
    stroke(231, 211, 177, 112);
  } else {
    stroke(255, 253, 247, 150);
  }
  strokeWeight(2);
  noFill();
  if (type == 1) {
    rectMode(CENTER);
    rect(0, 0, s * 0.68, s * 0.68, 9);
    rectMode(CORNER);
  } else {
    ellipse(0, 0, s * 0.62, s * 0.62);
  }

  if (phase == 2) {
    stroke(35, 25, 19, 58);
  } else {
    stroke(74, 62, 45, 32);
  }
  strokeWeight(1);
  for (int i = -2; i <= 2; i++) {
    line(-s * 0.23, i * s * 0.07, s * 0.23, i * s * 0.07 + sin(i) * 2);
  }

  popMatrix();
}

void drawInkBlot(float x, float y, float s, float seed, int type) {
  // 敌人本体：普通是墨渍，暗黑阶段会叠加鬼脸。
  pushMatrix();
  translate(x, y);

  noStroke();
  boolean dark = phase == 2;
  if (dark) {
    fill(8, 6, 5, 58);
    drawBlotShape(6, 9, s * 1.18, seed + 12, 0.0);

    fill(92, 45, 34, 218);
    drawBlotShape(0, 0, s * 1.08, seed, frameCount * 0.010);

    fill(148, 70, 47, 112);
    drawBlotShape(-s * 0.05, s * 0.05, s * 0.76, seed + 50, frameCount * 0.012);
  } else {
    fill(92, 54, 32, 20);
    drawBlotShape(4, 6, s * 1.05, seed + 12, 0.0);

    fill(201, 130, 90, 168);
    drawBlotShape(0, 0, s, seed, frameCount * 0.006);

    fill(201, 130, 90, 82);
    drawBlotShape(-s * 0.06, s * 0.05, s * 0.64, seed + 50, frameCount * 0.008);
  }

  if (dark) {
    fill(101, 46, 33, 172);
  } else {
    fill(201, 130, 90, 144);
  }
  int drops = (dark ? 8 : 5) + type;
  for (int i = 0; i < drops; i++) {
    float a = seed + i * TWO_PI / drops + sin(frameCount * 0.01 + i) * 0.05;
    float r = s * (0.42 + (dark ? 0.27 : 0.19) * noise(seed + i));
    float d = s * (0.10 + (dark ? 0.11 : 0.08) * noise(seed + i * 3.1));
    if (dark && i % 2 == 0) {
      pushMatrix();
      translate(cos(a) * r, sin(a) * r);
      rotate(a);
      ellipse(0, 0, d * 1.7, d * 0.78);
      popMatrix();
    } else {
      ellipse(cos(a) * r, sin(a) * r, d, d * randomStable(seed + i));
    }
  }

  if (dark) {
    drawGhostFace(s, seed, type);
  }

  popMatrix();
}

void drawBlotShape(float x, float y, float s, float seed, float t) {
  // 用 noise 做不规则墨渍边缘，避免太像普通圆形。
  beginShape();
  int steps = 34;
  for (int i = 0; i < steps; i++) {
    float a = map(i, 0, steps, 0, TWO_PI);
    float n = noise(seed + cos(a) * 0.8 + t, seed + sin(a) * 0.8 + t);
    float base = phase == 2 ? 0.29 : 0.34;
    float rough = phase == 2 ? 0.33 : 0.22;
    float r = s * (base + n * rough);
    vertex(x + cos(a) * r, y + sin(a) * r);
  }
  endShape(CLOSE);
}

void drawGhostFace(float s, float seed, int type) {
  // 暗黑阶段的鬼脸：眼洞、嘴巴、牙齿和裂纹。
  float breathe = sin(frameCount * 0.07 + seed) * s * 0.018;

  noStroke();
  fill(17, 11, 9, 226);
  ellipse(-s * 0.16 + breathe, -s * 0.10, s * 0.18, s * 0.28);
  ellipse(s * 0.16 - breathe * 0.5, -s * 0.12, s * 0.15, s * 0.25);

  fill(239, 217, 181, 40);
  ellipse(-s * 0.18 + breathe, -s * 0.16, s * 0.045, s * 0.03);
  ellipse(s * 0.14 - breathe * 0.5, -s * 0.18, s * 0.038, s * 0.026);

  fill(16, 10, 8, 235);
  if (type == 0) {
    beginShape();
    vertex(-s * 0.22, s * 0.14);
    vertex(-s * 0.10, s * 0.08);
    vertex(s * 0.07, s * 0.10);
    vertex(s * 0.23, s * 0.17);
    vertex(s * 0.11, s * 0.29);
    vertex(-s * 0.09, s * 0.28);
    endShape(CLOSE);
  } else if (type == 1) {
    ellipse(0, s * 0.18, s * 0.34, s * 0.25);
  } else {
    beginShape();
    vertex(-s * 0.25, s * 0.16);
    vertex(-s * 0.16, s * 0.09);
    vertex(-s * 0.07, s * 0.18);
    vertex(s * 0.02, s * 0.10);
    vertex(s * 0.10, s * 0.20);
    vertex(s * 0.24, s * 0.13);
    vertex(s * 0.18, s * 0.27);
    vertex(-s * 0.16, s * 0.28);
    endShape(CLOSE);
  }

  fill(236, 213, 179, 130);
  triangle(-s * 0.09, s * 0.13, -s * 0.02, s * 0.13, -s * 0.05, s * 0.22);
  triangle(s * 0.06, s * 0.13, s * 0.13, s * 0.14, s * 0.09, s * 0.23);

  stroke(21, 13, 10, 166);
  strokeWeight(max(1.2, s * 0.026));
  for (int i = 0; i < 4; i++) {
    float a = seed * 0.1 + i * 1.7;
    float sx = cos(a) * s * 0.18;
    float sy = sin(a) * s * 0.12;
    line(sx, sy, sx + cos(a + 0.7) * s * 0.22, sy + sin(a + 0.7) * s * 0.16);
  }
}

void drawScallopedCircle(float x, float y, float s, int baseCol, float alphaValue) {
  // 圆形邮票的齿边，用很多顶点绕一圈画出来。
  noStroke();
  fill(red(baseCol), green(baseCol), blue(baseCol), alphaValue);
  beginShape();
  int steps = 72;
  for (int i = 0; i < steps; i++) {
    float a = map(i, 0, steps, 0, TWO_PI);
    float wave = sin(a * 18) * 0.035;
    float r = s * (0.48 + wave);
    vertex(x + cos(a) * r, y + sin(a) * r);
  }
  endShape(CLOSE);
}

void drawScallopedSquare(float x, float y, float s, int baseCol, float alphaValue) {
  // 方形邮票的齿边，用一圈小圆点加中间方块。
  noStroke();
  fill(red(baseCol), green(baseCol), blue(baseCol), alphaValue);
  rectMode(CENTER);
  for (int i = -4; i <= 4; i++) {
    ellipse(x + i * s * 0.105, y - s * 0.42, s * 0.14, s * 0.14);
    ellipse(x + i * s * 0.105, y + s * 0.42, s * 0.14, s * 0.14);
    ellipse(x - s * 0.42, y + i * s * 0.105, s * 0.14, s * 0.14);
    ellipse(x + s * 0.42, y + i * s * 0.105, s * 0.14, s * 0.14);
  }
  rect(x, y, s * 0.84, s * 0.84, s * 0.12);
  rectMode(CORNER);
}

void drawPinnedCornerScraps() {
  // 屏幕角落的装饰纸片，让画面更像纸质海报。
  noStroke();
  fill(255, 253, 247, 58);
  pushMatrix();
  translate(width * 0.03, height * 0.04);
  rotate(-0.52);
  drawTornRect(0, 0, 92, 35, 210, 2);
  popMatrix();

  pushMatrix();
  translate(width * 0.90, height * 0.03);
  rotate(0.58);
  fill(COL_TAPE, 74);
  rect(0, 0, 126, 38, 2);
  popMatrix();

  pushMatrix();
  translate(width * 0.96, height * 0.62);
  rotate(0.74);
  fill(255, 253, 247, 72);
  drawTornRect(0, 0, 78, 48, 300, 2);
  popMatrix();
}

void drawDarkPaperOverlay() {
  // 暗黑纸纹已经提前生成，这里只按透明度叠加，减少切换卡顿。
  float d = darkAmount();
  if (darkPaperTexture == null || d <= 0) {
    return;
  }

  tint(255, 255 * d);
  image(darkPaperTexture, 0, 0);
  noTint();
}

void drawPhaseTransitionNotice() {
  // 进入暗黑阶段时出现的提示纸条。
  if (phaseTransitionTimer <= 0) {
    return;
  }

  float fadeIn = constrain((PHASE_NOTICE_FRAMES - phaseTransitionTimer) / 35.0, 0, 1);
  float fadeOut = constrain(phaseTransitionTimer / 45.0, 0, 1);
  float a = 210 * min(fadeIn, fadeOut);
  float w = min(460, width * 0.58);
  float h = 82;
  float x = (width - w) / 2;
  float y = height * 0.17;

  noStroke();
  fill(8, 5, 4, a * 0.24);
  rect(x + 8, y + 10, w, h, 8);
  stroke(235, 218, 184, a * 0.32);
  strokeWeight(1);
  fill(57, 44, 34, a * 0.82);
  rect(x, y, w, h, 8);

  fill(237, 224, 201, a);
  textAlign(CENTER, CENTER);
  textFont(bodyFont);
  textSize(22);
  text("THE PAPER DARKENS", x + w / 2, y + h * 0.43);

  fill(237, 224, 201, a * 0.64);
  textFont(smallFont);
  textSize(13);
  text("ghost ink wakes beneath the folds", x + w / 2, y + h * 0.70);
}

void drawPosterScraps() {
  // 开始和结束界面用的额外纸片装饰。
  noStroke();
  fill(255, 253, 247, 96);
  pushMatrix();
  translate(width * 0.61, height * 0.08);
  rotate(-0.12);
  drawTornRect(0, 0, 210, 70, 28, 3);
  popMatrix();

  fill(COL_TAPE, 122);
  pushMatrix();
  translate(width * 0.73, height * 0.12);
  rotate(0.07);
  rect(0, 0, 130, 34, 2);
  popMatrix();

  fill(255, 253, 247, 86);
  pushMatrix();
  translate(width * 0.03, height * 0.82);
  rotate(-0.62);
  drawTornRect(0, 0, 92, 62, 89, 2);
  popMatrix();
}

void drawPosterLabel() {
  // 右上角像设计稿标签一样的小纸片。
  float w = min(390, width * 0.30);
  float h = 74;
  float x = width - w - width * 0.08;
  float y = height * 0.09;

  if (width < 900) {
    return;
  }

  drawSoftShadow(x, y, w, h, 3);
  noStroke();
  fill(255, 253, 247, 150);
  drawTornRect(x + w / 2, y + h / 2, w, h, 440, 3);
  fill(COL_TEXT);
  textFont(smallFont);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("Processing Game UI Concept", x + w / 2, y + h * 0.38);
  textSize(14);
  fill(47, 48, 43, 178);
  text("Warm  \u00b7  Minimal  \u00b7  Playful", x + w / 2, y + h * 0.68);
}

void drawTornPaperLip(float x, float y, float w, float h) {
  // Game Over 卡片上方的撕纸边。
  noStroke();
  if (darkPaperMode()) {
    fill(84, 67, 52, 178);
  } else {
    fill(255, 253, 247, 158);
  }
  drawTornRect(x + w / 2, y + h / 2, w, h, 818, 2);
  if (darkPaperMode()) {
    stroke(236, 221, 193, 32);
  } else {
    stroke(126, 108, 82, 30);
  }
  line(x + 10, y + h - 2, x + w - 10, y + h - 4);
}

void drawSmallTrophy(float x, float y) {
  // 用简单线条画一个奖杯，不用图标素材。
  pushMatrix();
  translate(x, y);
  stroke(uiInkColor());
  strokeWeight(1.7);
  noFill();
  arc(-19, -8, 18, 23, -HALF_PI, HALF_PI);
  arc(19, -8, 18, 23, HALF_PI, PI + HALF_PI);
  if (darkPaperMode()) {
    fill(77, 60, 45, 220);
  } else {
    fill(255, 253, 247, 210);
  }
  rectMode(CENTER);
  rect(0, -8, 35, 35, 2);
  line(-12, 11, -6, 23);
  line(12, 11, 6, 23);
  rect(0, 27, 24, 5, 1);
  rectMode(CORNER);
  for (int i = -2; i <= 2; i++) {
    float xx = i * 15;
    line(xx, -37, xx + i * 2, -43);
  }
  popMatrix();
}

void drawDottedCurve(float x1, float y1, float x2, float y2, float x3, float y3) {
  // 开始界面纸飞机后面的虚线轨迹。
  stroke(COL_TEXT, 112);
  strokeWeight(1.5);
  noFill();
  PVector last = null;
  for (int i = 0; i <= 34; i++) {
    float t = i / 34.0;
    float xa = lerp(x1, x2, t);
    float ya = lerp(y1, y2, t);
    float xb = lerp(x2, x3, t);
    float yb = lerp(y2, y3, t);
    PVector now = new PVector(lerp(xa, xb, t), lerp(ya, yb, t));
    if (last != null && i % 3 != 0) {
      line(last.x, last.y, now.x, now.y);
    }
    last = now;
  }
}

void dashedLine(float x1, float y1, float x2, float y2, float dash, float gap) {
  // 自己写的虚线函数，Processing 默认没有直接的 dashed line。
  PVector a = new PVector(x1, y1);
  PVector b = new PVector(x2, y2);
  PVector d = PVector.sub(b, a);
  float len = d.mag();
  if (len <= 0.1) return;
  d.normalize();

  for (float distAlong = 0; distAlong < len; distAlong += dash + gap) {
    float end = min(distAlong + dash, len);
    line(a.x + d.x * distAlong, a.y + d.y * distAlong, a.x + d.x * end, a.y + d.y * end);
  }
}

void drawTornRect(float cx, float cy, float w, float h, float seed, float roughness) {
  // 画撕纸边矩形。四条边都用 noise 加一点抖动。
  beginShape();
  int perSide = 6;
  for (int i = 0; i <= perSide; i++) {
    float t = i / float(perSide);
    float jitter = (noise(seed, t * 4.0) - 0.5) * roughness * 3.2;
    vertex(cx - w / 2 + t * w, cy - h / 2 + jitter);
  }
  for (int i = 0; i <= perSide; i++) {
    float t = i / float(perSide);
    float jitter = (noise(seed + 10, t * 4.0) - 0.5) * roughness * 3.2;
    vertex(cx + w / 2 + jitter, cy - h / 2 + t * h);
  }
  for (int i = 0; i <= perSide; i++) {
    float t = i / float(perSide);
    float jitter = (noise(seed + 20, t * 4.0) - 0.5) * roughness * 3.2;
    vertex(cx + w / 2 - t * w, cy + h / 2 + jitter);
  }
  for (int i = 0; i <= perSide; i++) {
    float t = i / float(perSide);
    float jitter = (noise(seed + 30, t * 4.0) - 0.5) * roughness * 3.2;
    vertex(cx - w / 2 + jitter, cy + h / 2 - t * h);
  }
  endShape(CLOSE);
}

float randomStable(float seed) {
  // 根据 seed 得到稳定的随机感，避免每帧乱跳。
  return 0.72 + noise(seed * 0.21) * 0.55;
}
