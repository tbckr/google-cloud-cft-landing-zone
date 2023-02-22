locals {
  activate_apis          = distinct(concat(var.activate_apis, ["billingbudgets.googleapis.com"]))
  cicd_project_iam_roles = [
	"roles/iam.serviceAccountAdmin",
	"roles/iam.workloadIdentityPoolAdmin",
  ]
  sa_mapping = {
	for sa, sa_obj in var.terraform_sa_names : sa => {
	  sa_name   = sa_obj.full_name
	  attribute = "attribute.repository/${var.github_repos[sa]}"
	}
  }
}

module "cicd_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.1"

  name                        = var.project_name
  random_project_id           = true
  org_id                      = var.org_id
  folder_id                   = var.folder_id
  billing_account             = var.billing_account
  budget_alert_spent_percents = var.budget_alert_spent_percents
  budget_amount               = var.budget_amount
  create_project_sa           = false
  default_service_account     = "disable"
  labels                      = var.project_labels
  activate_apis               = local.activate_apis
}

resource "google_project_iam_member" "cicd_project_org_admins_iam" {
  for_each = toset(local.cicd_project_iam_roles)
  project  = module.cicd_project.project_id
  role     = each.value
  member   = "group:${var.group_org_admins}"
}

resource "google_project_iam_member" "cicd_project_bootstrap_iam" {
  for_each = toset(local.cicd_project_iam_roles)
  project  = module.cicd_project.project_id
  role     = each.value
  member   = "serviceAccount:${var.terraform_sa_names["bootstrap"].email}"
}

module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = module.cicd_project.project_id
  pool_id     = var.wif_pool_id
  provider_id = var.wif_provider_id
  sa_mapping  = local.sa_mapping
}
