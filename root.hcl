# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for OpenTofu/Terraform that provides extra tools for working with multiple modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load project-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  project_id   = local.project_vars.locals.project_id
  project_name = local.project_vars.locals.project_name
  region       = local.region_vars.locals.region
}

# Generate a GCP provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  project = "${local.project_id}"
  region  = "${local.region}"
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in a GCS bucket, one per project directory.
remote_state {
  backend = "gcs"
  config = {
    # Bucket names are unique across all of GCP, and so are project IDs, so the project ID keeps the name unique
    bucket = "${local.project_id}-${local.project_name}-tfstate"
    prefix = path_relative_to_include()

    # Terragrunt creates the bucket with these settings when it doesn't exist yet
    project                   = local.project_id
    location                  = local.region
    enable_bucket_policy_only = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure what repositories to search when you run 'terragrunt catalog'
catalog {
  urls = [
    "https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example"
  ]
}
