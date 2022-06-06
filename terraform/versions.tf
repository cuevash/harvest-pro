terraform {

  cloud {
    organization = "eternal-rtn"

    workspaces {
      name = "harvest-pro"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.24.0"
    }
  }

  required_version = ">= 1.2.0"

}
