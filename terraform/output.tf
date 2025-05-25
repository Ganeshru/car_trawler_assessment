output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "kubeconfig" {
  description = "Kubeconfig for the EKS cluster (requires 'aws eks update-kubeconfig' to be run locally)"
  value       = module.eks.kubeconfig
  sensitive   = true # Mark as sensitive to avoid printing to console directly
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_group_roles_arns" {
  description = "ARNs of the IAM roles used by the EKS node groups"
  value       = [for group in module.eks.eks_managed_node_groups : group.iam_role_arn]
}

output "vpc_id" {
  description = "The ID of the VPC created for EKS."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = module.vpc.public_subnets
}
