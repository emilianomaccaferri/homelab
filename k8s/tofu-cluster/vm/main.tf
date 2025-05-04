terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.77"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = var.name
  node_name = var.node_name
  vm_id     = var.vm_id
  agent {
    enabled = true
  }
  stop_on_destroy = true
  disk {
    datastore_id = var.storage
    file_id      = var.iso_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.size == "small" ? 50 : var.size == "medium" ? 100 : var.size == "big" ? 150 : 100
  }
  network_device {
    bridge = "tagged11"
  }
  cpu {
    cores = var.size == "small" ? 2 : var.size == "medium" ? 3 : var.size == "big" ? 4 : 3
    type  = "x86-64-v2-AES"
  }
  memory {
    dedicated = var.size == "small" ? 2048 : var.size == "medium" ? 4096 : var.size == "big" ? 8092 : 4096
    floating  = var.size == "small" ? 2048 : var.size == "medium" ? 4096 : var.size == "big" ? 8092 : 4096
  }
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
