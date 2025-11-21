# exporters
Ansible playbooks for deploying dedicated VMs to run Jumpstarter exporters

## GCP VM Instance Creation

This Ansible playbook automates the creation of a VM instance on Google Cloud Platform (GCP) with a custom VPC, firewall rules, and persistent disks.

### Features

- Creates a custom VPC network with subnet
- Configures firewall rules:
  - Allow SSH (22), HTTP (80), HTTPS (443) from the internet
  - Allow all internal traffic within the subnet
  - Allow all egress traffic
- Provisions a VM instance with:
  - Instance type: c4a-highmem-96-metal
  - RHEL 10 operating system (configurable)
  - Boot disk
  - Additional data disk

### Prerequisites

1. **Python Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **GCP Service Account**
   - Create a service account in your GCP project
   - Grant necessary permissions:
     - Compute Admin
     - Service Account User
   - Download the JSON key file

3. **Environment Setup**
   ```bash
   export GCP_SERVICE_ACCOUNT_FILE="/path/to/your/service-account-key.json"
   ```

4. **Ansible Collection**
   ```bash
   ansible-galaxy collection install google.cloud
   ```

### Configuration

1. Copy the example variables file:
   ```bash
   cp example_vars.yml my_vars.yml
   ```

2. Edit `my_vars.yml` with your specific values:
   - `gcp_project`: Your GCP project ID
   - `gcp_region`: Desired GCP region
   - `gcp_zone`: Desired GCP zone
   - `vm_name`: Name for your VM instance
   - Other customizations as needed

3. Customize default values in `roles/create-vm/defaults/main.yml` if needed

### Usage

#### Create VM Instance

```bash
ansible-playbook 1_create_vm.yml -e @my_vars.yml
```

#### Delete VM Instance and Resources

```bash
ansible-playbook 1_create_vm.yml -e @my_vars.yml -e "ACTION=UNINSTALL"
```

### Directory Structure

```
.
├── 1_create_vm.yml              # Main playbook
├── example_vars.yml             # Example variables file
├── requirements.txt             # Python dependencies
└── roles/
    └── create-vm/
        ├── defaults/
        │   └── main.yml         # Default variables
        ├── tasks/
        │   ├── main.yml         # Main task orchestration
        │   ├── install.yml      # Installation tasks
        │   └── uninstall.yml    # Cleanup tasks
        ├── files/               # Static files
        └── templates/           # Jinja2 templates
```

### Variables Reference

#### Core Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `gcp_project` | GCP project ID | `your-gcp-project-id` |
| `gcp_region` | GCP region | `us-central1` |
| `gcp_zone` | GCP zone | `us-central1-a` |
| `vm_name` | VM instance name | `rhel10-vm-instance` |
| `vm_machine_type` | Instance type | `c4a-highmem-96-metal` |

#### Network Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `vpc_name` | VPC network name | `custom-vpc` |
| `subnet_name` | Subnet name | `custom-subnet` |
| `subnet_cidr` | Subnet CIDR range | `10.0.0.0/24` |

#### Disk Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `boot_disk_size_gb` | Boot disk size in GB | `100` |
| `boot_disk_type` | Boot disk type | `pd-balanced` |
| `data_disk_name` | Data disk name | `data-disk` |
| `data_disk_size_gb` | Data disk size in GB | `500` |
| `data_disk_type` | Data disk type | `pd-balanced` |

#### Image Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `os_image_project` | OS image project | `rhel-cloud` |
| `os_image_family` | OS image family | `rhel-9` |

### Firewall Rules

The playbook creates three firewall rules:

1. **allow-ssh-http-https**: Allows inbound SSH, HTTP, and HTTPS from 0.0.0.0/0
2. **allow-internal**: Allows all TCP/UDP/ICMP traffic within the subnet
3. **allow-all-egress**: Allows all outbound traffic

### Notes

- **RHEL 10**: Currently using RHEL 9 as RHEL 10 may not be generally available. Update `os_image_family` to `rhel-10` when available.
- **Machine Type**: The `c4a-highmem-96-metal` instance type is a high-performance, bare metal instance. Ensure it's available in your selected zone.
- **Costs**: This configuration can incur significant GCP costs. Monitor your usage and delete resources when not needed.
- **Data Disk**: The data disk has `auto_delete: false` to prevent accidental data loss. Delete manually if needed.

### Troubleshooting

#### Authentication Issues
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
export GCP_SERVICE_ACCOUNT_FILE="/path/to/service-account-key.json"
```

#### Check Available Machine Types
```bash
gcloud compute machine-types list --zones=us-central1-a --filter="name:c4a-highmem-96-metal"
```

#### List Available RHEL Images
```bash
gcloud compute images list --project=rhel-cloud --filter="family:rhel-9"
```
