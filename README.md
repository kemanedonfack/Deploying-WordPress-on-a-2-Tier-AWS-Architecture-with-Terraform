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

## Step 1: Create VPC and subnets

First, let's create a `variables.tf` file to store all our variables.
```
variable "inbound_port_production_ec2" {
  type        = list(any)
  default     = [22, 80]
  description = "inbound port allow on production node"
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
