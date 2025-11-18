resource "aws_security_group" "endpoint_sg" {
  name   = "${var.project_name}-endpoints-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.private_subnets
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = { Name = "${var.project_name}-ecr-api-endpoint" }
}

