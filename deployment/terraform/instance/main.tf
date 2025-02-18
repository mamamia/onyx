data "google_compute_default_service_account" "default" {
  count = var.service_account_email == null ? 1 : 0

  project = var.project
}

resource "google_compute_address" "static_ip" {
  name         = var.instance_name
  project      = var.project
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "instance" {
  name    = var.instance_name
  project = var.project
  zone    = var.zone

  machine_type   = "n1-standard-8"
  enable_display = false
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12-bookworm-v20250113"
      size  = 250
    }
  }
  guest_accelerator {
    count = 1
    type  = "nvidia-tesla-t4"
  }

  # See https://cloud.google.com/compute/docs/gpus/install-drivers-gpu#install-script
  metadata_startup_script = <<-EOT
  #!/bin/bash
  if test -f /opt/google/cuda-installer
  then
    exit
  fi

  mkdir -p /opt/google/cuda-installer
  cd /opt/google/cuda-installer/ || exit

  curl -fSsL -O https://github.com/GoogleCloudPlatform/compute-gpu-installation/releases/download/cuda-installer-v1.1.0/cuda_installer.pyz
  python3 cuda_installer.pyz install_cuda
  EOT

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
  tags = ["http-server", "https-server"]

  service_account {
    email = coalesce(var.service_account_email, data.google_compute_default_service_account.default.0.email)
    scopes = [
      # default scopes
      "storage-ro",
      "logging-write",
      "monitoring-write",
      "pubsub",
      "service-management",
      "service-control",
      "trace",
    ]
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
  }
  allow_stopping_for_update = true
}

locals {
  public_ip = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip
}