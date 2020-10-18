# Security group for the public internet facing load balancer
resource "aws_security_group" "lb" {
  name        = "Load balancer"
  description = "Load balancer security group"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow traffic from public internet
resource "aws_security_group_rule" "lb-ingress" {
  type = "ingress"

  from_port   = var.public_port
  to_port     = var.public_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lb
}

# Allow outbound traffic
resource "aws_security_group_rule" "lb-egress" {
  type = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lb
}

# Security group for the backends that run the application.
# Allows traffic from the load balancer
resource "aws_security_group" "backend" {
  name        = "Backend"
  description = "Backend security group"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow traffic from the load balancer to the backends
resource "aws_security_group_rule" "backend-ingress" {
  type = "ingress"

  from_port                = var.backend_port
  to_port                  = var.backend_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id

  security_group_id = aws_security_group.backend
}

# Allow outbound traffic from the backends
resource "aws_security_group_rule" "backend-egress" {
  type = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.lb
}
