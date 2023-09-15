# AWS Kubernetes cluster for Master Thesis simulations

This project serves as a demonstration of my proficiency in DevOps practices and showcases my ability to deploy and manage applications using Kubernetes, AWS, Terraform, and related technologies. The motivation behind this project stems from my master's thesis work, where I encountered the need to run numerous machine learning simulations efficiently.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Dashboard](#dashboard)
- [Simulation Environment](#simulation-environment)
- [Contributing](#contributing)
- [License](#license)

---

## Introduction

In my master's thesis, I encountered the challenge of running a large number of machine learning simulations on my local machine, which proved to be time-consuming. To address this issue, I decided to leverage DevOps principles and create a Kubernetes cluster on AWS using Terraform. This allows for the concurrent execution of multiple simulations, significantly improving efficiency.

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

## Description
This repository contains source code for the master thesis.

There is also a version available in which the simulation environment was created in Unity and Tensorflow library. However, it is not finished! It was decided to use an environment written in C++ because of the higher computing efficiency and much shorter simulation time.
Unity version can be found [here](https://github.com/adrian-slimak/artifical-agents).

Some visualizations from learning process can be found [here](http://bit.ly/praca_magisterska_adrian_slimak).

## Features

- **Kubernetes Cluster Deployment**: The project includes Terraform scripts for provisioning an AWS-based Kubernetes cluster.
- **Dashboard for Simulation Management**: A simple Flask-based dashboard is provided for initiating simulations, monitoring progress, and downloading results upon completion.
- **Asynchronous Simulation Tasks**: Celery is used for asynchronous task execution, ensuring that simulations can run concurrently.
- **Simulation Environment**: The machine learning simulation environment is written in C++ for optimal performance. It is exported as a Python module with a wrapper for seamless integration.

## Technologies Used

- **Python**: The primary programming language used for developing the project.
- **Flask**: Used to create the web-based dashboard for simulation management.
- **Celery**: Enables the execution of asynchronous simulation tasks.
- **C++**: Chosen for the simulation environment due to its superior performance characteristics.
- **Kubernetes**: Utilized for orchestrating the containerized simulations.
- **Terraform**: Used to define and provision the AWS infrastructure.
- **AWS**: The cloud platform on which the Kubernetes cluster is deployed.

## Getting Started

To get started with this project, follow the steps outlined in the [Getting Started](docs/getting-started.md) guide.

## Usage

For detailed usage instructions and examples, refer to the [Usage](docs/usage.md) documentation.

## Dashboard

The dashboard provides a user-friendly interface for managing simulations. More information can be found in the [Dashboard](docs/dashboard.md) documentation.

## Simulation Environment

The simulation environment is written in C++ to maximize performance. It is exposed as a Python module with a wrapper.