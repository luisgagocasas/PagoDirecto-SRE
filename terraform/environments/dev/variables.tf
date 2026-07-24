variable "kubernetes_version" {
  type    = string
  default = "1.34"
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D4s_v3" // 4 vCPU, 16 GiB RAM
}

variable "max_pods" {
  type    = number
  default = 250
}

variable "argocd_chart_version" {
  type    = string
  default = "10.2.1"
}

variable "log_retention_days" {
  type    = number
  default = 30
}
