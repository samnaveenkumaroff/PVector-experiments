// Enhanced Anime Chidori Fighting Game
// Click to place shinobi, SPACE to charge Chidori, mouse to control attack

// Global variables
String gameState = "placing"; // placing, idle, charging, active, hit, defeated
Chidori chidori;
Shinobi shinobi;
int chargeTime = 0;
ArrayList<Particle> particles;
ArrayList<SakuraPetal> sakuraPetals;
ArrayList<Star> stars;
float cameraShake = 0;
ArrayList<ChargeParticle> chargeParticles;
int hitTimer = 0;

void setup() {
  size(1200, 800);
  smooth();
  chidori = new Chidori();
  shinobi = new Shinobi();
  particles = new ArrayList<Particle>();
  sakuraPetals = new ArrayList<SakuraPetal>();
  stars = new ArrayList<Star>();
  chargeParticles = new ArrayList<ChargeParticle>();
  initializeBackground();
}

void draw() {
  // Camera shake effect
  if (cameraShake > 0) {
    translate(random(-cameraShake, cameraShake), random(-cameraShake, cameraShake));
    cameraShake *= 0.9;
  }
  
  drawBackground();
  
  // Handle game states
  if (gameState.equals("placing")) {
    drawPlacementUI();
  }
  else if (gameState.equals("charging")) {
    chargeTime++;
    chidori.charge(chargeTime);
    createChargeParticles();
    
    if (chargeTime > 120) { // 2 seconds
      gameState = "active";
    }
  }
  else if (gameState.equals("active")) {
    chidori.updatePosition(mouseX, mouseY);
    chidori.moveTowardsMouse();
    
    // Check collision from all sides
    float distance = PVector.dist(chidori.position, shinobi.position);
    if (distance < 50) {
      shinobi.takeDamage(25);
      createHitEffects();
      cameraShake = 20;
      hitTimer = 60; // Red flash duration
      
      // Remove chidori and reset to create new one
      chidori.destroy();
      
      if (shinobi.health <= 0) {
        gameState = "defeated";
        shinobi.finalBlow();
      } else {
        gameState = "hit";
      }
    }
  }
  else if (gameState.equals("hit")) {
    hitTimer--;
    if (hitTimer <= 0) {
      gameState = "idle";
      chidori.resetForNewAttack();
    }
  }
  else if (gameState.equals("defeated")) {
    shinobi.flyAway();
  }
  
  // Update and display all elements
  updateParticles();
  updateChargeParticles();
  updateSakura();
  updateStars();
  
  shinobi.update();
  shinobi.display(hitTimer > 0);
  
  if (!chidori.destroyed) {
    chidori.display();
  }
  
  drawUI();
  drawParticles();
}

void mousePressed() {
  if (gameState.equals("placing")) {
    shinobi.place(mouseX, mouseY);
    gameState = "idle";
  }
}

void keyPressed() {
  if (key == ' ' && gameState.equals("idle")) {
    gameState = "charging";
    chargeTime = 0;
    chidori.startCharge();
  }
}

void initializeBackground() {
  // Create floating cherry blossoms
  for (int i = 0; i < 40; i++) {
    sakuraPetals.add(new SakuraPetal());
  }
  // Create twinkling stars
  for (int i = 0; i < 100; i++) {
    stars.add(new Star());
  }
}

void drawBackground() {
  // Enhanced gradient background - twilight atmosphere
  for (int i = 0; i < height; i++) {
    float t = (float)i / height;
    int r = (int)(15 + (80 - 15) * t);
    int g = (int)(5 + (40 - 5) * t);
    int b = (int)(60 + (120 - 60) * t);
    stroke(r, g, b);
    line(0, i, width, i);
  }
  
  // Twinkling stars
  for (Star star : stars) {
    star.display();
  }
  
  // Enhanced mountains with multiple layers
  fill(10, 20, 50, 180);
  noStroke();
  beginShape();
  vertex(0, height);
  for (int x = 0; x < width; x += 15) {
    float y = height - 200 + sin(x * 0.008) * 60 + cos(x * 0.003) * 40;
    vertex(x, y);
  }
  vertex(width, height);
  endShape(CLOSE);
  
  // Second mountain layer
  fill(20, 30, 70, 120);
  beginShape();
  vertex(0, height);
  for (int x = 0; x < width; x += 20) {
    float y = height - 120 + sin(x * 0.01 + 100) * 40 + cos(x * 0.006) * 25;
    vertex(x, y);
  }
  vertex(width, height);
  endShape(CLOSE);
  
  // Enhanced traditional pagoda
  fill(5, 10, 30, 220);
  rect(width - 250, height - 400, 40, 300); // Main tower
  
  // Multiple pagoda roofs with more detail
  for (int i = 0; i < 6; i++) {
    float y = height - 100 - i * 50;
    float roofWidth = 50 - i * 3;
    // Main roof triangle
    triangle(width - 250 - roofWidth/2, y, width - 210 + roofWidth/2, y, width - 230, y - 25);
    // Roof details
    fill(40, 20, 10);
    rect(width - 235, y - 3, 10, 6);
  }
  
  // Traditional torii gate
  fill(120, 40, 40, 150);
  rect(150, height - 200, 15, 150); // Left pillar
  rect(250, height - 200, 15, 150); // Right pillar
  rect(140, height - 180, 140, 20); // Top beam
  rect(145, height - 160, 130, 12); // Second beam
  
  // Ground mist effect
  fill(200, 200, 255, 30);
  noStroke();
  for (int i = 0; i < 5; i++) {
    ellipse(random(width), height - random(50), random(100, 300), 40);
  }
}

void updateSakura() {
  for (SakuraPetal petal : sakuraPetals) {
    petal.update();
    petal.display();
  }
}

void updateStars() {
  for (Star star : stars) {
    star.update();
  }
}

void drawPlacementUI() {
  fill(255, 220);
  textAlign(CENTER);
  textSize(28);
  text("Click to place your Shinobi opponent", width/2, 100);
  textSize(18);
  text("Then press SPACE to charge Chidori", width/2, 130);
  
  // Enhanced crosshair
  stroke(255, 200, 100, 200);
  strokeWeight(3);
  line(mouseX - 25, mouseY, mouseX + 25, mouseY);
  line(mouseX, mouseY - 25, mouseX, mouseY + 25);
  // Crosshair circle
  noFill();
  stroke(255, 150, 50, 150);
  strokeWeight(2);
  ellipse(mouseX, mouseY, 50, 50);
}

void drawUI() {
  if (gameState.equals("placing")) {
    return;
  }
  
  // Health bar with enhanced styling
  fill(20, 20, 20, 180);
  rect(20, 20, 320, 40, 5);
  
  // Health fill with gradient effect
  float healthWidth = map(shinobi.health, 0, 100, 0, 310);
  
  if (shinobi.health > 60) {
    fill(50, 255, 100);
  } else if (shinobi.health > 30) {
    fill(255, 200, 50);
  } else {
    fill(255, 50, 50);
  }
  
  rect(25, 25, healthWidth, 30, 3);
  
  // Health text with shadow
  fill(0, 150);
  textAlign(LEFT);
  textSize(18);
  text("Shinobi Health: " + (int)shinobi.health, 32, 47);
  fill(255);
  text("Shinobi Health: " + (int)shinobi.health, 30, 45);
  
  // Enhanced instructions
  if (gameState.equals("idle")) {
    textAlign(RIGHT);
    fill(200, 200, 255);
    textSize(16);
    text("Press SPACE to charge Chidori", width - 20, height - 80);
    text("Move mouse to aim and attack", width - 20, height - 60);
    text("Hit from any angle!", width - 20, height - 40);
  } else if (gameState.equals("charging")) {
    textAlign(CENTER);
    textSize(24);
    fill(150, 100, 255, 200 + sin(frameCount * 0.3) * 55);
    text("⚡ CHARGING CHIDORI ⚡", width/2, height - 50);
  } else if (gameState.equals("active")) {
    textAlign(RIGHT);
    fill(100, 255, 100, 200 + sin(frameCount * 0.5) * 55);
    textSize(18);
    text("⚡ CHIDORI ACTIVE! ⚡", width - 20, height - 40);
  }
}

class Chidori {
  PVector position;
  PVector target;
  PVector velocity;
  boolean charging;
  ArrayList<LightningBolt> lightningBolts;
  float coreIntensity;
  ArrayList<PVector> trailPositions;
  boolean destroyed;
  
  Chidori() {
    position = new PVector(100, height/2);
    target = new PVector(100, height/2);
    velocity = new PVector(0, 0);
    charging = false;
    lightningBolts = new ArrayList<LightningBolt>();
    coreIntensity = 0;
    trailPositions = new ArrayList<PVector>();
    destroyed = false;
  }
  
  void startCharge() {
    charging = true;
    destroyed = false;
    position = new PVector(100, height/2);
    lightningBolts.clear();
    trailPositions.clear();
  }
  
  void charge(int time) {
    coreIntensity = min((float)time / 120.0, 1.0);
    
    // Create intense charging lightning
    int numBolts = (int)(20 * coreIntensity);
    for (int i = 0; i < numBolts; i++) {
      float angle = random(TWO_PI);
      float r = random(40, 100 * coreIntensity);
      
      PVector boltPos = new PVector(
        position.x + cos(angle) * r,
        position.y + sin(angle) * r
      );
      
      lightningBolts.add(new LightningBolt(boltPos, (int)random(8, 25)));
    }
    
    // Clean up old bolts
    for (int i = lightningBolts.size() - 1; i >= 0; i--) {
      LightningBolt bolt = lightningBolts.get(i);
      bolt.life--;
      if (bolt.life <= 0) {
        lightningBolts.remove(i);
      }
    }
  }
  
  void updatePosition(float mx, float my) {
    target.x = mx;
    target.y = my;
  }
  
  void moveTowardsMouse() {
    if (destroyed) return;
    
    // Enhanced movement towards mouse
    PVector direction = PVector.sub(target, position);
    direction.mult(0.18);
    velocity.add(direction);
    velocity.mult(0.82);
    position.add(velocity);
    
    // Add to trail
    trailPositions.add(new PVector(position.x, position.y));
    if (trailPositions.size() > 20) {
      trailPositions.remove(0);
    }
    
    // Active lightning effects
    for (int i = 0; i < 12; i++) {
      float angle = random(TWO_PI);
      float r = random(25, 60);
      PVector boltPos = new PVector(
        position.x + cos(angle) * r,
        position.y + sin(angle) * r
      );
      lightningBolts.add(new LightningBolt(boltPos, (int)random(5, 15)));
    }
    
    // Clean particles
    for (int i = lightningBolts.size() - 1; i >= 0; i--) {
      LightningBolt bolt = lightningBolts.get(i);
      bolt.life--;
      if (bolt.life <= 0) {
        lightningBolts.remove(i);
      }
    }
  }
  
  void destroy() {
    destroyed = true;
    lightningBolts.clear();
    trailPositions.clear();
  }
  
  void resetForNewAttack() {
    position = new PVector(100, height/2);
    velocity = new PVector(0, 0);
    trailPositions.clear();
    destroyed = false;
  }
  
  void display() {
    if (gameState.equals("placing") || destroyed) {
      return;
    }
    
    // Draw enhanced trail
    if (trailPositions.size() > 1) {
      for (int i = 0; i < trailPositions.size() - 1; i++) {
        float alpha = map(i, 0, trailPositions.size() - 1, 0, 200);
        stroke(150, 100, 255, alpha);
        float weight = map(i, 0, trailPositions.size() - 1, 1, 12);
        strokeWeight(weight);
        PVector pos1 = trailPositions.get(i);
        PVector pos2 = trailPositions.get(i + 1);
        line(pos1.x, pos1.y, pos2.x, pos2.y);
      }
    }
    
    // Draw lightning bolts with more variation
    for (LightningBolt bolt : lightningBolts) {
      float alpha = map(bolt.life, 0, bolt.maxLife, 0, 255);
      stroke(100 + random(100), 50 + random(150), 255, alpha);
      strokeWeight(random(1, 5));
      
      // More jagged lightning
      int steps = 8;
      float prevX = position.x;
      float prevY = position.y;
      
      for (int i = 1; i <= steps; i++) {
        float t = (float)i / steps;
        float targetX = lerp(position.x, bolt.pos.x, t);
        float targetY = lerp(position.y, bolt.pos.y, t);
        
        // Enhanced electrical noise
        targetX += random(-12, 12);
        targetY += random(-12, 12);
        
        line(prevX, prevY, targetX, targetY);
        prevX = targetX;
        prevY = targetY;
      }
    }
    
    // Enhanced core energy ball
    pushMatrix();
    translate(position.x, position.y);
    
    float sizeMult = charging ? coreIntensity : 1.0;
    
    // Multiple energy layers
    noStroke();
    fill(80, 40, 255, 40);
    ellipse(0, 0, 80 * sizeMult, 80 * sizeMult);
    
    fill(120, 70, 255, 80);
    ellipse(0, 0, 60 * sizeMult, 60 * sizeMult);
    
    fill(160, 120, 255, 120);
    ellipse(0, 0, 40 * sizeMult, 40 * sizeMult);
    
    fill(200, 170, 255, 160);
    ellipse(0, 0, 25 * sizeMult, 25 * sizeMult);
    
    fill(255, 220, 255, 200);
    ellipse(0, 0, 15 * sizeMult, 15 * sizeMult);
    
    // Pulsing center
    float pulse = sin(frameCount * 0.3) * 0.3 + 0.7;
    fill(255, 255, 255, 220 * pulse);
    ellipse(0, 0, 8 * sizeMult * pulse, 8 * sizeMult * pulse);
    
    popMatrix();
  }
}

class Shinobi {
  PVector position;
  PVector velocity;
  float health;
  boolean placed;
  boolean defeated;
  boolean flying;
  float rotation;
  
  Shinobi() {
    position = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);
    health = 100;
    placed = false;
    defeated = false;
    flying = false;
    rotation = 0;
  }
  
  void place(float x, float y) {
    position.x = x;
    position.y = y;
    placed = true;
  }
  
  void takeDamage(float damage) {
    health = max(0, health - damage);
    
    // Enhanced knockback effect
    PVector knockback = PVector.sub(position, chidori.position);
    knockback.normalize();
    knockback.mult(15);
    velocity.add(knockback);
  }
  
  void finalBlow() {
    defeated = true;
    flying = true;
    velocity = new PVector(random(-20, 20), random(-25, -15));
    rotation = random(-0.3, 0.3);
  }
  
  void flyAway() {
    if (flying) {
      velocity.y += 0.8; // Gravity
      position.add(velocity);
      rotation += 0.1;
    }
  }
  
  void update() {
    if (!flying) {
      velocity.mult(0.85);
      position.add(velocity);
      
      // Keep on screen
      position.x = constrain(position.x, 40, width - 40);
      position.y = constrain(position.y, 40, height - 40);
    }
  }
  
  void display(boolean isHit) {
    if (!placed && gameState.equals("placing")) {
      return;
    }
    
    pushMatrix();
    translate(position.x, position.y);
    rotate(rotation);
    
    // Hit flash effect - make entire shinobi red
    if (isHit) {
      stroke(255, 50, 50);
      fill(255, 100, 100, 150);
    } else {
      stroke(200, 200, 255);
      fill(50, 50, 100, 100);
    }
    
    strokeWeight(3);
    
    // Enhanced shinobi/samurai figure
    // Head with ninja mask
    ellipse(0, -35, 28, 28);
    // Eyes
    fill(isHit ? color(255, 200, 200) : color(255, 255, 255));
    ellipse(-6, -38, 4, 6);
    ellipse(6, -38, 4, 6);
    
    // Body armor
    if (isHit) {
      fill(255, 100, 100, 180);
      stroke(255, 50, 50);
    } else {
      fill(40, 40, 80, 150);
      stroke(200, 200, 255);
    }
    rect(-12, -20, 24, 35, 5);
    
    // Armor details
    line(-8, -15, 8, -15);
    line(-8, -5, 8, -5);
    line(-8, 5, 8, 5);
    
    // Arms in defensive stance
    strokeWeight(4);
    line(-12, -10, -25, -5);
    line(-25, -5, -20, 10);
    line(12, -10, 25, -5);
    line(25, -5, 20, 10);
    
    // Katana sword
    if (!isHit) {
      stroke(180, 180, 200);
    }
    strokeWeight(2);
    line(20, 10, 35, -5);
    line(35, -5, 40, -8);
    // Sword guard
    strokeWeight(4);
    point(35, -5);
    
    // Legs in fighting stance
    strokeWeight(4);
    if (isHit) {
      stroke(255, 50, 50);
    } else {
      stroke(200, 200, 255);
    }
    line(0, 15, -15, 40);
    line(-15, 40, -10, 55);
    line(0, 15, 15, 40);
    line(15, 40, 20, 55);
    
    // Ninja sandals
    strokeWeight(6);
    line(-12, 55, -8, 55);
    line(18, 55, 22, 55);
    
    // Aura effect when not hit
    if (!defeated && !isHit) {
      noStroke();
      fill(100, 150, 255, 20);
      ellipse(0, 0, 100, 140);
      fill(150, 200, 255, 10);
      ellipse(0, 0, 120, 160);
    }
    
    popMatrix();
  }
}

class LightningBolt {
  PVector pos;
  int life;
  int maxLife;
  float intensity;
  
  LightningBolt(PVector position, int lifespan) {
    pos = position.copy();
    life = lifespan;
    maxLife = lifespan;
    intensity = random(0.5, 1.0);
  }
}

class SakuraPetal {
  float x, y;
  float speed;
  float size;
  float rotation;
  float rotSpeed;
  color petalColor;
  
  SakuraPetal() {
    x = random(width);
    y = random(height);
    speed = random(0.3, 1.5);
    size = random(6, 12);
    rotation = random(TWO_PI);
    rotSpeed = random(-0.03, 0.03);
    petalColor = color(255, random(120, 180), random(150, 220), random(80, 150));
  }
  
  void update() {
    y += speed;
    x += sin(y * 0.01) * 0.5;
    rotation += rotSpeed;
    
    if (y > height + 20) {
      y = -20;
      x = random(width);
    }
  }
  
  void display() {
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    fill(petalColor);
    noStroke();
    
    // Enhanced sakura petal shape
    ellipse(0, 0, size, size * 0.6);
    ellipse(size * 0.3, -size * 0.1, size * 0.7, size * 0.4);
    ellipse(-size * 0.3, -size * 0.1, size * 0.7, size * 0.4);
    ellipse(0, -size * 0.3, size * 0.5, size * 0.5);
    
    popMatrix();
  }
}

class Star {
  float x, y;
  float brightness;
  float twinkleSpeed;
  
  Star() {
    x = random(width);
    y = random(height * 0.6); // Only in upper part of sky
    brightness = random(100, 255);
    twinkleSpeed = random(0.02, 0.08);
  }
  
  void update() {
    brightness = 150 + sin(frameCount * twinkleSpeed) * 105;
  }
  
  void display() {
    stroke(255, 255, 200, brightness);
    strokeWeight(1 + brightness/200);
    point(x, y);
  }
}

// Particle classes remain the same as before...
class Particle {
  PVector pos;
  PVector vel;
  int life;
  int maxLife;
  float size;
  color col;
  
  Particle(PVector position, PVector velocity, int lifespan, float particleSize, color particleColor) {
    pos = position.copy();
    vel = velocity.copy();
    life = lifespan;
    maxLife = lifespan;
    size = particleSize;
    col = particleColor;
  }
  
  void update() {
    pos.add(vel);
    vel.mult(0.95);
    life--;
  }
  
  boolean isDead() {
    return life <= 0;
  }
  
  void display() {
    float alpha = map(life, 0, maxLife, 0, 255);
    fill(red(col), green(col), blue(col), alpha);
    noStroke();
    ellipse(pos.x, pos.y, size, size);
  }
}

class ChargeParticle {
  PVector pos;
  PVector target;
  int life;
  int maxLife;
  color col;
  
  ChargeParticle(PVector position, PVector targetPos) {
    pos = position.copy();
    target = targetPos.copy();
    life = 60;
    maxLife = 60;
    col = color(random(150, 255), random(50, 150), 255);
  }
  
  void update() {
    PVector direction = PVector.sub(target, pos);
    direction.mult(0.1);
    pos.add(direction);
    life--;
  }
  
  boolean isDead() {
    return life <= 0;
  }
  
  void display() {
    float alpha = map(life, 0, maxLife, 0, 200);
    fill(red(col), green(col), blue(col), alpha);
    noStroke();
    ellipse(pos.x, pos.y, 6, 6);
  }
}

void createChargeParticles() {
  for (int i = 0; i < 8; i++) {
    PVector startPos = new PVector(
      chidori.position.x + random(-150, 150),
      chidori.position.y + random(-150, 150)
    );
    chargeParticles.add(new ChargeParticle(startPos, chidori.position));
  }
}

void updateChargeParticles() {
  for (int i = chargeParticles.size() - 1; i >= 0; i--) {
    ChargeParticle cp = chargeParticles.get(i);
    cp.update();
    if (cp.isDead()) {
      chargeParticles.remove(i);
    }
  }
}

void createHitEffects() {
  for (int i = 0; i < 40; i++) {
    PVector vel = PVector.random2D();
    vel.mult(random(3, 12));
    color particleColor = color(random(200, 255), random(50, 150), 255);
    particles.add(new Particle(
      shinobi.position.copy(),
      vel,
      (int)random(40, 80),
      random(4, 10),
      particleColor
    ));
  }
}

void updateParticles() {
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
}

void drawParticles() {
  for (Particle p : particles) {
    p.display();
  }
  
  for (ChargeParticle cp : chargeParticles) {
    cp.display();
  }
}
