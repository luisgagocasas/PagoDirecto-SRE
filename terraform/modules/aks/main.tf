resource "azurerm_kubernetes_cluster" "this" {
  name                              = var.cluster_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.dns_prefix
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = "Free"
  private_cluster_enabled           = false
  local_account_disabled            = false
  role_based_access_control_enabled = true
  tags                              = var.tags

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                 = "default"
    vm_size              = var.node_vm_size
    vnet_subnet_id       = var.subnet_id
    max_pods             = var.max_pods
    auto_scaling_enabled = false
    node_count           = 1
    tags                 = var.tags
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    load_balancer_sku   = "standard"
  }

  web_app_routing {
    dns_zone_ids             = []
    default_nginx_controller = "External"
  }
}
