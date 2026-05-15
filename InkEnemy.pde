// 墨渍敌人类。
// 普通阶段像橙色墨点，暗黑阶段由 UI 绘制成鬼脸墨渍。
class InkEnemy {
  PVector pos;
  PVector vel;
  float size;
  int type;
  float blotSeed;

  InkEnemy(PVector start, float s, int t) {
    // 每个敌人有自己的随机种子，所以墨渍形状不会完全一样。
    pos = start.copy();
    size = s;
    type = t;
    vel = PVector.random2D();
    vel.mult(random(0.2, 0.7));
    blotSeed = random(1000);
  }

  void update(Player p, float difficulty) {
    // 朝玩家方向产生一个很小的拉力，这样敌人会追但不是瞬移。
    PVector toPlayer = PVector.sub(p.pos, pos);
    float d = max(1, toPlayer.mag());
    toPlayer.normalize();

    float pull = map(constrain(d, 80, 620), 80, 620, 0.010, 0.040);
    // difficulty 会随时间和暗黑阶段变大，所以敌人越来越凶。
    pull *= 1.0 + difficulty * 0.78;
    toPlayer.mult(pull);
    vel.add(toPlayer);

    // meander 是一点随机游动感，像墨水在纸上飘。
    PVector meander = new PVector(sin(frameCount * 0.014 + blotSeed), cos(frameCount * 0.011 + blotSeed));
    meander.mult(0.010 + difficulty * 0.010);
    vel.add(meander);
    // 限制最大速度，否则后期会快到看不清。
    vel.limit((1.18 + type * 0.08) * (1.0 + difficulty * 0.95));

    pos.add(vel);
    pos.x += worldWind.x * 0.35;
    pos.y += worldWind.y * 0.35;

    // 碰到边缘会反弹一点，不让敌人卡在屏幕外。
    float margin = size * 0.7;
    if (pos.x < margin || pos.x > width - margin) {
      vel.x *= -0.72;
      pos.x = constrain(pos.x, margin, width - margin);
    }
    if (pos.y < margin || pos.y > height - margin) {
      vel.y *= -0.72;
      pos.y = constrain(pos.y, margin, height - margin);
    }
  }

  void display() {
    // 暗黑阶段敌人视觉上变大一点，压迫感更强。
    float visualSize = size;
    visualSize *= 1.0 + darkBlend * 0.18;
    drawInkBlot(pos.x, pos.y, visualSize, blotSeed, type);
  }

  boolean hits(Player p) {
    // 用圆形距离判断碰撞，简单也方便解释。
    return PVector.dist(pos, p.pos) < p.radius + size * 0.36;
  }
}
