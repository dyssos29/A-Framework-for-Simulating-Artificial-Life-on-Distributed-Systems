import com.rabbitmq.client.*;
import com.rabbitmq.client.impl.recovery.*;
import com.rabbitmq.client.impl.*;
import com.rabbitmq.utility.*;
import com.rabbitmq.tools.jsonrpc.*;
import com.rabbitmq.tools.json.*;
import com.rabbitmq.client.impl.nio.*;

import org.slf4j.event.*;
import org.slf4j.helpers.*;
import org.slf4j.*;
import org.slf4j.spi.*;
import org.slf4j.impl.*;

import com.google.gson.*;
import com.google.gson.stream.*;
import com.google.gson.reflect.*;
import com.google.gson.internal.*;
import com.google.gson.internal.reflect.*;
import com.google.gson.internal.bind.*;
import com.google.gson.internal.bind.util.*;
import com.google.gson.annotations.*;

import java.io.*;
import java.util.concurrent.TimeoutException;
import java.util.UUID;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ArrayBlockingQueue;

public class ClientIsland
{
  private ConnectionFactory factory;
  private Connection connection;
  private Channel channel;
  private QueueingConsumer consumer;
  private final String REQUEST_QUEUE_NAME = "rpc_request_queue";
  private String responseQueueName = "";
  private Gson jsonMaker;
  private String correlationId;
  private MigrationMessage[] receivedMigrationMessages = {};
  private int bestFitnessValue;
  
  public ClientIsland() throws  TimeoutException
  {
    factory = new ConnectionFactory();
    factory.setHost("ody-rabbit");
    try
    {
      connection = factory.newConnection();
    }
    catch (IOException e)
    {
      System.out.println("Error in creating connection: " + e.getMessage());
    }
    
    try
    {
      channel = connection.createChannel();
    }
    catch (IOException e)
    {
      System.out.println("Error in creating channel: " + e.getMessage());
    }
    
    try
    {
      responseQueueName = channel.queueDeclare().getQueue();
    }
    catch (IOException e)
    {
      System.out.println("Error in creating anonymous queue: " + e.getMessage());
    }
    
    consumer = new QueueingConsumer(channel);
    jsonMaker = new Gson();
  }
  
  public void updateBestFitnessValue(int bestFitnessValue)
  {
    this.bestFitnessValue = bestFitnessValue;
  }
  
  public String getNodeId()
  {
    String nodeId = "";
    
    try
    {
      File file = new File("/etc/hostname"); 
      BufferedReader br = new BufferedReader(new FileReader(file));
      nodeId = br.readLine();
      br.close();
    }
    catch (IOException e)
    {
      System.out.println("Error in retrieving the node id from the hostname file: " + e.getMessage());
    }
    catch (NullPointerException p)
    {
      System.out.println("Null pointer exception in retrieving the node id from the hostname file: " + p.getMessage());
    }
    
    return nodeId;
  }
  
  public void sendMigration(MigrationMessage migration) throws IOException, NullPointerException
  {
    receivedMigrationMessages = new MigrationMessage[]{};
    correlationId = UUID.randomUUID().toString();
    AMQP.BasicProperties properties = new AMQP.BasicProperties
                .Builder()
                .correlationId(correlationId)
                .replyTo(responseQueueName)
                .build();
    String json = serializeMigrationMessage(migration);
    
    channel.basicPublish("", REQUEST_QUEUE_NAME, properties, json.getBytes());
  }
  
  public NeuralNetwork[] requestMigrations() throws Exception
  {
    NeuralNetwork[] receivedNNs = {};
    receivedMigrationMessages = new MigrationMessage[]{};
    correlationId = UUID.randomUUID().toString();
    AMQP.BasicProperties properties = new AMQP.BasicProperties
                .Builder()
                .correlationId(correlationId)
                .replyTo(responseQueueName)
                .build();
    String request = "{}";
    
    channel.basicPublish("", REQUEST_QUEUE_NAME, properties, request.getBytes());
    receivedNNs = getReceivedNeuralNetworks();
    
    return receivedNNs;
  }
  
  public NeuralNetwork[] getReceivedNeuralNetworks() throws Exception
  {
    NeuralNetwork[] receivedNNs = {};
    
    if (checkIfMigrantsArrived())
    {
      if (bestFitnessValue == receivedMigrationMessages[0].getBestFitnessValue())
      {
        if (receivedMigrationMessages.length > 1)
        {
          receivedNNs = receivedMigrationMessages[1].getMigrantNeuralNetwors();
          System.out.println("Chose the second best migration, which is : " + receivedMigrationMessages[1].getBestFitnessValue());
        }
        else
          System.out.println("The island received only one migration message and did not choose it because it had the same fitness value with the island's best fitness value so far.");
      }
      else
      {
        receivedNNs = receivedMigrationMessages[0].getMigrantNeuralNetwors();
        System.out.println("Chose the best migration, which is : " + receivedMigrationMessages[0].getBestFitnessValue());
      }
    }
    
    return receivedNNs;
  }
  
  private boolean checkIfMigrantsArrived() throws Exception
  {
    BlockingQueue<String> response  = new ArrayBlockingQueue<String>(1);
    
    channel.basicConsume(responseQueueName, consumer);
    QueueingConsumer.Delivery deliver = consumer.nextDelivery();
    
    if (processMessage(deliver, response))
    {
      long deliveryTag = deliver.getEnvelope().getDeliveryTag();
      channel.basicAck(deliveryTag, true);
      
      if (receivedMigrationMessages.length == 0)
        return false;
      else
        return true;
    }
      
    return false;
  }
  
  private boolean processMessage(QueueingConsumer.Delivery delivery, BlockingQueue<String> response) throws Exception
  {
    if (delivery.getProperties().getCorrelationId().equals(correlationId)) 
    {
      //System.out.println("Correct correlation id.");
      if (response.offer(new String(delivery.getBody(), "UTF-8")))
      {
        String responseStr = response.take();
        if (responseStr.equals("{}"))
          System.out.println("The message is empty.");
        else
        {
          receivedMigrationMessages = deserializeMigrationMessages(responseStr);
          if (receivedMigrationMessages.length == 1)
            System.out.println("Received the following migrants: " + receivedMigrationMessages[0].getBestFitnessValue());
          else
            System.out.println("Received the following migrants: " + receivedMigrationMessages[0].getBestFitnessValue() + ", " + receivedMigrationMessages[1].getBestFitnessValue());
        }
          
        return true;
      }
      else
      {
        System.out.println("Error: the insertion to the blocking queue was not successful.");
        return false;
      }
    }
    System.out.println("Wrong correlation id.");
    return false;
  }
  
  private String serializeMigrationMessage(MigrationMessage migration)
  {
    return jsonMaker.toJson(migration);
  }
  
  private MigrationMessage[] deserializeMigrationMessages(String migrationJson)
  {
    return jsonMaker.fromJson(migrationJson, MigrationMessage[].class);
  }
}
