locals {
  project        = "pagodirecto"
  project_short  = "pgd"
  environment    = "dev"
  location       = "eastus2"
  location_short = "eus2"
  instance       = "001"
  name_prefix    = "${local.project_short}-${local.environment}-${local.location_short}"

  tags = {
    project     = local.project
    environment = local.environment
    managed-by  = "terraform"
  }
}

module "resource_group" {
  source = "../../modules/resource_group"

  name     = "rg-${local.name_prefix}-${local.instance}"
  location = local.location
  tags     = local.tags
}

module "network" {
  source = "../../modules/network"

  vnet_name             = "vnet-${local.name_prefix}-${local.instance}"
  vnet_address_space    = "10.10.0.0/16"
  subnet_name           = "snet-aks-${local.name_prefix}-${local.instance}"
  subnet_address_prefix = "10.10.1.0/24"
  location              = module.resource_group.location
  resource_group_name   = module.resource_group.name
  tags                  = local.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  name                = "log-${local.name_prefix}-${local.instance}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}

module "aks" {
  source = "../../modules/aks"

  cluster_name               = "aks-${local.name_prefix}-${local.instance}"
  dns_prefix                 = "aks-${local.name_prefix}"
  location                   = module.resource_group.location
  resource_group_name        = module.resource_group.name
  subnet_id                  = module.network.subnet_id
  kubernetes_version         = var.kubernetes_version
  node_vm_size               = var.node_vm_size
  max_pods                   = var.max_pods
  pod_cidr                   = "10.244.0.0/16"
  service_cidr               = "10.11.0.0/16"
  dns_service_ip             = "10.11.0.10"
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags
}

module "argocd" {
  source = "../../modules/argocd"

  chart_version       = var.argocd_chart_version
  server_service_type = "LoadBalancer"

  depends_on = [module.aks]
}

data "kubernetes_service_v1" "ingress_nginx" {
  metadata {
    name      = "nginx"
    namespace = "app-routing-system"
  }

  depends_on = [module.aks]
}

data "kubernetes_service_v1" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = module.argocd.namespace
  }

  depends_on = [module.argocd]
}
