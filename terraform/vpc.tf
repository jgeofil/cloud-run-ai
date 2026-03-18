resource "google_compute_network" "n8n_network" {
  name                    = "n8n-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "n8n_subnet" {
  name          = "n8n-vpc-subnet-v3"
  ip_cidr_range = "10.8.2.0/28"
  region        = var.region
  network       = google_compute_network.n8n_network.id
}

# Connector resource (commented out per your request to avoid the Code 13 error for now)
/*
resource "google_vpc_access_connector" "n8n_connector" {
  name          = "n8n-connector"
  region        = var.region
  ip_cidr_range = "10.8.3.0/28"
  network       = google_compute_network.n8n_network.name
}
*/
