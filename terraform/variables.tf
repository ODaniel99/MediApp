variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "The availability zones to use for high availability."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "aws_replica_region" {
  description = "The AWS region for disaster recovery replicas."
  type        = string
  default     = "us-west-2"
}
