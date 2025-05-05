variable "cluster_name" {
  type = string
}
variable "cluster_endpoint" {
  type = string
}
variable "cluster_nodes" {
  type = list(object({
    ip           = string
    controlplane = bool
  }))
}
variable "first_cluster_node" {
  type = string
}
