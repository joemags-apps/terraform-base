terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.6.0"
    }
  }
}

provider "linode" {
    token = var.token
}

resource "linode_instance" "Template" {
    label = "Template"
    image = "linode/ubuntu22.04"
    group = "Template"
    region = "eu-central"
    type = "g6-standard-1"
    root_pass=var.root_pass
    authorized_keys= [var.authorized_keys]

    provisioner "remote-exec" {
      connection {
        host        = self.ip_address
        type        = "ssh"
        user        = "root"
        agent       = "false"
        private_key = chomp(file(var.private_ssh_key))
      }

      inline = [
        "apt -q update",
        "timedatectl set-timezone Africa/Harare",
        "hostnamectl set-hostname ${var.server_name}",
        "adduser --disabled-password --gecos \"\" ${var.user_name}",
        "usermod -aG sudo ${var.user_name}",
        "ufw allow OpenSSH",
        "ufw enable --force",
        "rsync --archive --chown=${var.user_name}:${var.user_name} ~/.ssh /home/${var.user_name}",
        "echo '${var.user_name} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
      ]
    }
}