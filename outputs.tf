output "vm_info" {
  description = "Public IP addresses of the EC2 instances"
  value = {
    for idx, instance in aws_instance.ec2_instance :
    instance.tags["Name"] => instance.public_ip
  }
}

