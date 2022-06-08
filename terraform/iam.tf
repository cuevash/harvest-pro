# resource "google_project_iam_binding" "sa_iam_bindings" {
#   project = var.project_id
#   role    = "roles/bigquery.admin"

#   members = [
#     "serviceAccount:${google_service_account.airbyte_sa.email}",
#     "serviceAccount:${google_service_account.airflow_sa.email}",
#     "serviceAccount:${google_service_account.dbt_sa.email}",
#     "serviceAccount:${google_service_account.metabase_sa.email}",
#   ]
# }

# resource "google_project_iam_binding" "compute_developer_bindings" {
#   project = var.project_id
#   role    = "roles/${google_project_iam_custom_role.Instance_Start_Stop_Role.role_id}"

#   members = [
#     "serviceAccount:1019074943065-compute@developer.gserviceaccount.com"
#   ]
# }


# # Role needed to attached schedules to compute instances
# resource "google_project_iam_custom_role" "Instance_Start_Stop_Role" {
#   role_id     = "instanceStartStopRole"
#   title       = "Instance Start Stop Role"
#   description = "Instance Start Stop Role"
#   project     = var.project_id

#   permissions = ["compute.instances.start", "compute.instances.stop"]
# }
