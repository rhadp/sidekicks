# create-vm

Ansible role for creating Google Cloud Platform (GCP) virtual machine instances with custom VPC networking.

## Purpose

This role is designed to:
- Create a VPC network with custom configuration (optional)
- Set up firewall rules for the VPC (SSH and internal traffic)
- Verify that VPC and VM resources don't already exist
- Deploy a GCP VM instance with specified configuration
- Configure SSH access using public key authentication

## Tasks

This role performs the following tasks:
- **Validation**: Checks that required variables are defined and validates resource existence
- **VPC Network Creation**: Creates a custom VPC with auto subnet mode and regional BGP routing
- **Firewall Rules**: Configures firewall rules for internal traffic and SSH access
- **SSH Key Setup**: Reads and configures SSH public key for VM access
- **VM Instance Creation**: Creates the VM with specified machine type, disks, and network configuration
- **Information Display**: Shows created VM details including IPs and network information

## Required Variables

These variables must be set via environment variables in a `.env` file:

- `PROJECT_ID`: GCP project ID where resources will be created
- `INSTANCE_NAME`: Name for the VM instance
- `ZONE`: GCP zone for the VM (e.g., us-central1-c)
- `NETWORK`: VPC network name (leave empty to use default network)
- `SSH_USERNAME`: Username for SSH access
- `SSH_KEY_PATH`: Path to SSH public key file

## Optional Variables

These variables have defaults in `defaults/main.yml`:

- `gcp_subnet_name`: Subnet name (default: empty, uses auto-created subnet)
- `gcp_machine_type`: Machine type (default: c4a-highmem-96-metal)
- `gcp_image_family`: OS image family (default: rhel-10-arm64)
- `gcp_image_project`: Image project (default: rhel-cloud)
- `gcp_boot_disk_size_gb`: Boot disk size in GB (default: 20)
- `gcp_data_disk_size_gb`: Data disk size in GB (default: 250)
- `gcp_nic_type`: Network interface card type (default: IDPF)
- `gcp_maintenance_policy`: Maintenance policy (default: TERMINATE)

## Usage

1. Create a `.env` file in the project root with required variables:
```bash
PROJECT_ID="your-gcp-project"
ZONE="us-central1-c"
INSTANCE_NAME="your-vm-name"
NETWORK="your-network-name"
SSH_USERNAME="your-username"
SSH_KEY_PATH="$HOME/.ssh/your-key.pub"
```

2. Run the playbook:
```bash
ansible-playbook 1_create_vm.yml
```

3. To uninstall/delete resources, set `ACTION: "UNINSTALL"` in the playbook vars.

## References

- [GCP Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [GCP VPC Documentation](https://cloud.google.com/vpc/docs)
- [gcloud compute instances create](https://cloud.google.com/sdk/gcloud/reference/compute/instances/create)
