resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnets
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = var.node_role_arn

  subnet_ids = var.private_subnets
  instance_types = ["t3.micro"]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  tags = {
    Name = "${var.project_name}-node-group"
  }
}

