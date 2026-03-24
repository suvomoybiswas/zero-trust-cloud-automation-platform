resource "aws_route_table" "public_rt" {

  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  tags = {
    Name = "zero-trust-public-rt"
  }

}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_ids)

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id
  tags = {
    Name = "zero-trust-private-rt"
  }
}
resource "aws_route_table_association" "private_association" {
  subnet_id = var.private_subnet_id
  route_table_id = aws_route_table.private_rt.id
}
