variable "subnets" {
  type = list(object({
    name      = string
    cidr      = string
    vnet_name = string
    rg_name   = string
  }))
  default = [
    {
      name      = "linux_servers"
      cidr      = "10.0.101.0/24"
      vnet_name = "example-network"
      rg_name   = "example-resources-xyz"
    },
    {
      name      = "db_servers"
      cidr      = "10.0.102.0/24"
      vnet_name = "example-network"
      rg_name   = "example-resources-xyz"
    },
    {
      name      = "win_servers"
      cidr      = "10.0.103.0/24"
      vnet_name = "example-network"
      rg_name   = "example-resources-xyz"
    }
  ]
}