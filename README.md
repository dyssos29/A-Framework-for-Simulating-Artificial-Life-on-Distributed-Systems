# A Framework for Simulating Artificial Life on Distributed Systems
This is the dissertation research project that I needed to build for my Bachelor's degree in Computer Science. In brief, this project is essentially a tool for running Artificial Life digital simulations on a distributed system, using state of the art technologies related to distributed computing and graphic visuals. In particular, the main technologies used in this software are the following:
* **Processing** for presenting the digital simulation in a graphical environment.
* **RabbitMQ** for robust data communication between software components.
* **Node.js** for its event-driven and non-blocking I/O nature, a characteristic that the project sofware needed.
* **WebSockets** for real-time communication and data transfer.
* **Docker** containerization technology for containerizing the whole software stack and Docker Swarm for enabling it to operate on any distributed system.

Last important point to make is that the notion of Parallel Genetic Algorithms were heavily used for the creation of this framework. More precisely, the particular framework is primarily based on a Parallel Genetic Algorithm, which is the **Island Model Genetic Algorithm**.

## Abstract of Dissertation Research Paper
*Abstract*: This paper describes a software project, which is a distributed framework
for running Artificial Life simulations. Operating this type of simulations
can be sometime very expensive in terms of computational power. This
undermines the operation of the simulation and thus poses a problem to the
user or developer of the simulation software. As such, a promising solution
for this problem is to run this simulation on a distributed system, which will
handle more efficiently the large computational load that usually comes
with it. However, this is not a simple task and requires a lot of system
configurations and changes in the software of the simulation. Therefore,
this paper proposes an efficient and state of the art tool to solve this problem
in a modern fashion. More specifically, this tool is a microservice-based
framework which is able to run on any distributed environment.

## Initial Vision of the System
![system vision](/Pictures/SystemVision.jpg?raw=true)

## Theoretical Model of the System
![theoretical model](/Pictures/TheoreticalModel.jpg?raw=true)

## Final Architecture of the System
![final architecture](/Pictures/SoftwareStackArchitecture.jpg?raw=true)

## Video Demo
[![video_demo](/Pictures/YoutubeScreenshot.png?raw=true)](https://www.youtube.com/watch?v=nsu5uAYe1us&t=0s&ab_channel=OdysseasFilippidis "Short Video Presentation")
