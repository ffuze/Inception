*This project has been created as part of the 42 curriculum by adegl-in.*

# Inception - System administration with Docker compose

**Inception** is a core system administration in the 42 curriculum path. Its main goal is to design, build, and deploy a fully autonomous, secure, multi-container infrastructure using **Docker Compose** on a virtualized Linux host environment. 

Instead of pulling pre-built, standard images from Docker Hub, this project strictly requires authoring custom `Dockerfiles` from scratch. The infrastructure represents a production-ready, three-tier web architecture consisting of:
* **NGINX**: A high-performance web server acting as the sole, encrypted entry point via a strict TLS reverse proxy.
* **WordPress**: A content management platform powered by PHP-FPM to dynamically process web scripts.
* **MariaDB**: A relational database engine tasked with securely storing and managing application metadata.

### Architectural Constraints & Security
To satisfy strict operational security requirements, all internal components (WordPress and MariaDB) are completely isolated within a dedicated, private Docker virtual network. They do not expose any ports directly to the host machine. The only public interface is NGINX, which accepts incoming traffic exclusively over HTTPS using port 443.

---

## Technical choices & Concept Comparisons

### Docker and Component Configuration
* **Operating System Base**: All images utilize **Debian Bookworm** as their core system baseline. This choice ensures access to stable package repositories (`php8.2-fpm`, `mariadb-server`, `nginx`) while ensuring compliance with modern enterprise deployment practices.
* **PID 1 Process Lifecycles**: To avoid creating zombie background processes, every service runs directly in the foreground. Scripted initialization entrypoints use the Bash `exec` directive to replace the shell process entirely with the program binary. This ensures that kernel shutdown signals (like `SIGTERM`) are caught directly by the daemon, guaranteeing a clean shutdown sequence when stopping containers.

### Virtual Machines vs Docker
* **Virtual Machines (VMs)**: Virtualize an entire computer hardware stack via a hypervisor. Each VM must embed a complete Guest Operating System, custom kernels, device drivers, and heavy memory mappings. This creates notable CPU and memory overhead, along with slow boot sequences.
* **Docker Containers**: Virtualize the host operating system kernel directly. Containers isolate execution workspaces using native Linux kernel primitives: **Namespaces** (for separating mount points, network adapters, and process IDs) and **Cgroups** (for capping hardware resources). This eliminates Guest OS overhead, making containers lightweight, highly performant, and capable of booting instantly.

### Secrets vs Environment Variables
* **Environment Variables**: Storing root credentials or database passwords inside standard environment variables (`.env` files or `ENV` directives) introduces significant security flaws. Any user or compromised process with access to the container can run `env` or `docker inspect` to read secrets in plaintext. They can also easily slip into unencrypted log dumps.
* **Secrets**: Encrypt sensitive data both at rest and during infrastructure transit. Injection occurs through safe, memory-only files (mounted at `/run/secrets/`), bypassing the standard process environment entirely. This mitigates lookup exploits and keeps sensitive passwords out of log files.

### Docker Network vs Host Network
* **Host Network**: Drops all network isolation. The container shares the host machine’s interfaces and network ports directly. If a process binds to a port inside the container, it binds directly to that port on the host machine. This increases collision vulnerabilities and bypasses firewall boundaries between applications.
* **Docker Network**: Establishes an isolated, software-defined bridge network. Containers receive dynamic internal IPs on a dedicated private subnet and can communicate using secure internal DNS nicknames (e.g., resolving `mariadb` or `wordpress`). No communication passes to the host machine unless explicitly mapped.

### Docker Volumes vs Bind Mounts
* **Docker Volumes**: Managed entirely by the Docker engine within isolated, system-owned storage directories (`/var/lib/docker/volumes/`). They abstract the underlying storage layer from host mutations and are heavily optimized for database performance, automated persistence, and engine-level backups.
* **Bind Mounts**: Explicitly tie a directory inside the container to a strict, absolute path on the host machine (`/home/adegl-in/data/mariadb` and `/home/adegl-in/data/wordpress`). Although they demand careful directory permissions management on the host, they are used here to meet the exact requirements for absolute user-space data inspection.

---

## Instructions

### Prerequisites
* A Linux environment (Debian/Ubuntu preferred).
* **Docker Engine** and **Docker Compose CLI V2** installed.
* `sudo` privileges to update internal network mappings and write to system directories.

### Local Domain Resolution
Before booting the infrastructure, map the official project domain name locally. Append the following entry to your host system's hosts routing file:

```bash
echo "127.0.0.1 adegl-in.42.fr" | sudo tee -a /etc/hosts