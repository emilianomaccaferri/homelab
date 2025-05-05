output "mac_addresses" {
  value = [for vm_module in module.vm : vm_module.mac_address]
}
output "ip_addresses" {
  value = [for vm_module in module.vm : vm_module.ip_address]
}

