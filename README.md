# Nomad & Consul: Single-Node Infrastructure Setup

## Project Overview

This project demonstrates the installation, configuration, and integration of HashiCorp Nomad and Consul in a single-node Ubuntu environment running on WSL2.

Nomad is configured as both a server and client, while Consul provides service discovery and service registration. Docker Desktop is integrated with WSL2 to enable containerized workload execution through Nomad.

## Objectives

- Install and configure HashiCorp Nomad.
- Install and configure HashiCorp Consul.
- Configure Nomad in single-node server and client mode.
- Integrate Nomad with Consul.
- Enable Docker integration with WSL2.
- Deploy and execute a Docker workload through Nomad.
- Verify cluster health, service registration, and workload execution.

## Technology Stack

| Component | Version |
|---|---|
| OS | Ubuntu 26.04 LTS (WSL2) |
| Consul | 2.1.0 |
| Nomad | 2.1.1 |
| Docker Engine | 29.8.2 |
| Docker Desktop | 4.95.0 |
| Git | Git & GitHub |

## Architecture

The single-node environment contains:

- Consul Server
- Nomad Server
- Nomad Client
- Docker Engine
- Nomad Docker Driver

Nomad and Consul communicate through local network addresses.

## Implementation

### Phase 01 – Environment Preparation
- Prepared Ubuntu environment using WSL2.
- Updated system packages.
- Installed required dependencies.
- Configured HashiCorp APT repository.

### Phase 02 – Consul Installation
- Installed Consul.
- Configured a single-node Consul server.
- Set `bootstrap_expect = 1`.
- Configured data directory and network addresses.
- Enabled Consul Web UI.
- Configured and enabled systemd service.

### Phase 03 – Consul Verification
- Verified Consul service status.
- Verified cluster membership.
- Verified Raft leader election.
- Confirmed Consul HTTP API accessibility.

### Phase 04 – Nomad Installation & Configuration
- Installed Nomad.
- Configured Nomad as both server and client.
- Set `bootstrap_expect = 1`.
- Integrated Nomad with Consul.
- Enabled and started Nomad systemd service.
- Verified Nomad server membership and client node readiness.
- Verified Nomad Raft leadership.
- Enabled Docker Desktop WSL2 integration.
- Verified Nomad Docker driver health.

### Phase 05 – Docker Workload Deployment
- Created a Nomad batch job specification.
- Validated the job configuration.
- Submitted the job using `nomad job run`.
- Successfully created a Nomad allocation.
- Executed `hello-world:latest` through the Docker driver.
- Verified successful task completion.
- Confirmed the output: `Hello from Docker!`

## Docker Workload

Job specification: `jobs/hello-world.nomad.hcl`

Run the job:

```bash
nomad job validate jobs/hello-world.nomad.hcl
nomad job run jobs/hello-world.nomad.hcl
```

Check job status:

```bash
nomad job status docker-hello-world
```

View allocation logs:

```bash
nomad alloc logs 37f50c21 hello-world
```

Expected output:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

## Verification Results

| Verification | Result |
|---|---|
| Consul service | Active |
| Consul Raft leader | Verified |
| Nomad service | Active |
| Nomad server | Alive |
| Nomad client | Ready |
| Nomad Raft leader | Verified |
| Consul service registration | Verified |
| Docker Engine | Working |
| Nomad Docker driver | Healthy |
| Docker workload | Completed |
| Hello World output | Successful |
| Nomad Web UI | Accessible |
| Consul Web UI | Accessible |

## Web UI Access

| Service | URL |
|---|---|
| Nomad UI | http://127.0.0.1:4646/ui/ |
| Consul UI | http://127.0.0.1:8500/ui/ |

## Screenshots

Implementation evidence is available in the `screenshots/` directory:

- `02-environment-setup/` – Environment preparation.
- `03-consul-installation/` – Consul installation and verification.
- `04-nomad-installation/` – Nomad installation, Docker integration, workload deployment, and verification.

## Current Project Status

**Completed:**
- Environment preparation.
- Consul installation and configuration.
- Nomad installation and configuration.
- Nomad–Consul integration.
- Docker Desktop WSL2 integration.
- Nomad Docker driver verification.
- Docker workload deployment and execution.

## Notes

This project is intended for learning and practical demonstration in a single-node environment. It is not a production-ready highly available deployment.

TLS and ACL security configurations have not been implemented.

## Author

**Tahsinul Hoque Siddiki**

GitHub: https://github.com/tahsinulhoque