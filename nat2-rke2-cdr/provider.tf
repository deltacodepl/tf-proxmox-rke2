terraform {
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

provider "proxmox" {
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_tls_insecure     = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }

  pm_api_url          = "https://192.168.1.214:8006/api2/json"
  pm_api_token_id     = "terpro@pve!terraform-token"
  pm_api_token_secret = "1300b08a-28cd-459c-ac4d-ad598dddca9f"
}