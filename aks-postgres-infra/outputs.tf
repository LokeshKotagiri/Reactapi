output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive = true
}

output "postgresql_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}
