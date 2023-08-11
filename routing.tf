

resource "azurerm_route_table" "rt_snetsviacheckpoint" {

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }

  name                          = "rt-snetsviacheckpoint"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  disable_bgp_route_propagation = true

  #   route {
  #     name           = "snet-azurelabaks-pods-dev"
  #     address_prefix = "10.53.2.128/25"
  #     next_hop_type  = "VirtualAppliance"
  #     next_hop_in_ip_address = var.vna
  #   }

  dynamic "route" {
    for_each = var.subnets
    iterator = subnet

    content {
      name                   = "route-to-${subnet.value.name}"
      address_prefix         = data.azurerm_subnet.example[subnet.value.name].address_prefix
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.vna
    }
  }

}

resource "azurerm_route_table" "rt_defaultcheckpoint" {

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }

  name                          = "rt-defaultcheckpoint"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  disable_bgp_route_propagation = true


  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.vna
  }
}


data "azurerm_subnet" "example" {
  depends_on = [ azurerm_virtual_network.example ]
  for_each = { for subnet in var.subnets : subnet.name => subnet }


  name                 = each.key
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.rg_name
}



resource "azurerm_subnet_route_table_association" "example" {

  for_each = { for subnet in var.subnets : subnet.name => subnet }

  subnet_id      = data.azurerm_subnet.example[each.key].id
  route_table_id = azurerm_route_table.rt_defaultcheckpoint.id
}
