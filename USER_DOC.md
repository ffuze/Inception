# User & Administrator Documentation

Welcome to the User Documentation for the Inception infrastructure. This guide is designed for administrators or end-users who need to manage, run, and interact with the deployed web services without diving into the underlying source code.

---

## 1. Services Provided by the Stack
The infrastructure automatically deploys a secure, localized instance of a modern web application consisting of three main components:
* **Web Server (NGINX)**: Acts as the secure gateway. It serves the website encrypted over HTTPS and ensures no unencrypted connection is allowed.
* **Content Management System (WordPress)**: The user-facing website platform where you can publish articles, manage pages, and interact with the site interface.
* **Database Management System (MariaDB)**: The backend storage engine that holds all website data, including posts, user profiles, and comments.

---

## 2. Starting and Stopping the Project
All management operations are controlled using the system `Makefile` located at the root of the project folder. Open your terminal and use the following commands:

* **Start the Infrastructure**:
    ```bash
    make
    ```
    *This will set up the necessary folders, build the services, and launch them safely in the background.*

* **Stop the Infrastructure**:
    ```bash
    make down
    ```
    *This stops the running services without destroying your website content or database entries.*

---

## 3. Accessing the Website and Administration Panel

### Main Website URL
To browse the live WordPress website, open your web browser and go to:
`https://adegl-in.42.fr`

> **Note**: Since the stack uses a self-signed SSL security certificate for development purposes, your browser will show a warning ("Your connection is not private"). Click on **Advanced** and choose **Proceed to adegl-in.42.fr (unsafe)** to access the site.

### WordPress Dashboard (Admin Panel)
To log into the administrator dashboard to customize the site, install plugins, or write posts, navigate to:
`https://adegl-in.42.fr/wp-admin`

---

## 4. Locating and Managing Credentials
For security reasons, application credentials are standardized and isolated outside the system code. 
* **Where are they?**: All passwords, usernames, and database root keys are defined within the hidden `.env` configuration file located at `src/.env`.
* **Default Setup Users**:
    * **WordPress Administrator**: An administrative user account dedicated solely to managing the WordPress dashboard layout.
    * **WordPress Standard User**: A non-administrative account with editing/subscribing privileges, used for regular platform testing.
    * **Database Administrator**: The root account used to manage internal technical tables.

---

## 5. Verifying Service Health
To check if all services are up and running correctly, execute the following command in your terminal:
```bash
docker compose -f src/docker-compose.yml ps