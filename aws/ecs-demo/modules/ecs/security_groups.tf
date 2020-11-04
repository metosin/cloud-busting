# Security group for the public internet facing load balancer
resource "aws_security_group" "lb" {
  name        = "${local.res_prefix} load balancer"
  description = "${local.res_prefix} Load balancer security group"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-lb-sg"
  })

}

# Allow traffic from public internet
resource "aws_security_group_rule" "lb-ingress" {
  description = "${local.res_prefix}: allow traffic from public internet"
  type        = "ingress"

  from_port   = var.public_port
  to_port     = var.public_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lb.id
}

# Allow outbound traffic
resource "aws_security_group_rule" "lb-egress" {
  description = "${local.res_prefix}: allow all outbound traffic"
  type        = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lb.id
}

# Security group for the backends that run the application.
# Allows traffic from the load balancer
resource "aws_security_group" "backend" {
  name        = "${local.res_prefix} backend"
  description = "${local.res_prefix} Backend security group"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-backend-sg"
  })

}

# Allow traffic from the load balancer to the backends
resource "aws_security_group_rule" "backend-ingress" {
  description = "${local.res_prefix}: allow traffic from load balancer"
  type        = "ingress"

  from_port                = var.backend_port
  to_port                  = var.backend_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id

  security_group_id = aws_security_group.backend.id
}

# Allow outbound traffic from the backends
resource "aws_security_group_rule" "backend-egress" {
  description = "${local.res_prefix}: allow all outbound traffic"
  type        = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.backend.id
}
