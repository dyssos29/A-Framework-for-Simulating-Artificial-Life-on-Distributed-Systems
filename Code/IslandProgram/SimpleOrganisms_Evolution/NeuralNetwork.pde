class NeuralNetwork {
  Layer[] layers ={};
  float[] inputs ={};
  float[] outputs ={};

  NeuralNetwork() {
  }

  void addLayer(int connectionCount, int neuronCount) {
    layers = (Layer[]) append(layers, new Layer(connectionCount, neuronCount));
  }

  void setInputs(float[] i) {
    inputs = i;
  }

  void setOutputs(float[] o) {
    outputs = o;
  }

  float[] getOutputs() {
    return outputs;
  }

  int getLayerCount() {
    return layers.length;
  }
  
  Layer getLayer(int index)
  {
    return layers[index];
  }

  void setInputsAtLayer(float[] inputs, int index) {
    if (index > layers.length-1) {
      println("Error: exceeded layer limits!");
    } else {
      layers[index].setInputs(inputs);
    }
  }

  void processInputs(float[] tmpInputs) {
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
  
  String toString()
  {
    return "The weights of the NN are the following --> layer 1: " + getLayer(0).getWeights().length + " weights, layer 2: " + getLayer(1).getWeights().length + "\n" +
            "Layer 1: " + getLayer(0).getWeightsString() + ", Layer 2: " + getLayer(1).getWeightsString();
  }
} //end class
