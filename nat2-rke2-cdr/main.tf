
module "k3s" {
  source = "../"
  # version = ">= 0.0.0, < 1" # Get latest 0.X release

  authorized_keys_file = "~/.ssh/id_rsa.pub"

  proxmox_node = "nat2"

  node_template         = "ubuntu-2204"
  proxmox_resource_pool = "rke2"

  network_gateway = "192.168.1.1"
  lan_subnet      = "192.168.1.0/24"

  master_nodes_count = 3
  master_node_settings = {
    cores  = 2
    memory = 4096
  }

  # 192.168.0.200 -> 192.168.0.207 (6 available IPs for nodes)
  control_plane_subnet = "192.168.1.156/30"

  node_pools = [
    {
      name     = "rke2"
      size     = 5
      start_id = 210
      #/28 192.168.0.208 -> 192.168.0.223 (14 available IPs for nodes)
      subnet = "192.168.1.160/29"
    }
  ]
}


