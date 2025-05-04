output "mac_address" {
  value = proxmox_virtual_environment_vm.this.mac_addresses[7]
}
output "ip_address" {
  value = proxmox_virtual_environment_vm.this.ipv4_addresses[7][0]
}
output "name" {
  value = proxmox_virtual_environment_vm.this.name
}
output "controlplane" {
  value = var.controlplane
}
