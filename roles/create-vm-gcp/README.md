# create-vm

Ansible role for creating Google Cloud Platform (GCP) virtual machine instances with custom VPC networking.

## Purpose

This role is designed to:

- Create a VPC network with custom configuration (optional)
- Set up firewall rules for the VPC (SSH and internal traffic)
- Deploy a GCP VM instance with specified configuration
- Configure SSH access using public key authentication
