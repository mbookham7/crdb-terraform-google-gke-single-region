provider "google" {
  project = "cockroach-bookham"
  region  = var.region_1

}

data "google_client_config" "current" {}

provider "kubernetes" {
  alias                  = "region_1"
  host                   = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "null" {
  # Configuration options
}

provider "tls" {
  # Configuration options
}

provider "time" {
  # Configuration options
}

