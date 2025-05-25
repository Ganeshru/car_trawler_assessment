# --- VPC Module ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" # Use a recent stable version

  name = "${var.cluster_name}-vpc" # Name derived from cluster_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = true # Set to false for high availability across AZs (more costly)
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = var.tags
}

# --- EKS Cluster Module ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0" # Use a recent stable version

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets # EKS worker nodes typically reside in private subnets

  # Enable public endpoint access, but restrict it to specific CIDRs
  cluster_endpoint_public_access      = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # WARNING: This allows access from anywhere. Restrict in production!

  # Managed Node Group configuration
  eks_managed_node_groups = {
    default = {
      name = "default-node-group"

      instance_types = [var.eks_node_instance_type]
      min_size       = var.eks_node_min_size
      max_size       = var.eks_node_max_size
      desired_size   = var.eks_node_desired_size

      # Attach policies to the node group role for common addons
      attach_vpc_cni_policy = true
      attach_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

  tags = var.tags

  # Addons for EKS (CoreDNS, Kube-Proxy, VPC CNI are typically installed by default,
  # but you can manage them explicitly here)
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
}
