// 背景纸片类
// 这些不是玩法物体只是为了让纸质海报有层次和漂浮感
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
    // 每张纸片都有不同大小角度透明度和旋转速度
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
    // 暗黑阶段纸片飘得更快配合整体节奏变紧张
    float driftBoost = 1.0 + darkBlend * 0.75;
    pos.x += vel.x * driftBoost + worldWind.x * 0.65;
    pos.y += vel.y * driftBoost + worldWind.y * 0.65;
    angle += spin * driftBoost;
    wrapPosition(pos, max(w, h) + 60);
  }

  void display() {
    // 纸片外观改成 PNG 资源，运行时只保留位置、旋转和透明度。
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    drawPaperScrapAsset(style, w, h, alpha);
    popMatrix();
  }
}
