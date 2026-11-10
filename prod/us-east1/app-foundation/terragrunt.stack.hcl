locals {
  // Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  // Also names the bucket, which is unique across all of GCP.
  name = "${get_env("EX_APP_PREFIX")}-app-prod"
}

stack "app" {
  // You'll typically want to pin this to a particular version of your catalog repo.
  // e.g.
  // source = "github.com/acme/terragrunt-infrastructure-catalog//stacks/gcp/app-foundation?ref=v0.1.0"
  //
  // If you are using a private catalog, you may want to use an SSH source URL instead:
  // source = "git::git@github.com:acme/terragrunt-infrastructure-catalog.git//stacks/gcp/app-foundation"
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//stacks/gcp/app-foundation"

  path = "app"

  values = {
    name     = local.name
    location = local.region_vars.locals.region

    // Alert on the bucket's failed requests and egress, in prod only
    enable_alerts = true
  }
}
