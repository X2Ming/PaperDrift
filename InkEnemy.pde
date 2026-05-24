// ink enemies
// two stages: normal and dark
class InkEnemy {
  PVector pos;
  PVector vel; //speed and direction
  float size; // base size, will be visually scaled up in dark stage
  int type; // enemy type 0-3, determines the shape of the ink blot
  float blotSeed; // each enemy has own random seed, so can has different path

  InkEnemy(PVector start, float s, int t) {
    // each enemy has own random seed, so can has different path
    pos = start.copy();
    size = s;
    type = t;
    vel = PVector.random2D();
    vel.mult(random(0.2, 0.7));
    blotSeed = random(1000);
  }

  void update(Player p, float difficulty) {
    // give a small push for enemy to chase the player, the pull strength depends on the distance and difficulty level
    PVector toPlayer = PVector.sub(p.pos, pos);
    float d = max(1, toPlayer.mag());
    toPlayer.normalize();

    float pull = map(constrain(d, 80, 620), 80, 620, 0.010, 0.040);
    // difficulty is a value between 0 and 1, higher and the enemy will faster.
    pull *= 1.0 + difficulty * 0.78;
    // the pull strength is also affected by the distance to the player, closer enemies will be pulled more strongly
    toPlayer.mult(pull);
    vel.add(toPlayer);

    // enemy will use mendering movement to make the path less predictable, 
    // the meandering strength also depends on the difficulty level
    PVector meander = new PVector(sin(frameCount * 0.014 + blotSeed), cos(frameCount * 0.011 + blotSeed));
    meander.mult(0.010 + difficulty * 0.010);
    vel.add(meander);
    // limit the max speed; prevent enemies from flying off the screen 
    vel.limit((1.18 + type * 0.08) * (1.0 + difficulty * 0.95));

    pos.add(vel);
    pos.x += worldWind.x * 0.35;
    pos.y += worldWind.y * 0.35;

    // prevent enemy from going off the screen, and bounce back with some energy loss when hitting the edge
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
    // larger size enemy
    drawInkBlot(pos.x, pos.y, visualBaseSize(), blotSeed, type);
  }

  float visualBaseSize() {
    return size * (1.0 + darkBlend * 0.18);
  }

  float hitRadius() {
    // kepp the hit radius in line with the visual size, so that the collision feels more fair to the player. 
    // The hit radius is slightly smaller than half of the visual size, to give players a bit of leeway when dodging.
    float imageDiameter = visualBaseSize() * (1.58 + darkAmount() * 0.20);
    return imageDiameter * 0.5;
  }

  boolean hits(Player p) {
    // enmey hits the player when the distance between them is less than the sum of their hit radii, 
    // which means their hit circles are touching or overlapping.
    return PVector.dist(pos, p.pos) < p.hitRadius() + hitRadius();
  }
}
