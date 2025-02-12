terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "appGatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aksSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  # No delegation for AKS subnet
}

resource "azurerm_subnet" "netapp_subnet" {
  name                 = "netappSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  delegation {
    name = "netapp-delegation"

    service_delegation {
      name = "Microsoft.Netapp/volumes"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_public_ip" "app_gateway_pip" {
  name                = "appGatewayPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = var.app_gateway_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIp"
    public_ip_address_id = azurerm_public_ip.app_gateway_pip.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  backend_address_pool {
    name = "backendPool"
  }

  backend_http_settings {
    name                  = "httpSetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appGatewayFrontendIp"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "httpRoutingRule"
    rule_type                  = "Basic"
    priority                   = 1
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "backendPool"
    backend_http_settings_name = "httpSetting"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    service_cidr   = "10.100.0.0/16"
    dns_service_ip = "10.100.0.10"
  }

  default_node_pool {
    name       = "nodepool1"
    node_count = var.node_count
    vm_size    = var.vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.app_gateway.id
  }
}

resource "azurerm_netapp_account" "netapp" {
  name                = "my-netapp-account"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_netapp_pool" "netapp_pool" {
  name                = "my-netapp-pool"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_netapp_account.netapp.name
  service_level       = "Premium"
  size_in_tb         = 4
}

resource "azurerm_netapp_volume" "netapp_volume" {
  name                = "my-netapp-volume"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_netapp_account.netapp.name
  pool_name           = azurerm_netapp_pool.netapp_pool.name
  volume_path         = "nfs-volume"
  service_level       = "Premium"
  subnet_id           = azurerm_subnet.netapp_subnet.id
  storage_quota_in_gb = 100
  protocols           = ["NFSv4.1"]

  export_policy_rule {
    rule_index       = 1
    allowed_clients  = ["0.0.0.0/0"]
    protocols_enabled = ["NFSv4.1"]
    unix_read_only   = false
    unix_read_write  = true
  }
}
