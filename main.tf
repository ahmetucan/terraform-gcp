provider "google" {
  credentials = file("path-to-credentials.json")
  project     = "project"
  region      = "us-central1"  
}

resource "google_compute_network" "my_vpc" {
  name                    = "case-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "case-subnet"
  ip_cidr_range = "10.10.0.0/24"  
  region        = "us-central1"
  network       = google_compute_network.my_vpc.self_link
}


resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.10.96.0/24"
  region        = "us-central1"
  network       = google_compute_network.my_vpc.self_link
}

# Create Firewall Rules for Communication
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.my_vpc.name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.10.0.0/16"]
  target_tags   = ["allow-internal"]
}

resource "google_compute_firewall" "allow_1194" {
  name    = "allow-1194"
  network = google_compute_network.my_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["1194"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-1194"]
}

resource "google_compute_instance" "k8s-master" {
  name         = "k8s-master"
  machine_type = "e2-standard-2"  
  zone         = "us-central1-a" 
  tags         = ["allow-internal"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
      size  = 40  
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.self_link
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get upgrade -y
  EOF

}

resource "google_compute_instance" "k8s-worker" {
  name         = "k8s-worker"
  machine_type = "e2-standard-2"  
  zone         = "us-central1-b" 
  tags         = ["allow-internal"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
      size  = 40 
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.self_link
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get upgrade -y
  EOF

}

resource "google_compute_instance" "vpn_instance" {
  name         = "openvpn"
  machine_type = "e2-standard-2"  
  zone         = "us-central1-c"  
  tags         = ["allow-1194","open-vpn-ssh-only-fw"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
      size  = 20  
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.self_link
    access_config {
      // Ephemeral IP address is automatically assigned
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get upgrade -y
  EOF
}

resource "google_compute_router" "router" {
  project = "project"
  name    = "nat-router"
  network = "case-vpc"
  region  = "us-central1"
}


resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = "us-central1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}