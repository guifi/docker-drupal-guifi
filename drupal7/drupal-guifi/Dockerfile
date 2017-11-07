# Set the base image
FROM debian:jessie

LABEL net.guifi.vendor="Fundacio guifi.net"
LABEL version="1.0"
LABEL description="This docker image is ready for \
developing with guifi.net web environment (drupal7)"
LABEL maintainer="roger.garcia@guifi.net"


RUN apt-get update && apt-get dist-upgrade -y \
  && apt-get install -y apache2 php5 php5-mysqlnd php5-gd \
  php5-xdebug libapache2-mod-php5 wget vim \
  gzip git mysql-client \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

# Installing Drush 8.1.13
RUN wget https://github.com/drush-ops/drush/releases/download/8.1.13/drush.phar -P /tmp/ \
  && chmod +x /tmp/drush.phar \
  && mv /tmp/drush.phar /usr/local/bin/drush


# Preparing php5 configuration
COPY ./php-config.pl /tmp/
RUN perl /tmp/php-config.pl

# Copy over the apache configuration file
COPY ./drupal.conf /etc/apache2/sites-available/drupal.conf

# Enable new site
RUN a2enmod rewrite
RUN a2dissite 000-default.conf
RUN a2ensite drupal.conf

# Define Volume for Drupal
VOLUME /usr/share/drupal/guifi-web

# Preparing development dir
RUN mkdir /usr/share/guifi-dev/

# Copying Entrypoint scripts
COPY ./docker-entrypoint.sh /
COPY ./drupal-entry.pl /

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
