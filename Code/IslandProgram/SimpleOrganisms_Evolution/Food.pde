class Food{
  PVector position;
  int size;

  Food(float x, float y) {
    position = new PVector(x, y);
    size = int(random(5, 18));
  }

  void run() {
    display();
  }

  void display() {

    noStroke();
    fill(140, 240, 140);
    ellipse(position.x, position.y, size, size);
  }
}
