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

  void addNeuron(Neuron n) {
    neurons = (Neuron[]) append(neurons, n);
  }

  void setInputs(float[] i) {              //set inputs for this layer
    layerInputs = i;
  }

  float[] getWeights() {
    return weights;
  }
  
  String getWeightsString() {
    String weightsStr = "";
    
    for (int i=0; i < weights.length; i++) 
    {
      weightsStr += weights[i] + " - ";
    }
    
    return weightsStr;
  }

  int getNeuronCount() {
    return neurons.length;
  }

  // increment output array
  void addLayerOutputs() {
    layerOutputs = (float[]) expand(layerOutputs, (layerOutputs.length+1));
  }

  void setWeights(float[] w) {
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

  void processInputs() {
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
