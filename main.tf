data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "aws" {
  region = var.region
  default_tags{
    tags = {
      Environment = "${terraform.workspace}"
      Managed-by  = "Terraform"
    }
  }
}


data "aws_availability_zones" "available" {}

resource "aws_resourcegroups_group" "lab" {

  name = "${terraform.workspace}-group"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Environment",
      "Values": [ "${terraform.workspace}"]
    },
    {
      "Key": "Managed-by",
      "Values": [ "Terraform"]
    }
  ]
}
JSON
  }
}
