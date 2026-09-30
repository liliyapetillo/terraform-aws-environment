output "instance_id" {
  value       = aws_instance.app.id
  description = "The EC2 instance ID, used as the target for aws ssm start-session."
}

output "public_ip" {
  value       = aws_instance.app.public_ip
  description = "The instance's public IP. Outbound only; no inbound rules allow traffic to it."
}