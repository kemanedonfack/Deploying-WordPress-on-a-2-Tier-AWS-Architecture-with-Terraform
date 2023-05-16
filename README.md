# Deploying WordPress on a 2-Tier AWS Architecture with Terraform

## Introduction

Deploying WordPress on a **two-tier AWS architecture** with Terraform provides a robust and scalable solution for hosting your WordPress site. **Amazon Web Services (AWS)** offers a wide range of services that can be leveraged to create a resilient and high-performing infrastructure, while Terraform enables us to automate the deployment process.

In this article, we will explore the step-by-step process of deploying WordPress on a two-tier AWS architecture using Terraform. By following this guide, you will be able to set up a reliable infrastructure that separates the presentation layer from the data layer, thereby optimizing performance and providing flexibility for future growth.

## What is Terraform?

[**Terraform**](https://www.terraform.io/) is an open-source tool developed by [**HashiCorp**](https://www.hashicorp.com/) that allows for the automated management of IT infrastructure. It uses a declarative approach to create, modify, and delete cloud resources. With **Terraform**, you can describe your infrastructure in configuration files, making it easier to manage as code. The tool is compatible with multiple cloud providers, enabling you to provision resources on different platforms. Terraform provides a powerful and flexible solution for automating the deployment and management of your cloud infrastructure.

### Advantages of Terraform
- **Infrastructure Automation**: Terraform allows for the automation of provisioning and managing your cloud infrastructure. You can describe your infrastructure using configuration files, making it easy to deploy and update your resources.
- **Multi-Cloud and Multi-Provider**: Terraform supports multiple public cloud providers such as AWS, Azure, GCP, as well as private cloud providers. You can use the same Terraform configuration files to provision resources on different platforms.
- **Modularity**: Terraform allows you to define infrastructure as reusable modules. These modules can encapsulate specific configurations and be used to create complex and scalable infrastructures. This also facilitates sharing and reusing best practices within your organization.
- **Dependency Management**: Terraform automatically manages dependencies between different resources in your infrastructure. It identifies dependencies and updates them consistently during changes. This simplifies the management of complex infrastructures with many interconnected components.

## What is a 2-Tier Architecture?

In the context of the article about deploying WordPress on a 2-Tier AWS architecture with Terraform, here is a concise description of what a 2-Tier architecture is:

A 2-Tier architecture, also known as a two-tier architecture, is a model of IT infrastructure that separates application components into two distinct layers: `the presentation layer` and `the data layer`.

- **The presentation layer**: also known as the front-end layer, is responsible for the user interface and interaction with end-users. In the case of WordPress, this layer includes the web server that handles HTTP requests and displays website pages to visitors.

- **The data layer**: also known as the back-end layer, is responsible for data storage and access. For WordPress, this involves managing the database where articles, comments, user information, etc., are stored.

By using a 2-Tier architecture, we can achieve several benefits. Firstly, it allows for a clear separation of responsibilities between the presentation layer and the data layer, making application management and maintenance easier.

Additionally, this approach provides greater **flexibility** and **scalability**. In the event of traffic spikes, we can scale only the presentation layer by adding additional web server instances, without impacting the data layer. This ensures optimal performance and a smooth user experience.

## Prerequisites

Before starting the deployment process, make sure you have the following prerequisites in place:

- Basic knowledge of Terraform & AWS
- Installed AWS CLI
- Installed Terraform CLI 

Now, let’s start configuring our project

## Step 1: Configure our provider

create a file `provider.tf` with the below content

```
provider "aws" {
  region = "eu-north-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}
```
The `provider.tf` file is used to configure the AWS provider for Terraform, specifying the AWS region and the required provider version.

The resources defined in this file are:

provider "aws": Specifies the AWS provider for Terraform. It sets the region to "eu-north-1", indicating that the resources will be provisioned in the AWS EU (Stockholm) region. The role of this resource is to authenticate Terraform with the specified AWS region and allow it to manage AWS resources.
terraform block: Defines the required providers for the Terraform configuration. In this case, it specifies that the "aws" provider is required, with a specific version of "4.65.0". The role of this block is to ensure that the correct version of the AWS provider is used for the configuration.

## Step 2: Create VPC and subnets

First, let's create a `variables.tf` file to store all our variables.
```
variable "inbound_port_production_ec2" {
  type        = list(any)
  default     = [22, 80]
  description = "inbound port allow on production instance"
}

variable "db_name" {
  type    = string
  default = "kemanedonfack"
}

variable "db_user" {
  type    = string
  default = "kemane"
}

variable "db_password" {
  type    = string
  default = "Kemane-AWS2023"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami" {
  type    = string
  default = "ami-0cf13cb849b11b451"
}

variable "key_name" {
  type    = string
  default = "kemane"
}

variable "availability_zone" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "list of all cidr for subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "target_application_port" {
  type    = string
  default = "80"
}

```

The `variables.tf` file is used to define and initialize the Terraform variables required for configuring and deploying the 2-Tier architecture for the WordPress application on AWS. The defined variables include information about **EC2 instances**, **the database**, **ports**, **instance type**, **AMI ID**, **availability zone**, **VPC CIDR**, **subnet CIDRs**, and **target application ports**. These variables can be modified to fit the specific needs of the project.

create `vpc.tf` file and add the below content

```
resource "aws_vpc" "infrastructure_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  instance_tenancy     = "default"

  tags = {
    Name = "2-tier-architecture-vpc"
  }
}

#It enables our vpc to connect to the internet
resource "aws_internet_gateway" "tier_architecture_igw" {
  vpc_id = aws_vpc.infrastructure_vpc.id
  tags = {
    Name = "2-tier-architecture-igw"
  }
}

#first ec2 instance public subnet
resource "aws_subnet" "ec2_1_public_subnet" {
  vpc_id                  = aws_vpc.infrastructure_vpc.id
  cidr_block              = var.subnet_cidrs[1]
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = var.availability_zone[1]
  tags = {
    Name = "first ec2 public subnet"
  }
}

#second ec2 instance public subnet
resource "aws_subnet" "ec2_2_public_subnet" {
  vpc_id                  = aws_vpc.infrastructure_vpc.id
  cidr_block              = var.subnet_cidrs[2]
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = var.availability_zone[2]
  tags = {
    Name = "second ec2 public subnet"
  }
}

#database private subnet
resource "aws_subnet" "database_private_subnet" {
  vpc_id                  = aws_vpc.infrastructure_vpc.id
  cidr_block              = var.subnet_cidrs[4]
  map_public_ip_on_launch = "false" //it makes this a private subnet
  availability_zone       = var.availability_zone[2]
  tags = {
    Name = "database private subnet"
  }
}

#database read replica private subnet
resource "aws_subnet" "database_read_replica_private_subnet" {
  vpc_id                  = aws_vpc.infrastructure_vpc.id
  cidr_block              = var.subnet_cidrs[3]
  map_public_ip_on_launch = "false"
  availability_zone       = var.availability_zone[1]
  tags = {
    Name = "database read replica private subnet"
  }
}
```
The `vpc.tf` file contains the definition of the **Virtual Private Cloud (VPC)** where the infrastructure resources will be created for our 2-tier AWS architecture using Terraform.

The resources defined in this file are:

- **aws_vpc**: Defines the VPC with the CIDR block and the enabled DNS resolution and hostname settings. The role of this resource is to create the main VPC that will be used to host the different EC2 instances and RDS databases.
- **aws_internet_gateway**: Adds a gateway to allow the VPC to connect to the internet. The role of this resource is to enable internet connectivity for the VPC, which will be used to provide internet access to the EC2 instances.
- **aws_subnet**: Defines the subnets that will be used to create the EC2 instances and RDS databases. Two subnets are public for the EC2 instances, while the other two are private for the databases. The role of this resource is to create the subnets for the different resources that will be created in the VPC.

create `route_table.tf` file and add the below content

```
resource "aws_route_table" "infrastructure_route_table" {
  vpc_id = aws_vpc.infrastructure_vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.tier_architecture_igw.id
  }

}

# attach ec2 1 subnet to an internet gateway
resource "aws_route_table_association" "route-ec2-1-subnet-to-igw" {
  subnet_id      = aws_subnet.ec2_1_public_subnet.id
  route_table_id = aws_route_table.infrastructure_route_table.id
}

# attach ec2 2 subnet to an internet gateway
resource "aws_route_table_association" "route-ec2-2-subnet-to-igw" {
  subnet_id      = aws_subnet.ec2_2_public_subnet.id
  route_table_id = aws_route_table.infrastructure_route_table.id
}

```

The `route_table.tf` file contains the configuration for the route table in our 2-tier AWS architecture created with Terraform.

The resources defined in this file are:

- **aws_route_table**: Defines the main route table for the VPC. It specifies that any traffic with a destination CIDR block of "0.0.0.0/0" (which represents all IP addresses) should be routed through the aws_internet_gateway.tier_architecture_igw resource. The role of this resource is to enable internet connectivity for the associated subnets.
- **aws_route_table_association**: Associates the EC2 subnets with the route table. It specifies that the aws_subnet.ec2_1_public_subnet and aws_subnet.ec2_2_public_subnet subnets should be associated with the aws_route_table.infrastructure_route_table. This association allows the instances in these subnets to access the internet through the configured route. The role of these resources is to establish the routing between the subnets and the internet gateway.
