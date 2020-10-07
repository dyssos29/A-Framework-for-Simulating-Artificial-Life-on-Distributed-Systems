Environment environment;
ClientIsland island;

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
boolean toSendMigration;

void setup() {
  //fullScreen();
  size(900, 500);
  smooth();
  organismCount = 60;
  //foodCount = 65;
  foodCount = 30;
  time = 0;
  currentGeneration = 0;
  longestGeneration = 0;
  highestAge = 0;
  bestGeneration = 0;
  environment = new Environment(organismCount, foodCount);
  try
  {
    island = new ClientIsland();
  }
  catch (TimeoutException t)
  {
    System.out.println("Timeout exception in initializing the island object: " + t.getMessage());
  }
  
  toSendMigration = true;
 

  results = createWriter("results.csv");
  // results = createWriter("results("+day()+"/"+month()+"/"+year()+").csv");
  results.println("Organisms, Food, Food rate, Best generation, Maximum fitness, Mutation rate, Number of mutations");
}

void mouseClicked() {
  results.println(organismCount +", " +foodCount +", " +environment.foodRate +", " +(bestGeneration+1) +", " +highestAge +", " +environment.mutationRate +", " +environment.numberOfMutations);

  results.flush();
  results.close();

  exit();
}

void draw() {
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
      highestAge = int(environment.findMaxFitness());
      bestGeneration = currentGeneration;
      toSendMigration = true;
      island.updateBestFitnessValue(highestAge);
    }
    else
      toSendMigration = false;

    time = 0;
    currentGeneration++;

    environment.foods.clear();
    int r = organismRadius;
    for (int i=0; i < foodCount; i++) {
      environment.foods.add(new Food(random(r+r/2, width-(r+r/2)), random(r+r/2, height-(r+r/2))));    //initialize food for the next gen
    }

    environment.organismSelection();
    environment.organismReproduction();
    
    MigrationMessage migration = new MigrationMessage(island.getNodeId(), currentGeneration, highestAge, environment.getMigrantNeuralNets());
    NeuralNetwork[] receivedNeuralNetworks = {}; 

    try
    {
      if (toSendMigration)
      {
        island.sendMigration(migration);
        receivedNeuralNetworks = island.getReceivedNeuralNetworks();
      }
      else
      {
        receivedNeuralNetworks = island.requestMigrations();
        System.out.println("Request sent successfully.");
      }
    }
    catch (IOException e)
    {
      System.out.println("IOException error in sending: " + e.getMessage());
    }
    catch(NullPointerException p)
    {
      System.out.println("Null pointer exception in sending: " + p.getMessage());
    }
    catch (Exception e)
    {
      System.out.println("Exception error in sending: " + e.getMessage());
    }
    
    if (receivedNeuralNetworks.length == 0)
    {
      // Since no migrants arrived, it will add its own migrants to the population and continue.
      environment.addMigrants(environment.getMigrantNeuralNets());
      System.out.println("No migration received.");
    }
    else
    {
      System.out.println("Migrations received.");
      environment.addMigrants(receivedNeuralNetworks);
    }
    
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
