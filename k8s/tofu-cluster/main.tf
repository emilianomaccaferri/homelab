terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.77"
    }
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.11"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.8"
    }
  }
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "homelab/tofu-cluster.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints = {
      s3 = "https://dcfa5af67bebf90c53f37a36690b8858.eu.r2.cloudflarestorage.com"
    }
  }
}
provider "talos" {}
provider "cloudflare" {}
provider "opnsense" {
  uri            = "https://172.10.0.2"
  allow_insecure = true
}
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  ssh {
    username = var.proxmox_ssh_username
    password = var.proxmox_ssh_password
  }
}
resource "proxmox_virtual_environment_download_file" "latest_talos_linux" {
  file_name    = "talos_1.1.0_qemu.iso"
  overwrite    = false
  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.iso_node_name
  url          = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.10.0/metal-amd64.iso"
}
module "vm" {
  source       = "./vm"
  count        = length(var.vms)
  vm_id        = var.vms[count.index].vm_id
  node_name    = var.vms[count.index].node_name
  name         = var.vms[count.index].name
  size         = var.vms[count.index].size
  iso_id       = proxmox_virtual_environment_download_file.latest_talos_linux.id
  controlplane = var.vms[count.index].controlplane
}
data "opnsense_kea_subnet" "k8s_nodes" {
  id = "fcec9b21-b303-4cf4-9e52-4b7ac242378f"
}
resource "opnsense_kea_reservation" "dhcp_reservation" {
  subnet_id   = data.opnsense_kea_subnet.k8s_nodes.id
  count       = length(var.vms)
  ip_address  = module.vm[count.index].ip_address
  mac_address = module.vm[count.index].mac_address
  description = module.vm[count.index].name
}
module "talos_config" {
  source           = "./talos-config"
  cluster_endpoint = "https://11.11.11.253:6443"
  cluster_name     = "proxmox-cluster"
  cluster_nodes = [
    for vm in module.vm : { controlplane = vm.controlplane, ip = vm.ip_address }
  ]
}
