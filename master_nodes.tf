resource "macaddress" "k3s-masters" {
  count = var.master_nodes_count
}

locals {
  master_node_settings = var.master_node_settings
  master_node_ips = [for i in range(var.master_nodes_count) : cidrhost(var.control_plane_subnet, i + 1)]
  lan_subnet_cidr_bitnum = split("/", var.lan_subnet)[1]
}

resource "proxmox_vm_qemu" "k3s-master" {

  count       = var.master_nodes_count
  target_node = var.proxmox_node
  name        = "${var.cluster_name}-master-${count.index}"

  clone = var.node_template

  pool = var.proxmox_resource_pool
  vmid = var.vm_start_id + count.index + 1

  # cores = 2
  cores   = local.master_node_settings.cores
  sockets = local.master_node_settings.sockets
  memory  = local.master_node_settings.memory

  agent = 1
  # define_connection_info = false
  onboot = var.onboot
  scsihw = "virtio-scsi-pci"

  disk {
    type    = local.master_node_settings.storage_type
    storage = local.master_node_settings.storage_id
    size    = local.master_node_settings.disk_size
  }

  network {
    bridge    = local.master_node_settings.network_bridge
    firewall  = true
    link_down = false
    macaddr   = upper(macaddress.k3s-masters[count.index].address)
    model     = "virtio"
    queues    = 0
    rate      = 0
    tag       = local.master_node_settings.network_tag
  }

  lifecycle {
    ignore_changes       = [
      ciuser,
      sshkeys,
      disk,
      network
    ]
  }

  os_type = "cloud-init"

  ciuser = local.master_node_settings.user

  ipconfig0 = "ip=${local.master_node_ips[count.index]}/${local.lan_subnet_cidr_bitnum},gw=${var.network_gateway}"

  sshkeys = file(var.authorized_keys_file)

  nameserver = var.nameserver

  connection {
    type        = "ssh"
    user        = local.master_node_settings.user
    host        = local.master_node_ips[count.index]
    private_key = file(var.private_key)
  }

  provisioner "file" {
    # source = "${path.module}/scripts/install-updates.sh.tftpl"
    destination = "/tmp/install.sh"
    content = templatefile("${path.module}/scripts/install-updates.sh.tftpl", {
      k3s_is_master = true
    })
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/install.sh",
      "/tmp/install.sh",
      "rm -r /tmp/install.sh",
    ]
  }
  # provisioner "remote-exec" {
  #   inline = [
  #     templatefile("${path.module}/scripts/install-updates.sh.tftpl", {
  #       mode         = "server"
  #       tokens       = [random_password.k3s-server-token.result]
  #       alt_names    = concat([local.support_node_ip], var.api_hostnames)
  #       server_hosts = []
  #       node_taints  = ["CriticalAddonsOnly=true:NoExecute"]
  #       disable      = var.k3s_disable_components
  #       datastores   = [
  #         {
  #           host     = "${local.support_node_ip}:3306"
  #           name     = "k3s"
  #           user     = "k3s"
  #           password = random_password.k3s-master-db-password.result
  #         }
  #       ]
  #       http_proxy = var.http_proxy
  #     })
  #   ]
  # }
}
