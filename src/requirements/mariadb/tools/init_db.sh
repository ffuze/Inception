#!bin/bash

set -e

echo "MariaDB is starting to initialize..."

# check if data directory of mysql exists, if not create it
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "MySQL data directory does not exist! Creating..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# in order to have our db we need to configure the stuff for it,
# since when maraiadb is installed in the first place, it will
# basically be empty, so to fix this we create a temporary db;
# --skip-networking is very useful since it disconnects the container
# from the network, so nobody can access it while we configure it
echo "Starting temporary server for MariaDB..."
mysqld --skip-networking --socket=/run/mysqld/mysqld.sock \
        --user=mysql & pid="$!"

# we wait for the temporary server to be functional by pinging
# it into the db socket, if not succesful it's going to try the
# same thing once every second, to prevent it to make a lot of
# operations at the same
echo "Waiting for MariaDB to be ready..."
until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done
echo "MariaDB is ready!"

# configure the database
echo "Running setup SQL..."
mysql --socket=/run/mysqld/mysqld.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "Shutting down temporary MariaDB server..."
mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

wait "$pid" || true

echo "Initialization complete, starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock

# to check if the socket file is present: sudo docker exec -it <container_id_or_name> ls -l /run/mysqld/mysqld.sock
# to check if the necessary mariadb files are present: docker exec -it <container_id_or_name> mysqladmin ping -u root -p
