[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_terragrunt-infra-live-gcp-example)

# Example infrastructure-live for Terragrunt on GCP

This repository, along with the [terragrunt-infrastructure-catalog-example repository](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example),
offers a best practice system for organizing your Infrastructure as Code (IaC) on Google Cloud (GCP) so that you can maintain your
IaC at any scale with confidence using an `infrastructure-live` repository.

It follows the same patterns as the [terragrunt-infrastructure-live-stacks-example repository](https://github.com/gruntwork-io/terragrunt-infrastructure-live-stacks-example), which does the same for AWS, and the [terragrunt-infrastructure-live-azure-example repository](https://github.com/gruntwork-io/terragrunt-infrastructure-live-azure-example), which does the same for Azure.

If you have not already done so, you are encouraged to read the [Terragrunt Getting Started Guide](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/) to get familiar with the terminology and concepts used in this repository before proceeding.

## What is an `infrastructure-live` repository?

An `infrastructure-live` repository is a Gruntwork best practice for managing your "live" infrastructure. That is, the
infrastructure that is actually provisioned, as opposed to infrastructure patterns that *can* be provisioned.

## Key Features & Benefits

This repository provides a practical blueprint for managing GCP infrastructure with Terragrunt, demonstrating:

* **Modern Terragrunt Workflow:** Leverages Terragrunt Stacks for clear dependency management and streamlined multi-component deployments.
* **Scalable `infrastructure-live` Structure:** Organizes infrastructure logically by project and region, providing a proven foundation adaptable to growing complexity.
* **Best-Practice Separation:** Clearly separates environment-specific "live" configurations (this repo) from reusable infrastructure patterns (via an `infrastructure-catalog`).
* **DRY Configuration:** Reduces code duplication using hierarchical configuration files (`root.hcl`, `project.hcl`, `region.hcl`).
* **Concrete End-to-End Example:** Deploys the foundation for an application (storage bucket, Firestore database, Artifact Registry repository, and a service account with only the access it needs) across distinct production and non-production environments.
* **Reproducible Tooling:** Includes `mise` configuration for easy installation of pinned versions of Terragrunt and OpenTofu/Terraform.

## Getting Started

To use this repository, you'll want to fork this repository into your own Git organization.

The steps for doing this are the following:

1. Create a new Git repository in your organization (e.g. [GitHub](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository), [GitLab](https://docs.gitlab.com/user/project/repository/)).

2. Create a bare clone of this repository somewhere on your local machine.

   ```bash
   git clone --bare https://github.com/gruntwork-io/terragrunt-infrastructure-live-gcp-example.git
   ```

3. Push the bare clone to your new Git repository.

   ```bash
   cd terragrunt-infrastructure-live-gcp-example.git
   git push --mirror <YOUR_GIT_REPO_URL> # e.g. git push --mirror git@github.com:acme/terragrunt-infrastructure-live-gcp-example.git
   ```

4. Remove the local clone of the repository.

   ```bash
   cd ..
   rm -rf terragrunt-infrastructure-live-gcp-example.git
   ```

5. (Optional) Delete the contents of this usage documentation from your fork of this repository.

## Prerequisites

To use this repository, you'll want to make sure you have the following installed:

- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [OpenTofu](https://opentofu.org/docs/intro/install/) (or [Terraform](https://developer.hashicorp.com/terraform/install))
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)

To simplify the process of installing Terragrunt and OpenTofu, you can install [mise](https://mise.jdx.dev/), then run the following to concurrently install them, pinned to the versions they were tested with (as tracked in the [mise.toml](./mise.toml) file):

```bash
mise install
```

You'll also need the **Owner** role on the projects you deploy to, because the stacks grant a service account roles on the project, a bucket and an Artifact Registry repository. **Editor** can't change IAM policies. See [Required GCP permissions](https://docs.terragrunt.com/features/units/authentication/gcp/#required-permissions) for what the state backend needs.

## Repository Contents

> [!NOTE]
> This code is solely for demonstration purposes. This is not production-ready code, so use at your own risk. If you are interested in battle-tested, production-ready Terragrunt and OpenTofu/Terraform code, continuously updated and maintained by a team of subject matter experts, consider purchasing a subscription to the [Gruntwork IaC Library](https://www.gruntwork.io/platform/iac-library).

This repository contains the following:

- `root.hcl`: The root Terragrunt configuration inherited by all other Terragrunt units in this repository. This file contains code that reads the `project.hcl` and `region.hcl` files in every unit, and leverages them for provider and backend configurations.

- `non-prod`/`prod` directories: Each of these directories are a representation of a GCP project, and all the infrastructure that's provisioned for a project can be found in the respective directory.

- `project.hcl` files: In each project directory, there is a `project.hcl` file that defines the common configurations for that project.

- `region.hcl` files: In each region directory (e.g. `us-east1`), there is a `region.hcl` file that defines the common configurations for that region.

- `terragrunt.stack.hcl` files: These files define a stack of Terragrunt units.

  Both the `terragrunt.stack.hcl` files in this repository use the `app-foundation` stack, which provisions what an application needs before it can run, including:

  - Cloud Storage bucket, private, for the app's `data`
  - Firestore database in Native mode
  - Artifact Registry repository for the app's Docker images
  - Service account, with `roles/artifactregistry.reader` on the repository, `roles/storage.objectViewer` on the bucket, and `roles/datastore.user` on the database
  - Alerts on the bucket's failed requests and egress (`prod` only)

  This example doesn't deploy application code, so it ends with the resources above and their outputs.

  The configurations for these resources aren't defined in this repository, but are instead defined in the [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) repository.

  This is a recommended, Gruntwork best practice, as it allows infrastructure teams to iterate on infrastructure patterns as versioned, immutable artifacts, and then reference pinned versions of these patterns in their "live" infrastructure-live repositories.

## Best practices for an `infrastructure-live` repository

The following conventions are some best practices for an `infrastructure-live` repository, as defined by Gruntwork:

- Primarily use [Terragrunt](https://terragrunt.com) configurations to define your IaC.
- Avoid using OpenTofu/Terraform directly in `infrastructure-live` repositories. Instead, prefer to author OpenTofu/Terraform configurations in an `infrastructure-catalog` repository (see [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example)).
- Follow [Trunk-Based Development](https://trunkbaseddevelopment.com/). The source of truth for your infrastructure is the code in the `main` branch (or whatever you configure the default branch to be).
- Avoid using [OpenTofu/Terraform Workspaces](https://opentofu.org/docs/language/state/workspaces/). Instead, use [Terragrunt units](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#unit) to isolate state.
- Use [Stacks](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#stack) to organize your infrastructure into logical collections of units.

## How to provision the infrastructure in this repository

### Setup

Before you start provisioning the infrastructure in this repository, you'll want to do the following:

1. Log in with Application Default Credentials.

   ```bash
   gcloud auth application-default login
   ```

   Terragrunt and the OpenTofu Google provider use these credentials. `gcloud auth login` on its own isn't enough, because it only signs in the `gcloud` CLI. See [GCP authentication](https://docs.terragrunt.com/features/units/authentication/gcp/) for other options, such as Workload Identity Federation in CI.

2. Set the `EX_NON_PROD_PROJECT_ID` and `EX_PROD_PROJECT_ID` environment variables to the IDs of the GCP projects you want to use for non-production and production workloads, respectively.

   ```bash
   export EX_NON_PROD_PROJECT_ID="acme-non-prod"
   export EX_PROD_PROJECT_ID="acme-prod"
   ```

   Alternatively, you can replace the `get_env(...)` calls in [`non-prod/project.hcl`](/non-prod/project.hcl) and [`prod/project.hcl`](/prod/project.hcl) with hardcoded project ID strings.

   > [!TIP]
   > If you want everything deployed in a single GCP project, you can set both environment variables to the same value (or use the same hardcoded string in both files). For example, to use the project `gcloud` is set to:
   >
   > ```bash
   > export EX_NON_PROD_PROJECT_ID="$(gcloud config get-value project)"
   > export EX_PROD_PROJECT_ID="$EX_NON_PROD_PROJECT_ID"
   > ```

3. Enable the APIs the stacks and the state backend use, in each project.

   ```bash
   for PROJECT in "$EX_NON_PROD_PROJECT_ID" "$EX_PROD_PROJECT_ID"; do
     gcloud services enable \
       artifactregistry.googleapis.com \
       cloudresourcemanager.googleapis.com \
       firestore.googleapis.com \
       iam.googleapis.com \
       monitoring.googleapis.com \
       storage.googleapis.com \
       --project "$PROJECT"
   done
   ```

4. Set the `EX_APP_PREFIX` environment variable to something unique to you, using at most 18 lowercase letters, digits and hyphens, starting with a letter.

   ```bash
   export EX_APP_PREFIX="acme"
   ```

   Bucket names must be unique across all of GCP, so the stacks start every resource name with the prefix (e.g. `acme-app-dev-data`, `acme-app-dev-db`, `acme-app-dev-sa`). The limit of 18 characters comes from the service account ID, which allows at most 30.

5. Review the `remote_state` block in the `root.hcl` file. It stores state in a Cloud Storage bucket in each project.

   ```hcl
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
   ```

   The bucket name is the project ID, the project directory name, and `tfstate`, so state for the projects above lives in `acme-non-prod-non-prod-tfstate` and `acme-prod-prod-tfstate`. You can change the `tfstate` suffix if you like. See the [gcs backend docs](https://docs.terragrunt.com/features/units/state-backend/gcs/) for all the options.

   Terragrunt turns on object versioning when it creates the bucket, so every state change keeps the previous version. `enable_bucket_policy_only` turns on uniform bucket-level access, so IAM on the bucket is the only way to reach the state.

   Each project directory gets its own bucket, so `non-prod` and `prod` keep separate state even if you deploy both to a single GCP project. All regions in a project share its bucket, under different prefixes. Terragrunt creates the bucket in the region of the first stack you bootstrap.

### Provisioning a single stack

1. Navigate to the directory of the stack you want to provision.
   e.g.

   ```bash
   cd non-prod/us-east1/app-foundation
   ```

2. Run the following to generate the relevant units for the stack, and run a plan against them.

   ```bash
   terragrunt run --all --non-interactive --backend-bootstrap plan
   ```

   > [!TIP]
   >
   > The `--backend-bootstrap` flag there allows Terragrunt to automatically create relevant backend resources for you before running OpenTofu. Here, that's the state bucket.
   >
   > You don't need to use the flag if you are using backend resources that already exist, or don't want Terragrunt to create them for you.
   >
   > If the first run fails with `SERVICE_DISABLED` or `403` right after you enabled the APIs, wait a few minutes and run it again. GCP can take that long to finish enabling an API.

3. If the plan looks good, run the following to apply the changes.

   ```bash
   terragrunt run --all --non-interactive apply
   ```

### Provisioning all stacks

If you want to provision all the stacks in this repository, you can do the same at the root of the repository.

1. Navigate back up to the root of the repository.

   ```bash
   cd ../../..
   ```

2. Plan all units.

   ```bash
   terragrunt run --all --non-interactive --backend-bootstrap plan
   ```

3. Apply all units.

   ```bash
   terragrunt run --all --non-interactive apply
   ```

## Interacting with the provisioned infrastructure

If you'd like to interact with the infrastructure that was just provisioned, you can do the following:

1. Get the output values for the stack that you just provisioned.

   ```bash
   $ cd non-prod/us-east1/app-foundation
   $ terragrunt stack output
   app = {
     bucket = {
       name      = "acme-app-dev-data"
       self_link = "https://www.googleapis.com/storage/v1/b/acme-app-dev-data"
       url       = "gs://acme-app-dev-data"
     }
     database = {
       id   = "projects/acme-non-prod/databases/acme-app-dev-db"
       name = "acme-app-dev-db"
     }
     identity = {
       bucket_iam_member_ids = {
         object_viewer = "b/acme-app-dev-data/roles/storage.objectViewer/serviceAccount:acme-app-dev-sa@acme-non-prod.iam.gserviceaccount.com"
       }
       email  = "acme-app-dev-sa@acme-non-prod.iam.gserviceaccount.com"
       id     = "projects/acme-non-prod/serviceAccounts/acme-app-dev-sa@acme-non-prod.iam.gserviceaccount.com"
       member = "serviceAccount:acme-app-dev-sa@acme-non-prod.iam.gserviceaccount.com"
       project_iam_member_ids = {
         datastore_user = "acme-non-prod/roles/datastore.user/serviceAccount:acme-app-dev-sa@acme-non-prod.iam.gserviceaccount.com/acme-app-dev-db only//resource.name == \"projects/acme-non-prod/databases/acme-app-dev-db\""
       }
       repository_iam_member_ids = {
         artifact_reader = "projects/acme-non-prod/locations/us-east1/repositories/acme-app-dev-images/roles/artifactregistry.reader/serviceAccount:acme-app-dev-sa@acme-non-prod.iam.gserviceaccount.com"
       }
     }
     registry = {
       id           = "projects/acme-non-prod/locations/us-east1/repositories/acme-app-dev-images"
       location     = "us-east1"
       name         = "acme-app-dev-images"
       registry_uri = "us-east1-docker.pkg.dev/acme-non-prod/acme-app-dev-images"
     }
   }
   ```

   Note that all the units in the stack display their outputs here. Outputs are organized by stack, then unit, then output name.

2. Use the output values to interact with the infrastructure.

   ```bash
   $ SA_MEMBER="$(terragrunt stack output --raw app.identity.member)"
   $ gcloud projects get-iam-policy "$EX_NON_PROD_PROJECT_ID" \
       --flatten=bindings \
       --filter="bindings.members:$SA_MEMBER" \
       --format="table(bindings.role, bindings.condition.expression)"
   ROLE                  EXPRESSION
   roles/datastore.user  resource.name == "projects/acme-non-prod/databases/acme-app-dev-db"
   ```

   This lists the roles the stack gave the service account on the project. Firestore has no IAM per database, so the stack grants `roles/datastore.user` on the project, with a condition that limits it to this stack's database. The other two roles are on the bucket and the repository themselves:

   ```bash
   $ gcloud storage buckets get-iam-policy "gs://$(terragrunt stack output --raw app.bucket.name)" \
       --flatten="bindings[].members" \
       --format="value(bindings.role, bindings.members)" \
       | grep "$SA_MEMBER"
   roles/storage.objectViewer	serviceAccount:acme-app-dev-sa@acme-non-prod.iam.gserviceaccount.com
   ```

   This command doesn't accept `--filter`, so `grep` picks out the service account's lines.

   An application that runs as this service account can pull images from the repository, read objects in the bucket, and read and write documents in the database, and nothing else.

   Outputs can be indexed by output key. In this case, the `identity` unit of the `app` stack has an output key of `member`, so we can access it directly with `app.identity.member`. When outputs are nested into stacks, you can access them by chaining the stack name, unit name, and output key.

## Cleaning up

1. The `prod` stack keeps the catalog's default of delete protection on the Firestore database, and GCP refuses to delete a protected database. Before you destroy `prod`, add `enable_delete_protection = false` to the `values` in [`prod/us-east1/app-foundation/terragrunt.stack.hcl`](prod/us-east1/app-foundation/terragrunt.stack.hcl), the way `non-prod` does, and apply it.

   ```bash
   cd prod/us-east1/app-foundation
   terragrunt run --all --non-interactive apply
   ```

2. Destroy the infrastructure, from a stack directory or from the root of the repository.

   ```bash
   terragrunt run --all --non-interactive destroy
   ```

3. Delete the buckets that hold the state, including every old version of the state. Only do this once nothing else stores state there.

   ```bash
   gcloud storage rm --recursive "gs://${EX_NON_PROD_PROJECT_ID}-non-prod-tfstate"
   gcloud storage rm --recursive "gs://${EX_PROD_PROJECT_ID}-prod-tfstate"
   ```

## Browsing the infrastructure catalog

The `catalog` block at the end of [`root.hcl`](./root.hcl) lists repositories of reusable infrastructure that you can build on in this repository:

```hcl
catalog {
  urls = [
    "https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example"
  ]
}
```

To browse them, run the following from the root of the repository:

```bash
terragrunt catalog
```

Terragrunt reads the `catalog` block from `root.hcl`, clones each repository into a temporary directory, and opens a terminal UI listing the components it found: OpenTofu/Terraform modules, Boilerplate templates and Terragrunt units + stacks. You can also run it from any directory below the root, since Terragrunt searches parent directories for `root.hcl`.

In the terminal UI:

- Press `Tab` and `Shift+Tab` to switch between tabs that show all components or one kind at a time.
- Press `/` and start typing to filter the list.
- Use the arrow keys to move through the list.
- Press `Enter` to read the README of the selected component.
- Press `s` to scaffold the selected component.
- Press `q` to quit.

Scaffolding writes to the directory you launched the catalog from, so create the directory for the new component and run the catalog from there. Units and stacks are copied as they are, and templates are rendered with Boilerplate. A module gets a new unit with a `terragrunt.hcl` file, which by default includes a root file named `root.hcl`.

The GCP components in the catalog are under `modules/gcp`, `units/gcp` and `stacks/gcp`.

To browse a different repository, pass its URL to the command (e.g. `terragrunt catalog https://github.com/acme/infrastructure-catalog`), or add it to the `urls` list in `root.hcl` to share it with everyone working in this repository. For more, see the [Catalog docs](https://docs.terragrunt.com/features/catalog).

## How is the code in this repository organized?

The IaC code in this repository is organized into a hierarchy of Terragrunt stacks, representing the blast radius of the infrastructure being managed in the context of GCP infrastructure management.

The hierarchy is as follows:

```tree
project
 `-- region
      `-- resources
```

Where:

- `project` is the GCP project being managed (e.g. `non-prod`, `prod`, `mgmt`).
- `region` is the GCP region being managed (e.g. `us-east1`).
- `resources` are the resources being managed (e.g. `app-foundation`).

This structure is geared towards exclusive management of infrastructure in GCP, but can be adapted to other cloud providers, etc. by adjusting the hierarchy according to the patterns of the platform.

The top-level `project` and `region` directories are there to give clear context for users that are familiar with GCP infrastructure management. The OpenTofu Google provider is configured per project, and the bucket, database and repository in this example are all regional, so it's also useful to have these directories to provide a straight-forward way to configure the provider, the state backend, and the location of the resources.

Some GCP resources belong to the whole project rather than a region, like the service account and alert policies in this example. They still live in the regional stack, next to the resources they serve, so destroying the stack removes them too.

Many teams like to organize their environments into individual GCP projects, and this structure makes it easy to do that. If you are part of a team that manages multiple environments in a single GCP project, you can simply add a new level of hierarchy under the `region` directory, like this:

```tree
project
 `-- region
      `-- environment
           `-- resources
```

There's also an established convention to leverage a special `_global` directory to manage resources that are available across all regions, environments, etc. Structuring your IaC like that would look like this:

```tree
project
 |-- _global
 |    `-- resources
 `-- region
      |-- _global
      |    `-- resources
      `-- environment
           `-- resources
```

Where:

- **Project-level `_global`**: Contains resources that are available across all regions in the project, such as VPC networks (which span every region in GCP), project IAM bindings, Cloud DNS zones, and log sinks.
- **Region-level `_global`**: Contains resources that are available across all environments in a region, such as subnets, Cloud NAT gateways, and shared Artifact Registry repositories.

The `resources` directory can be arbitrarily deep, and can be used to organize resources under management in a way that makes sense for the team managing the infrastructure. In this repository it's fairly shallow for the sake of simplicity, with the units constituting the stack defined in the [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) repository.

## Where to store configuration

### `root.hcl`

The contents of the `root.hcl` file is configuration that is common to all units the repository. It's idiomatic Terragrunt code to always include this root file in every unit. There's very frequently some boilerplate configuration like defining the OpenTofu provider, setting state backend configurations, etc. that have to be repeated in every unit, so it's nice to have it defined once in the root file, and included in every unit.

Avoid overloading this file with too much configuration, as it might not be the right level of abstraction for the configuration you need. Instead, prefer to use `terragrunt.stack.hcl` files to define configurations in `values` attributes, and pass down the values to the stacks and units that need them.

### `terragrunt.stack.hcl`

The `terragrunt.stack.hcl` file is used to define configurations for a stack of Terragrunt units. Any time you have multiple `terragrunt.hcl` files that need to be run together as part of your infrastructure deployment, you can define a `terragrunt.stack.hcl` file instead to encapsulate those configurations as a single entity that can be reliably reproduced across projects, regions, environments, etc.

Using the `values` attribute of [stack](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#stack) and [unit](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#unit) configuration blocks allows you to pass down configuration to units with granular control.

For example, consider the [prod/us-east1/app-foundation/terragrunt.stack.hcl](prod/us-east1/app-foundation/terragrunt.stack.hcl) file:

```hcl
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
```

Here, you can see that the `values` attribute is setting exactly the values that are unique to the `app-foundation` stack in the context of `prod`: the name of its resources, the location it reads from `region.hcl`, and `enable_alerts`, which turns on the `alerts` unit that `non-prod` leaves out. The `non-prod` stack sets `enable_delete_protection = false` instead, so it can be torn down without first changing the database.

The alerts have nowhere to send notifications until you list email addresses in the `alert_email_addresses` value. Until then, you can see them fire in the Cloud Monitoring console.

A `stack` block pulls in a whole stack from the catalog, so this file stays short. If you need to change how a single unit is configured, you can instead list `unit` blocks in the `terragrunt.stack.hcl` file, the way the [terragrunt-infrastructure-live-stacks-example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-stacks-example) repository does.

### Declaring dependencies between units

The units in the `app-foundation` stack depend on each other. For example, the `identity` unit needs the names of the bucket and repository, and the ID of the database, to grant the service account roles on them. The catalog's stack file declares these dependencies directly using an [`autoinclude`](https://terragrunt.gruntwork.io/docs/reference/hcl/blocks/#autoinclude) block:

```hcl
unit "identity" {
  source                 = "../../..//units/gcp/service-account"
  update_source_with_cas = true

  path = "identity"

  values = {
    name         = "${local.name}-sa"
    display_name = "${local.name} app"
  }

  autoinclude {
    dependency "bucket" {
      config_path = unit.bucket.path

      mock_outputs = {
        name = "mock-bucket"
      }
    }

    # ... the `database` and `registry` dependencies ...

    inputs = {
      bucket_roles = {
        object_viewer = {
          bucket = dependency.bucket.outputs.name
          role   = "roles/storage.objectViewer"
        }
      }

      # ... the `repository_roles` and `project_roles` grants ...
    }
  }
}
```

- `config_path = unit.bucket.path` resolves to the generated directory of the `bucket` unit, so you never compute relative paths like `../bucket` by hand. If you rename or relocate a unit, the reference follows it automatically.
- `mock_outputs` provide placeholder values so that a `plan` succeeds before the dependencies have been applied.

When you run `terragrunt stack generate`, Terragrunt writes each declared dependency into a `terragrunt.autoinclude.hcl` file next to the generated unit, then merges it into that unit whenever the unit is run. As a result, the catalog units stay free of any knowledge about where their dependencies live: the `service-account` unit simply consumes `bucket_roles`, and the stack decides which `bucket` unit satisfies that dependency.

This is the [stacks dependencies](https://terragrunt.gruntwork.io/docs/features/stacks/explicit/#declaring-dependencies-between-units) feature, which is enabled by default in Terragrunt `v1.1.0` and later.

## What to do with `.terraform.lock.hcl` files

When you run `terragrunt` commands you may find that `.terraform.lock.hcl` files are created in your working directories.

These files are intentionally not committed to this example repository, but definitely should be in your own repositories!

They help make sure that your IaC results in reproducible infrastructure. For more on this, read [Lock File Handling docs](https://docs.terragrunt.com/features/units/lock-files/).

## How to get help

If you need help troubleshooting usage of this repository, or Terragrunt in general, check out the [Support docs](https://terragrunt.gruntwork.io/docs/community/support/).
