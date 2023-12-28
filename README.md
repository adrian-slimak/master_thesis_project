
# Kubernetes cluster in AWS environment for machine learning simulations

This project was created to practice and showcase my DevOps skills, including infrastructure automation using Terraform, Kubernetes orchestration, and application deployment in AWS.
The project was inspired by a problem I encountered while writing my master's thesis. In the thesis, I used machine learning and genetic algorithm to run the necessary simulations, so a big limitation was the computational capacity of my computer. I decided to move these calculations to the cloud to solve this problem. For this purpose, I created a Kubernetes cluster on the AWS cloud using Terraform.

## Table of Contents

- [Description](#description)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)
- [Project Achitecture](#project-architecture)
- [Master Thesis](#master-thesis)

## Description

There are three main parts to the project, consisting of the cluster, the application and machine learning.

- **Kubernetes Cluster Provisioning**: The project includes Terraform scripts for provisioning an AWS-based Kubernetes cluster.
- **Application Deployment on Kubernetes**: The project includes Kubernetes configuration files and resources for deployment of the application on a Kubernetes cluster. This ensures scalability and robust management of simulations.

**Application**
The application that runs on the cluster consists of a dashboard and workers.

The dashboard is used to manage machine learning processes. It can be used to start new processes, as well as to track their progress and retrieve their results.
The dashboard was created in python language using flask. The learning results are stored in a MongoDB database.

Workers are responsible for running machine learning processes. Once a new process is ordered, it goes to a queue and then to a free worker. This has been achieved through the use of Celery. This solution makes it easy to scale computing capacity by increasing the number of workers.

**Machine Learning**
Machine learning consists of a genetic algorithm and a simulation environment. The genetic algorithm is used to train LSTM and RNN models based on data obtained from the simulation environment.
The machine learning process itself was written in python. It consists of a genetic algorithm, real-time visualization of the learning process and the creation of graphs based on the obtained data.
A json file is used to configure the learning parameters.
The simulation environment is written in c++ for its efficiency, and is used in python through a wrapper.
Detailed information can be found in the master's thesis.

## Project Structure
```
├── README.md
├── machine_learning
|  └── learning
|  └── simulation_environment
├── terraform
|  └── s3_bucket
|  └── environment
├── docker
|  └── flask_dashboard
|  └── celery_worker
|  └── docker-compose.yaml
└── kubernetes
```

## Technologies Used

- **AWS**: The cloud platform on which the project cluster is deployed.
- **Terraform**: Used to define and provision the AWS infrastructure.
- **Kubernetes**: Utilized for orchestrating the containerized simulations.
- **RKE**: Used for installation of kubernetes cluster.
- **Python**: Programming language used for developing the application.
- **C++**: Programming language chosen for machine learning and simulations due to its superior performance.
- **Docker**: Used to build the application images.
- **Docker Compose**: Used to test the application locally.
- **Flask**: Used to create a web-based dashboard for the application for managing machine learning processes.
- **Celery**: Used for distributed processing of machine learning processes.
- **Redis**: Used as a backend and a message broker for celery.
- **MongoDB**: Used to store data, configuration files, and results of machine learning processes.

## Project Architecture

Soon...

## Master Thesis

**Thesis name:<br>
Forming herd behaviour by virtual agents using deep neural networks**

**Thesis abstract:**<br>
A review of the literature on the evolution of artificial life herd behaviour has shown that
existing research focuses mainly on the pressure exerted by the presence of a predator and the
creation of herds by prey in response to different forms of attacks. However, there is a lack of
research that would address more broadly such key issues in nature as the need for prey to feed or
communication among predators, that could allow breaking through the form of prey defense
that is a herd.
This work fills this gap. For this purpose, a virtual environment has been constructed, which
contains the necessary mechanisms and models a selected fragment of nature to the extent
required for research. The environment is inhabited by agents, that is, artificial animals, which
are controlled by a driver based on a recurrent neural network RNN or LSTM. Based on the
observations received from the environment by the senses and their memory state, the driver
decides to change the position of the agent or to release a sound.
In this thesis, a comparison was made of the type of controller used in the research on the
formation of herd behaviour among agents, living under the pressure of predator attacks and the
need to search for food, as well as the impact of the communication mechanism present in both
preys and predators.

Some visualizations from learning process can be found [here](http://bit.ly/praca_magisterska_adrian_slimak).
