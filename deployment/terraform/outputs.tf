output "instance_ip" {
  description = "The public IP of the VM instance"
  value       = module.onyx_staging.instance_ip
}

output "staging_command_output" {
  description = "Command output from staging instance"
  value       = module.onyx_staging.command_output
}

output "test_command_output" {
  description = "Command output from test instance" 
  value       = module.test.command_output
}
