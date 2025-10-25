
variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "West US 2"
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
  default     = "c1b1f12b-41c7-4fb3-b5ac-02e36ce1331e"
}

variable "tenant_id" {
  description = "The Azure tenant ID."
  type        = string
  default     = "6dd7381d-4ace-410a-b7f3-011a192ebe60"
}
