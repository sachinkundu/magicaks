variable resource_group_name { default = "k8s" }
variable "cluster_name" { }
variable location { default = "West Europe" }
variable ghuser { default = "sachinkundu" }
variable k8s_manifest_repo {}
variable k8s_workload_repo {}
variable pat {}
variable tenant_id {}
variable client_id {}
variable k8s_subnet_id {}
variable "app_name" { }