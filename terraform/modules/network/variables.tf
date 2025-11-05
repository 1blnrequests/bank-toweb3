variable "name" {
  description = "Base name used for tagging network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "subnets" {
  description = "Subnet definitions that will be created inside the VPC."
  type = list(object({
    name   = string
    cidr   = string
    az     = string
    public = bool
  }))
}

variable "tags" {
  description = "Tags inherited by the network resources."
  type        = map(string)
  default     = {}
}
