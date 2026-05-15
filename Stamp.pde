// 邮票类：玩家要收集的得分物。
// 每个邮票有类型和尺寸，显示时会有一点轻微晃动。
class Stamp {
  PVector pos;
  float size;
  int type;
  boolean collected;
  float wobbleSeed;

  Stamp(PVector start, float s, int t) {
    // 保存初始位置、大小和颜色类型。
    pos = start.copy();
    size = s;
    type = t;
    collected = false;
    wobbleSeed = random(1000);
  }

  void update() {
    // 邮票会跟着世界风轻微漂移，避免画面太死。
    pos.x += worldWind.x * 0.45 + sin(frameCount * 0.012 + wobbleSeed) * 0.08;
    pos.y += worldWind.y * 0.45 + cos(frameCount * 0.010 + wobbleSeed) * 0.06;
    wrapPosition(pos, size + 40);
  }

  void display() {
    // collected 只是防止同一帧重复收集，真正重生在 respawn 里。
    if (!collected) {
      float wobble = sin(frameCount * 0.018 + wobbleSeed) * 0.035;
      drawStamp(pos.x, pos.y, size, type, wobble);
    }
  }

  boolean checkCollected(Player p) {
    // 距离小于碰撞半径就算收集成功。
    if (collected) {
      return false;
    }

    float hitDistance = p.radius + size * 0.42;
    if (PVector.dist(pos, p.pos) < hitDistance) {
      collected = true;
      return true;
    }
    return false;
  }

  void respawn() {
    // 收集后换一个离玩家不太近的位置重新出现。
    pos = randomPlayablePosition(90);
    while (PVector.dist(pos, player.pos) < 190) {
      pos = randomPlayablePosition(90);
    }
    size = random(42, 62);
    type = int(random(3));
    wobbleSeed = random(1000);
    collected = false;
  }
}
