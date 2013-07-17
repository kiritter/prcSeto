/* @pjs preload="img/background.jpg, img/ship.png"; */

BG bg;
Mover ship;
ArrayList<Mover> birds;
final int NUM_BIRDS = 8;

//--------------------------------------------------
void setup(){
  initWindow();
  initObjects();
}
void initWindow() {
  size(640, 480);
  smooth();
  frameRate(12);
}
void initObjects() {
  PImage imgBackground = loadImage("img/background.jpg");
  bg = new BG(imgBackground);

  PImage imgShip = loadImage("img/ship.png");
  PImage imgLight = loadImage("img/redlight.png");
  ship = new Ship(imgShip, imgLight);
  
  birds = new ArrayList<Mover>();
  for (int i = 0; i < NUM_BIRDS; i++) {
    birds.add(new Bird());
  }
}

//--------------------------------------------------
void draw () {
  bg.run();
  ship.run();

  int len = birds.size();
  for (int i = 0; i < len; i++) {
    birds.get(i).run();
  }
}
void keyPressed() {
  if (key == 'r') {
    saveFrame("output/frame-####.png");
  }
}

//--------------------------------------------------
class BG {
  PImage img;
  float darkness;
  final float DARKNESS_VELOCITY = 0.1;
  final int DARKNESS_BORDER = 128;
  final int DARKNESS_MAX = 148;
  ArrayList<Star> stars;

  BG(PImage img) {
    this.img = img;
    this.darkness = 0;
    
    this.stars = new ArrayList<Star>();
    this.stars.add(new Star(new PVector(10, 60)));
    this.stars.add(new Star(new PVector(30, 10)));
    this.stars.add(new Star(new PVector(100, 25)));
    this.stars.add(new Star(new PVector(150, 15)));
    this.stars.add(new Star(new PVector(300, 5)));
    this.stars.add(new Star(new PVector(width-100, 15)));
    this.stars.add(new Star(new PVector(width-150, 20)));
    this.stars.add(new Star(new PVector(width-250, 10)));
  }
  
  void run() {
    update();
    display();
  }

  void update() {
    updateDarkness();
    updateStars();
  }
  void updateDarkness() {
    if (this.darkness < this.DARKNESS_MAX) {
      this.darkness += this.DARKNESS_VELOCITY;
    }
  }
  void updateStars() {
    if (this.darkness > this.DARKNESS_BORDER) {
      int len = this.stars.size();
      for (int i = 0; i < len; i++) {
        this.stars.get(i).update();
      }
    }
  }
  
  void display() {
    tint(255 - (darkness*1.5), 255 - darkness, 255 - (darkness*0.8));
    imageMode(CORNER);
    image(this.img, 0, 0);

    if (this.darkness > this.DARKNESS_BORDER) {
      displayStars();
    }
  }
  void displayStars() {
    int len = this.stars.size();
    for (int i = 0; i < len; i++) {
      this.stars.get(i).display();
    }
  }
}
//--------------------------------------------------
class Star {
  PVector position;
  float starlight;
  final float STAR_VELOCITY = 0.4;
  float star_max;
  int intervalOfTwinkle; 
  
  Star(PVector position) {
    this.position = position;
    this.starlight = 0;
    this.star_max = random(64, 255);
    this.intervalOfTwinkle = (int)random(36, 36+80);
  }
  
  void update() {
    if (this.starlight < this.star_max) {
      this.starlight += this.STAR_VELOCITY;
    }
  }
  
  void display() {
    if (frameCount % this.intervalOfTwinkle == 0) {
      setPixelTwinkle((int)this.position.x, (int)this.position.y);
    }else{
      setPixel((int)this.position.x, (int)this.position.y);
    }
  }
  void setPixel(int x, int y) {
    color nowc = get(x, y);
    color newc = color(red(nowc) + starlight, green(nowc) + starlight, blue(nowc) + starlight);
    set(x, y, newc);
  }
  void setPixelTwinkle(int x, int y) {
    color nowc = get(x, y);
    color newc = color(red(nowc) -50, green(nowc) -50, blue(nowc) -50);
    set(x, y, newc);
  }
}

//--------------------------------------------------
abstract class Mover {
  float POSITION_X_LEFT_BORDER;
  float POSITION_X_RIGHT_BORDER;
  float POSITION_Y;
  PVector position;
  float VEL;
  PVector velocity;
  float turn;

  final void run() {
    updateMove();
    update();
    display();
  }
  final void updateMove() {
    if (this.turn > 0 && this.position.x > width + 10) {
      this.position.x = this.POSITION_X_RIGHT_BORDER;
      this.velocity.x *= -1;
      this.turn *= -1;
    }else if (this.turn < 0 && this.position.x < -10) {
      this.position.x = this.POSITION_X_LEFT_BORDER;
      this.velocity.x *= -1;
      this.turn *= -1;
    }
  }
  abstract void update();
  abstract void display();
}

//--------------------------------------------------
class Ship extends Mover {
  PImage img;
  ArrayList<Light> lights;
  
  Ship(PImage img, PImage imgLight) {
    this.img = img;
    this.POSITION_X_LEFT_BORDER = img.width * -1;
    this.POSITION_X_RIGHT_BORDER = width + img.width;
    this.POSITION_Y = 312;
    this.position = new PVector(random(-50, width/4), POSITION_Y);
    this.VEL = 0.8;
    this.velocity = new PVector(VEL, 0);
    this.turn = 1;

    this.lights = new ArrayList<Light>();
    this.lights.add(new Light(imgLight, new PVector(45, 3)));
    this.lights.add(new Light(imgLight, new PVector(191, 10)));
    this.lights.add(new Light(imgLight, new PVector(23, 11)));
  }
  
  void update() {
    this.position.add(this.velocity);
    
    int len = lights.size();
    for (int i = 0; i < len; i++) {
      this.lights.get(i).update();
    }
  }
  
  void display() {
    imageMode(CORNER);
    pushMatrix();
    translate(this.position.x, this.position.y);
    scale(this.turn, 1);
    image(this.img, 0, 0);
    displayLights();
    popMatrix();
  }
  void displayLights() {
    int len = this.lights.size();
    for (int i = 0; i < len; i++) {
      this.lights.get(i).display();
    }
  }
}

//--------------------------------------------------
class Light {
  PImage img;
  PVector offset;
  final float LIGHT_POWER_MIN = 0;
  final float LIGHT_POWER_MAX = 0.9;
  float lightPower;
  float lightPowerDelta;
  
  Light(PImage img, PVector offset) {
    this.img = img;
    this.offset = offset;
    this.lightPower = random(LIGHT_POWER_MIN, LIGHT_POWER_MAX);
    this.lightPowerDelta = 0.03;
  }
  
  void update() {
    this.lightPower += this.lightPowerDelta;
    if (this.lightPower >= this.LIGHT_POWER_MAX) {
      this.lightPower = this.LIGHT_POWER_MAX;
      this.lightPowerDelta *= -1;
    }else if (this.lightPower < this.LIGHT_POWER_MIN) {
      this.lightPower = this.LIGHT_POWER_MIN;
      this.lightPowerDelta *= -1;
    }
  }
  
  void display() {
    noTint();
    imageMode(CENTER);
    pushMatrix();
    translate(this.offset.x, this.offset.y);
    scale(this.lightPower);
    image(this.img, 0, 0);
    popMatrix();
  }
}

//--------------------------------------------------
class Bird extends Mover {
  float radian;
  int slope;
  
  Bird() {
    this.POSITION_X_LEFT_BORDER = -300;
    this.POSITION_X_RIGHT_BORDER = width + 300;
    this.POSITION_Y = 240;
    this.position = new PVector(random(POSITION_X_LEFT_BORDER -200, -200), POSITION_Y + random(-10, 10));
    this.VEL = 2;
    this.velocity = new PVector(VEL, 0);
    this.turn = 1;
    this.radian = random(0, TWO_PI);
    this.slope = 0;
  }
  
  void update() {
    if (this.radian >= PI && this.radian < TWO_PI) {
      this.slope = 1;
    }else{
      this.slope = -1;
    }

    if (this.radian < TWO_PI) {
      this.radian += 0.1;
    }else{
      this.radian = 0;
    }
    this.velocity.y = sin(this.radian);

    this.position.add(this.velocity);
  }
  
  void display() {
    stroke(0);
    pushMatrix();
    translate(this.position.x, this.position.y);
    scale(this.turn, 1);
    line(0, 0, 2, 2 * this.slope);
    line(0, 0, -2, 2 * this.slope);
    popMatrix();
  }
}
