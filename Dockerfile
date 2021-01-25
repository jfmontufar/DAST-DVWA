FROM debian:9.2

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    debconf-utils && \
    echo mariadb-server mysql-server/root_password password vulnerables | debconf-set-selections && \
    echo mariadb-server mysql-server/root_password_again password vulnerables | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    mariadb-server \
    netcat \
    curl \
    php \
    php-mysql \
    php-pgsql \
    php-pear \
    php-gd \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/allow_url_include = Off/allow_url_include = On/' /etc/php/7.0/apache2/php.ini

COPY . /var/www/html

COPY config/config.inc.php.dist /var/www/html/config/config.inc.php

RUN chown www-data:www-data -R /var/www/html && \
    rm /var/www/html/index.html

RUN service mysql start && \
    sleep 3 && \
    mysql -uroot -pvulnerables -e "CREATE USER app@localhost IDENTIFIED BY 'vulnerables';CREATE DATABASE dvwa;GRANT ALL privileges ON dvwa.* TO 'app'@localhost;" && \
    cd /var/www/html && php ./autosetup.php

EXPOSE 80

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
