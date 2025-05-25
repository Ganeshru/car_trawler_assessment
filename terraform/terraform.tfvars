# This file provides default values for your variables.
# You can override these via -var-file or environment variables.

aws_region = "us-east-1"
cluster_name = "my-dev-eks-cluster"
cluster_version = "1.28"

vpc_cidr = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

eks_node_instance_type = "t3.medium"
eks_node_min_size = 1
eks_node_max_size = 3
eks_node_desired_size = 1

tags = {
  Environment = "Development"
  Project     = "EKS-MyApp"
  Owner       = "DevOpsTeam"
}
