## 1. Setting Up the Environment from Scratch

### Prerequisites
Before starting, ensure your local development system or Virtual Machine has the following installed:
* Operating System: Linux (Debian Bookworm or Ubuntu recommended).
* Docker Engine (v20+ recommended)
* Docker Compose CLI V2 (`docker compose` subcommand syntax).
* GNU Make

### Configuration Files and Architecture
The project is structured under the `src/` directory:
* `src/docker-compose.yml`: Defines the network, volumes, and service constraints.
* `src/requirements/`: Contains individual configuration blueprints (`Dockerfiles`, entrypoints, and server configurations) grouped by service name (`nginx/`, `wordpress/`, `mariadb/`).
* `src/.env`: Contains local environment keys, usernames, and database interaction passwords required during build routines.

---

## 2. Build and Launch Lifecycle
The build stack handles the setup sequence seamlessly through the automated `Makefile`.

* **Initial Compile & Launch**:
    ```bash
    make
    ```
    *This target automatically triggers local directory setups, reads the `.env` context, builds the Debian Bookworm-based local images, and connects them inside the isolated virtual bridge network.*

* **Complete System Rebuild**:
    ```bash
    make re
    ```
    *Cleans the existing active execution stacks and triggers a fresh compilation of the containers.*

---

## 3. Container & Volume Management Commands
As a developer, use the following diagnostic commands to check and control execution:

* **Interactive Container Shell Access**:
    ```bash
    docker exec -it nginx /bin/bash
    docker exec -it wordpress /bin/bash
    docker exec -it mariadb /bin/bash
    ```

* **Inspecting Real-time Application Logs**:
    ```bash
    docker logs nginx
    docker logs wordpress
    docker logs mariadb
    ```

* **Inspecting Named Volume Bindings**:
    ```bash
    docker volume ls
    docker volume inspect src_mariadb_data
    docker volume inspect src_wordpress_data
    ```

---

## 4. Data Persistence & Storage Mapping
To comply with data evaluation rules, data persistence is achieved by linking container storage directly onto the host filesystem using **Bind Mounts**.

### Host Storage Locations
Data is permanently stored outside the container life cycle inside the following directories on the host machine:
* **Database Files**: `/home/adegl-in/data/mariadb` (Maps to `/var/lib/mysql` within the container).
* **Website Assets**: `/home/adegl-in/data/wordpress` (Maps to `/var/www/html` within the container).

### Lifecycle Persistence Validation
When you execute `make down`, the containers are completely deleted from system memory, but the underlying database tables and media files remain safely on the host machine. When you run `make` again, the newly created containers instantly rebind to these directories, picking up exactly where the application left off without any data loss.