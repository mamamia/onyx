output "instance_ip" {
  description = "The public IP of the VM instance"
  value       = module.onyx_staging.instance_ip
}
