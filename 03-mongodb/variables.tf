variable "project_name" {
    default = "roboshop"
}

variable "common_tags" {
    default = {
        project = "roboshop"
        Component= "mongodb"
        Environment = "DEV"
        Terraform = true
    }
}

variable "env" {
    default = "dev"
  
}

variable "zone_name" {
  default = "joindevops.store"
}