variable "name" {
  type = string
}
variable "storage" {
  type    = string
  default = "local-lvm"
}
variable "size" {
  type    = string
  default = "medium"
}
variable "controlplane" {
  type    = bool
  default = false
}
variable "node_name" {
  type = string
}
variable "vm_id" {
  type = number
}
variable "iso_id" {
  type = string
}
