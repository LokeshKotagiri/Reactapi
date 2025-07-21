terraform {
  backend "azurerm" {
    resource_group_name  = "lokesh-Octa"
    storage_account_name = "sgocta123"
    container_name       = "tfstate"
    key                  = "aks.tfstate2"
  }
}
