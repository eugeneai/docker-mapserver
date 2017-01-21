# Mapserver for Docker
FROM ubuntu:yakkety
MAINTAINER Evgeny Cherkashin<eugeneai@irnok.net>

ENV LANG C.UTF-8
RUN update-locale LANG=C.UTF-8

# Update and upgrade system
RUN apt-get -qq update --fix-missing && apt-get -qq --yes upgrade

#ADD 71-apt-cacher-ng /etc/apt/apt.conf.d/71-apt-cacher-ng

#-------------Application Specific Stuff ----------------------------------------------------

# Install mapcache compilation prerequisites
RUN apt-get install -y software-properties-common g++ make cmake wget git  bzip2 \
    apache2 apache2-dev curl 

# Install mapcache dependencies provided by Ubuntu repositories
RUN apt-get install -y \
    libxml2-dev \
    libxslt1-dev \
    libproj-dev \
    libfribidi-dev \
    libcairo2-dev \
    librsvg2-dev \
    libmysqlclient-dev \
    libpq-dev \
    libcurl4-gnutls-dev \
    libexempi-dev \
    libgdal-dev \
    libgeos-dev \
    gdal-bin

ADD resources /tmp/resources

ADD setup.sh /setup.sh
RUN chmod 0755 /setup.sh
RUN /setup.sh


# Configure localhost in Apache
RUN cp  /tmp/resources/000-default.conf /etc/apache2/sites-available/

# To be able to install libapache.
RUN echo

# RUN echo 'deb http://archive.ubuntu.com/ubuntu yakkety multiverse' >> /etc/apt/sources.list
# RUN echo 'deb http://archive.ubuntu.com/ubuntu yakkety-updates multiverse' >> /etc/apt/sources.list
# RUN echo 'deb http://security.ubuntu.com/ubuntu yakkety-security multiverse' >> /etc/apt/sources.list
# RUN  apt-get update

# Install PHP5 and necessary modules
RUN  apt-get install -y libapache2-mod-fastcgi php-fpm \
     libapache2-mod-php php-common php-cli php-fpm php

# Disable these Apache modules
# Already disabled
# RUN  a2dismod mpm_event

# Enable these Apache modules
RUN  a2enmod actions cgi alias 

# Apache configuration for PHP-FPM
RUN cp /tmp/resources/php5-fpm.conf /etc/apache2/conf-available/

# Link to cgi-bin executable
RUN chmod o+x /usr/local/bin/mapserv
RUN ln -s /usr/local/bin/mapserv /usr/lib/cgi-bin/mapserv
RUN chmod 755 /usr/lib/cgi-bin

EXPOSE  80

ENV HOST_IP `ifconfig | grep inet | grep Mask:255.255.255.0 | cut -d ' ' -f 12 | cut -d ':' -f 2`

CMD apachectl -D FOREGROUND
