#!/bin/bash

# Simple script to create a VM instance on Google Cloud Platform

source .env

# Configuration - modify these values
#PROJECT_ID="rhauto-dev"
#ZONE="us-central1-c"

#INSTANCE_NAME="rhauto-dev"
#NETWORK="rhauto-net"  # VPC network name (or leave empty for default)
#SUBNET=""  # Subnet name (optional, will use default subnet if not specified)

#SSH_USERNAME="rhas"  # Username for SSH access
#SSH_KEY_PATH="$HOME/.ssh/auto1-gcp.pub"  # Path to your SSH public key

MACHINE_TYPE="c4a-highmem-96-metal"

IMAGE_FAMILY="rhel-10-arm64" # rhel-9-arm64 
IMAGE_PROJECT="rhel-cloud" 

BOOT_DISK_SIZE="20GB"
DATA_DISK_SIZE="250GB"

# Set the project
gcloud config set project "$PROJECT_ID"

# Create VPC network if it doesn't exist
if [ -n "$NETWORK" ]; then
    echo "Checking if VPC network '$NETWORK' exists..."
    if ! gcloud compute networks describe "$NETWORK" --project="$PROJECT_ID" &> /dev/null; then
        echo "VPC network '$NETWORK' not found. Creating..."
        gcloud compute networks create "$NETWORK" \
            --project="$PROJECT_ID" \
            --subnet-mode=auto \
            --bgp-routing-mode=regional
        
        echo "VPC network '$NETWORK' created successfully!"
        
        # Create basic firewall rules
        echo "Creating firewall rules..."
        
        # Allow internal traffic
        gcloud compute firewall-rules create "$NETWORK-allow-internal" \
            --project="$PROJECT_ID" \
            --network="$NETWORK" \
            --allow=tcp:0-65535,udp:0-65535,icmp \
            --source-ranges=10.128.0.0/9
        
        # Allow SSH
        gcloud compute firewall-rules create "$NETWORK-allow-ssh" \
            --project="$PROJECT_ID" \
            --network="$NETWORK" \
            --allow=tcp:22 \
            --source-ranges=0.0.0.0/0
        
        echo "Firewall rules created successfully!"
    else
        echo "VPC network '$NETWORK' already exists."
    fi
fi

# Prepare SSH key metadata
SSH_METADATA=""
if [ -f "$SSH_KEY_PATH" ]; then
    echo "Adding SSH public key from $SSH_KEY_PATH..."
    SSH_KEY_CONTENT=$(cat "$SSH_KEY_PATH")
    SSH_METADATA="ssh-keys=${SSH_USERNAME}:${SSH_KEY_CONTENT}"
fi

# Build network-interface flag
NETWORK_INTERFACE="nic-type=IDPF"
if [ -n "$NETWORK" ]; then
    NETWORK_INTERFACE="$NETWORK_INTERFACE,network=$NETWORK"
fi
if [ -n "$SUBNET" ]; then
    NETWORK_INTERFACE="$NETWORK_INTERFACE,subnet=$SUBNET"
fi

# Create the VM instance
gcloud compute instances create "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --maintenance-policy="TERMINATE" \
    --machine-type="$MACHINE_TYPE" \
    --boot-disk-size="$BOOT_DISK_SIZE" \
    --create-disk="size=$DATA_DISK_SIZE" \
    --network-interface="$NETWORK_INTERFACE" \
    --image-family="$IMAGE_FAMILY" \
    --image-project="$IMAGE_PROJECT" \
    --metadata="$SSH_METADATA"

echo "VM instance '$INSTANCE_NAME' created successfully!"

# ,type=pd-balanced,auto-delete=yes