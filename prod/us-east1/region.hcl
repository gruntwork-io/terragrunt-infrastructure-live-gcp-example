# Set common variables for the region. This is automatically pulled in by the root.hcl configuration to configure the
# provider and the location of the state bucket, and by the stacks in this region to set their location.
locals {
  region = "us-east1"
}
