FROM php:fpm-alpine3.17

RUN apk update && apk add --no-cache libzip-dev && docker-php-ext-configure zip && docker-php-ext-install zip
RUN apk add nginx

# COPY ./deps/php.ini-development /u
# COPY ./deps/pterodactyl.conf

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install pdo_mysql zip bcmath

RUN mkdir -p /var/www/pterodactyl

WORKDIR /var/www/pterodactyl

RUN curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
RUN tar -xzvf panel.tar.gz
RUN rm panel.tar.gz
RUN chmod -R 755 storage/* bootstrap/cache/
COPY ./deps/.env /var/www/pterodactyl/
# RUN cp .env.example .env

RUN composer install --no-dev --optimize-autoloader
# RUN php artisan key:generate --force

RUN chown -R www-data:www-data /var/www/pterodactyl

# nginx stuff

COPY ./deps/pterodactyl.conf /etc/nginx/http.d/pterodactyl.conf

RUN rm /etc/nginx/http.d/default.conf

RUN mkdir /app

COPY ./deps/start.sh /app/

RUN chown -R root /app
RUN chmod +x /app/start.sh

CMD /app/start.sh