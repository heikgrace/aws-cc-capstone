Capstone Project 

This project deploys a complete **WordPress environment on AWS**, including:

- **VPC + Subnets (Public & Private)**
- **EC2 Web Server (Amazon Linux 2023)**
- **MariaDB RDS (Multi-AZ, private)**
- **Security Groups**
- **Route Tables & Internet Gateway**
- **Automatic WordPress installation via User-Data**

Everything is fully automated using **Terraform**.

---

## 🚀 Architecture Overview

**Public Subnet**
- EC2 Web Server  
- Apache + PHP  
- WordPress installed automatically via `userdata.sh`  

**Private Subnets**
- RDS MariaDB (Multi-AZ)  
- Not publicly accessible  
- Accessible only from the web server (SG-to-SG)  

**VPC**
- 1× Public Subnet  
- 2× Private Subnets (for Multi-AZ RDS)  
- Internet Gateway  
- Route Tables  

---

## 📁 Project Structure
├──Level 1
  ├── main.tf
  ├── variables.tf
  ├── terraform.tfvars
  ├── userdata.sh
├──Level 2
  ├── main.tf
  ├── variables.tf
  ├── terraform.tfvars
  ├── userdata.sh
└── README.md
└── .gitignore



---

## 🧩 Prerequisites

- AWS account  
- IAM user with permissions for EC2, RDS, and VPC  
- AWS CLI configured  
- Terraform installed  

---

## ⚙️ Input Parameters

These variables must be set in your `terraform.tfvars`.

| Variable | Description | Example / Notes |
|---------|--------------|----------------|
| **aws_region** | AWS region for deployment | `us-west-2` |
| **ami_id** | Amazon Linux 2023 AMI ID | `ami-04f9aa2b7c7091927` |
| **instance_type** | EC2 instance type | `t3.small` |
| **key_name** | Name of the AWS SSH key pair | e.g. `mykey` |
| **profile** | AWS CLI profile | e.g. `default` |
| **my_ip** | Your public IP for SSH access | `"1.2.3.4/32"` |
| **vpc_cidr** | CIDR block for the VPC | `"10.0.0.0/16"` |
| **public_subnet_cidr** | Public subnet CIDR | `"10.0.1.0/24"` |
| **private_subnet_cidr** | Private subnet A CIDR | `"10.0.2.0/24"` |
| **private_subnet_2_cidr** | Private subnet B (Multi-AZ) CIDR | `"10.0.3.0/24"` |
| **db_user** | RDS database username | e.g. `admin` |
| **db_password** | RDS database password | Sensitive – do **not** commit |

---


