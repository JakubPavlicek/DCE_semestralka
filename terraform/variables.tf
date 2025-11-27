variable "opennebula_endpoint" {
    description = "Open Nebula endpoint URL"
    default = "https://nuada.zcu.cz/RPC2"
}
variable "opennebula_username" {
    description = "Open Nebula username"
    default = "maxmilio"
}
variable "opennebula_token" {
    description = "Open Nebula Token"
    default = "NONE"
}
variable "vm_count" {
    description = "Number of VMs to create"
    default = 1
}
variable "vm_ssh_pubkey" {
    description = "SSH public key used for login as root into the VM instance"
}
variable "vm_admin_user" {
    description = "Username of the admin user"
    default = "nodeadm"
}
variable "vm_node_init_log" {
    description = "Node initialization log file"
    default = "/var/log/node-init.log"
}
variable "vm_imagedatastore_id" {
    description = "Open Nebula datastore ID"
    default = 101 # => "nuada_pool"
}
variable "vm_network_id" {
    description = "ID of the virtual network to attach to the virtual machine"
    default = 3 # => "vlan173"
}
variable "vm_image_name" {
    description = "VM OS image name"
}
variable "vm_image_url"  {
    description = "VM OS image URL"
}
variable "vm_machine_name" {
    description = "Name of the VM"
    default = "vm-node"
}
