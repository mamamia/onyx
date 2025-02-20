output "instance_ip" {
  description = "The public IP of the VM instance"
  value       = local.public_ip
}

output "command_output" {
  description = "Output from remote command execution"
  value       = data.external.remote_command.result.output
}
