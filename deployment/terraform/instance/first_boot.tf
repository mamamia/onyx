resource "null_resource" "install_dependencies" {
  triggers = {
    instance_id = google_compute_instance.instance.id
  }

  provisioner "remote-exec" {
    inline = [
      # See https://docs.onyx.app/production/gcp#installing-dependencies
      ## GPG
      "sudo apt update",
      "sudo apt install -y ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      ## Docker
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update",
      "sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      # See https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt
      ## Container toolkit
      "curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg",
      "curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list",
      "sudo apt update",
      "sudo apt install -y nvidia-container-toolkit",
      "sudo nvidia-ctk runtime configure --runtime=docker",
      "sudo systemctl restart docker"
    ]

    connection {
      type        = "ssh"
      user        = "samwarner"
      host        = local.public_ip
      private_key = file("~/.ssh/google_compute_engine")
    }
  }
}

resource "null_resource" "clone_repo" {
  depends_on = [null_resource.install_dependencies]

  triggers = {
    instance_id = google_compute_instance.instance.id
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~",
      "git clone -b ${var.onyx_branch_name} --single-branch ${var.onyx_repository_url}"
    ]

    connection {
      type        = "ssh"
      user        = "samwarner"
      host        = local.public_ip
      private_key = file("~/.ssh/google_compute_engine")
    }
  }
}

resource "null_resource" "environment" {
  depends_on = [null_resource.clone_repo]

  triggers = {
    instance_id = google_compute_instance.instance.id
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/env.template",
      {
        subdomain                  = var.subdomain
        google_oauth_client_id     = var.google_oauth_client_id
        google_oauth_client_secret = var.google_oauth_client_secret
        anthropic_api_key          = var.anthropic_api_key
        bing_api_key               = var.bing_api_key
      }
    )
    destination = "/tmp/.env"

    connection {
      type        = "ssh"
      user        = "samwarner"
      host        = local.public_ip
      private_key = file("~/.ssh/google_compute_engine")
    }
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/env.nginx.template",
      {
        subdomain = var.subdomain
      }
    )
    destination = "/tmp/.env.nginx"

    connection {
      type        = "ssh"
      user        = "samwarner"
      host        = local.public_ip
      private_key = file("~/.ssh/google_compute_engine")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/.env ~/onyx/deployment/docker_compose/.env",
      "sudo mv /tmp/.env.nginx ~/onyx/deployment/docker_compose/.env.nginx",
    ]

    connection {
      type        = "ssh"
      user        = "samwarner"
      host        = local.public_ip
      private_key = file("~/.ssh/google_compute_engine")
    }
  }
}

resource "null_resource" "launch" {
  depends_on = [null_resource.environment]

  triggers = {
    instance_id = google_compute_instance.instance.id
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~/onyx/deployment/docker_compose",
      "sudo ./init-letsencrypt-gpu.sh"
    ]

    connection {
      type        = "ssh"
      user        = "samwarner"
      host        = local.public_ip
      private_key = file("~/.ssh/google_compute_engine")
    }
  }
}