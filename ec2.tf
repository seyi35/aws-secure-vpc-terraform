# --------------------------------------------------
# UBUNTU 24.04 AMI
# Retrieve the latest official Ubuntu 24.04 image
# rather than hard-coding an AMI ID.
# --------------------------------------------------

data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# --------------------------------------------------
# PRIVATE WEB SERVERS
# Deploy one EC2 instance in each private subnet.
# Both instances use the same configuration.
# --------------------------------------------------

resource "aws_instance" "web" {
  count = 2

  ami           = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = "t3.micro"

  # Place each instance in a different private subnet.
  subnet_id = module.vpc.private_subnet_ids[count.index]

  # Never assign public IPv4 addresses.
  associate_public_ip_address = false

  # Only allow inbound traffic permitted by our web SG.
  vpc_security_group_ids = [aws_security_group.web.id]

  # Configure Apache and install the same Tooplate site
  # on both private EC2 instances during initial boot.
  user_data = templatefile("${path.module}/scripts/user-data.sh", {
    server_name  = format("web%02d", count.index + 1)
    tooplate_url = var.tooplate_download_url
  })


  # Recreate the instance if its initial setup changes.
  user_data_replace_on_change = true

  # Small root volume for this temporary learning lab.
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = format("web%02d", count.index + 1)
  }
}
