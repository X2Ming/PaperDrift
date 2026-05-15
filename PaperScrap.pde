// 背景纸片类。
// 这些不是玩法物体，只是为了让纸质海报有层次和漂浮感。
class PaperScrap {
  PVector pos;
  PVector vel;
  float w;
  float h;
  float angle;
  float spin;
  float alpha;
  float seed;
  int style;

  PaperScrap(float x, float y, float wide, float high) {
    // 每张纸片都有不同大小、角度、透明度和旋转速度。
    pos = new PVector(x, y);
    vel = PVector.random2D();
    vel.mult(random(0.015, 0.16));
    w = wide;
    h = high;
    angle = random(TWO_PI);
    spin = random(-0.0015, 0.0015);
    alpha = random(62, 125);
    seed = random(1000);
    style = int(random(3));
  }

  void update() {
    // 暗黑阶段纸片飘得更快，配合整体节奏变紧张。
    float driftBoost = 1.0 + darkBlend * 0.75;
    pos.x += vel.x * driftBoost + worldWind.x * 0.65;
    pos.y += vel.y * driftBoost + worldWind.y * 0.65;
    angle += spin * driftBoost;
    wrapPosition(pos, max(w, h) + 60);
  }

  void display() {
    // 用 torn rect 画不规则纸片，不直接用图片素材。
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);

    // 先画一个很淡的阴影。
    noStroke();
    fill(88, 70, 46, 13);
    drawTornRect(4, 5, w, h, seed + 9, 3);

    // 再画纸片本体。
    if (style == 1) {
      fill(230, 220, 198, alpha * 0.72);
    } else {
      fill(255, 253, 247, alpha);
    }
    stroke(128, 112, 86, alpha * 0.18);
    strokeWeight(1);
    drawTornRect(0, 0, w, h, seed, 3);

    // 纸片上的细线模拟纸纤维。
    stroke(160, 142, 112, alpha * 0.16);
    strokeWeight(0.7);
    for (int i = 0; i < 3; i++) {
      float yy = map(i, 0, 2, -h * 0.25, h * 0.25);
      line(-w * 0.34, yy, w * 0.34, yy + sin(seed + i) * 3);
    }

    popMatrix();
  }
}
