class Neuron {
  NNConnection[] connections ={};
  float[] connectionWeights ={};
  float bias;
  float neuronInput;
  float neuronOutput;

  Neuron(int connectionCount) {
    randomBias();
    for (int i = 0; i < connectionCount; i++) {
      NNConnection connection = new NNConnection();
      addConnection(connection);
      float w = connection.getWeight();
      connectionWeights = (float[]) append(connectionWeights, w);
    }
    connectionWeights = (float[]) append(connectionWeights, bias);
  }

  void addConnection(NNConnection c) {
    connections = (NNConnection[]) append(connections, c);
  }

  int getConnectionCount() {
    return connections.length;
  }

  void setBias(float b) {
    bias = b;
  }

  void randomBias() {
    setBias(random(-1, 1));
  }

  float getNeuronOutput(float[] connectionEntries) {
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

  float ActivateFunction(float x) {
    return (2 / (1 + exp(-1 * (x*2)))) -1;
  }
}
