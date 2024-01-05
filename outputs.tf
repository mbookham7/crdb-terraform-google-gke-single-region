### Region_1 Outputs

output "region" {
  value       = var.region_1
  description = "GCloud Region"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}
output "crdb_namespace_region_1" {
  value     = kubernetes_namespace_v1.ns_region_1.metadata[0].name
}