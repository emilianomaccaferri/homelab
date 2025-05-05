terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.8"
    }
  }
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "homelab/tofu-cluster-talos.tfstate"
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

module "talos_config" {
  source             = "../talos-config"
  cluster_endpoint   = "https://${var.controlplane_ip}:6443"
  cluster_name       = "proxmox-cluster-lb-yay"
  first_cluster_node = var.first_cluster_node_ip
  cluster_nodes = [
    for vm in var.vms : { controlplane = vm.controlplane, ip = vm.ip }
  ]
}
