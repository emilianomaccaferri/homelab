output "kubeconfig" {
  sensitive = true
  value     = module.talos_config.kubeconfig
}
