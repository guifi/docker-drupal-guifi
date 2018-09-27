# Set the base image
FROM debian:jessie

LABEL net.guifi.vendor="Fundacio guifi.net"
LABEL version="1.0"
LABEL description="This docker image is ready for \
developing with guifi.net web environment."
LABEL maintainer="roger.garcia@guifi.net"

ENV GUIFI_URL http://dev.guifi.net/static/
ENV GUIFI_UNIX_USER fiberfy
ENV GUIFI_USER_ID 1000
ENV GUIFI_USER_GID 1000

RUN apt-get update && apt-get dist-upgrade -y \
  && apt-get install -y apache2 php5 php5-mysqlnd php5-gd \
  php5-xdebug libapache2-mod-php5 drush wget vim \
  gzip git mysql-client \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

# We install gosu
WORKDIR /tmp

RUN wget http://ftp.es.debian.org/debian/pool/main/g/gosu/gosu_1.10-1~bpo8+1_amd64.deb && dpkg -i gosu_1.10-1~bpo8+1_amd64.deb

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

# Creating UNIX User for development (security reasons)
RUN groupadd --gid "${GUIFI_USER_GID}" "${GUIFI_UNIX_USER}" && \
    useradd \
      --uid ${GUIFI_USER_ID} \
      --gid ${GUIFI_USER_GID} \
      --create-home \
      --shell /bin/bash \
      ${GUIFI_UNIX_USER}

# Preparing development dir
RUN mkdir /usr/share/guifi-dev/

# Copying Entrypoint scripts
COPY ./docker-entrypoint.sh /
COPY ./drupal-entry.pl /
COPY ./user-mapping.sh /

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
