variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "ami" {}

variable "AWS_REGION" {
  default = "us-east-1"
}

# variable "FILE_SYSTEM_ID" {
#   default = "fs-08c1be7a6d41588a1"
# }

# variable "MOUNT_POINT" {
#     default = "/var/www/html"
# }
  

variable "environment" {
  default = "dev"
}

variable "vpc_id" {
  default = "vpc-ad7857c9"
}

variable "system" {
  default = "Retail Reporting"
}

variable "subsystem" {
  default = "CliXX"
}

variable "availability_zone" {
  default = "us-east-1c"
}
variable "subnets_cidrs" {
  type = list(string)
  default = [
    "172.31.80.0/20"
  ]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "my_key.pub"
}

variable "OwnerEmail" {
  default = "olamide.solola@gmail.com"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-stack-1.0"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}

variable "MOUNT_POINT" {
    default = "/var/www/html"
}

variable "FILE_SYSTEM_ID" {
    default = "fs-08c1be7a6d41588a1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

variable "subnet" {
  default = "subnet-0b3bad804a1e1eb2f"
}
