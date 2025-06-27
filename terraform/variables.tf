# Variables

# Default AMI (not used for specific instances)
variable "ami" {
  default = "ami-0e35ddab05955cf57"
}

# AMIs for specific instances
variable "jenkins_ami" {
  default = "ami-0ffc82a94a2297a83"
}

variable "k8s_master_ami" {
  default = "ami-0708a0fdb5ccf3048"
}

variable "k8s_worker_ami" {
  default = "ami-08f41881a59f26675"
}

variable "sonarqube_ami" {
  default = "ami-02b5dd712f2623c43"
}

# Instance types
variable "instance_type" {
  default = "t2.medium"
}

variable "large_instance_type" {
  default = "t3.2xlarge"
}

variable "key_name" {
  default = "myuswestkey"
}

variable "availability_zone" {
  default = "us-west-1a"
}

variable "environment" {
  default = "nodejs_devops "
}