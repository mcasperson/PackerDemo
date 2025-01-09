packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "ami_name" {
  type    = string
  default = "packerdemo"
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "subnet" {
  type    = string
}

variable "vpc" {
  type    = string
}

locals {
  versioned_ami_name = "${var.ami_name}.${formatdate("YYYY.MM.DD.hhmmss", timestamp())}"
}

data "amazon-ami" "autogenerated_1" {
  filters = {
    name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
}

source "amazon-ebs" "AWS_AMI_Builder" {
  ami_description             = local.versioned_ami_name
  ami_name                    = local.versioned_ami_name
  associate_public_ip_address = "true"
  ena_support                 = true
  encrypt_boot                = false
  instance_type               = "t3.small"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 40
    volume_type           = "gp3"
  }
  region = "${var.aws_region}"
  run_tags = {
    Name = local.versioned_ami_name
  }
  run_volume_tags = {
    Name = local.versioned_ami_name
  }
  security_group_filter {
    filters = {
      "tag:Name" = "packer-build-sg"
    }
  }
  snapshot_tags = {
    Name = local.versioned_ami_name
  }
  source_ami   = "${data.amazon-ami.autogenerated_1.id}"
  ssh_username = "ubuntu"
  subnet_id    = "${var.subnet}"
  tags = {
    Name            = local.versioned_ami_name
  }
  vpc_id = "${var.vpc}"
}

build {
  sources = ["source.amazon-ebs.AWS_AMI_Builder"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "current_time=$(date)",
      "echo \"<html><body><h1>Hello Octopus!</h1><p>Build time: $current_time</p></body></html>\" | sudo tee /var/www/html/index.html"]
    pause_before = "10s"
    timeout      = "10s"
  }
}