# Kubernetes cluster in AWS environment for Master Thesis simulations

This project was created to practice and showcase my devops skills, including deploying and managing applications using Kubernetes, AWS, and Terraform.
The project was inspired by a problem I encountered while writing my master's thesis. I had to run hundreds of simulations using machine learning on my computer, which took a very long time. Running the calculations in parallel in the cloud, would then be very helpful and speed up the work considerably.

## Table of Contents

- [Description](#introduction)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)
- [Project Achitecture](#project-architecture)
- [Master Thesis](#master-thesis)

---

## Description

Celery worker which gets a simulation config, splits simulation for N tasks, which are executed asynchronous, n because of averaging of results.
Celery workers runs simulations...
The process that controls the course of machine learning is in python
python.
The simulation environment is written in C++ to maximize performance. It is exposed as a Python module with a wrapper.

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

## Features

- **Kubernetes Cluster Provisioning**: The project includes Terraform scripts for provisioning an AWS-based Kubernetes cluster.
- **Application Deployment on Kubernetes**: The project includes Kubernetes configuration files and resources for deployment of the application on a Kubernetes cluster. This ensures scalability and robust management of simulations.
- **Dashboard for Simulation Management**: The application includes a simple Flask-based dashboard for initiating simulations, monitoring progress, and downloading results upon completion.
- **Simulations**: Simulation control proces is written in python. It has genetic algorithm for machine learning and uses simulation environment python module
module.
- **Simulation Environment**: The machine learning simulation environment is written in C++ for optimal performance. It is exported as a Python module with a wrapper for seamless integration.
- **Asynchronous Simulation Tasks**: Celery is used for asynchronous task execution, ensuring that simulations can run concurrently.

## Technologies Used

- **Python**: The primary programming language used for developing the project.
- **Flask**: Used to create the web-based dashboard for simulation management.
- **Celery**: Enables the execution of asynchronous simulation tasks.
- **C++**: Chosen for the simulation environment due to its superior performance characteristics.
- **Kubernetes**: Utilized for orchestrating the containerized simulations.
- **Terraform**: Used to define and provision the AWS infrastructure.
- **AWS**: The cloud platform on which the Kubernetes cluster is deployed.

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