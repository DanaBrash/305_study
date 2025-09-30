
variable "rgs" {
  description = "A list of resource groups to create."
  type = list(object({
    name     = string
    location = string
  }))
  default = [
    {
      name     = "rg1"
      location = "westus2"
    },
    {
      name     = "rg2"
      location = "westcentralus"
    }
  ]
}