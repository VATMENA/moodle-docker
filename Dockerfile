# PHP 8.3 with Apache as base
FROM php:8.3-apache

LABEL maintainer="Michael Meese <michael@evomation.de>"
LABEL description="Moodle 4.5.x Docker image with PHP 8.3 and required extensions"

# Pass Moodle tag as build argument
ARG MOODLE_TAG=MOODLE_500_STABLE
ENV MOODLE_TAG=${MOODLE_TAG}

# Install system dependencies and required PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    libicu-dev \
    libxslt1-dev \
    libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        zip \
        intl \
        xsl \
        soap \
        exif \
        opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# PHP and OPcache settings
RUN echo "max_input_vars=5000" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "zend_extension=opcache.so" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.max_accelerated_files=4000" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo "opcache.revalidate_freq=60" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Clone Moodle from official GitHub repository
RUN git clone --depth 1 --branch ${MOODLE_TAG} https://github.com/moodle/moodle.git /var/www/html

# Prepare data folder and permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Add entrypoint for dynamic config.php generation
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Add cron.sh script for moodle-cron container
COPY cron.sh /cron.sh
RUN chmod +x /cron.sh

ENTRYPOINT ["/entrypoint.sh"]

