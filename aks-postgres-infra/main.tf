resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
    depends_on = [ azurerm_resource_group.main ]
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "postgres" {
  name                 = "postgres-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "postgres-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_network_security_group" "aks_nsg" {
    depends_on = [ azurerm_resource_group.main ]
  name                = "aks-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowKubeAPI"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}
resource "azurerm_private_dns_zone" "postgres_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "postgres-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.resource_group_name}"

  default_node_pool {
    name       = "system"
    node_count = 2
    vm_size    = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
    service_cidr       = "10.1.0.0/16"         # ✅ does NOT overlap with 10.0.1.0/24
    dns_service_ip     = "10.1.0.10"           # ✅ must be inside the service_cidr range
  }
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = var.pg_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = "pgadmin"
  administrator_password = var.pg_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  version                = "13"

  delegated_subnet_id = azurerm_subnet.postgres.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres_dns.id
  public_network_access_enabled = false
}
