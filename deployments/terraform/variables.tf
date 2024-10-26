# deployments/terraform/variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}



variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "sre-learning"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}


variable "instance_ami" {
  description = "AMI ID for EC2 instance (Ubuntu 22.04 LTS in us-east-1)"
  type        = string
  default     = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS in us-east-1
}
variable "key_name" {
  description = "Name of SSH key pair"
  type        = string
}

variable "admin_ip" {
  description = "IP address allowed to access the instance"
  type        = string
}