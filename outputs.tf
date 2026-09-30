output "instance_id" {
  value       = module.compute.instance_id
  description = "The EC2 instance ID, used as the target for aws ssm start-session."
}

output "public_ip" {
  value       = module.compute.public_ip
  description = "The instance's public IP. Outbound only; no inbound rules allow traffic to it."
}