# Google Cloud Infrastructure Deployment with Terraform

This Terraform configuration deploys a simple Google Cloud infrastructure with the following components:

- **Virtual Private Cloud (VPC):** Defines a custom VPC named `case-vpc` with auto-created subnets disabled.

- **Subnetworks:**
  - `public_subnet`: A subnetwork named `case-subnet` with IP range `10.10.0.0/24` in the `us-central1` region.
  - `private_subnet`: A subnetwork named `private-subnet` with IP range `10.10.96.0/24` in the `us-central1` region.

- **Firewall Rules:**
  - `allow_internal`: Allows all protocols within the `10.10.0.0/16` range for internal communication.
  - `allow_1194`: Allows TCP traffic on port `1194` from any source.

- **Compute Instances:**
  - `k8s-master`: Represents a Kubernetes master node with Ubuntu 20.04 LTS, `e2-standard-2` machine type, and located in `us-central1-a`.
  - `k8s-worker`: Represents a Kubernetes worker node with similar specifications in `us-central1-b`.
  - `vpn_instance` (OpenVPN): Represents an instance named `openvpn` with Ubuntu 20.04 LTS, `e2-standard-2` machine type, and located in `us-central1-c`. This instance is tagged for specific firewall rules.

- **Router and NAT Configuration:**
  - `router`: Defines a router named `nat-router` associated with the `case-vpc` network in `us-central1`.
  - `nat`: Configures Network Address Translation (NAT) for the router, allowing all subnetworks and IP ranges.

## Prerequisites

Before running this Terraform configuration, ensure you have the following:

1. [Terraform](https://www.terraform.io/) installed on your machine.
2. Google Cloud Platform (GCP) account and project.
3. Service account credentials JSON file with the necessary permissions. Create the `credentials.json` file and update path in the `main.tf` file.

## Usage

Clone this repository:

```bash
git  https://github.com/ahmetucan/terraform-gcp.git
cd terraform-gcp```

Update the main.tf file:

Set the correct path to your GCP service account credentials file.
Adjust project details, region, and other parameters as needed.
Initialize Terraform:

```bash
terraform init```
Review the execution plan:

```bash
terraform plan```
Apply the Terraform configuration:

```bash
terraform apply```
Type yes when prompted to confirm the changes.

Terraform will provision the specified infrastructure on GCP.

Cleanup
To destroy the created resources and avoid unnecessary charges, run:

```bash
terraform destroy```
Type yes when prompted.

Notes
Ensure your GCP project has the necessary API services enabled.
Review the firewall rules, instance specifications, and other configurations to meet your requirements.
This configuration is for educational purposes and may require adjustments for production use.
Feel free to customize this Terraform configuration according to your specific needs and best practices.
