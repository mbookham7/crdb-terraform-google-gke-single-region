#####################################
# Google Infrastructure             #
#####################################

# Enable APIs

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"

  disable_dependent_services=true
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"

#  disable_dependent_services = true
}

# Create a virtual Network

resource "google_compute_network" "main" {
  name                            = "main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

# Create subnets

resource "google_compute_subnetwork" "private" {
  name                     = "private"
  ip_cidr_range            = var.location_1_vnet_address_space
  region                   = var.region_1
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = var.location_1_gke_pod_subnet
  }
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = var.location_1_gke_service_subnet
  }
}

# Create a router

resource "google_compute_router" "router" {
  name    = "router"
  region  = var.region_1
  network = google_compute_network.main.id
}

# Create Cloud NAT

resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  region = var.region_1

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

resource "google_compute_address" "nat" {
  name         = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.compute]
}

# Create GKE Cluster


resource "google_container_cluster" "primary" {
  name                     = var.gke_cluster_name
  location                 = var.region_1
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.main.self_link
  subnetwork               = google_compute_subnetwork.private.self_link
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"

  # Optional, if you want multi-zonal cluster
  node_locations = [
    var.location_2
  ]

  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }
}

# Create Node Pool

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "general" {
  name       = var.gke_pool_name
  cluster    = google_container_cluster.primary.id
  node_count = var.gke_node_count

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = false
    machine_type = var.gke_vm_size

    labels = {
      role = var.gke_pool_name
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


