# -------------------------------------
# 1. Provider Block
# -------------------------------------
provider "aws" {
  region = "ap-south-1"
}

# -------------------------------------
# 2. EC2 Instance Resource Block
# -------------------------------------
resource "aws_instance" "ec2_instance" {
  count         = var.number_of_instances
  ami           = var.ami_id
  subnet_id     = var.subnet_id
  instance_type = var.instance_type
  key_name      = var.ami_key_pair_name
  security_groups = ["sg-0d5a8a0b8d71d70ff"]

  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }
}

# -------------------------------------
# 3. Provisioning SSH Keys with null_resource
# -------------------------------------
resource "null_resource" "configure_ssh" {
  count = var.number_of_instances

  connection {
    type        = "ssh"
    host        = aws_instance.ec2_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = file("/home/ubuntu/T/DevOps.pem")
  }

  provisioner "file" {
    source      = "/home/ubuntu/.ssh/id_ed25519.pub"
    destination = "/home/ubuntu/id_ed25519.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "cat /home/ubuntu/id_ed25519.pub >> ~/.ssh/authorized_keys",
      "chmod 700 ~/.ssh",
      "chmod 600 ~/.ssh/authorized_keys"
    ]
  }
}

# -------------------------------------
# 4. Disable Strict Host Key Checking
# -------------------------------------
resource "null_resource" "disable_strict_host_key_checking" {
  count = var.number_of_instances

  connection {
    type        = "ssh"
    host        = aws_instance.ec2_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = file("/home/ubuntu/T/DevOps.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Host *' >> ~/.ssh/config",
      "echo '  StrictHostKeyChecking no' >> ~/.ssh/config",
      "echo '  UserKnownHostsFile=/dev/null' >> ~/.ssh/config",
      "echo '  LogLevel ERROR' >> ~/.ssh/config"
    ]
  }

  depends_on = [aws_instance.ec2_instance]
}

