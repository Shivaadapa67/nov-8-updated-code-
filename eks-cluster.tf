/*data "aws_iam_user" "users" {
  for_each = toset(local.users)
  user_name = each.value
}*/
data "aws_iam_user" "developer_users" {
  for_each = toset(local.users)
  user_name = each.value
}
/*data "aws_iam_role" "roles" {
  for_each = toset(local.roles)
  name = each.value
}*/
/*locals {
  admin_user_map_users = [
    for admin_user in var.users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"
      username = admin_user
      groups   = ["system:masters"]
    }
  ]
  developer_user_map_users = [
    for developer_user in var.developer_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${developer_user}"
      username = developer_user
      groups   = ["${var.name_prefix}-developers"]
    }
  ]
}*/

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = local.cluster_name
  cluster_version = "1.23"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth_configmap = true
  aws_auth_users = [
    
    /*for user in data.aws_iam_user.users : 
    {
      userarn  = user.arn
      username = user.user_name
      groups   = ["system:masters"]
    },*/
    for ab in data.aws_iam_user.developer_users : 
    {
      userarn  = ab.arn
      username = ab.user_name
      groups   = ["developer-role"]
    }
  ] 
  /*aws_auth_roles = [
    for role in data.aws_iam_role.roles :
    {
      rolearn  = role.arn
      name = role.name
    }
  ]*/

  eks_managed_node_group_defaults = {
    #ami_type = "AL2_x86_64"
    instance_types = ["t3.small"]

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false
  }


  eks_managed_node_groups = {
    one = {
      name = "${local.prefix}-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

      vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]
    }

    two = {
      name = "${local.prefix}-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      vpc_security_group_ids = [
        aws_security_group.node_group_two.id
      ]
    }
  }
}
/*  # create some variables
variable "name_prefix" {
  type        = string
  default     = "cofo"
  description = "Prefix to be used on each infrastructure object Name created in AWS."
}
variable "users" {
  type        = list(string)
  description = "List of Kubernetes admins."
  default = ["HarikaG","SivaiahA","JocelynC",]
}
variable "developer_users" {
  type        = list(string)
  default = ["technical-user"]
  description = "List of Kubernetes developers."
}

# create Admins & Developers user maps

# add 'mapUsers' section to 'aws-auth' configmap with Admins & Developers
resource "time_sleep" "wait" {
  create_duration = "180s"
  triggers = {
    cluster_endpoint = data.aws_eks_cluster.cluster.endpoint
  }
}
/*resource "kubernetes_config_map_v1_data" "aws_auth_users" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  

  data = {
    mapUsers = yamlencode(concat(local.admin_user_map_users, local.developer_user_map_users))
  }

  force = true

  depends_on = [time_sleep.wait]
}*/

# create developers Role using RBAC */
resource "kubernetes_cluster_role" "iam_roles_developers" {
  metadata {
    name = "developer-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

# bind developer Users with their Role
resource "kubernetes_cluster_role_binding" "iam_roles_developers" {
  metadata {
    name = "developer-rolebinding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "developer-role"
  }

  dynamic "subject" {
    for_each = toset(var.developer_users)

    content {
      name      = subject.key
      kind      = "User"
      api_group = "rbac.authorization.k8s.io"
    }
  }
}
