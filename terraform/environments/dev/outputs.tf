output "resource_group_name" {
  value = module.resource_group.name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "aks_node_resource_group" {
  value = module.aks.node_resource_group
}

output "argocd_namespace" {
  value = module.argocd.namespace
}

output "ingress_public_ip" {
  value = data.kubernetes_service_v1.ingress_nginx.status.0.load_balancer.0.ingress.0.ip
}

output "argocd_url" {
  value = "https://${data.kubernetes_service_v1.argocd_server.status.0.load_balancer.0.ingress.0.ip}"
}

output "argocd_admin_username" {
  value = "admin"
}
