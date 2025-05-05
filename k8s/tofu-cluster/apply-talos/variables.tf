variable "first_cluster_node_ip" {
  type = string
}
variable "controlplane_ip" {
  type = string
}
variable "vms" {
  type = list(object({
    ip           = string
    controlplane = bool
  }))
}
