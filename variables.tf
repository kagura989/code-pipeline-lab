variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_owner" {
  description = "GitHub username"
  type        = string
}

variable "key_name" {
  description = "Name of EC2 key pair"
  type        = string
}

variable "ec2_ip" {
  description = "Public IP of EC2 instance to deploy to"
  type        = string
}