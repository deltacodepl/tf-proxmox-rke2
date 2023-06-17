terraform {
  required_version = ">= 1.3.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }

    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}

locals {
  authorized_keyfile = "authorized_keys"
}
