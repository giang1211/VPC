

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = format("%s-%s-vpc", var.tags["environment"], var.tags["owner"])
    },
  )
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = format("%s-%s-igw", var.tags["environment"], var.tags["owner"])
    },
  )
}

resource "aws_subnet" "public" {
  count = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = merge(var.tags, {
   Name = format("%s-%s-public-subnet-%d", var.tags["environment"], var.tags["owner"], count.index)
    }
  )
}

resource "aws_subnet" "private" {
  count = var.subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.subnet_count)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = merge(var.tags, {
   Name = format("%s-%s-private-subnet-%d", var.tags["environment"], var.tags["owner"], count.index)
    }
  )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  tags = merge(var.tags, {
    Name = format("%s-%s-nate-gateway", var.tags["environment"], var.tags["owner"])
    },
  )
}

resource "aws_eip" "nat" {
  vpc = true
 tags = merge(var.tags, {
    Name = format("%s-%s-eip", var.tags["environment"], var.tags["owner"])
    },
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
   tags = merge(var.tags, {
    Name = format("%s-%s-public-route-table", var.tags["environment"], var.tags["owner"])
    },
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
   tags = merge(var.tags, {
    Name = format("%s-%s-private-route-table", var.tags["environment"], var.tags["owner"])
    },
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

data "aws_availability_zones" "available" {}

# output "vpc_id" {
#   value = aws_vpc.main.id
# }

# output "public_subnet_ids" {
#   value = aws_subnet.public[*].id
# }

# output "private_subnet_ids" {
#   value = aws_subnet.private[*].id
# }
