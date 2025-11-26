# https://registry.terraform.io/providers/OpenNebula/opennebula/latest/docs

# Terraform provider dependency:
terraform {
  required_providers {
    opennebula = {
      source  = "OpenNebula/opennebula"
      version = "~> 1.2"
    }
  }
}

# Terraform provider parameters definition:
provider "opennebula" {
  endpoint = var.opennebula_endpoint
  username = var.opennebula_username
  password = var.opennebula_token
}

# Resource (OS image) definition:
# resource "opennebula_image" "os-image" {
#   name         = var.vm_image_name
#   datastore_id = var.vm_imagedatastore_id
#   persistent   = false
#   path         = var.vm_image_url
#   permissions  = "600"
# }

# Resource (VM) definition:
resource "opennebula_virtual_machine" "vmnode" {
  name        = var.vm_machine_name
  description = "Main node VM"
  cpu         = 1
  vcpu        = 4
  memory      = 4096
  permissions = "600"
  group       = "users"

  context = {
    NETWORK        = "YES"
    HOSTNAME       = "$NAME"
    SSH_PUBLIC_KEY = var.vm_ssh_pubkey
  }

  os {
    arch = "x86_64"
    boot = "disk0"
  }

  disk {
    # image_id = opennebula_image.os-image.id
    image_id = 1101 # Existing image ID (to prevent OpenNebula error [ALLOCATE]: [one.image.allocate] Error allocating a new image. NAME is already taken by IMAGE ...)
    target   = "vda"
    size     = 6000 # 6GB
  }

  graphics {
    listen = "0.0.0.0"
    type   = "vnc"
  }

  # The Network Interface Controller is connected to 'vlan173' network (147.228.173.0/24) which has ID = 3
  nic {
    network_id = var.vm_network_id
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = self.ip
    private_key = file("/var/iac-dev-container-data/id_ecdsa")
  }

  provisioner "file" {
    source      = "init-scripts/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "export INIT_USER=${var.vm_admin_user}",
      "export INIT_PUBKEY='${var.vm_ssh_pubkey}'",
      "export INIT_LOG=${var.vm_node_init_log}",
      "export INIT_HOSTNAME=${self.name}",
      "touch ${var.vm_node_init_log}",
      "sh /tmp/init-start.sh",
      "sh /tmp/init-node.sh",
      "sh /tmp/init-users.sh",
      "sh /tmp/init-finish.sh"
    ]
  }
}

resource "local_file" "host_inventory" {
  content = templatefile("inventory.template", {
    vm_admin_user = var.vm_admin_user,
    ip_list       = opennebula_virtual_machine.vmnode.*.ip
  })
  filename = "../ansible/inventory.yml"
}

# ---------- Run Ansible on the newly created infrastructure ---------
# We use a "null_resource" in order to start Ansible using the "local-exec" provisioner.
# Because the Ansible host inventory is created dynamically using a template file,
# we must add a dependency using the "depends_on" property. This ensures, that the
# inventory is created before we call Ansible.

resource "null_resource" "ansible-provisioner" {
  provisioner "local-exec" {
    # Start provisioning all nodes:
    command = "ansible-playbook -i inventory.yml site.yml"
    working_dir = "../ansible"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
  depends_on = [local_file.host_inventory]
}

# ---------------------------- Output variables ---------------------------- #

# Output the VM IP address:
output "vm_ips" {
  value = opennebula_virtual_machine.vmnode.*.ip
}
