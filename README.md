# Nomad & Consul: Single-Node Infrastructure Setup

## Project Overview

This project demonstrates the installation, configuration, and integration of HashiCorp Nomad and Consul on a single Ubuntu Linux environment using WSL2.

Nomad is configured as both a server and client, while Consul provides service discovery and service registration for the Nomad cluster. Docker Desktop is integrated with WSL2 to enable Nomad's Docker task driver.

## Objectives

- Install and configure HashiCorp Consul.
- Install and configure HashiCorp Nomad.
- Configure Nomad in single-node server and client mode.
- Integrate Nomad with Consul.
- Enable Docker Desktop integration with WSL2.
- Verify Nomad's Docker driver.
- Access Nomad and Consul Web UIs.
- Deploy and test a sample Docker workload (next step).

## Technology Stack

| Component | Version / Environment |
|---|---|
| OS | Ubuntu 26.04 LTS (WSL2) |
| HashiCorp Consul | 2.1.0 |
| HashiCorp Nomad | 2.1.1 |
| Docker Engine | 29.8.2 |
| Docker Desktop | 4.95.0 |
| Git | Git & GitHub |

## Architecture

The project uses a single-node architecture:

- **Consul Agent:** Runs as a server and provides service discovery.
- **Nomad Server:** Manages scheduling and cluster leadership.
- **Nomad Client:** Executes workloads on the same node.
- **Docker Driver:** Allows Nomad to run containerized workloads through Docker.

Nomad and Consul communicate through the local environment.

## Installation and Configuration

### 1. Environment Setup

- Prepared Ubuntu on WSL2.
- Updated system packages.
- Installed required dependencies.
- Configured the HashiCorp APT repository.

### 2. Consul Setup

- Installed Consul.
- Configured a single-node Consul server.
- Set `bootstrap_expect = 1`.
- Configured the data directory and local network addresses.
- Enabled the Consul Web UI.
- Configured and enabled the systemd service.

### 3. Nomad Setup

- Installed Nomad.
- Configured Nomad as both server and client.
- Set `bootstrap_expect = 1`.
- Configured the data directory and local network addresses.
- Integrated Nomad with Consul.
- Enabled and started the Nomad systemd service.

### 4. Docker Integration

- Enabled Docker Desktop WSL2 integration for Ubuntu.
- Verified Docker Engine connectivity.
- Executed the Docker `hello-world` container successfully.
- Added the Nomad service account to the Docker group.
- Restarted Nomad and verified Docker driver health.

## Verification Results

| Verification | Result |
|---|---|
| Consul service status | Active |
| Consul cluster membership | Verified |
| Consul Raft leader | Verified |
| Nomad service status | Active |
| Nomad server membership | Verified |
| Nomad client node | Ready |
| Nomad Raft leader | Verified |
| Consul service registration | Verified |
| Docker Engine connectivity | Successful |
| Docker Hello World test | Successful |
| Nomad Docker driver | Healthy |
| Nomad Web UI | Accessible |
| Consul Web UI | Accessible |

## Web UI Access

| Service | URL |
|---|---|
| Nomad UI | http://127.0.0.1:4646/ui/ |
| Consul UI | http://127.0.0.1:8500/ui/ |

## Screenshots

Implementation evidence is available in the `screenshots/` directory.

- `02-environment-setup/` — Environment preparation.
- `03-consul-installation/` — Consul installation and verification.
- `04-nomad-installation/` — Nomad installation, cluster verification, Web UI, and Docker integration.

## Current Project Status

**Completed:**
- Environment preparation.
- Consul installation and configuration.
- Nomad installation and single-node configuration.
- Nomad–Consul integration.
- Docker Desktop WSL2 integration.
- Nomad Docker driver health verification.

**Pending:**
- Deploying a sample Docker workload through Nomad.
- Final end-to-end workload verification.
- Final documentation review.

## Notes

This is a single-node learning and practical implementation environment. It is not intended to represent a production-ready, highly available deployment.

Security features such as TLS and ACLs have not yet been configured.

## Author

**Tahsinul Hoque Siddiki**

GitHub: https://github.com/tahsinulhoque