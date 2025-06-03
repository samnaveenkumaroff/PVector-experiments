particle = None

class Particle:
    def __init__(self):
        self.position = PVector(width / 2, height / 2)
        self.velocity = PVector(0, 0)
        self.acceleration = PVector(0, 0)
        self.max_speed = 5

    def update(self):
        mouse = PVector(mouseX, mouseY)
        direction = PVector.sub(mouse, self.position)
        direction.normalize()
        direction.mult(0.4)
        self.acceleration = direction
        self.velocity.add(self.acceleration)
        self.velocity.limit(self.max_speed)
        self.position.add(self.velocity)

    def display(self):
        noStroke()
        fill(180, 80, 255, 120)  # Outer glow
        ellipse(self.position.x, self.position.y, 30, 30)
        fill(255)
        ellipse(self.position.x, self.position.y, 10, 10)

def setup():
    size(800, 600)
    global particle
    particle = Particle()
    background(10)
    smooth()

def draw():
    # Transparent background for trail effect
    fill(10, 10, 10, 30)
    noStroke()
    rect(0, 0, width, height)

    particle.update()
    particle.display()

