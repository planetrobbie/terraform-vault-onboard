provider "google" {
  region      = var.region
  project     = var.project_name
}

# Startup script template where we grab SSH CA from Vault API.
data "template_file" "startup_script" {
  template = "${file("./files/script.sh")}"

  vars = {
    vault_namespace = var.vault_namespace
  }
}

resource "google_compute_instance" "vm" {
  name         = "ssh-automation-test"
  machine_type = var.instance_type
  zone         = var.region_zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = ["compute-ro"]
  }

  metadata_startup_script = "${data.template_file.startup_script.rendered}"

}
