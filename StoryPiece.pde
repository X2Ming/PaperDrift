// ending story sentence fragments
// after clicking, each line drifts down like loose text on the paper surface
class StoryPiece {
  // position, velocity, and visual state for the falling text
  String textLine;
  PVector pos;
  PVector vel;
  float gravity;
  float baseFallSpeed;
  float alphaValue;
  float angle;
  float spin;
  int index;

  StoryPiece(String t, float x, float y, int i) {
    // initialize each fragment with slight random drift and rotation
    textLine = t;
    pos = new PVector(x, y);
    index = i;

    // longer lines feel heavier and fall faster
    float lengthPower = constrain(textLine.length() / 48.0, 0.55, 1.55);
    vel = new PVector(random(-0.34, 0.34), 0);
    gravity = 0.055 + lengthPower * 0.070;
    baseFallSpeed = 1.05 + lengthPower * 1.25 + index * 0.08;
    alphaValue = 235;
    angle = random(-0.018, 0.018);
    spin = random(-0.0025, 0.0025);
  }

  void update() {
    // accelerate downward and fade out over time
    vel.y += gravity;
    pos.x += vel.x;
    pos.y += vel.y + baseFallSpeed;
    angle += spin;
    alphaValue = max(0, alphaValue - 1.05);
  }

  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);

    int c = uiInkColor();
    fill(red(c), green(c), blue(c), alphaValue);
    textAlign(CENTER, CENTER);
    textFont(storyFont);
    textSize(storyTextSize());
    text(textLine, 0, 0);

    popMatrix();
  }

  boolean gone() {
    // fragment is off-screen or fully transparent
    return pos.y > height + 90 || alphaValue <= 2;
  }
}
