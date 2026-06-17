#!/bin/bash
set -e

# be sure SSL directory exists
mkdir -p /etc/nginx/ssl

: "${DOMAIN_NAME:=localhost}"

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo "Generating self-signed SSL certificate for ${DOMAIN_NAME}..."

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=IT/ST=Florence/L=Florence/O=42/OU=Inception/CN=${DOMAIN_NAME}"

    chmod 600 /etc/nginx/ssl/nginx.key
    chmod 644 /etc/nginx/ssl/nginx.crt

    echo "SSL certificate generated at /etc/nginx/ssl/"
else
    echo "SSL certificate already exists. Skipping generation."
fi

envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.tmp && mv /etc/nginx/nginx.conf.tmp /etc/nginx/nginx.conf

echo "Testing nginx configuration..."
nginx -t
echo "Nginx configuration test passed."

echo "Starting Nginx..."
exec nginx -g "daemon off;"
