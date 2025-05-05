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
          disk  = "/dev/vda"
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.10.0" # required otherwise proxmox wouldn't be able to turn off deployed vms
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
    talos_machine_configuration_apply.this
  ]
  node                 = var.cluster_nodes[count.index].ip
  client_configuration = talos_machine_secrets.this.client_configuration
  lifecycle {
    replace_triggered_by = [talos_machine_configuration_apply.this]
  }

}
resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  node                 = var.first_cluster_node
  client_configuration = talos_machine_secrets.this.client_configuration
  lifecycle {
    replace_triggered_by = [talos_machine_configuration_apply.this]
  }

}
