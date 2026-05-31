// user 
// 我把移动旋转受伤无敌都放在这里主程序只需要调用 updatedisplay
class Player {
  // pos 是位置vel 是速度angle 用来让纸飞机朝着移动方向旋转
  PVector pos;
  PVector vel;
  float angle;
  float radius;
  int invincibleTimer;

  Player(PVector start) {
    // 构造函数游戏开始时给纸飞机一个初始位置
    pos = start.copy();
    vel = new PVector(0, 0);
    angle = -0.25;
    radius = 30;
    invincibleTimer = 0;
  }

  void update(float speedBoost) {
    // 鼠标不是直接控制飞机位置而是控制从屏幕中心指向鼠标的方向
    PVector mouseDir = new PVector(mouseX - width / 2.0, mouseY - height / 2.0);
    float mag = mouseDir.mag();

    // deadZone 是死区鼠标接近中心时飞机会慢下来
    float deadZone = min(width, height) * 0.035;
    float maxControl = min(width, height) * 0.43;
    float maxSpeed = constrain(min(width, height) * 0.007, 4.0, 7.4) * speedBoost;

    if (mag > deadZone) {
      // 鼠标离中心越远速度越接近最大速度
      mouseDir.normalize();
      float strength = map(constrain(mag, deadZone, maxControl), deadZone, maxControl, 0, 1);
      mouseDir.mult(maxSpeed * strength);
      PVector desired = mouseDir;
      // lerp 让飞机慢慢跟上目标速度有漂移感
      vel.lerp(desired, 0.065);
    } else {
      // 鼠标回到中间飞机慢慢减速
      vel.mult(0.93);
    }

    pos.add(vel);

    // 限制飞机不要飞出屏幕
    float pad = radius + 22;
    if (pos.x < pad) {
      pos.x = pad;
      vel.x *= -0.18;
    }
    if (pos.x > width - pad) {
      pos.x = width - pad;
      vel.x *= -0.18;
    }
    if (pos.y < pad) {
      pos.y = pad;
      vel.y *= -0.18;
    }
    if (pos.y > height - pad) {
      pos.y = height - pad;
      vel.y *= -0.18;
    }

    if (vel.mag() > 0.08) {
      // 飞机朝向速度方向而不是固定朝右
      angle = lerpAngle(angle, vel.heading(), 0.11);
    }

    // 受伤后的无敌时间倒计时
    if (invincibleTimer > 0) {
      invincibleTimer--;
    }
  }

  void display() {
    // 无敌时闪烁提示玩家现在不会再次扣血
    if (isInvincible() && frameCount % 12 < 5) {
      return;
    }

    drawPaperAirplane(pos.x, pos.y, radius * 2.9, angle, isInvincible());
  }

  void damage() {
    // 被敌人碰到后 90 帧无敌大概 15 秒
    invincibleTimer = 90;
  }

  boolean isInvincible() {
    // 只要计时器大于 0 就算无敌
    return invincibleTimer > 0;
  }

  float hitRadius() {
    // 玩家碰撞体积比飞机核心略大一点，手感上更贴近视觉轮廓
    return radius * 1.12;
  }
}
