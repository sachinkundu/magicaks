resource "kubernetes_namespace" "admin" {
  metadata {
    labels  = {created-by = "terraform"}
    name    = "admin"
  }
}

module flux {
  providers           = { kubernetes = kubernetes, helm = helm }
  source              = "./fluxfiles"
  github_user         = var.github_user
  admin_repo          = var.k8s_manifest_repo
  workload_repo       = var.k8s_workload_repo
}

# Upload keys only after a suitable delay
resource "time_sleep" "flux_admin" {
  create_duration = "120s"

  triggers = {
    admin_namespace  = module.flux.admin_namespace
  }
}

# Upload keys only after a suitable delay
resource "time_sleep" "flux_workloads" {
  create_duration = "120s"

  triggers = {
    workload_namespace  = module.flux.workload_namespace
  }
}

module github {
  source              = "./github"
  admin_repo          = var.k8s_manifest_repo
  workload_repo       = var.k8s_workload_repo
  admin_namespace     = time_sleep.flux_admin.triggers["admin_namespace"]
  workload_namespace  = time_sleep.flux_workloads.triggers["workload_namespace"]
  depends_on          = [ module.flux ]
}

module "servicebus" {
  source              = "./servicebus"
  cluster_name        = var.cluster_name
  location            = var.location
}

resource "azurerm_key_vault_secret" "sbconnectionstring" {
  name                = "servicebus-connectionstring"
  value               = module.servicebus.primary_connection_string
  key_vault_id        = var.key_vault_id

  provisioner "local-exec" {
    command = "${path.cwd}/../utils/expose-secret.sh ${self.name} ${var.key_vault_id} ${var.app_name}"
  }

  depends_on          = [module.flux]
}
