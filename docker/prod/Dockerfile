FROM php:7.4-fpm

MAINTAINER Meetup <meetup-devp@devon.nl>

RUN echo 'deb [trusted=yes] https://repo.symfony.com/apt/ /' | tee /etc/apt/sources.list.d/symfony-cli.list
# Install developer dependencies
RUN apt-get update -yqq && apt-get install -y \
    openssl git vim libsqlite3-dev libxml2-dev libicu-dev \
    libfreetype6-dev libmcrypt-dev libjpeg62-turbo-dev libpng-dev \
    libzip-dev unzip libonig-dev \
    libcurl4-gnutls-dev libbz2-dev libssl-dev -yqq \
    libmemcached-dev symfony-cli \
    nodejs npm \
    && rm -r /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/*

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    npm install -g yarn

# Install php extensions
RUN docker-php-ext-install opcache \
    && docker-php-ext-install json \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install xml \
    && docker-php-ext-install zip \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install curl \
    && docker-php-ext-configure gd \
    && docker-php-ext-install gd \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-install intl \
    && pecl install pcov \
    && docker-php-ext-enable pcov

COPY /docker/prod/entrypoint.sh /etc/entrypoint.sh
RUN chmod +x /etc/entrypoint.sh

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY /docker/prod/php/*.ini $PHP_INI_DIR/conf.d/

COPY ./ /code
WORKDIR /code

RUN useradd -r -m -u 1000 appmgmt && usermod -a -G www-data appmgmt && \
mkdir -p /code/var/{cache,log} && \
rm -rf /code/var/cache/* /code/var/log/* && \
chown -R appmgmt:www-data /code/var/{cache,log} && \
chmod 775 /code/var/{cache,log}

#USER appmgmt

#EXPOSE 8000

ENTRYPOINT ["/etc/entrypoint.sh"]
