FROM ubuntu:22.10 as dependencies

RUN apt update && apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg

RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

ENV DEBIAN_FRONTEND=noninteractive

# Install PHP and NGINX
RUN apt -y install php8.1
RUN apt -y install php8.1-common php8.1-cli php8.1-gd php8.1-mysql php8.1-mbstring php8.1-bcmath
RUN apt -y install php8.1-xml php8.1-fpm php8.1-curl php8.1-zip nginx

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /var/www/pterodactyl

WORKDIR /var/www/pterodactyl

RUN curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
RUN tar -xzvf panel.tar.gz
RUN rm panel.tar.gz
RUN chmod -R 755 storage/* bootstrap/cache/
RUN cp .env.example .env
RUN composer install --no-dev --optimize-autoloader
RUN php artisan key:generate --force

RUN chown -R www-data:www-data /var/www/pterodactyl

COPY ./deps/www.conf /etc/php/8.1/fpm/pool.d/www.conf

# nginx stuff
COPY ./deps/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
RUN rm /etc/nginx/sites-enabled/default

WORKDIR /app
COPY ./deps/start.sh /app
RUN chmod u+x start.sh

CMD [ "./start.sh" ]