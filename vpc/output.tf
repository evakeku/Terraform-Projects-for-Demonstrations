output "vpc_id" {
  value = "${aws_vpc.main.id}"
}  
output "subnet_id" {
  value = "${aws_subnet.main.0.id}"
}
output "subnet_id1" {
  value = "${aws_subnet.main.1.id}"
}

output "db_subnet_group_id" {
  value = "${aws_db_subnet_group.subnet_group.id}"
}

output "subnetpub_id" {
  value = "${aws_subnet.public.id}"
}

