# Set the base image
FROM debian:jessie

LABEL net.guifi.vendor="Fundacio guifi.net"
LABEL version="1.0"
LABEL description="This docker image is ready for \
developing with guifi.net web environment."
LABEL maintainer="roger.garcia@guifi.net"

# Definition of environment variables

RUN apt-get update && apt-get dist-upgrade -y \
  && apt-get install -y apache2 php5 php5-mysqlnd php5-gd \
  git mysql-client libapache2-mod-php5 drush \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

# Preparing drupal workdir
RUN mkdir /usr/share/drupal

# Downloading Drupal files
WORKDIR /usr/share/drupal
RUN drush dl drupal-6 --drupal-project-rename=guifi-web

# Preparing Drupal environment
COPY ./drupal-config.pl /tmp/
RUN perl /tmp/drupal-config.pl

# Copy over the apache configuration file
COPY ./drupal.conf /etc/apache2/sites-available/drupal.conf

# Enable new site
RUN a2enmod rewrite
RUN a2dissite 000-default.conf
RUN a2ensite drupal.conf

# Define Volume for Drupal
VOLUME /usr/share/drupal/guifi-web

# Copying Entrypoint scripts
COPY ./docker-entrypoint.sh /

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
