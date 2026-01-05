locals {
  startup_script = templatefile("${path.module}/startup.sh.tftpl", {
    tokyo_rds_host = var.tokyo_rds_host
    tokyo_rds_port = var.tokyo_rds_port
    tokyo_rds_user = var.tokyo_rds_user
    secret_name    = var.db_password_secret_name
  })
}

# Explanation: Chewbacca clones disciplined soldiers—MIG gives you controlled, replaceable compute.
resource "google_compute_instance_template" "nihonmachi_tpl01" {
  name_prefix  = "nihonmachi-tpl01-"
  machine_type = "e2-medium"
  tags         = ["nihonmachi-app"]

  service_account {
    email  = google_service_account.nihonmachi_sa01.email
    scopes = ["cloud-platform"]
  }

  disk {
    source_image = "projects/debian-cloud/global/images/family/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.nihonmachi_subnet01.id
    # No external IP (private-only)
  }

  metadata = {
    startup-script = local.startup_script
  }
}

# Explanation: Nihonmachi MIG scales staff demand without creating new databases or new compliance nightmares.
resource "google_compute_region_instance_group_manager" "nihonmachi_mig01" {
  name   = "nihonmachi-mig01"
  region = var.gcp_region

  version {
    instance_template = google_compute_instance_template.nihonmachi_tpl01.id
  }

  base_instance_name = "nihonmachi-app"
  target_size        = 2
}
