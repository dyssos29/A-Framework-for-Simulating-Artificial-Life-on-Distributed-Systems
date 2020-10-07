class Organism {
  NeuralNetwork NN;
  float[] inputs;

  PVector position;
  PVector velocity;
  PVector leftAntenna;
  PVector rightAntenna;

  int radius;
  float antennaLength;
  float antennaRadius;
  float age;
  float health;
  float maxHealth;
  float speed;
  float maxSpeed;
  float angle;
  float rotationSpeed;

  boolean stucked;

  Organism(float x, float y, NeuralNetwork NN) {

    this.NN = NN;

    NN.addLayer(4, 5);
    NN.addLayer(5, 4);

    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    leftAntenna = new PVector(0, 0);
    rightAntenna = new PVector(0, 0);

    radius = 25;
    antennaLength = radius;
    antennaRadius = radius/5;
    age = 0;
    maxHealth = 200;
    health = maxHealth/2;
    speed = 0;
    maxSpeed = 4;
    angle = 0;
    rotationSpeed = 2;
    stucked = false;
  }
  
  Organism(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    leftAntenna = new PVector(0, 0);
    rightAntenna = new PVector(0, 0);

    radius = 25;
    antennaLength = radius;
    antennaRadius = radius/5;
    age = 0;
    maxHealth = 200;
    health = maxHealth/2;
    speed = 0;
    maxSpeed = 4;
    angle = 0;
    rotationSpeed = 2;
    stucked = false;
  }
  
  NeuralNetwork getNeuralNetwork()
  {
    return NN;
  }
  
  public void setNeuralNetwork(NeuralNetwork neuralNetwork)
  {
    NN = neuralNetwork;
  }

  void run() {
    wrapAround();
    track();

    float healthLoss = map(speed, 0, maxSpeed, 0, maxSpeed*0.1);
    if (healthLoss < 0.2) {
      healthLoss = 0.2;
    }
    health -= healthLoss;

    display();
  }

  void track() {
    float newFoodDistance = 10000;
    PVector closestFood = new PVector (random(0, 1), random(0, 1));

    ArrayList<Food> foods = environment.getFoods();
    for (int j = foods.size()-1; j >= 0; j--) {
      PVector foodPosition = foods.get(j).position;
      float foodDistance = PVector.dist(position, foodPosition);

      if (foodDistance < newFoodDistance) {
        newFoodDistance = foodDistance;
        closestFood = foodPosition;
      }
      if (foodDistance < radius/2) {
        foods.remove(j);
        health += 35;
      }
    }
    inputs = new float[0];
    float leftAntennaDistance = PVector.dist(leftAntenna, closestFood);
    inputs = (float[]) append(inputs, leftAntennaDistance); //first neuron
    float rightAntennaDistance = PVector.dist(leftAntenna, closestFood);
    inputs = (float[]) append(inputs, rightAntennaDistance); //second neuron
    float bodyDistance = PVector.dist(position, closestFood);
    inputs = (float[]) append(inputs, bodyDistance); //third neuron

    float hunger = map(health, 0, maxHealth, -10, 10);
    inputs = (float[]) append(inputs, hunger); //fourth neuron

    NN.processInputs(inputs);

    if (NN.outputs[0] > 0.0) angle += radians(rotationSpeed);

    if (NN.outputs[1] > 0.0) angle -= radians(rotationSpeed);

    speed = map(NN.outputs[2], -1, 1, 0, maxSpeed);

    if (NN.outputs[3] > 0.0 && stucked == false) {
      velocity.x = speed*cos(angle);
      velocity.y = speed*sin(angle);
      position.add(velocity);
    }
  } //end track

  boolean isDead() {
    if (health < 0.0 || health > maxHealth) {
      return true;
    } else {
      return false;
    }
  }

  void borders() {
    position.x=constrain(position.x, radius+radius/2, width-radius+radius/2);
    position.y=constrain(position.y, radius+radius/2, height-radius+radius/2);
  }

  void wrapAround() {
    if (position.x < -radius) position.x = width+radius;
    if (position.y < -radius) position.y = height+radius;
    if (position.x > width+radius) position.x = -radius;
    if (position.y > height+radius) position.y = -radius;
  }

  void display() {
    float colour = 0;

    stroke(0);
    // noStroke();
    if (health < maxHealth/2) {
      colour = map(health, 0, maxHealth/2, 230, 10);
      fill(colour, colour, 230);
    } else {
      colour = map(health, maxHealth/2, maxHealth, 230, 10);
      fill(40, 40, colour);
    }

    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);
    ellipseMode(CENTER);

    stroke(240);
    line(0, 0, radius/2+10, -radius/2);
    ellipse(radius/2+10, -radius/2, radius/3, radius/3);
    // leftAntenna.x = screenX(radius+radius/2, -radius/2);
    // leftAntenna.y = screenY(radius+radius/2, -radius/2);
    leftAntenna.x = screenX(radius, -radius/2);
    leftAntenna.y = screenY(radius, -radius/2);

    line(0, 0, radius/2+10, radius/2);
    ellipse(radius/2+10, radius/2, radius/3, radius/3);
    // rightAntenna.x = screenX(radius+radius/2, radius/2);
    // rightAntenna.y = screenY(radius+radius/2, radius/2);
    rightAntenna.x = screenX(radius, radius/2);
    rightAntenna.y = screenY(radius, radius/2);

    line(0, 0, -35, 0); //tail
    line(0, 0, 0, 25); //right leg
    line(0, 0, 0, -25); //left leg



    stroke(0);
    ellipse(0, 0, radius, radius); //body

    // fill(240, 0,0);
    // ellipse(0,10,5,5);
    // ellipse(0,-10,5,5);

    popMatrix();
  }
}
