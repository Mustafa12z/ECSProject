# Amazon Threat Model Application

## Overview
This project involves containerizing Amazon's threat model application using Docker, with optimizations achieved through multi-stage builds. The Docker image is then pushed to Amazon Elastic Container Registry (ECR). Infrastructure provisioning for deploying this application is managed with Terraform, creating an ECS task, service, and cluster A Virtual Private Cloud (VPC) and load balancer was implemented. The project includes automated pipelines, creating an end-to-end DevOps project.

Below is a working instance of the threat model tool:

![alt text](image.png)


## Features
- **Containerization:** Dockerized Amazon's threat model application for consistent and portable deployment.
- **Optimized Docker Builds:** Multi-stage builds to reduce image size and improve performance.
- **ECR Integration:** Push Docker images to Amazon ECR for easy deployment.
- **Infrastructure as Code (IaC):** Use of Terraform to provision ECS task, service, and cluster.
- **High Availability:** Implemented a load balancer and VPC for scalable and reliable application deployment.
- **Automated Pipelines:** End-to-end deployment pipelines for continuous integration and continuous deployment (CI/CD).

## Setup


### Local Application Setup

If you want to view the threat composer tool locally,folow the steps below

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   ```
   This command will copy the project repository from the remote server (such as GitHub) to your local machine. Ensure you have the correct URL for the repository to get all the necessary files and code.

2. **Navigate to the project directory:**
   ```bash
   cd <project-directory>
   ```
   After cloning the repository, move into the project directory where all the application files are located. This is essential for running further commands and setting up the application.

3. **Install dependencies using Yarn:**
   ```bash
   yarn install
   ```
   This command will install all the necessary dependencies listed in the project's `package.json` file. Yarn ensures that all required libraries and modules are set up correctly so the application can run without issues.

4. **Start the application locally:**
   ```bash
   yarn start
   ```
   Once the dependencies are installed, use this command to start the application on your local machine. This will launch the application, allowing you to test and interact with it in your local development environment.

### Local Docker Container Setup
1. **Build the Docker image:**
   ```bash
   docker build -t <image-name> .
   ```
   This command will create a Docker image of the application using the Dockerfile in the project directory. The `-t <image-name>` option tags the image with a specific name, which makes it easier to reference later.

2. **Run the Docker container:**
   ```bash
   docker run -d -p 3000:3000 --name <container-name> <image-name>
   ```
   This command will start a new container from the Docker image you just built. The `-d` flag runs the container in detached mode (in the background), and `-p 3000:3000` maps port 3000 of the container to port 3000 on your local machine. Replace `<container-name>` with a name for the container and `<image-name>` with the name you used when building the image.

3. **Stop the Docker container:**
   ```bash
   docker stop <container-name>
   ```
   Use this command to stop the running container when you no longer need the application running. Replace `<container-name>` with the name you assigned to the container when starting it.

4. **Remove the Docker container:**
   ```bash
   docker rm <container-name>
   ```
   After stopping the container, you can remove it using this command. This helps keep your Docker environment clean by removing unused containers.

## CICD Pipelines

### Docker.Yaml

The docker.yaml pipeline is explained below, it is the pipeline we have that is responsible for building the docker image and uploading it to Amazon ECR

Checkout Code: Pulls the latest code from the repository.
Log in to Amazon ECR: Authenticates Docker with ECR, allowing it to push images to your ECR repository.
Build and Push Docker Image:
Builds the Docker image from the Dockerfile in the app directory.
Pushes the tagged image to the specified ECR repository.

### Terraform YAML files

The terraform pipelines we have, are responsible for terraform plan, apply and destroy. 

The terraform plan pipeline is set which means it runs on a push from any branch. The terraform apply and destroy pipelines can only be triggered manually using workflow-dispatch on the main branch (Once a PR has been completed). 

Checkout Code: Retrieves the latest repository files.
Setup Terraform: Installs and sets up Terraform in the workflow environment.
Terraform Init: Initializes the Terraform configuration and downloads provider plugins.
Terraform Plan: Creates an execution plan, displaying the resources Terraform will create or modify.
Terraform Apply: Applies the configuration to provision the infrastructure if triggered manually.
Terraform Destroy: Applies the destroy to the infrastructure if triggered manually within the main branch.