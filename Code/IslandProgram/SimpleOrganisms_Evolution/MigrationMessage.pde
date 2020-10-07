class MigrationMessage
{
  private String nodeId;
  private int generationNumber;
  private int bestFitnessValue;
  private NeuralNetwork[] migrantsNN;
  
  public MigrationMessage(){}
  
  public MigrationMessage(String nodeId, int generationNumber, int bestFitnessValue, NeuralNetwork[] migrantsNN){
    this.nodeId = nodeId;
    this.generationNumber = generationNumber;
    this.bestFitnessValue = bestFitnessValue;
    this.migrantsNN = migrantsNN;
  }
  
  public String getNodeId(){
    return nodeId;
  }
  
  public int getGenerationNumber(){
    return generationNumber;
  }
  
  public int getBestFitnessValue(){
    return bestFitnessValue;
  }
  
  public NeuralNetwork[] getMigrantNeuralNetwors(){
    return migrantsNN;
  }
}