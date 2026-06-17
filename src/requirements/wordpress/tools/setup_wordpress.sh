#!/bin/bash
set -e

WP_PATH="/var/www/html"

if [ -n "$WORDPRESS_DB_PASSWORD_FILE" ] && [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
    WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
    export WORDPRESS_DB_PASSWORD
fi

echo "Setting up WordPress..."

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Installing WP-CLI..."
    if [ ! -f "/usr/local/bin/wp" ]; then
        wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /tmp/wp-cli.phar
        chmod +x /tmp/wp-cli.phar
        mv /tmp/wp-cli.phar /usr/local/bin/wp
    fi

    echo "Downloading WordPress with WP-CLI..."
    wp core download --path="$WP_PATH" --force --allow-root

	#creating of the file wp-config.php (the bridge to the db)
	wp config create --allow-root \
		--dbname=$MYSQL_DATABASE \
		--dbuser=$MYSQL_USER \
		--dbpass=$MYSQL_PASSWORD \
		--dbhost=mariadb:3306

    echo "Installing WordPress core via WP-CLI..."
    wp core install \
        --path=$WP_PATH \
        --url=$DOMAIN_NAME \
        --title="adegl-in's Inception" \
        --admin_user=$WORDPRESS_ADMIN_USER\
        --admin_password=$WORDPRESS_ADMIN_PASSWORD \
        --admin_email=root@alek.com \
        --skip-email --allow-root

    echo "Creating second user..."
    wp user create \
        --path="$WP_PATH" \
        "${WORDPRESS_USER}" \
        "adegl-in@student.42.fr" \
        --user_pass="${WORDPRESS_PASSWORD}" \
        --role=author --allow-root

    echo "WordPress setup just got over!!"
else
    echo "WordPress is already initialized, skipping setup..."
fi

chown -R www-data:www-data "$WP_PATH"
chmod -R 755 "$WP_PATH"

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F