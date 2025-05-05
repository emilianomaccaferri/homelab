variable "proxmox_api_token" {
  type = string
}
variable "proxmox_endpoint" {
  type    = string
  default = "https://172.10.0.11:8006"
}
variable "vms" {
  type = list(object({
    name         = string
    node_name    = string
    size         = string
    vm_id        = number
    controlplane = bool
  }))
}
variable "proxmox_ssh_username" {
  type = string
}
variable "proxmox_ssh_password" {
  type = string
}
variable "iso_datastore_id" {
  type    = string
  default = "nfs-dbero"
}
variable "iso_node_name" {
  type    = string
  default = "dbero"
}
