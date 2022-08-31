#                      Variables                         #
# This section defines the variables needed.             #

variable "azure_subscription_id" {
  type = string
}
variable "azure_app_id" {
  type = string
}
variable "azure_client_secret" {
  type = string
}
variable "azure_tenant_id" {
  type = string
}
variable "vnet_group_name" {
  type = string
}
variable "vnet_name" {
  type = string
}
variable "subnet_name" {
  type = string
}
variable "aks_resource_group" {
  type = string
}
variable "aks_name" {
  type = string
}
variable "aks_vm_size" {
  type = string
}
variable "aks_node_count" {
  type = number
}
variable "acr_name" {
  type = string
}


#                       Provider                         #
# This section defines the Terraform Provider.           #
# https://www.terraform.io/docs/providers/index.html     #

provider "azurerm" {
  version = "=2.15.0"
  skip_provider_registration = true

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_app_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id

  features {}
}

data "azurerm_resource_group" "main_rg" {
  name = var.aks_resource_group
}


#                Virtual Network Subnet                  #
data "azurerm_subnet" "main_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_group_name
}

#               Azure Kubernetes Service                 #
# Creates the Kubernetes cluster.                        #

resource "azurerm_kubernetes_cluster" "main_aks" {
  name                = var.aks_name
  location            = data.azurerm_resource_group.main_rg.location
  resource_group_name = data.azurerm_resource_group.main_rg.name
  dns_prefix          = var.aks_name

  default_node_pool {
    name           = "default"
    node_count     = var.aks_node_count
    vm_size        = var.aks_vm_size
    vnet_subnet_id = data.azurerm_subnet.main_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }
}


# container registry.                                    #
resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = data.azurerm_resource_group.main_rg.name
  location                 = data.azurerm_resource_group.main_rg.location
  sku                      = "Standard"
}



#         K8s Service Principle role assignment          #
# Below role assignments gives the "Network Contributor" #
# role to the AKS Service Principle to eg. read public   #
# IP resources and a role for the AKS cluster to be able #
# to pull images from the ACR.                           #

resource "azurerm_role_assignment" "role1" {
  scope                = data.azurerm_resource_group.main_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main_aks.identity[0].principal_id
}


resource "azurerm_role_assignment" "role2" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main_aks.kubelet_identity[0].object_id
}


#            Public IP for Ingress Controller           #
# In my setup, i chose to create a a Public IP resource #
# which will be used for my ingress controller.         #

resource "azurerm_public_ip" "ingress" {
  name                = "AKS-Ingress-Controller"
  resource_group_name = data.azurerm_resource_group.main_rg.name
  location            = data.azurerm_resource_group.main_rg.location
  allocation_method   = "Static"
}


#                        Output                         #
# Output the public IP address.                         #

output "ingress-ip" {
  value = azurerm_public_ip.ingress.ip_address
}

output "service-principal-id" {
  value = azurerm_kubernetes_cluster.main_aks.identity[0].principal_id
}

output "main-resource-group" {
  value = data.azurerm_resource_group.main_rg.name 
}