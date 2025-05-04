output "talosconfig" {
  sensitive = true
  value = data.talos_client_configuration.this.talos_config  
}
output "controlplane" {
  sensitive = true
  value = data.talos_machine_configuration.this_controlplane.machine_configuration  
}
output "worker" {
  sensitive = true
  value = data.talos_machine_configuration.this_worker.machine_configuration
}
