
 data "aws_availability_zones" "available" {
 }


# VPC Creation
 resource "aws_vpc" "demo-vpc" {
   cidr_block = "10.0.0.0/16"
   enable_dns_hostnames = true
   enable_dns_support = true
   assign_generated_ipv6_cidr_block = true
   tags = {
     "Name"  = "demo-vpc"
   }
 }


# Subnet Creation
 resource "aws_subnet" "demo-subnet" {
   count = 3

   availability_zone = data.aws_availability_zones.available.names[count.index]
   cidr_block        = "10.0.${count.index}.0/24"
   vpc_id            = aws_vpc.demo-vpc.id
   #if cidr_block
   #ipv6_cidr_block = "${cidrsubnet(aws_vpc.demo-vpc.ipv6_cidr_block, 8, 0)}"
   #assign_ipv6_address_on_creation = true
   tags = {
     "Name"	= "demo-subnet${count.index}"
   }
 }

# Internet Gateway Creation

 resource "aws_internet_gateway" "demo-igw" {
   vpc_id = aws_vpc.demo-vpc.id

   tags = {
     Name = "demo-igw"
   }
 }

 # Routing Tables Creations

 resource "aws_route_table" "demo-rt0" {
   vpc_id = aws_vpc.demo-vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.demo-igw.id
   }
   route {
     ipv6_cidr_block = "::/0"
     gateway_id = aws_vpn_gateway.demo-vpn_gw.id
   }

   tags = {
     Name = "demo-rt0"
   }
 }

 resource "aws_route_table" "demo-rt1" {
   vpc_id = aws_vpc.demo-vpc.id
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_vpn_gateway.demo-vpn_gw.id
   }
   tags = {
     Name = "demo-rt1"
   }
 }

# Routing Table assocations to subnets

 resource "aws_route_table_association" "demo-rta0" {
   subnet_id      = aws_subnet.demo-subnet.0.id
   route_table_id = aws_route_table.demo-rt0.id
 }

 resource "aws_route_table_association" "demo-rta1" {
   subnet_id      = aws_subnet.demo-subnet.1.id
   route_table_id = aws_route_table.demo-rt1.id
 }

# Virtual Private Gateway
 resource "aws_vpn_gateway" "demo-vpn_gw" {
   vpc_id = aws_vpc.demo-vpc.id

   tags = {
     Name = "demo-vpg"
   }
 }

# Customer gateway

resource "aws_customer_gateway" "demo-cgw" {
  bgp_asn    = 65000
  ip_address = "172.83.124.10"
  type       = "ipsec.1"

  tags = {
    Name = "demo-customer-gateway"
  }
}

# VPN Connection

resource "aws_vpn_connection" "demo-vpn" {
  vpn_gateway_id      = aws_vpn_gateway.demo-vpn_gw.id
  customer_gateway_id = aws_customer_gateway.demo-cgw.id
  type                = "ipsec.1"
  static_routes_only  = true
}

# Elatic IP creation_date
resource "aws_eip" "eip" {
  vpc = true
}
# Creating EC2 instances

resource "aws_instance" "instance-A" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.demo-subnet.0.id
  tags = {
    "Name"	= "demo-instance-A"
  }
}
resource "aws_instance" "instance-B" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  associate_public_ip_address = false
  ipv6_address_count = 1
  subnet_id = aws_subnet.demo-subnet.0.id
  tags = {
    "Name"	= "demo-instance-B"
  }
}

resource "aws_instance" "instance-C" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.demo-subnet.1.id
  tags = {
    "Name"	= "demo-instance-C"
  }
}

resource "aws_instance" "instance-D" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.demo-subnet.2.id
  tags = {
    "Name"	= "demo-instance-D"
  }
}

# EIP Association to EC2 Instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.instance-A.id
  allocation_id = aws_eip.eip.id
}
