variable "project_name" {
    default = "roboshop"
}

variable "common_tags" {
    default = {
        project = "roboshop"
        Component= "vpn"
        Environment = "DEV"
        Terraform = true
    }
}

variable "env" {
    default = "dev"
  
}