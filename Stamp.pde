// collectible stamps — drift / collect / respawn

class Stamp {
  PVector pos;
  float size;
  int type;          // 0-2: sage / yellow / pink
  boolean collected;
  float wobbleSeed;  // unique seed so each stamp wobbles differently

  Stamp(PVector start, float s, int t) {
    pos = start.copy();
    size = s;
    type = t;
    collected = false;
    wobbleSeed = random(1000);
  }

  // drift with world wind + sine wobble
  void update() {
    pos.x += worldWind.x * 0.45 + sin(frameCount * 0.012 + wobbleSeed) * 0.08;
    pos.y += worldWind.y * 0.45 + cos(frameCount * 0.010 + wobbleSeed) * 0.06;
    wrapPosition(pos, size + 40);
  }

  void display() {
    if (!collected) {
      float wobble = sin(frameCount * 0.018 + wobbleSeed) * 0.035;
      drawStamp(pos.x, pos.y, size, type, wobble);
    }
  }

  // distance check against player
  boolean checkCollected(Player p) {
    if (collected) {
      return false;
    }
    if (PVector.dist(pos, p.pos) < p.radius + size * 0.42) {
      collected = true;
      return true;
    }
    return false;
  }

  // move to a new spot away from the player
  void respawn() {
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
