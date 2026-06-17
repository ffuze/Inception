#!/bin/bash
set -e

echo "MariaDB is starting..."

setup_database() {
    mysql "$@" << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
DROP USER IF EXISTS '${MYSQL_USER}'@'localhost';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
}

# Verifica se il database è già stato inizializzato in passato
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First boot: Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo "Starting temporary server for initial configuration..."
    mysqld --skip-networking --socket=/run/mysqld/mysqld.sock --user=mysql & pid="$!"

    echo "Waiting for temporary MariaDB to be ready..."
    until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
        sleep 1
    done

    echo "Running initial setup SQL..."
    setup_database --socket=/run/mysqld/mysqld.sock -u root

    echo "Shutting down temporary MariaDB server..."
    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid"
    echo "Initial configuration complete!"
else
    echo "MariaDB is already initialized. Skipping setup steps..."
fi

echo "Starting MariaDB normally..."
mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock &
pid="$!"

echo "Waiting for MariaDB to be ready..."
until mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" ping >/dev/null 2>&1; do
    sleep 1
done

echo "Ensuring database users and grants are correct..."
setup_database --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}"

wait "$pid"