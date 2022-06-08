resource "google_compute_instance" "airbyte_instance" {
  name                      = "${var.project_id}-airbyte"
  machine_type              = local.airbyte_machine_type
  project                   = var.project_id
  metadata_startup_script   = file("./sh_scripts/airbyte.sh")
  allow_stopping_for_update = true

  resource_policies = [
    google_compute_resource_policy.morning_one_hour_up.id
  ]

  depends_on = [
    google_project_service.data_project_services,
    #google_project_iam_binding.compute_developer_bindings
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210415"
      size  = 50
      type  = "pd-balanced"
    }
  }
  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }
}
resource "google_compute_resource_policy" "morning_one_hour_up" {
  name        = "morning-1-hour-up"
  description = "Start and stop instances"
  project     = var.project_id
  instance_schedule_policy {
    vm_start_schedule {
      schedule = "0 8 * * *"
    }
    vm_stop_schedule {
      schedule = "0 9 * * *"
    }
    time_zone = "Europe/Madrid"
  }
}


# resource "google_compute_instance" "metabase_instance" {
#   name                    = "${var.project_id}-metabase"
#   machine_type            = local.metabase_machine_type
#   project                 = var.project_id
#   metadata_startup_script = file("./sh_scripts/metabase.sh")

#   depends_on = [
#     google_project_service.data_project_services,
#   ]

#   boot_disk {
#     initialize_params {
#       image = "ubuntu-2004-focal-v20210415"
#       size  = 50
#       type  = "pd-balanced"
#     }
#   }
#   network_interface {
#     network = "default"
#     access_config {
#       network_tier = "PREMIUM"
#     }
#   }
# }

# resource "google_compute_instance" "airflow_instance" {
#   name                    = "${var.project_id}-airflow"
#   machine_type            = local.airflow_machine_type
#   project                 = var.project_id
#   metadata_startup_script = file("./sh_scripts/airflow.sh")

#   depends_on = [
#     google_project_service.data_project_services,
#   ]

#   boot_disk {
#     initialize_params {
#       image = "ubuntu-2004-focal-v20210415"
#       size  = 50
#       type  = "pd-balanced"
#     }
#   }
#   network_interface {
#     network = "default"
#     access_config {
#       network_tier = "PREMIUM"
#     }
#   }
# }
