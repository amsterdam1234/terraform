# Terraform Project - Deploying a Monitored Flask Web Server on AWS

## Table of Contents
1. [Project Overview](#project-overview)
2. [Project Architecture and Components](#project-architecture-and-components)
   - [AWS Resources](#aws-resources)
     - [VPC - Virtual Private Cloud](#vpc---virtual-private-cloud)
     - [Subnets - Public and Private Subnets](#subnets---public-and-private-subnets)
     - [Security Groups](#security-groups)
     - [Internet Gateway](#internet-gateway)
     - [Route Table](#route-table)
     - [Elastic Load Balancer (ELB)](#elastic-load-balancer-elb)
     - [Auto Scaling Group](#auto-scaling-group)
     - [Key Pairs](#key-pairs)
     - [User Data Scripts](#user-data-scripts)
     - [DNS - Route53](#dns---route53)
     - [SNS](#sns)
3. [Monitoring and Alerting Architecture](#monitoring-and-alerting-architecture)
   - [CloudWatch](#cloudwatch)
   - [Prometheus](#prometheus)
4. [How to run the project](#how-to-run-the-project)

## Project Overview

This project utilizes Infrastructure as Code (IaC) principles through Terraform to automate the creation and management of AWS resources required to run a monitored Flask web server.

## Project Architecture and Components

The project is composed of several AWS resources:

![terraform project.jpg](photos%2Fterraform%20project.jpg)

### AWS Resources

#### VPC - Virtual Private Cloud

- **Description**: A VPC is created to isolate the resources within the project.
- **CIDR Block**: `10.0.0.0/26` for 64 IP addresses.

#### Subnets - Public and Private Subnets

- **Public Subnet**:
    - **CIDR Block**: `10.0.0.0/28`
    - **Components**:
        - **Bastion Host & Prometheus**: Used for secure SSH access to instances in the private subnet and to present and collect metrics from Prometheus.
        - **NAT Gateway**: Allows instances in the private subnet to access the internet without exposing them to inbound internet traffic.
        - **Elastic IP**: A static public IP address associated with the NAT Gateway.

- **Private Subnet**:
    - **CIDR Block**: `10.0.0.16/28`
    - **Components**:
        - **Auto Scaling Group**: Automatically adjusts the number of EC2 instances based on demand.
        - **EC2 Instances from the ASG**: Hosts the Flask web application.

#### Security Groups

- **Description**: Define rules for inbound and outbound traffic.
- **Components**:
    - **Bastion Host & Prometheus Security Group**:
        - **Port 22**: SSH access for secure management.
        - **Port 9090**: Access to Prometheus web UI and API.
        - **Port 9100**: Node Exporter for Prometheus monitoring - allow scraping the metrics.
    - **NAT Gateway Security Group**: Manages internet access for private instances.
    - **EC2 Instances Security Group**:
        - **Port 80**: HTTP access for the Flask application.
        - **Port 443**: HTTPS access for the Flask application.
        - **Port 9100**: Node Exporter for Prometheus monitoring - allow scraping the metrics.
    - **ELB Security Group**:
        - **Port 80**: HTTP access for load balancing web traffic.
        - **Port 443**: HTTPS access for load balancing web traffic.

#### Internet Gateway

- **Description**: Connects the VPC to the internet.
- **Components**:
    - **NAT Gateway**: Allows instances in the private subnet to access the internet without exposing them to inbound internet traffic.
    - **Internet Gateway**: Provides a path for inbound and outbound internet traffic.

#### Route Table

- **Description**: Manages routing of network traffic within the VPC.
- **Components**:
    - **Public Route Table**: Routes traffic from the public subnet to the internet gateway.
    - **Private Route Table**: Routes traffic from the private subnet to the NAT Gateway.

#### Elastic Load Balancer (ELB)

- **Description**: Distributes incoming application traffic across multiple EC2 instances.
- **Configuration**:
    - **Health Check**: Monitors the health of the instances and directs traffic to healthy instances.
    - **Listeners**: Listens for incoming traffic on specific ports and forwards it to the instances.
    - **Security Group**: Controls inbound and outbound traffic to the ELB.

#### Auto Scaling Group

- **Description**: Ensures the application can handle varying traffic loads by automatically adjusting the number of EC2 instances.
- **Components**:
    - **Launch Template**: Defines the configuration for EC2 instances, including AMI, instance type, and user data.
    - **Scaling Policies**: Define how the group scales in and out based on CloudWatch alarms or target tracking policies.
        - **Scale Out**: Increase the number of instances when the average CPU utilization exceeds a threshold using CloudWatch alarms.
    - **EC2 Instances**: Automatically launched or terminated based on the scaling policies to handle the application load.

#### Key Pairs

- **Description**: Manage SSH access to EC2 instances.
- **Function**: Securely connect to EC2 instances using SSH keys (the ASG's EC2).

#### User Data Scripts

- **Purpose**: Automate the configuration of EC2 instances at launch.
- **Scripts**:
    - `userdata.sh`: Sets up Node Exporter, installs necessary packages, runs the Flask application, and clones the web repo.
    - `userdata_bastion_prometheus.sh`: Configures the Bastion host with Node Exporter, Prometheus, and Apache server.

#### DNS - Route53

- **Description**: Manages DNS settings.
- **Components**:
    - **Hosted Zone**: Stores DNS records for the domain.
    - **Record Set**: Maps the domain name to the ELB’s IP address.
    - **Domain Name**: Used to access the application deployed on AWS using the omer-amsterdam.com domain.

#### SNS

- **Description**: Sends notifications.
- **Components**:
    - **Topic**: Defines the subject and message for the notification.
    - **Subscription**: Specifies the endpoint to receive the notifications (email and SMS).

## Monitoring and Alerting Architecture

### CloudWatch

- **Description**: Collects logs and metrics.
- **Function**: Provides monitoring and alerting capabilities.
- **Alarms**:
    - **CPU Utilization for ASG's EC2**: Triggers when the average CPU utilization exceeds a threshold, triggering a scaling policy for scale up.
    - **CPU Utilization for the Bastion Host & Prometheus**: Triggers when the average CPU utilization exceeds a threshold.
    - **High request count for the ELB**: Triggers when the number of requests exceeds a threshold.
    - **High latency for the ELB**: Triggers when the latency exceeds a threshold.
    - **High HTTP 4XX count for the ELB**: Triggers when the number of errors exceeds a threshold.

### Prometheus

- **Description**: Monitors system and application performance.
- **Components**:
    - **Node Exporter**: Collects metrics from instances.
        - **Port 9100**: Metrics collection endpoint.
    - **Prometheus Server**: Collects and visualizes metrics from Node Exporter.
        - **Port 9090**: Access Prometheus web UI and API.

## How to run the project
1. Clone the repository:
    ```bash
    git clone https://github.com/amsterdam1234/terraform.git
    cd terraform
    ```
2. Install terraform:
    ```bash
    brew tap hashicorp/tap  
    brew install hashicorp/tap/terraform
    ```
3. Install the AWS CLI:
    ```bash
    brew install awscli
    ```
4. Initialize Terraform:
    ```bash
    terraform init
    ```
5. Change the aws profile in the `main.tf` file to your aws profile
6. Run the following commands to create the infrastructure:
    ```bash
    terraform plan
    terraform apply
    ```
7. Go to the domain name to see the web server (http://omer-amsterdam.com)
![webpage.png](photos%2Fwebpage.png)
8. If it is not working, it due to the DNS propagation, so you can use the ELB DNS name to access the web server to see the web server
#t odo adding picture
9. Go to the bastion host to see the prometheus metrics use the public IP of the bastion host and the port 9090 to see the prometheus metrics (http://bastion-host-public-ip:9090)
10. To destroy the infrastructure run the following command:
    ```bash
    terraform destroy
    ```