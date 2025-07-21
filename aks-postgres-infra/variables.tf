variable "location" {
  default = "central india"
}

variable "resource_group_name" {
  default = "octa-aks-rg"
}

variable "vnet_name" {
  default = "octa-aks-vnet"
}

variable "aks_name" {
  default = "octa-aks"
}

variable "pg_name" {
  default = "octadb"
}

variable "pg_password" {
  description = "PostgreSQL password"
  default = "Lokesh*7782#"
}
