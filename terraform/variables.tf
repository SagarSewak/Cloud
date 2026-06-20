variable "aws_region" {
  description = "AWS Region to deploy services"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu AMI in us-east-1
}

variable "ssh_key_name" {
  description = "SSH key name for access validation"
  type        = string
  default     = "gdb-ssh-key"
}

variable "admin_ip_cidr" {
  description = "Admin IP CIDR block for SSH access restriction"
  type        = string
  default     = "0.0.0.0/0" # In production, restrict this to admin's public IP
}
