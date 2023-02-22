output "project_id" {
  value = module.cicd_project.project_id
}

output "wif_provider_name" {
  value = module.gh_oidc.provider_name
}
