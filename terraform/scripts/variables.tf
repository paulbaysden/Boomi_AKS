variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
  default     = "paul-resource-group"
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "app_gateway_name" {
  description = "The name of the Azure Application Gateway"
  type        = string
  default     = "paul-app-gateway"
}

variable "aks_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "paul-aks-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "paulaks"
}

variable "node_count" {
  description = "The number of nodes in the default AKS node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "The size of the virtual machines in the AKS cluster"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "netapp_account_name" {
  description = "The name of the Azure NetApp account"
  type        = string
  default     = "paul-netapp-account"
}

variable "netapp_pool_name" {
  description = "The name of the NetApp capacity pool"
  type        = string
  default     = "paul-netapp-pool"
}

variable "netapp_volume_name" {
  description = "The name of the NetApp volume"
  type        = string
  default     = "paul-netapp-volume"
}

variable "netapp_service_level" {
  description = "The service level for the NetApp capacity pool"
  type        = string
  default     = "Premium"
}

variable "netapp_volume_size" {
  description = "The size of the NetApp capacity pool in TB"
  type        = number
  default     = 4
}

variable "netapp_volume_path" {
  description = "The export path for the NetApp volume"
  type        = string
  default     = "nfs-volume"
}
