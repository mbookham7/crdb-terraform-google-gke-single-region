variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "region_1" {
  description = "The GCP Region in which all resources in this example should be provisioned"
}

variable "location_1" {
  description = "First Avalibility Zone"
}

variable "location_2" {
  description = "Second Avalibility Zone"
}

variable "location_1_vnet_address_space" {
  description = "The GCP VNET address space for first location"
  default = "10.1.0.0/18"
}


variable "location_1_gke_pod_subnet" {
  description = "The GKE pod address space for first location"
  default = "10.1.64.0/18"
}

variable "location_1_gke_service_subnet" {
  description = "The GKE Service address space for first location"
  default = "10.1.128.0/18"
}

variable "gke_cluster_name" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "crdb-gke-cluster"
}

variable "gke_pool_name" {
  description = "GKE Node Pool Nmae"
  default = "nodepool"
}

variable "gke_vm_size" {
  description = "Node Pool Instance Size"
  default = "e2-standard-8"
}

variable "gke_node_count" {
  description = "Node Pool Instance Count"
  default = 3
}

variable "cockroachdb_version" {
  description = "CockroachDB Version"
  default = "v23.1.2"
}

variable "cockroachdb_pod_cpu" {
  description = "Number of CPUs per CockroachDB Pod"
  default = "4"
}

variable "cockroachdb_pod_memory" {
  description = "Amount of Memory per CockroachDB Pod"
  default = "8Gi"
}

variable "cockroachdb_storage" {
  description = "Persistent Volume Size in GB"
  default = "50Gi"
}

variable "statfulset_replicas" {
  description = "Number of replicas in the CockraochDB StatefulSet"
  default = 3
}