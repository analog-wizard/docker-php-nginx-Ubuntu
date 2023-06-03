FROM ubuntu:latest
#LABEL Maintainer="Tim de Pater <code@trafex.nl>"
LABEL Description="Lightweight container with Nginx 1.22 & PHP 8.1 based on Alpine Linux."
# Setup document root
WORKDIR /var/www/html

ARG DEBIAN_FRONTEND=noninteractive
# Install packages and remove default server definition
RUN apt-get update && apt-get install -y \
  curl \
  nginx \
  php \
  php-ctype \
  php-curl \
  php-dom \
  php-fpm \
  php-gd \
  php-intl \
  php-mbstring \
  php-mysqli \
  php-opcache \
  php-phar \
  php-xml \
  php-xmlreader \
  supervisor


#  Both php-session and php-openssl do not currently have Ubuntu counterparts

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php/php-fpm.d/www.conf
COPY config/php.ini /etc/php/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add application  --chown=nobody
COPY src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
