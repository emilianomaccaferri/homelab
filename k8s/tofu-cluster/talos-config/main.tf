terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.8"
    }
  }
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this_controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}
data "talos_machine_configuration" "this_worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
}
resource "talos_machine_configuration_apply" "this" {
  count                       = length(var.cluster_nodes)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = var.cluster_nodes[count.index].controlplane ? data.talos_machine_configuration.this_controlplane.machine_configuration : data.talos_machine_configuration.this_worker.machine_configuration
  node                        = var.cluster_nodes[count.index].ip
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/vda"
        }
      }
      cluster = {
        proxy = {
          disabled = true
        }
        network = {
          cni = {
            name = "none"
          }
        }
      }
    })
  ]
}
resource "talos_machine_bootstrap" "this" {
  count = length(var.cluster_nodes)
  depends_on = [
    talos_machine_configuration_apply.this # waits for all nodes to be ready before starting applying 
  ]
  node                 = var.cluster_nodes[count.index].ip
  client_configuration = talos_machine_secrets.this.client_configuration
}
