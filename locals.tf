locals {
  prefix = "${terraform.workspace}"
  cluster_name = "AWS-EKS-${terraform.workspace}"
  users = var.developer_users
 /*roles = var.roles*/
}
