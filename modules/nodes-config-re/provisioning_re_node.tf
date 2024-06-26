#### Generating Ansible config, inventory, playbook 
#### and configuring RE nodes and installing RE software
#### (RE nodes need special configuration to work with Ubuntu 18)

#### TESTING
# Define a null_resource block for the retry logic
resource "null_resource" "retry" {
  count = 3

  # Retry logic to run remote-exec provisioner
  provisioner "local-exec" {
    command = "echo Retrying remote-exec provisioner attempt ${count.index + 1}"
    interpreter = ["/bin/bash", "-c"]
  }

  # Dependencies
  depends_on = [
    null_resource.remote-config
  ]
}

# Define a null_resource block for the remote-exec provisioning
resource "null_resource" "remote-config" {
  count = var.data-node-count

  # Provisioner block for remote-exec
  provisioner "remote-exec" {
    # Command to run on the remote node
    inline = [ var.os_family == "ubuntu" ? "sudo apt update > /dev/null" : "sudo yum update -y > /dev/null"]

    # SSH connection details
    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_key_path)
      host        = element(var.aws_eips, count.index)
    }
  }

  # Dependencies
  depends_on = [
    local_file.inventory-setup,
    local_file.ssh-setup,
    local_file.playbook_setup,
    time_sleep.wait_30_seconds_re
  ]
}

### TESTING

#### Sleeper, after instance, eip assoc, local file inventories & cfg created
#### otherwise it can run to fast, not find the inventory file and fail or hang
resource "time_sleep" "wait_30_seconds_re" {
  create_duration = "30s"
  depends_on = [local_file.inventory-setup, 
                local_file.ssh-setup]
}

#### Generate Ansible Playbook
resource "local_file" "playbook_setup" {
    count    = var.data-node-count
    content  = templatefile("${path.module}/ansible/playbooks/${var.os_family}/playbook_re_node.yaml.tpl", {
        re_download_url  = var.re_download_url
    })
    filename = "${path.module}/ansible/playbooks/playbook_re_node.yaml"
  #depends_on = [aws_instance.re_cluster_instance, aws_eip_association.re-eip-assoc, aws_volume_attachment.ephemeral_re_cluster_instance]
}



#### Generate Ansible Inventory for each node
resource "local_file" "inventory-setup" {
    count    = var.data-node-count
    content  = templatefile("${path.module}/ansible/inventories/inventory_re.tpl", {
        host_ip  = element(var.aws_eips, count.index)
        vpc_name = var.vpc_name
    })
    filename = "/tmp/${var.vpc_name}_node_${count.index}.ini"
  #depends_on = [aws_instance.re_cluster_instance, aws_eip_association.re-eip-assoc, aws_volume_attachment.ephemeral_re_cluster_instance]
}

#### Generate ansible.cfg file
resource "local_file" "ssh-setup" {
    content  = templatefile("${path.module}/ansible/config/ssh.tpl", {
        vpc_name = var.vpc_name
        ssh_user = var.ssh_user
    })
    filename = "/tmp/${var.vpc_name}_node.cfg"
  #depends_on = [aws_instance.re_cluster_instance, aws_eip_association.re-eip-assoc, aws_volume_attachment.ephemeral_re_cluster_instance]
}

######################
# Run ansible playbook to install RE software and configure node
resource "null_resource" "ansible-run" {
  count = var.data-node-count
  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/ansible/playbooks/playbook_re_node.yaml --private-key ${var.ssh_key_path} -i /tmp/${var.vpc_name}_node_${count.index}.ini"
    }
  depends_on = [null_resource.remote-config,time_sleep.wait_30_seconds_re]
}


