# Two-Tier Web Server with AWS ALB and EC2 Instances

This Terraform project deploys a two-tier web server architecture on AWS. The infrastructure includes an Application Load Balancer (ALB) for distributing traffic and EC2 instances as web servers. The project is designed to be scalable and highly available.

## Prerequisites

* Terraform installed on your local machine.
* AWS account with appropriate IAM permissions for managing ALB, EC2, VPC, security groups, and IAM roles.
* Backend S3 and DynamoDB setup ready for store terraform statefile with statelock feature.

## Architecture

* **Application Load Balancer (ALB)**: Distributes incoming traffic to web server instances.
* **EC2 Instances**: Act as web servers to handle application logic and serve content.
* **RDS**: Database to store the information.
* **VPC**: Logical network group for deploy the servers and databases.
* **Internet Gateway**: Provides the internet connectivity to the servers which part of private subnet.
* **Auto Scaling Group**: Scaling solution to the servers for unpredictable user requests.
* **Security Groups**: Ensures secure communication within and outside of the network.

![AWS_TwoTier_Architecture](https://github.com/gokul98raj/Terraform-two-tier-arch/assets/42057165/f8101573-74ea-4ede-a606-d380372758d1)

## Usage

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Initialize Terraform

  Run `terraform init` to install necessary providers and modules.

### 3. Set Up AWS Credentials

Configure your AWS credentials by setting environment variables or using an AWS credentials file.

### 4. Apply Terraform Configuration
Execute the following command to deploy the infrastructure:

```bash
terraform apply
```

Type `yes` to confirm the changes.

### 5. Verify Deployment

- Once deployment is complete, the ALB DNS name will be displayed. Use this DNS to access the web application.
- Verify the EC2 instances are registered with the ALB.

### 6. Destroy Resources

To tear down the infrastructure, run:

```bash
terraform destroy
```

## Variables

The following variables can be customized in the `terraform.tfvars` file:

* `region`: AWS region for deployment.
* `rds_identifier_name`: DB identifier name for an application.
* `rds creds`: Credentials to be used for RDS.

Refer to `variables.tf` for a complete list of configurable parameters.

## Backend

The following backend configuration can be setup in `backend.tf` file:

* `bucket`: bucket name which state file to be stored.
* `dynamodb_table`: db table name for state locking.

## Outputs

The following outputs are available after deployment:

* `alb_dns`: DNS name of the Application Load Balancer.