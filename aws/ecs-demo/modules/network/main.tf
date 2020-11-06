locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  module_name    = "network"
  res_prefix     = "${var.prefix}${local.workspace_name}"
  default_tags = {
    Resprefix = local.res_prefix
    Prefix    = var.prefix
    Workspace = terraform.workspace
    Module    = local.module_name
    Terraform = "true"
  }
}

data "aws_availability_zones" "main" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-vpc"
  })
}

resource "aws_subnet" "public" {
  count                   = var.public-subnet-count
  availability_zone       = data.aws_availability_zones.main.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name       = "${local.res_prefix}-public-subnet-${count.index}"
    SubnetType = "public"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "private" {
  count                   = var.private-subnet-count
  availability_zone       = data.aws_availability_zones.main.names[count.index]
  cidr_block              = "10.0.${count.index + 100}.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name       = "${local.res_prefix}-private-subnet-${count.index}"
    SubnetType = "private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-igw"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-nat-eip"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.default_tags, {
    Name = "${local.res_prefix}-nat-gw"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name       = "${local.res_prefix}-public-route-table"
    SubnetType = "public"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "public" {
  count          = var.public-subnet-count
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name       = "${local.res_prefix}-private-route-table"
    SubnetType = "private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "private" {
  count          = var.private-subnet-count
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id

  lifecycle {
    create_before_destroy = true
  }
}
