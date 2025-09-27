locals {
  public_subnet_configs = {
    for idx, cidr in var.public_subnets :
    format("%02d", idx) => {
      cidr = cidr
      az   = length(var.vpc_azs) > idx ? var.vpc_azs[idx] : null
    }
  }

  private_subnet_configs = {
    for idx, cidr in var.private_subnets :
    format("%02d", idx) => {
      cidr = cidr
      az   = length(var.vpc_azs) > idx ? var.vpc_azs[idx] : null
    }
  }

  ordered_public_keys  = sort(keys(local.public_subnet_configs))
  ordered_private_keys = sort(keys(local.private_subnet_configs))

  nat_gateway_keys = (
    !var.enable_nat_gateway ? [] :
    var.one_nat_gateway_per_az ? local.ordered_public_keys :
    length(local.ordered_public_keys) > 0 ? [local.ordered_public_keys[0]] : []
  )

  private_to_nat_key = {
    for idx, key in local.ordered_private_keys :
    key => (
      !var.enable_nat_gateway || length(local.nat_gateway_keys) == 0 ? null :
      var.one_nat_gateway_per_az ?
      element(local.nat_gateway_keys, min(idx, length(local.nat_gateway_keys) - 1)) :
      local.nat_gateway_keys[0]
    )
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = var.vpc_name
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.env}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnet_configs

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.env}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnet_configs

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.env}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? tomap({ for key in local.nat_gateway_keys : key => key }) : {}

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.env}-nat-eip-${each.key}"
  })
}

resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? aws_eip.nat : {}

  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.env}-nat-${each.key}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.env}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = local.private_subnet_configs

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway && local.private_to_nat_key[each.key] != null ? [local.private_to_nat_key[each.key]] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[route.value].id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.env}-private-rt-${each.key}"
  })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
