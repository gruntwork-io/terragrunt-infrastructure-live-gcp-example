# Set project-wide variables. These are automatically pulled in to configure the provider and remote state in the
# root.hcl configuration.
locals {
  project_name = "non-prod"
  project_id   = get_env("EX_NON_PROD_PROJECT_ID")
}
