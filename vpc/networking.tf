data "aws_availability_zones" "my"{}
resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
#  instance_tenancy = "${var.tenancy}"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  count = "${length(var.subnet_cidr)}"
#  count="{length(data.aws_availability_zones.my.names)}"
  availability_zone = "${element(data.aws_availability_zones.my.names,count.index)}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${element(var.subnet_cidr,count.index)}"

  tags = {
    Name = "subnet"
    env = "foundation"
  }
}

resource "aws_subnet" "public" {
 # count  =  "${length(var.subnetpub_cidr)}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.subnetpub_cidr}"
  map_public_ip_on_launch = true
}

resource "aws_eip" nat {
 # count = "${length(var.subnetpub_cidr)}"

  vpc = true
}

resource "aws_nat_gateway" "gw" {
 # count = "${length(var.subnetpub_cidr)}"

  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "main"
  }
}


resource "aws_route_table_association" "private" {
  count = "${length(var.subnet_cidr)}"

  subnet_id      = "${aws_subnet.main.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.*.id[count.index]}"
}

resource "aws_route_table_association" "public" {
 # count = "${length(var.subnetpub_cidr)}"

  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}


resource "aws_route_table" "private" {
  count = "${length(var.subnet_cidr)}"
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "main"
  }
}

resource "aws_route" "private" {
  count = "${length(var.subnet_cidr)}"

  route_table_id         = "${aws_route_table.private.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.gw.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "PublicRouteTable"
    Environment = "dev"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}
resource "aws_db_subnet_group" "subnet_group" {
  name       = "rds"
  #count = "${length(data.aws_subnet.my.id)}"
  #depends_on = [aws_vpc.vpc_id]
  #subnet_ids = ["${element(var.subnet_id,count.index)}"]
#  subnet_ids = "[${element(aws_subnet.main.*.id,0),element(aws_subnet.main.*.id.1)}]"
  subnet_ids = ["${aws_subnet.main.0.id}","${aws_subnet.main.1.id}"]
  tags =  {
    Name = "My DB subnet group"
  }
  depends_on = ["aws_subnet.main"]
}
