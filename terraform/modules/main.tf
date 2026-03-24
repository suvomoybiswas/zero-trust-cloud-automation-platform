resource "aws_security_group" "internal_sg" {
    name = "zero-trust-internal-sg"
    description = "Internal security group for zero trust architecture"
    vpc_id = aws_vpc.main.id
    ingress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["10.0.0.0/16"]
        description = "Allow internal traffic"
    }
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }
    
    tags = {
        Name = "zero-trust-sg"
    }
  
}