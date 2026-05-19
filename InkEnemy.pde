// 墨渍敌人
// 普通阶段像橙色墨点暗黑阶段由 UI 绘制成鬼脸墨渍
class InkEnemy {
  PVector pos;
  PVector vel;
  float size;
  int type;
  float blotSeed;

  InkEnemy(PVector start, float s, int t) {
    // 每个敌人有自己的随机种子所以墨渍形状不会完全一样
    pos = start.copy();
    size = s;
    type = t;
    vel = PVector.random2D();
    vel.mult(random(0.2, 0.7));
    blotSeed = random(1000);
  }

  void update(Player p, float difficulty) {
    // 朝玩家方向产生一个很小的拉力敌人会慢慢追过来
    PVector toPlayer = PVector.sub(p.pos, pos);
    float d = max(1, toPlayer.mag());
    toPlayer.normalize();

    float pull = map(constrain(d, 80, 620), 80, 620, 0.010, 0.040);
    // difficulty 会随时间和暗黑阶段变大敌人更有攻击性
    pull *= 1.0 + difficulty * 0.78;
    toPlayer.mult(pull);
    vel.add(toPlayer);

    // 敌人会有一点随机游荡的行为不会完全直线追玩家这样更有生命力
    PVector meander = new PVector(sin(frameCount * 0.014 + blotSeed), cos(frameCount * 0.011 + blotSeed));
    meander.mult(0.010 + difficulty * 0.010);
    vel.add(meander);
    // 限制最大速度
    vel.limit((1.18 + type * 0.08) * (1.0 + difficulty * 0.95));

    pos.add(vel);
    pos.x += worldWind.x * 0.35;
    pos.y += worldWind.y * 0.35;

    // 碰到边缘会反弹一点不让敌人卡在屏幕外
    float margin = hitRadius();
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
    // 暗黑阶段敌人视觉上变大一点压迫感更强
    drawInkBlot(pos.x, pos.y, visualBaseSize(), blotSeed, type);
  }

  float visualBaseSize() {
    return size * (1.0 + darkBlend * 0.18);
  }

  float hitRadius() {
    // UI.pde 里 drawInkBlot 会再按贴图视觉比例放大，这里保持碰撞半径和实际显示大小一致。
    float imageDiameter = visualBaseSize() * (1.58 + darkAmount() * 0.20);
    return imageDiameter * 0.5;
  }

  boolean hits(Player p) {
    // 敌人碰撞体积跟屏幕上的实际贴图大小一致，玩家体积略微放大。
    return PVector.dist(pos, p.pos) < p.hitRadius() + hitRadius();
  }
}
