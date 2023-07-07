FROM php:fpm-alpine3.17

COPY ./entrypoint.sh /entrypoint.sh

ENV GCLOUD=/google-cloud-sdk/bin

RUN chmod +x /entrypoint.sh

# RUN apk update && apk add --no-cache libzip-dev && docker-php-ext-configure zip && docker-php-ext-install zip
RUN apk update && apk add libzip-dev python3 && docker-php-ext-configure zip && docker-php-ext-install zip

# install gcloud cli
WORKDIR /
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-437.0.1-linux-x86_64.tar.gz
RUN tar xf google-cloud-cli-437.0.1-linux-x86_64.tar.gz
RUN ./google-cloud-sdk/install.sh -q
RUN ln -s $GCLOUD/* /usr/bin/

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install pdo_mysql zip bcmath

RUN mkdir -p /var/www/pterodactyl

WORKDIR /var/www/pterodactyl

RUN curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
RUN tar -xzvf panel.tar.gz
RUN rm panel.tar.gz
RUN chmod -R 755 storage/* bootstrap/cache/

# COPY ./deps/.env /var/www/pterodactyl/
# RUN cp .env.example .env

RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/pterodactyl

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]