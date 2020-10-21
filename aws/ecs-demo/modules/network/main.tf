locals {
  workspace_name = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
}

data "aws_availability_zones" "main" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name      = "${var.prefix}${local.workspace_name}-vpc"
    Prefix    = var.prefix
    Workspace = terraform.workspace
  }
}


resource "aws_subnet" "public" {
  count                   = var.public-subnet-count
  availability_zone       = data.aws_availability_zones.main.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name       = "${var.prefix}${local.workspace_name}-public-subnet-${count.index}"
    Prefix     = var.prefix
    Workspace  = terraform.workspace
    SubnetType = "public"
  }

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

  tags = {
    Name       = "${var.prefix}${local.workspace_name}-private-subnet-${count.index}"
    Prefix     = var.prefix
    Workspace  = terraform.workspace
    SubnetType = "private"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.prefix}${local.workspace_name}-igw"
    Prefix    = var.prefix
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name      = "${var.prefix}${local.workspace_name}-nat-eip"
    Prefix    = var.prefix
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name      = "${var.prefix}${local.workspace_name}-nat-gw"
    Prefix    = var.prefix
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name       = "${var.prefix}${local.workspace_name}-public-route-table"
    Prefix     = var.prefix
    Workspace  = terraform.workspace
    SubnetType = "public"
  }

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

  tags = {
    Name       = "${var.prefix}${local.workspace_name}-private-route-table"
    Prefix     = var.prefix
    Workspace  = terraform.workspace
    SubnetType = "private"
  }

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