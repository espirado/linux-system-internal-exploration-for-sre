# deployments/terraform/outputs.tf

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.sre_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.sre_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.sre_instance.public_dns
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.sre_vpc.id
}

output "instance_role_arn" {
  description = "ARN of the instance IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.sre_instance.public_dns}"
}