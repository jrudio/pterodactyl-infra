FROM ubuntu:22.04

# PANEL_SOURCE expects a compressed file within the ./deps directory
ARG PANEL_SOURCE=panel-wiper-built.tar.gz

RUN apt update && apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg iputils-ping

RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

ENV DEBIAN_FRONTEND=noninteractive

# Install PHP and NGINX
RUN apt update
RUN apt -y install php8.1
RUN apt -y install php8.1-common php8.1-cli php8.1-gd php8.1-mysql php8.1-mbstring php8.1-bcmath
RUN apt -y install php8.1-xml php8.1-fpm php8.1-curl php8.1-zip nginx

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /var/www/pterodactyl

WORKDIR /var/www/pterodactyl

COPY ./deps/${PANEL_SOURCE} .
RUN tar -xzvf ${PANEL_SOURCE}
RUN rm ${PANEL_SOURCE}

RUN chmod -R 755 storage/* bootstrap/cache/

COPY ./deps/.env .
RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/pterodactyl

COPY ./deps/www.conf /etc/php/8.1/fpm/pool.d/www.conf

RUN rm /etc/nginx/sites-enabled/default
RUN rm /etc/nginx/sites-available/default
COPY ./deps/pterodactyl.conf /etc/nginx/sites-available/pterodactyl.conf
RUN ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf

RUN mkdir -p /run/php

WORKDIR /app
COPY ./deps/start.sh /app
RUN chmod u+x start.sh

CMD [ "./start.sh" ]