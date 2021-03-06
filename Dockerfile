FROM php:7.2-apache-buster

# Surpresses debconf complaints of trying to install apt packages interactively
# https://github.com/moby/moby/issues/4032#issuecomment-192327844

ARG DEBIAN_FRONTEND=noninteractive

RUN usermod -u 1000 www-data
RUN usermod -G staff www-data
# Update
RUN apt-get -y update --fix-missing && \
    apt-get upgrade -y && \
    apt-get --no-install-recommends install -y apt-utils && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y libxml2-dev
# Install useful tools and install important libaries
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install nano wget \
dialog \
libsqlite3-dev \
libsqlite3-0 && \
    apt-get -y --no-install-recommends install default-mysql-client \
zlib1g-dev \
libzip-dev \
libicu-dev && \
    apt-get -y --no-install-recommends install --fix-missing apt-utils \
build-essential \
git \
curl \
libonig-dev && \
    apt-get -y --no-install-recommends install --fix-missing libcurl4 \
libcurl4-openssl-dev \
zip \
openssl && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install xdebug
RUN pecl install xdebug-2.8.0 && \
    docker-php-ext-enable xdebug

# Install redis
RUN pecl install redis-5.1.1 && \
    docker-php-ext-enable redis

# Other PHP7 Extensions
RUN apt-get update && apt-get install -y libxslt-dev

RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo_sqlite && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install curl && \
    docker-php-ext-install tokenizer && \
    docker-php-ext-install json && \
    docker-php-ext-install zip && \
    docker-php-ext-install -j$(nproc) intl && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install gettext && \
    docker-php-ext-install soap && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install xsl && \
    docker-php-ext-install sockets

# Install Freetype
RUN requirements="libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libcairo2-dev libjpeg62-turbo-dev libpango1.0-dev libgif-dev build-essential libfreetype6-dev libicu-dev libxslt1-dev unzip" \
    && apt-get update \
    && apt-get install -y $requirements \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && requirementsToRemove="libmcrypt-dev libcurl3-dev  libfreetype6-dev" \
    && apt-get purge --auto-remove -y $requirementsToRemove
# Enable apache modules
RUN a2enmod rewrite headers

# Cleanup
RUN rm -rf /usr/src/*

RUN chsh -s /bin/bash www-data


RUN service apache2 restart

RUN cd /var/www/html && mkdir generated && chmod -R 777 /var/www/html/generated/

