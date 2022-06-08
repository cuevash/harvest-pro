resource "google_sql_database_instance" "postgresql" {
  name             = "${local.app_name}-db"
  database_version = "POSTGRES_14"

  settings {
    tier              = "db-f1-micro"
    activation_policy = "ALWAYS"
    disk_autoresize   = true
    disk_size         = 10
    disk_type         = "PD_SSD"

    maintenance_window {
      day  = "7" # sunday
      hour = "3" # 3am
    }

    backup_configuration {
      binary_log_enabled             = true
      enabled                        = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 3
      start_time                     = "00:00"
    }

    ip_configuration {
      ipv4_enabled = "true"
      authorized_networks {
        value = var.db_instance_access_cidr
      }
    }
  }
}
