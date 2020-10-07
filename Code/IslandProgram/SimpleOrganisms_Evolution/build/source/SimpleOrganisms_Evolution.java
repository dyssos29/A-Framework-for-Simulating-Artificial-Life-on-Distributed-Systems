import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException;
import java.net.*;

public class SimpleOrganisms_Evolution extends PApplet {

Environment environment;

int time;
int totalTime;
int currentGeneration;
int longestGeneration;
int highestAge;
int bestGeneration;
int organismCount;
int foodCount;
int organismRadius = 20;
int finalGeneration = 3;
PrintWriter results;

public void setup() {
  
  // size(1100, 700);
  
  organismCount = 30;
  foodCount = 65;
  time = 0;
  currentGeneration = 0;
  longestGeneration = 0;
  highestAge = 0;
  bestGeneration = 0;
  environment = new Environment(organismCount, foodCount);

  results = createWriter("results.csv");
  // results = createWriter("results("+day()+"/"+month()+"/"+year()+").csv");
  results.println("Organisms, Food, Food rate, Best generation, Maximum fitness, Mutation rate, Number of mutations");
}

public void mouseClicked() {
  results.println(organismCount +", " +foodCount +", " +environment.foodRate +", " +(bestGeneration+1) +", " +highestAge +", " +environment.mutationRate +", " +environment.numberOfMutations);

  results.flush();
  results.close();

  exit();
}

public void draw() {
  background(45);

  if (environment.ancestorOrganisms.size() < organismCount) {
    environment.run();
    time += 1;
    totalTime +=1;
  } else {
    if (time > longestGeneration) {
      longestGeneration = time;
    }
    if (environment.findMaxFitness() > highestAge) {
      highestAge = PApplet.parseInt(environment.findMaxFitness());
      bestGeneration = currentGeneration;
    }

    time = 0;
    currentGeneration++;

    environment.foods.clear();
    int r = organismRadius;
    for (int i=0; i < foodCount; i++) {
      environment.foods.add(new Food(random(r+r/2, width-(r+r/2)), random(r+r/2, height-(r+r/2))));    //initialize food for the next gen
    }

    environment.organismSelection();
    environment.organismReproduction();

    if (currentGeneration == (finalGeneration)) {

      results.println(organismCount +", " +foodCount +", " +environment.foodRate +", " +(bestGeneration+1) +", " +highestAge +", " +environment.mutationRate +", " +environment.numberOfMutations);

      results.flush();
      results.close();

      exit();
    } //end simulation

    if (currentGeneration == 10) {
      foodCount = 2*foodCount;
    }
  }

  fill(210);
  textSize(15);
  text("Current generation: " + (currentGeneration+1), 20, 30);
  text("Best generation: " + (bestGeneration+1), 20, 50);
  text("No. of living organisms: " + environment.organisms.size(), 20, 70);
  text("Current food: " + environment.foods.size(), 20, 90);
  text("Highest fitness: " + highestAge, 20, 110);
  text("Time: " +time, 20, 130);
  text("Total time: " +totalTime, 20, 150);
}
class Connection {
  float connectionEntry;
  float connectionWeight;
  float connectionExit;

  Connection() {
    randomWeight();
  }

  public void setWeight(float w) {
    connectionWeight = w;
    connectionWeight = constrain(connectionWeight, -1, 1);
  }

  public void randomWeight() {
    setWeight(random(-1, 1));
  }

  public float getWeight() {
    return connectionWeight;
  }

  public float getConnectionExit(float e) {
    connectionEntry = e;
    connectionExit = connectionEntry * connectionWeight;
    return connectionExit;
  }
}
class Environment {

  ArrayList<Food> foods;
  ArrayList<Organism> organisms;
  ArrayList<Organism> ancestorOrganisms;
  ArrayList<Organism> matingPool;

  float foodRate = 0.03f;

  float mutationRate = 0.01f;
  // boolean hasMutated;
  int numberOfMutations = 0;

  int radius;

  //constructor
  Environment(int organismCount, int foodCount) {

    foods = new ArrayList<Food>();
    organisms = new ArrayList<Organism>();
    ancestorOrganisms = new ArrayList<Organism>();
    matingPool = new ArrayList<Organism>();

    for (int i=0; i<organismCount; i++) {
      organisms.add(new Organism( random(0, width), random(0, height),
      new NeuralNetwork()) );
    }

    for (int i=0; i<foodCount; i++) {
      foods.add(new Food( random(radius+radius/2, width-(radius+radius/2)), random(radius+radius/2, height-(radius+radius/2)) ));
    }
  } //end constructor

  public void run() {

    for (int i=foods.size()-1; i>=0;  i--) {
      Food f = foods.get(i);
      f.run();

      if (foods.size() > 2*foodCount) {
        foods.remove(0);
      }
    }

    for (int i=organisms.size()-1; i>=0; i--) {
      Organism o = organisms.get(i);
      o.run();
      // println("new org: " +organisms.size());

      if (o.isDead()) {
        ancestorOrganisms.add(o);
        organisms.remove(i);
        // println("dead org: " +organisms.size());
      } else {
        o.age ++;
      }
    }

    if (random(1) < foodRate) {
      foods.add(new Food( random(radius+radius/2, width-(radius+radius/2)), random(radius+radius/2, height-(radius+radius/2)) ));
    }
  } //end run

  public void organismSelection() {
    matingPool.clear();
    float maxFitness = findMaxFitness();

    for (int i=0; i<ancestorOrganisms.size(); i++) {
      float normalizedFitness = map(ancestorOrganisms.get(i).age, 0, maxFitness, 0, 1);
      int n = (int)(normalizedFitness*100);

      for (int j=0; j<n; j++) {
        matingPool.add( ancestorOrganisms.get(i) );
      }
    }
  } //end organismSelection

  public void organismReproduction() {
    float tmp;

    for (int i=0; i<organismCount; i++) {
      organisms.add(new Organism( random(0, width), random(0, height),
      new NeuralNetwork()) );

      int parentA = PApplet.parseInt(random( matingPool.size() ));
      int parentB = PApplet.parseInt(random( matingPool.size() ));

      Organism firstParent = matingPool.get(parentA);
      Organism secondParent = matingPool.get(parentB);

      for (int j=0; j<firstParent.NN.getLayerCount(); j++) {
        float[] firstParentWeights = new float[0];
        float[] secondParentWeights = new float[0];
        float[] successorWeights = new float[0];

        firstParentWeights = firstParent.NN.layers[j].getWeights();
        secondParentWeights = secondParent.NN.layers[j].getWeights();

        for (int k=0; k<firstParentWeights.length; k++) {
          if (random(1) > 0.5f) {
            tmp = firstParentWeights[k];
          } else {
            tmp = secondParentWeights[k];
          }
          if (random(1) < mutationRate) {
            tmp += random(-0.1f, 0.1f);
            numberOfMutations++;
          }
          tmp = constrain(tmp, -1, 1);
          successorWeights = (float[]) append(successorWeights, tmp);
        } //end k for
        Organism successor = organisms.get(i);
        successor.NN.layers[j].setWeights(successorWeights);
      }
      // if (hasMutated) {
      //   numberOfMutations++;
      // }
    }
    ancestorOrganisms.clear();
  } //end organismReproduction

  public float findMaxFitness() {
    float currentMax = 0;

    for (int i=0; i<ancestorOrganisms.size(); i++) {
      if (ancestorOrganisms.get(i).age > currentMax) {
        currentMax = ancestorOrganisms.get(i).age;
      }
    }
    return currentMax;
  }

  public ArrayList getFoods() {
    return foods;
  }

  public ArrayList getOrganisms() {
    return organisms;
  }
} //THE END
class Food{
  PVector position;
  int size;

  Food(float x, float y) {
    position = new PVector(x, y);
    size = PApplet.parseInt(random(5, 18));
  }

  public void run() {
    display();
  }

  public void display() {

    noStroke();
    fill(140, 240, 140);
    ellipse(position.x, position.y, size, size);
  }
}
class Layer {
  Neuron[] neurons ={};
  float[] weights ={};
  float[] layerInputs ={};
  float[] layerOutputs ={};

  Layer (int connectionCount, int neuronCount) {
    for (int i=0; i< neuronCount; i++) {
      Neuron n = new Neuron(connectionCount);
      addNeuron(n);
      addLayerOutputs();

      for (int j=0; j< n.connectionWeights.length; j++) {
        weights = (float[]) append(weights, n.connectionWeights[j]);
      }
    }
  }// end constructor

  public void addNeuron(Neuron n) {
    neurons = (Neuron[]) append(neurons, n);
  }

  public void setInputs(float[] i) {              //set inputs for this layer
    layerInputs = i;
  }

  public float[] getWeights() {
    return weights;
  }

  public int getNeuronCount() {
    return neurons.length;
  }

  // increment output array
  public void addLayerOutputs() {
    layerOutputs = (float[]) expand(layerOutputs, (layerOutputs.length+1));
  }

  public void setWeights(float[] w) {
    weights = new float[0];

    for (int i= 0; i < w.length; i++) {

      for (int j = 0; j < getNeuronCount(); j++) {
        neurons[j].connectionWeights = new float[0];

        for (int k = 0; k < neurons[j].getConnectionCount(); k++) {
          neurons[j].connections[k].setWeight(w[i]);
          weights = (float[]) append(weights, w[i]);
          neurons[j].connectionWeights = (float[]) append(neurons[j].connectionWeights, w[i]);
          i++;
        } //end k for
        neurons[j].setBias(w[i]);
        weights = (float[]) append(weights, w[i]);
        neurons[j].connectionWeights = (float[]) append(neurons[j].connectionWeights, w[i]);
        i++;
      } //end j for
    } //end i for
  } //end setWeights

  public void processInputs() {
    int neuronCount = getNeuronCount();

    if (neuronCount > 0) {
      if (layerInputs.length != neurons[0].getConnectionCount()) {
        println("Error in Layer!");
        exit();
      } else {
        for (int i=0; i<neuronCount; i++) {
          layerOutputs[i]=neurons[i].getNeuronOutput(layerInputs);
        }
      }
    } else {
      println("Error in Layer!");
      exit();
    }
  } // end processInputs
}
class NeuralNetwork {
  Layer[] layers ={};
  float[] inputs ={};
  float[] outputs ={};

  NeuralNetwork() {
  }

  public void addLayer(int connectionCount, int neuronCount) {
    layers = (Layer[]) append(layers, new Layer(connectionCount, neuronCount));
  }

  public void setInputs(float[] i) {
    inputs = i;
  }

  public void setOutputs(float[] o) {
    outputs = o;
  }

  public float[] getOutputs() {
    return outputs;
  }

  public int getLayerCount() {
    return layers.length;
  }

  public void setInputsAtLayer(float[] inputs, int index) {
    if (index > layers.length-1) {
      println("Error: exceeded layer limits!");
    } else {
      layers[index].setInputs(inputs);
    }
  }

  public void processInputs(float[] tmpInputs) {
    setInputs(tmpInputs);
    if (getLayerCount() > 0) {
      if ( inputs.length != layers[0].neurons[0].getConnectionCount()) {
        println("Error!");
        exit();
      } else {
        for (int i=0; i<layers.length; i++) {
          if (i == 0) {
            setInputsAtLayer(inputs, i);
          } else {
            setInputsAtLayer(layers[i-1].layerOutputs, i);
          }
          layers[i].processInputs();
        }
        setOutputs(layers[layers.length-1].layerOutputs);
      }
    } else {
      println("Error: ");
      exit();
    }
  } //end processInputs

} //end class
class Neuron {
  Connection[] connections ={};
  float[] connectionWeights ={};
  float bias;
  float neuronInput;
  float neuronOutput;

  Neuron(int connectionCount) {
    randomBias();
    for (int i = 0; i < connectionCount; i++) {
      Connection connection = new Connection();
      addConnection(connection);
      float w = connection.getWeight();
      connectionWeights = (float[]) append(connectionWeights, w);
    }
    connectionWeights = (float[]) append(connectionWeights, bias);
  }

  public void addConnection(Connection c) {
    connections = (Connection[]) append(connections, c);
  }

  public int getConnectionCount() {
    return connections.length;
  }

  public void setBias(float b) {
    bias = b;
  }

  public void randomBias() {
    setBias(random(-1, 1));
  }

  public float getNeuronOutput(float[] connectionEntries) {
    if (connectionEntries.length!=getConnectionCount()) {
      println("Neuron Error!");
      exit();
    }

    neuronInput = 0;

    for (int i = 0; i < getConnectionCount(); i++) {
      neuronInput += connections[i].getConnectionExit(connectionEntries[i]);
    }
    neuronInput += bias;
    neuronOutput = ActivateFunction(neuronInput);
    return neuronOutput;
  } //end getNeuronOutput

  public float ActivateFunction(float x) {
    return (2 / (1 + exp(-1 * (x*2)))) -1;
  }
}
class Organism {
  NeuralNetwork NN = new NeuralNetwork();
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

  public void run() {
    wrapAround();
    track();

    float healthLoss = map(speed, 0, maxSpeed, 0, maxSpeed*0.1f);
    if (healthLoss < 0.2f) {
      healthLoss = 0.2f;
    }
    health -= healthLoss;

    display();
  }

  public void track() {
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

    if (NN.outputs[0] > 0.0f) angle += radians(rotationSpeed);

    if (NN.outputs[1] > 0.0f) angle -= radians(rotationSpeed);

    speed = map(NN.outputs[2], -1, 1, 0, maxSpeed);

    if (NN.outputs[3] > 0.0f && stucked == false) {
      velocity.x = speed*cos(angle);
      velocity.y = speed*sin(angle);
      position.add(velocity);
    }
  } //end track

  public boolean isDead() {
    if (health < 0.0f || health > maxHealth) {
      return true;
    } else {
      return false;
    }
  }

  public void borders() {
    position.x=constrain(position.x, radius+radius/2, width-radius+radius/2);
    position.y=constrain(position.y, radius+radius/2, height-radius+radius/2);
  }

  public void wrapAround() {
    if (position.x < -radius) position.x = width+radius;
    if (position.y < -radius) position.y = height+radius;
    if (position.x > width+radius) position.x = -radius;
    if (position.y > height+radius) position.y = -radius;
  }

  public void display() {
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
  public void settings() {  fullScreen();  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SimpleOrganisms_Evolution" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
