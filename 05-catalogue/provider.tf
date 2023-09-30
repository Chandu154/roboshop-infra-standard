terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.15.0"
    }
  }

# we are telling to the terraform dont store sate in local ,store in backend means 
# remote in s3 bucket and lock with dynamodb 
backend "s3" {
  bucket = "roboshop-remote-state1"
  key = "catalogue"
  region= "us-east-1"
  dynamodb_table = "roboshop-locking"
  
}

}

provider "aws" {
  # Configuration options
  # you can give access key and secret key here, but security problem
  region = "us-east-1"
}