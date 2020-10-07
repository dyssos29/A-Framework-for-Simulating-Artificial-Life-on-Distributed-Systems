class NNConnection {
  float connectionEntry;
  float connectionWeight;
  float connectionExit;

  NNConnection() {
    randomWeight();
  }

  void setWeight(float w) {
    connectionWeight = w;
    connectionWeight = constrain(connectionWeight, -1, 1);
  }

  void randomWeight() {
    setWeight(random(-1, 1));
  }

  float getWeight() {
    return connectionWeight;
  }

  float getConnectionExit(float e) {
    connectionEntry = e;
    connectionExit = connectionEntry * connectionWeight;
    return connectionExit;
  }
}
