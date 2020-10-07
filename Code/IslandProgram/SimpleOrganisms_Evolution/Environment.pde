class Environment {

  ArrayList<Food> foods;
  ArrayList<Organism> organisms;
  ArrayList<Organism> ancestorOrganisms;
  ArrayList<Organism> matingPool;
  Organism[] randomMigrants = {};
  Organism fittestOrganism = null;
  NeuralNetwork[] migrantNNs = {};

  float foodRate = 0.03;

  float mutationRate = 0.01;
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

  void run() {

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

  void organismSelection() {
    int randomIndex1;
    int randomIndex2;
    
    matingPool.clear();
    int ancestorOrganismsCount = ancestorOrganisms.size();
    float maxFitness = findMaxFitness();
    System.out.println("Maximum fitness: " + maxFitness);
    
    randomIndex1 = (int)random(ancestorOrganismsCount - 2);
    do randomIndex2 = (int)random(ancestorOrganismsCount - 2); while (randomIndex1 == randomIndex2);
    
    System.out.println("The random numbers are: " + randomIndex1 + " and " + randomIndex2);
    
    for (int i=0; i < ancestorOrganismsCount - 1; i++) {
      if (i == randomIndex1 || i == randomIndex2)
        randomMigrants = (Organism[])append(randomMigrants, ancestorOrganisms.get(i));
      else
      {
        //System.out.println("Number of ancestors: " + ancestorOrganisms.size() + ", i = " + i + ", Ancestor fitness: " + ancestorOrganisms.get(i).age);
        float normalizedFitness = map(ancestorOrganisms.get(i).age, 0, maxFitness, 0, 1);
        int n = (int)(normalizedFitness*100);
        for (int j=0; j<n; j++)
          matingPool.add( ancestorOrganisms.get(i) );
      }
    }
  } //end organismSelection

  void organismReproduction() {
    float tmp;

    for (int i=0; i<organismCount - 3; i++) {
      organisms.add(new Organism( random(0, width), random(0, height),
      new NeuralNetwork()) );

      int parentA = int(random( matingPool.size() ));
      int parentB = int(random( matingPool.size() ));

      Organism firstParent = matingPool.get(parentA);
      Organism secondParent = matingPool.get(parentB);

      for (int j=0; j<firstParent.NN.getLayerCount(); j++) {
        float[] firstParentWeights = new float[0];
        float[] secondParentWeights = new float[0];
        float[] successorWeights = new float[0];

        firstParentWeights = firstParent.NN.layers[j].getWeights();
        secondParentWeights = secondParent.NN.layers[j].getWeights();

        for (int k=0; k<firstParentWeights.length; k++) {
          if (random(1) > 0.5) {
            tmp = firstParentWeights[k];
          } else {
            tmp = secondParentWeights[k];
          }
          if (random(1) < mutationRate) {
            tmp += random(-0.1, 0.1);
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
  
  void addMigrants(NeuralNetwork[] neuralNets)
  {
    Organism migrantOrganism;
    
    for(int i = 0; i < neuralNets.length; i++)
    {
      migrantOrganism = new Organism(random(0, width), random(0, height));
      migrantOrganism.setNeuralNetwork(neuralNets[i]);
      organisms.add(migrantOrganism);
      System.out.println("i = " + i + ", array length: " + organisms.size());
    }
    System.out.println("Migrants added successfully, array length: " + organisms.size());
  }

  float findMaxFitness() {
    float currentMax = 0;
    Organism tempOrganism = null;
    float tempAge;
    
    for (int i=0; i<ancestorOrganisms.size(); i++) {
      tempOrganism = ancestorOrganisms.get(i);
      tempAge = tempOrganism.age;
      if (tempAge > currentMax) {
        currentMax = tempAge;
        fittestOrganism = tempOrganism;
      }
    }
    return currentMax;
  }

  ArrayList getFoods() {
    return foods;
  }

  ArrayList getOrganisms() {
    return organisms;
  }
  
  NeuralNetwork[] getMigrantNeuralNets()
  {
    migrantNNs = new NeuralNetwork[]{};
    
    if (randomMigrants.length < 2)
      System.out.println("Not all random migrants are assembled.");
    else if (fittestOrganism == null)
      System.out.println("The fittest organism is not found (it is null).");
    else
    {
      migrantNNs = (NeuralNetwork[])append(migrantNNs, randomMigrants[0].getNeuralNetwork());
      migrantNNs = (NeuralNetwork[])append(migrantNNs, randomMigrants[1].getNeuralNetwork());
      migrantNNs = (NeuralNetwork[])append(migrantNNs, fittestOrganism.getNeuralNetwork());
    }
    
    return migrantNNs; 
  }
} //THE END
