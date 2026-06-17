*This project has been created as part of the 42 curriculum by adegl-in.*

# Inception - System administration with Docker compose

**Inception** is a core system administration in the 42 curriculum path. Its main goal is to design, build, and deploy a fully autonomous, secure, multi-container infrastructure using **Docker compose** on a virtualized Linux host environment, or a virtual machine. 

Instead of pulling pre-built images from Docker Hub, this project strictly asks to create custom `Dockerfiles` from scratch. The infrastructure represents a web architecture consisting of:
* **NGINX**: a high-performance web server;
* **WordPress**: a content management platform powered by PHP-FPM to process and eveb to play with web scripts;
* **MariaDB**: a relational database engine tasked with storing and managing application data.

### Architectural security
To satisfy the security requirements, all internal components (WordPress and MariaDB) are completely isolated within a private Docker virtual network, so that they will not expose any ports directly to the host machine. The only public interface is NGINX, which accepts incoming traffic exclusively over HTTPS using port 443.

---

## Technical choices

### Docker and component configuration
* **Operating system base**: all images utilize **Debian Bookworm** as their core system baseline. This choice ensures access to stable package repositories (`php8.2-fpm`, `mariadb-server`, `nginx`) while being in consistency with modern practices.
* **PID 1 process**: to avoid creating pointless background processes, every service runs directly in the foreground. This menas every scripted initialization entrypoints is going to use the Bash `exec` directive to replace the shell process entirely with the program binary, in order to ensure that the kernel shutdown signals (like `SIGTERM`) are caught directly by the daemon..

### Differences between VMs and Docker
* **Virtual Machines (VMs)**: they virtualize an entire computer hardware stack via a hypervisor. Each VM must embed a complete Guest Operating System, custom kernels, device drivers, and heavy memory mappings, which can create notable CPU and memory overhead, along with slow boot sequences.
* **Docker Containers**: these virtualize the host operating system kernel directly. Containers isolate execution workspaces using native Linux kernel primitives: **Namespaces** (for separating mount points, network adapters, and process IDs) and **Cgroups** (for capping hardware resources). This eliminates Guest OS overhead, making containers lightweight, highly performant, and capable of booting instantly.

### Docker network vs host network
* **Host Network**: drops all network isolation. The container shares the host machine’s interfaces and network ports directly. If a process binds to a port inside the container, it will bind directly to that port on the host machine. This increases collision vulnerabilities and bypasses firewall boundaries between applications.
* **Docker Network**: establishes an isolated, software-defined bridge network. Containers receive dynamic internal IPs on a dedicated private subnet and can communicate using secure internal DNS nicknames (e.g., resolving `mariadb` or `wordpress`). No communication passes to the host machine unless explicitly mapped.

### Docker Volumes vs Bind Mounts
* **Docker Volumes**: Managed entirely by the Docker engine within isolated, system-owned storage directories (`/var/lib/docker/volumes/`). They abstract the underlying storage layer from host mutations and are heavily optimized for database performance, automated persistence, and engine-level backups.
* **Bind Mounts**: Explicitly tie a directory inside the container to a strict, absolute path on the host machine (`/home/adegl-in/data/mariadb` and `/home/adegl-in/data/wordpress`). Although they demand careful directory permissions management on the host, they are used here to meet the exact requirements for absolute user-space data inspection.

### Secrets vs Environment Variables
* **Environment Variables**: storing sensitive records like database root credentials or user passwords inside standard environment variables (`.env` files or `ENV` directives) introduces more significant security flaws, which means any user, process, or compromised application with access to the container layer can easily run `env`, `printenv`, or `docker inspect` to read the keys in plaintext.
***In this project I'm not using secrets with the sole purpose of simplicity and the acknowledgment of the fact that this project aims towards the learning process of the concepts, although I am completely aware of the difference and will not replicate the same in future realistic projects.***
* **Secrets**: these ones instead provide a secure data management framework by encrypting sensitive keys both at rest and during infrastructure transit. Instead of being injected into the process environment space, Docker secrets are securely mounted as temporary, memory-only files at a specific path (`/run/secrets/`). This completely keeps passwords out of the standard environment, mitigating process lookup exploits and ensuring that production credentials never leak into system log logs.

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