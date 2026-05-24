// UI 和视觉资源绘制函数
// 这一版把复杂纸质 UI 改成 PNG 导入，运行时只负责布局、缩放和少量动态文字。

PImage paperBackground;
PImage darkOverlay;

PImage hudLight;
PImage hudDark;
PImage instructionLight;
PImage instructionDark;
PImage startPanel;
PImage gameOverLight;
PImage gameOverDark;
PImage phaseNotice;
PImage planeAsset;
PImage posterLabel;
PImage posterScrapLarge;
PImage posterScrapSmall;
PImage posterTape;

PImage enemyInk;
PImage enemyGhost;
PImage scrapLight;
PImage scrapWarm;
PImage scrapFaint;

PImage[] stampLight = new PImage[3];
PImage[] stampDark = new PImage[3];
PImage lifeFullLight;
PImage lifeEmptyLight;
PImage lifeFullDark;
PImage lifeEmptyDark;

void loadUiAssets() {
  paperBackground = loadUiImage("paper_background.png");
  darkOverlay = loadUiImage("dark_overlay.png");

  hudLight = loadUiImage("hud_light.png");
  hudDark = loadUiImage("hud_dark.png");
  instructionLight = loadUiImage("instruction_light.png");
  instructionDark = loadUiImage("instruction_dark.png");
  startPanel = loadUiImage("start_panel.png");
  gameOverLight = loadUiImage("game_over_light.png");
  gameOverDark = loadUiImage("game_over_dark.png");
  phaseNotice = loadUiImage("phase_notice.png");
  planeAsset = loadUiImage("plane.png");
  posterLabel = loadUiImage("poster_label.png");
  posterScrapLarge = loadUiImage("poster_scrap_large.png");
  posterScrapSmall = loadUiImage("poster_scrap_small.png");
  posterTape = loadUiImage("poster_tape.png");

  enemyInk = loadUiImage("enemy_ink.png");
  enemyGhost = loadUiImage("enemy_ghost.png");
  scrapLight = loadUiImage("scrap_light.png");
  scrapWarm = loadUiImage("scrap_warm.png");
  scrapFaint = loadUiImage("scrap_faint.png");

  stampLight[0] = loadUiImage("stamp_sage.png");
  stampLight[1] = loadUiImage("stamp_yellow.png");
  stampLight[2] = loadUiImage("stamp_pink.png");
  stampDark[0] = loadUiImage("stamp_sage_dark.png");
  stampDark[1] = loadUiImage("stamp_yellow_dark.png");
  stampDark[2] = loadUiImage("stamp_pink_dark.png");

  lifeFullLight = loadUiImage("life_full_light.png");
  lifeEmptyLight = loadUiImage("life_empty_light.png");
  lifeFullDark = loadUiImage("life_full_dark.png");
  lifeEmptyDark = loadUiImage("life_empty_dark.png");
}

PImage loadUiImage(String fileName) {
  PImage img = loadImage("ui/" + fileName);
  if (img == null) {
    println("Missing UI image: data/ui/" + fileName);
  }
  return img;
}


float darkAmount() {
  return constrain(darkBlend, 0, 1);
}

int uiInkColor() {
  return lerpColor(COL_TEXT, 0xFFF5F0E0, darkAmount());
}

void fillUiInk(float alphaValue) {
  int c = uiInkColor();
  fill(red(c), green(c), blue(c), alphaValue);
}

void strokeUiInk(float alphaValue) {
  int c = uiInkColor();
  stroke(red(c), green(c), blue(c), alphaValue);
}

void drawUiImage(PImage img, float x, float y, float w, float h) {
  drawUiImage(img, x, y, w, h, 255);
}

void drawUiImage(PImage img, float x, float y, float w, float h, float alphaValue) {
  if (img == null || alphaValue <= 0) {
    return;
  }
  pushStyle();
  tint(255, constrain(alphaValue, 0, 255));
  image(img, x, y, w, h);
  popStyle();
}

void drawBlendedUiImage(PImage lightImg, PImage darkImg, float x, float y, float w, float h) {
  float d = darkAmount();
  drawUiImage(lightImg, x, y, w, h, 255 * (1 - d));
  drawUiImage(darkImg, x, y, w, h, 255 * d);
}

void drawCenteredUiImage(PImage img, float x, float y, float w, float h, float rotation, float alphaValue) {
  if (img == null || alphaValue <= 0) {
    return;
  }
  pushMatrix();
  pushStyle();
  translate(x, y);
  rotate(rotation);
  imageMode(CENTER);
  tint(255, constrain(alphaValue, 0, 255));
  image(img, 0, 0, w, h);
  popStyle();
  popMatrix();
}

void drawHUD() {
  float m = max(24, min(width, height) * 0.035);
  float w = 254;
  float h = 128;

  drawBlendedUiImage(hudLight, hudDark, m, m, w, h);

  int scoreColor = lerpColor(COL_TEXT, 0xFFFFFFFF, darkAmount());
  fill(scoreColor);
  textAlign(LEFT, TOP);
  textFont(bodyFont);
  textSize(31);
  text(scoreText(score), m + 22, m + 65);

  drawLifeDots(m + 140, m + 76);

  textFont(smallFont);
  textSize(13);
  int hintColor = lerpColor(COL_TEXT, 0xFFEEEEE8, darkAmount());
  fill(red(hintColor), green(hintColor), blue(hintColor), 160 + 60 * darkAmount());
  if (phase == 2) {
    text("The paper darkens", m + 22, m + 103);
  } else {
    text("Move mouse to drift", m + 22, m + 103);
  }
}

void drawLifeDots(float x, float y) {
  float d = darkAmount();
  for (int i = 0; i < 3; i++) {
    float dx = x + i * 24;
    PImage lightImg = i < lives ? lifeFullLight : lifeEmptyLight;
    PImage darkImg = i < lives ? lifeFullDark : lifeEmptyDark;
    drawCenteredUiImage(lightImg, dx, y, 28, 28, 0, 255 * (1 - d));
    drawCenteredUiImage(darkImg, dx, y, 28, 28, 0, 255 * d);
  }
}

void drawInstructionCard() {
  float w = min(460, width * 0.46);
  float h = 74;
  float x = width - w - max(28, width * 0.035);
  float y = height - h - max(26, height * 0.04);

  drawBlendedUiImage(instructionLight, instructionDark, x, y, w, h);
}

void drawStartScreen() {
  drawPosterScraps();

  float cardW = min(455, width * 0.44);
  float cardH = min(570, height * 0.68);
  float x = width * 0.12;
  if (width < 900) {
    x = (width - cardW) / 2;
  }
  float y = (height - cardH) / 2 + height * 0.02;

  drawUiImage(startPanel, x, y, cardW, cardH);
  drawPosterLabel();

  float planeW = min(340, width * 0.28);
  float planeH = planeW * 0.70;
  drawCenteredUiImage(planeAsset, width * 0.73, height * 0.47, planeW, planeH, -0.06, 220);
}

void drawGameOverScreen() {
  drawPosterScraps();

  float cardW = min(435, width * 0.58);
  float cardH = min(485, height * 0.62);
  float x = (width - cardW) / 2;
  float y = (height - cardH) / 2;

  drawBlendedUiImage(gameOverLight, gameOverDark, x, y, cardW, cardH);

  int gameOverTextColor = lerpColor(COL_TEXT, 0xFFFFFFFF, darkAmount());
  fill(gameOverTextColor);
  textAlign(CENTER, CENTER);
  textFont(bodyFont);
  textSize(36);
  text(scoreText(score), x + cardW / 2, y + cardH * 0.69);
}

void drawStoryScreen() {
  drawPaperBackground();

  for (PaperScrap scrap : scraps) {
    scrap.display();
  }

  float centerX = width / 2;
  float top = storyTextTop();
  float gap = storyLineGap();
  float storyBottom = top + (storyLines.length - 1) * gap;

  textAlign(CENTER, CENTER);

  fillUiInk(226);
  textFont(titleFont);
  textSize(56);
  text("YOU WIN", centerX, top - gap * 1.8);

  fillUiInk(185);
  textFont(smallFont);
  textSize(13);
  text("PAGE COMPLETE", centerX, top - gap * 0.4);

  fillUiInk(226);
  textFont(storyFont);
  textSize(storyTextSize());

  if (storyDropStarted) {
    for (int i = 0; i < storyPieces.length; i++) {
      storyPieces[i].display();
    }
  } else {
    drawStoryWritingText(centerX, top, gap);
  }

  textFont(smallFont);
  textSize(14);
  fillUiInk(150);
  if (!storyFinishedWriting()) {
    text("The page is remembering", centerX, storyBottom + gap * 1.5);
  } else if (!storyDropStarted) {
    text("Click to release the sentences", centerX, storyBottom + gap * 1.5);
  } else if (storyPiecesGone()) {
    text("Click to restart the paper field", centerX, storyBottom + gap * 1.5);
  }
}

void drawStoryWritingText(float centerX, float top, float gap) {
  int remaining = storyVisibleChars;
  int cursorLine = -1;
  String cursorText = "";

  for (int i = 0; i < storyLines.length; i++) {
    String lineText = storyLines[i];
    int visible = constrain(remaining, 0, lineText.length());
    if (visible > 0) {
      String part = lineText.substring(0, visible);
      text(part, centerX, top + i * gap);
      cursorLine = i;
      cursorText = part;
    }
    remaining -= lineText.length();
  }

  if (!storyFinishedWriting() && cursorLine >= 0) {
    float cursorX = centerX + textWidth(cursorText) / 2 + 8;
    float cursorY = top + cursorLine * gap;
    noStroke();
    fillUiInk(190 + 45 * sin(frameCount * 0.22));
    ellipse(cursorX, cursorY + 1, 7, 7);
  }
}

void drawStoryGuideLines() {
  float left = storyTextLeft();
  float right = storyTextRight();
  float top = storyTextTop();
  float gap = storyLineGap();
  float a = gameState == STORY ? 92 : 26;

  strokeUiInk(a);
  strokeWeight(gameState == STORY ? 1.3 : 0.8);
  noFill();

  for (int i = 0; i < storyLines.length; i++) {
    float y = top + i * gap + storyTextSize() * 0.56;
    beginShape();
    for (float x = left; x <= right; x += 54) {
      float wobble = (noise(i * 9.7, x * 0.006) - 0.5) * (gameState == STORY ? 4.0 : 2.0);
      vertex(x, y + wobble);
    }
    vertex(right, y + (noise(i * 9.7, right * 0.006) - 0.5) * 2.0);
    endShape();
  }
}

void drawDirectionGuide() {
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
  if (invincible) {
    noStroke();
    fill(167, 184, 154, 52);
    ellipse(x, y, s * 1.18, s * 0.82);
  }
  drawCenteredUiImage(planeAsset, x, y, s * 1.42, s, a, 255);
}

void drawStamp(float x, float y, float s, int type, float rotation) {
  int idx = constrain(type, 0, 2);
  float d = darkAmount();
  float visualSize = s * 1.14;
  drawCenteredUiImage(stampLight[idx], x, y, visualSize, visualSize, rotation, 255 * (1 - d));
  drawCenteredUiImage(stampDark[idx], x, y, visualSize, visualSize, rotation, 255 * d);
}

void drawInkBlot(float x, float y, float s) {
  float d = darkAmount();
  float visualSize = s * (1.58 + d * 0.20);
  drawCenteredUiImage(enemyInk, x, y, visualSize, visualSize, 0, 255 * (1 - d));
  drawCenteredUiImage(enemyGhost, x, y, visualSize, visualSize, 0, 255 * d);
}

void drawPaperScrapAsset(int style, float w, float h, float alphaValue) {
  PImage img = scrapLight;
  if (style == 1) {
    img = scrapWarm;
  } else if (style == 2) {
    img = scrapFaint;
  }
  drawCenteredUiImage(img, 0, 0, w * 1.45, h * 1.75, 0, alphaValue);
}

void drawDarkPaperOverlay() {
  drawUiImage(darkOverlay, 0, 0, width, height, 255 * darkAmount());
}

void drawPhaseTransitionNotice() {
  if (phaseTransitionTimer <= 0) {
    return;
  }

  float fadeIn = constrain((PHASE_NOTICE_FRAMES - phaseTransitionTimer) / 35.0, 0, 1);
  float fadeOut = constrain(phaseTransitionTimer / 45.0, 0, 1);
  float alphaValue = 255 * min(fadeIn, fadeOut);
  float w = min(460, width * 0.58);
  float h = 82;
  float x = (width - w) / 2;
  float y = height * 0.17;

  drawUiImage(phaseNotice, x, y, w, h, alphaValue);
}

void drawPosterScraps() {
  drawCenteredUiImage(posterScrapLarge, width * 0.61, height * 0.08, 235, 95, -0.12, 255);
  drawCenteredUiImage(posterTape, width * 0.73, height * 0.12, 150, 56, 0.07, 255);
  drawCenteredUiImage(posterScrapSmall, width * 0.03, height * 0.82, 112, 82, -0.62, 255);
}

void drawPosterLabel() {
  if (width < 900) {
    return;
  }

  float w = min(390, width * 0.30);
  float h = 74;
  float x = width - w - width * 0.08;
  float y = height * 0.09;
  drawUiImage(posterLabel, x, y, w, h);
}

void dashedLine(float x1, float y1, float x2, float y2, float dash, float gap) {
  PVector a = new PVector(x1, y1);
  PVector b = new PVector(x2, y2);
  PVector d = PVector.sub(b, a);
  float len = d.mag();
  if (len <= 0.1) {
    return;
  }
  d.normalize();

  for (float distAlong = 0; distAlong < len; distAlong += dash + gap) {
    float end = min(distAlong + dash, len);
    line(a.x + d.x * distAlong, a.y + d.y * distAlong, a.x + d.x * end, a.y + d.y * end);
  }
}
