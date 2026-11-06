# Nomad & Consul: Single-Node Infrastructure Setup

**Project:** DEVOPS-1  
**Author:** Tahsinul Hoque Siddiki  
**GitHub:** https://github.com/tahsinulhoque/nomad-consul-single-node

---

## 1. Project Overview

This project demonstrates the installation, configuration, and integration of HashiCorp Nomad and Consul in a single-node Linux environment using Ubuntu 26.04 LTS on WSL2.

Nomad is configured to operate as both a server and client on the same machine. Consul runs as a single-node server and provides service discovery and service registration for Nomad.

Docker Desktop is integrated with WSL2 to enable Nomad to execute containerized workloads through its Docker task driver.

The primary objective is to establish a working single-node Nomad and Consul environment and verify that both services communicate properly.

## 2. Project Objectives

- Install and configure HashiCorp Nomad in single-node mode.
- Install and configure HashiCorp Consul in single-node mode.
- Configure Nomad as both server and client.
- Integrate Nomad with Consul.
- Enable and access the Nomad Web UI.
- Enable and access the Consul Web UI.
- Verify service registration and cluster leadership.
- Test Docker integration through a Nomad batch workload.

## 3. Environment & Technology Stack

| Component | Version / Configuration |
|---|---|
| Host OS | Windows |
| Linux Environment | Ubuntu 26.04 LTS |
| Linux Subsystem | WSL2 |
| Consul | 2.1.0 |
| Nomad | 2.1.1 |
| Docker Desktop | 4.95.0 |
| Docker Engine | 29.8.2 |
| Architecture | AMD64 |
| CPU | 8 cores |
| Memory | Approximately 3.7 GiB |

### Resource Considerations

The environment was configured as a single-node infrastructure with limited resources.

Both Nomad server and client processes run on the same machine. Consul also operates as a single-node server.

This approach demonstrates the orchestration and service discovery workflow without requiring multiple virtual machines.

## 4. Architecture

The environment consists of the following components:

- Consul Server: Service discovery and service registration.
- Nomad Server: Scheduling, cluster management, and leader election.
- Nomad Client: Executes scheduled workloads.
- Docker Engine: Container runtime.
- Nomad Docker Driver: Executes Docker containers through Nomad.

### Service Endpoints

| Component | Address |
|---|---|
| Consul HTTP API | 127.0.0.1:8500 |
| Consul DNS | 127.0.0.1:8600 |
| Nomad HTTP API | 127.0.0.1:4646 |
| Nomad RPC | 127.0.0.1:4647 |
| Nomad Serf | 127.0.0.1:4648 |

## 5. Implementation Guide

### Phase 01 – Environment Preparation

**Step 1: Install and access Ubuntu through WSL2**

From Windows PowerShell:

```powershell
wsl --install -d Ubuntu
wsl -l -v
wsl -d Ubuntu
```

**Step 2: Update Ubuntu**

Inside the Ubuntu terminal:

```bash
sudo apt update
sudo apt upgrade -y
```

**Step 3: Install required dependencies**

```bash
sudo apt install -y \
  curl \
  wget \
  unzip \
  gnupg \
  lsb-release \
  ca-certificates \
  apt-transport-https
```

**Step 4: Verify the environment**

```bash
uname -a
lsb_release -a
free -h
nproc
```

### Phase 02 – HashiCorp Repository Setup

The HashiCorp APT repository was configured to install Nomad and Consul.

**Step 1: Add the HashiCorp GPG key**

```bash
wget -O- https://apt.releases.hashicorp.com/gpg \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

**Step 2: Verify the GPG fingerprint**

```bash
gpg --no-default-keyring \
  --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  --fingerprint
```

Verified fingerprint:

```text
D55C 0D1A C78A 8D81 26CB 631C FC9C A96A CA02 6560
```

**Step 3: Add the repository**

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

**Step 4: Update package information**

```bash
sudo apt update
```

### Phase 03 – Consul Installation & Configuration

**Step 1: Install Consul**

```bash
sudo apt install -y consul
```

Verify the installation:

```bash
consul version
apt-cache policy consul
```

Installed version: `Consul v2.1.0`

**Step 2: Back up the default configuration**

```bash
sudo cp /etc/consul.d/consul.hcl \
  /etc/consul.d/consul.hcl.backup
```

**Step 3: Create the Consul configuration**

```bash
sudo nano /etc/consul.d/consul.hcl
```

Configuration:

```hcl
datacenter = "dc1"
node_name  = "consul-server-1"
data_dir   = "/opt/consul"

server           = true
bootstrap_expect = 1

bind_addr      = "127.0.0.1"
advertise_addr = "127.0.0.1"
client_addr    = "127.0.0.1"

ui_config {
  enabled = true
}

log_level = "INFO"
```

**Step 4: Prepare the data directory**

```bash
sudo install -d \
  -o consul \
  -g consul \
  -m 0750 \
  /opt/consul
```

**Step 5: Validate the Consul configuration**

```bash
sudo consul validate /etc/consul.d/
```

Expected result:

```text
Configuration is valid!
```

**Step 6: Enable Consul at startup**

```bash
sudo systemctl enable consul
sudo systemctl start consul
```

Check the service:

```bash
sudo systemctl status consul
```

**Step 7: Configure the systemd service override**

During the initial setup, Consul's default systemd notification behavior did not reach the active state as expected, although the agent was operational.

A systemd override was configured:

```bash
sudo mkdir -p /etc/systemd/system/consul.service.d
sudo nano /etc/systemd/system/consul.service.d/override.conf
```

Override content:

```ini
[Service]
Type=simple
```

Apply the change:

```bash
sudo systemctl daemon-reload
sudo systemctl restart consul
```

Verify:

```bash
sudo systemctl status consul
```

Expected state:

```text
Active: active (running)
```

**Step 8: Verify Consul cluster membership**

```bash
consul members
```

**Step 9: Verify Consul Raft leadership**

```bash
consul operator raft list-peers
```

**Step 10: Verify the Consul HTTP API**

```bash
curl -sS http://127.0.0.1:8500/v1/status/leader
```

Expected output:

```text
"127.0.0.1:8300"
```

### Phase 04 – Nomad Installation & Configuration

**Step 1: Install Nomad**

```bash
sudo apt install -y nomad
```

Verify:

```bash
nomad version
```

Installed version: `Nomad v2.1.1`

**Step 2: Back up the default configuration**

```bash
sudo cp /etc/nomad.d/nomad.hcl \
  /etc/nomad.d/nomad.hcl.backup
```

**Step 3: Prepare the Nomad data directory**

```bash
sudo install -d \
  -o nomad \
  -g nomad \
  -m 0750 \
  /opt/nomad/data
```

**Step 4: Configure Nomad**

```bash
sudo nano /etc/nomad.d/nomad.hcl
```

Configuration:

```hcl
datacenter = "dc1"
data_dir   = "/opt/nomad/data"
bind_addr  = "127.0.0.1"

advertise {
  http = "127.0.0.1"
  rpc  = "127.0.0.1"
  serf = "127.0.0.1"
}

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
  servers = ["127.0.0.1"]
}

consul {
  address = "127.0.0.1:8500"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}
```

This configuration enables:

- Nomad server mode.
- Nomad client mode.
- Single-node Raft bootstrap.
- Local HTTP, RPC, and Serf addresses.
- Consul service registration and automatic discovery.

**Step 5: Enable Nomad at startup**

```bash
sudo systemctl enable nomad
sudo systemctl start nomad
```

Check the service:

```bash
sudo systemctl status nomad
```

**Step 6: Verify Nomad server membership**

```bash
nomad server members
```

**Step 7: Verify the Nomad client node**

```bash
nomad node status
```

**Step 8: Verify Nomad Raft leadership**

```bash
nomad operator raft list-peers
```

**Step 9: Verify Consul integration**

```bash
consul catalog services
```

Expected registered services include:

```text
consul
nomad
nomad-client
```

**Step 10: Verify Nomad node details and Docker driver**

```bash
nomad node status -self -verbose
```

Expected Docker driver status:

```text
Driver    Detected  Healthy  Message
docker    true      true     Healthy
```

### Phase 05 – Docker Desktop Integration

Docker Desktop was integrated with the Ubuntu WSL2 environment.

**Step 1: Enable WSL integration**

In Docker Desktop:

1. Open Settings.
2. Navigate to Resources → WSL Integration.
3. Enable integration for Ubuntu.
4. Apply changes and restart Docker Desktop.

**Step 2: Verify Docker connectivity**

```bash
docker version
```

**Step 3: Verify Docker socket**

```bash
ls -l /var/run/docker.sock
```

**Step 4: Test Docker**

```bash
docker run hello-world
```

Expected output:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

**Step 5: Grant Docker group access to the Nomad service account**

Initially, the Nomad service account did not have permission to access the Docker socket.

Add Nomad to the Docker group:

```bash
sudo usermod -aG docker nomad
```

Verify:

```bash
id nomad
```

Restart Nomad:

```bash
sudo systemctl restart nomad
```

Verify Docker driver health:

```bash
nomad node status -self -verbose
```

### Phase 06 – Docker Workload Deployment Through Nomad

A batch job was created to verify that Nomad could execute a Docker container.

**Step 1: Create the jobs directory**

```bash
mkdir -p jobs
```

**Step 2: Create the job specification**

```bash
nano jobs/hello-world.nomad.hcl
```

Job configuration:

```hcl
job "docker-hello-world" {
  datacenters = ["dc1"]
  type        = "batch"

  group "hello-world" {
    task "hello-world" {
      driver = "docker"

      config {
        image      = "hello-world:latest"
        force_pull = false
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
```

**Step 3: Validate the job**

```bash
nomad job validate jobs/hello-world.nomad.hcl
```

Expected result:

```text
Job validation successful
```

**Step 4: Submit the job**

```bash
nomad job run jobs/hello-world.nomad.hcl
```

**Step 5: Check job status**

```bash
nomad job status docker-hello-world
```

Expected successful state:

```text
Status: dead
Complete: 1
Failed: 0
```

For a batch job, `dead` is the terminal job status after successful completion. The allocation status should be `complete`.

**Step 6: Find the allocation ID**

```bash
nomad job allocs docker-hello-world
```

**Step 7: Check allocation details**

Replace `<ALLOCATION_ID>` with the actual allocation ID:

```bash
nomad alloc status <ALLOCATION_ID>
```

**Step 8: View task logs**

```bash
nomad alloc logs <ALLOCATION_ID> hello-world
```

Verified output:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

This confirms that Nomad successfully scheduled and executed a Docker container.

---

## 6. Web UI Access

### Nomad Web UI

URL:

http://127.0.0.1:4646/ui/

The Nomad UI was verified, including the server and client views.

### Consul Web UI

URL:

http://127.0.0.1:8500/ui/

The Consul UI is enabled in the Consul configuration.

---

## 7. Verification Results

| Verification | Result |
|---|---|
| Consul systemd service | Active |
| Consul cluster membership | Verified |
| Consul Raft leader | Verified |
| Consul HTTP API | Accessible |
| Nomad systemd service | Active |
| Nomad server membership | Verified |
| Nomad client node | Ready |
| Nomad Raft leader | Verified |
| Nomad services in Consul | Registered |
| Nomad Web UI | Accessible |
| Consul Web UI | Accessible |
| Docker Engine | Working |
| Nomad Docker driver | Healthy |
| Docker batch workload | Complete |
| Hello World output | Verified |

## 8. Troubleshooting & Issues Resolved

This section documents the actual issues encountered during implementation and their resolutions.

### Issue 1: WSL Ubuntu Password Problem

**Problem:** The Linux user password was not available for sudo authentication.

**Resolution:** Reset the Ubuntu user password from Windows PowerShell:

```powershell
wsl -d Ubuntu -u root
```

Inside the root shell:

```bash
passwd dcl
```

Set a new password and return to the normal Ubuntu user.

**Note:** This changes the Linux user password, not the Windows account password or Windows PIN.

### Issue 2: Consul systemd Service Not Reaching Active State

**Problem:** The Consul agent was operational, but the systemd service remained in the activating state.

**Resolution:** Created a systemd override:

```ini
[Service]
Type=simple
```

Then applied it:

```bash
sudo systemctl daemon-reload
sudo systemctl restart consul
sudo systemctl status consul
```

The service subsequently reached `active (running)`.

### Issue 3: Docker Command Not Found in Ubuntu

**Problem:** Docker was available in Windows, but the Ubuntu WSL environment could not access the Docker CLI or socket.

**Resolution:**

1. Open Docker Desktop.
2. Navigate to Settings → Resources → WSL Integration.
3. Enable Ubuntu integration.
4. Apply changes and restart Docker Desktop.
5. Verify:

```bash
docker version
ls -l /var/run/docker.sock
```

### Issue 4: Nomad Docker Driver Could Not Access Docker

**Problem:** The Nomad service account was not initially a member of the Docker group.

**Resolution:**

```bash
sudo usermod -aG docker nomad
sudo systemctl restart nomad
```

Verify:

```bash
id nomad
nomad node status -self -verbose
```

The Docker driver was subsequently detected and reported healthy.

### Issue 5: Nomad Docker Driver Not Appearing in CSI Plugin Status

**Problem:** Running:

```bash
nomad plugin status
```

displayed:

```text
Container Storage Interface
No CSI plugins
```

**Explanation:** This command displayed CSI plugin information. The Docker driver is a task driver, not a CSI storage plugin.

**Correct verification command:**

```bash
nomad node status -self -verbose
```

Check the Drivers section for:

```text
docker    true    true    Healthy
```

### Issue 6: Nomad Agent `-validate` Flag Not Supported

**Problem:** Attempted to validate the Nomad agent configuration using:

```bash
nomad agent -config=/etc/nomad.d/ -validate
```

Nomad returned:

```text
flag provided but not defined: -validate
```

**Explanation:** In the installed Nomad version (2.1.1), this agent command does not support the `-validate` flag.

**Resolution:** The configuration was loaded successfully by starting the Nomad agent with the configuration, and the running service was verified through:

```bash
sudo systemctl status nomad
nomad server members
nomad node status
nomad operator raft list-peers
```

### Issue 7: Address Already in Use When Starting a Second Nomad Agent

**Problem:** Starting another Nomad agent using the example configuration returned:

```text
listen tcp 127.0.0.1:4647: bind: address already in use
```

**Explanation:** The existing Nomad systemd service was already using the RPC port 4647.

**Resolution:** No change was required to the running infrastructure. The existing service remained active. The second agent was not started because the port was already occupied.

### Issue 8: Consul Example File Extension

**Problem:** Running:

```bash
consul validate config/consul.hcl.example
```

returned an unknown file extension error.

**Resolution:** Explicitly specify the HCL configuration format:

```bash
sudo consul validate \
  -config-format=hcl \
  config/consul.hcl.example
```

Expected result:

```text
Configuration is valid!
```

### Issue 9: Consul Data Directory Permission Denied During Validation

**Problem:** Validating the example configuration as a normal user returned:

```text
Permission denied for data folder at "/opt/consul/mdb"
```

**Explanation:** The Consul data directory is owned by the Consul service account.

**Resolution:**

```bash
sudo consul validate \
  -config-format=hcl \
  config/consul.hcl.example
```

Validation succeeded.

**Important:** Existing data directory ownership and permissions were not changed to work around this validation issue.

### Issue 10: Windows and WSL Path Confusion

**Problem:** The Linux path `/mnt/c/...` was entered in Windows PowerShell, resulting in a path-not-found error.

**Resolution:**

From Windows PowerShell:

```powershell
cd C:\Users\DCL\Desktop\nomad-consul-single-node
wsl -d Ubuntu
```

Inside Ubuntu:

```bash
cd /mnt/c/Users/DCL/Desktop/nomad-consul-single-node
```

Use Windows paths in PowerShell and `/mnt/c/...` paths inside Ubuntu.

---

## 9. Important Technical Decisions

### Single-Node Architecture

A single machine was used to host both the Nomad server and client roles. This meets the project requirement while keeping resource consumption low.

### Bootstrap Expectation

Both Consul and Nomad use:

```hcl
bootstrap_expect = 1
```

This allows the respective single-node cluster to bootstrap without waiting for additional servers.

### Localhost Binding

The services were configured to use:

```text
127.0.0.1
```

This keeps the demonstration environment local to the WSL2 instance.

### Docker Desktop Integration

Docker Desktop was selected to provide a Docker Engine accessible from Ubuntu WSL2 without installing a separate Docker daemon inside the Ubuntu environment.

### Batch Workload

A batch job was selected because the Docker Hello World container executes once and exits. A batch workload is appropriate for this one-time execution test.

### Limited Resource Allocation

The Hello World task was configured with:

```hcl
resources {
  cpu    = 100
  memory = 64
}
```

This keeps the demonstration workload lightweight.

---

## 10. Repository Structure

```text
nomad-consul-single-node/
│
├── config/
│   ├── consul.hcl.example
│   └── nomad.hcl.example
│
├── jobs/
│   └── hello-world.nomad.hcl
│
├── screenshots/
│   ├── 02-environment-setup/
│   ├── 03-consul-installation/
│   └── 04-nomad-installation/
│
└── README.md
```

The `config/` directory contains example configuration files. The actual running service configurations are stored under `/etc/consul.d/` and `/etc/nomad.d/` inside Ubuntu.

## 11. Screenshots & Evidence

Screenshots documenting the implementation and verification are available in the `screenshots/` directory.

### Environment Setup

`02-environment-setup/`

### Consul Installation

`03-consul-installation/`

Evidence includes:

- HashiCorp GPG key verification.
- APT repository setup.
- Consul installation and version.
- Configuration validation.
- Service startup and leader election.
- Systemd service status.
- Cluster verification.

### Nomad Installation & Integration

`04-nomad-installation/`

Evidence includes:

- Nomad installation and version.
- Nomad systemd service.
- Nomad system data.
- Consul catalog services and nodes.
- Nomad Web UI.
- Docker Desktop WSL2 integration.
- Docker Hello World execution.
- Nomad Docker driver health.
- Nomad batch job completion.
- Nomad allocation logs.
- Nomad job Web UI.

## 12. Security Considerations & Limitations

This project is intended for local learning and practical demonstration.

The following production features were not configured:

- Nomad mutual TLS (mTLS).
- Consul TLS.
- Consul ACLs.
- Nomad ACLs.
- Multi-node high availability.
- Production network isolation.

The environment uses localhost addresses and single-node bootstrap settings. It should not be exposed as a production deployment without additional security and availability configuration.

## 13. Final Project Status

**Completed:**

- Ubuntu WSL2 environment preparation.
- HashiCorp repository configuration.
- Consul installation and configuration.
- Consul single-node server setup.
- Nomad installation and configuration.
- Nomad single-node server and client setup.
- Nomad and Consul integration.
- Consul and Nomad leader verification.
- Nomad and Consul Web UI access.
- Docker Desktop WSL2 integration.
- Nomad Docker driver verification.
- Docker workload deployment through Nomad.
- Batch job and allocation verification.
- Technical troubleshooting documentation.

## 14. Conclusion

The single-node HashiCorp Nomad and Consul infrastructure was successfully installed, configured, and verified.

Nomad operates as both a server and client, while Consul provides service registration and discovery. Both Web UIs are accessible through their default local ports.

The Docker integration test further demonstrates that Nomad can successfully schedule and execute a containerized workload.

The project meets the stated technical acceptance criteria for the DEVOPS-1 task.

---

**Author:** Tahsinul Hoque Siddiki  
**GitHub Repository:** https://github.com/tahsinulhoque/nomad-consul-single-node