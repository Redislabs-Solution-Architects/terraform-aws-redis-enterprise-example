#### AMI for Nodes
#### find the ami based on image id from variables
data "aws_ami" "ami" {
  filter {
    name   = "name"
    values = [var.re_ami_name]
  }

  owners = [var.re_ami_owner]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "ena-support"
    values = [var.ena-support]
  }
}