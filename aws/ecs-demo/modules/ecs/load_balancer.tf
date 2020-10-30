# The application will be reachable from public internet via a publi Application Load Balancer
resource "aws_lb" "backend" {
  name     = "${local.prefix_name}-backend"
  internal = false
  # We use Application Load Balancer: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_ids
  idle_timeout       = 900

  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.lb-logs.id
    # In case we'd use share access log bucket, a prefix could be assigned
    # prefix  = "..."
  }
}

#
# Logging
#

# Access logs will be stored into a S3 bucket
resource "aws_s3_bucket" "lb-logs" {
  bucket = "${local.prefix_name}-access-logs"
  acl    = "private"

  # Destroy the bucket and all files when removing the bucket
  # For production, one might want to disable this
  force_destroy = true
}

# Objects in this bucket will be private
resource "aws_s3_bucket_public_access_block" "lb-logs" {
  bucket = aws_s3_bucket.lb-logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket_policy.lb-logs
  ]
}

# Used for looking up our own AWS Account ID
data "aws_caller_identity" "current" {}

# We allow the AWS load balancing service to write logs into the log bucket
# The ELB service accounts are listed at: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
# Here, we specify the account in var.elb_account_id input variable.
resource "aws_s3_bucket_policy" "lb-logs" {
  bucket = aws_s3_bucket.lb-logs.id

  policy = jsonencode(
    {
      Id = "AccessLogsPolicy"
      Statement = [{
        Action = "s3:PutObject"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.elb_account_id}:root"
        },
        Resource = "${aws_s3_bucket.lb-logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Sid      = "AllowWriteFromLoadBalancerAccount"
        },
        {
          Action = "s3:PutObject"
          Condition = {
            StringEquals = {
              "s3:x-amz-acl" = "bucket-owner-full-control"
            }
          },
          Effect = "Allow"
          Principal = {
            Service = "delivery.logs.amazonaws.com"
          },
          Resource = "${aws_s3_bucket.lb-logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
          Sid      = "AWSLogDeliveryWrite"
        },
        {
          Action = "s3:GetBucketAcl"
          Effect = "Allow"
          Principal = {
            Service = "delivery.logs.amazonaws.com"
          },
          Resource = aws_s3_bucket.lb-logs.arn
          Sid      = "AWSLogDeliveryAclCheck"
        }
      ],
      Version = "2012-10-17"
  })
}


#
# Routing
#

# Targets to the load balancer are registered by IP address, into the following target group
resource "aws_lb_target_group" "backend" {
  name                 = "${local.prefix_name}-backend"
  port                 = var.backend_port
  protocol             = "HTTP"
  deregistration_delay = 30
  vpc_id               = data.terraform_remote_state.network.outputs.vpc_id
  target_type          = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/api/status"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  depends_on = [
    aws_lb.backend
  ]
}

# The default route will point all traffic to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

}
