#                     Credentials                       
azure_subscription_id = "xxxxxxxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx" # Use: az account list
azure_app_id          = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # Service Principal AppId.
azure_client_secret   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   # Service Principal Password.
azure_tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # Use: az account show

#                   Network Variables                   #
vnet_name               = "ibmtestvnet"           # Use: az network vnet list
vnet_group_name         = "ibmtestRG"  # Use: az network vnet list
subnet_name             = "ibmtestsubnet"                   # Use: az network vnet subnet list --vnet-name <virtualNetworkName> -g <virtualNetworkResourceGroup> 


#               Azure Kubernetes Service                #
aks_resource_group = "ibmtestRG"     # Name of your existing resource group.
aks_name           = "ibmtest"
aks_vm_size        = "Standard_D2_v2"
aks_node_count     = 2

#                Azure Container Registry               #
acr_name = "ibmtestregistry"  # Alphanumeric, no spaces, no hyphen, no caps.
