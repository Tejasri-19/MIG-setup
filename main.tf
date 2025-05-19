provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance_template" "default" {
  name_prefix = "apache-template"
  machine_type = "e2-medium"

  tags = ["http-server"]

  metadata = {
    enable-oslogin = "TRUE"
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_region_instance_group_manager" "default" {
  name               = "apache-mig"
  base_instance_name = "apache"
  region             = var.region
  version {
    instance_template = google_compute_instance_template.default.id
  }

  target_size = 2

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 60
  }
}

resource "google_compute_health_check" "default" {
  name = "apache-health-check"
  http_health_check {
    port = 80
  }
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}
