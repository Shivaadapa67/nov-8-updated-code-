output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "aws_auth_configmap_yaml" {
   description = "Kubernetes user map"
   value      = module.eks.aws_auth_configmap_yaml
}

/*output "users" {
   description = "List of users"
   value = data.aws_iam_user.users
}

output "roles" {
   description = "List of roles"
   value = data.aws_iam_role.roles
}

output "mapUser" {
  description = "list of users"
  value = [
    for user in data.aws_iam_user.users : 
    {
      userarn  = user.arn
      username = user.user_name
      groups   = ["system:masters"]
    }
  ]
}
output "mapRole" {
  description = " list of roles"
  value = [
    for role in data.aws_iam_role.roles : 
    {
      rolearn  = role.arn
      rolename = role.role_name
      groups   = ["system:masters"]
    }
  ]
}*/
