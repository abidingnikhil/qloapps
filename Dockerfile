FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apache2 \
    mariadb-server \
    php7.4 \
    libapache2-mod-php7.4 \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-soap \
    php7.4-xml \
    php7.4-zip \
    php7.4-fpm \
    php7.4-bcmath \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

RUN sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/7.4/apache2/php.ini && \
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 16M/' /etc/php/7.4/apache2/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 16M/' /etc/php/7.4/apache2/php.ini && \
    sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php/7.4/apache2/php.ini

# Remove default Apache index.html
RUN rm -f /var/www/html/index.html

# Download and set up QloApps
#RUN wget https://github.com/Qloapps/QloApps/archive/refs/heads/develop.zip -O /tmp/qloapp.zip && \
#    unzip /tmp/qloapp.zip -d /var/www/html/ && \
#    mv /var/www/html/QloApps-develop/* /var/www/html/ && \
#    mv /var/www/html/QloApps-develop/.* /var/www/html/ 2>/dev/null || true && \
#    rmdir /var/www/html/QloApps-develop && \
#    chown -R www-data:www-data /var/www/html && \
#    chmod -R 755 /var/www/html && \
#    rm /tmp/qloapp.zip
RUN wget https://github.com/Qloapps/QloApps/archive/refs/heads/v1.6.x.zip -O /tmp/qloapp.zip && \
    unzip /tmp/qloapp.zip -d /var/www/html/ && \
    mv /var/www/html/QloApps-develop/* /var/www/html/ && \
    mv /var/www/html/QloApps-develop/.* /var/www/html/ 2>/dev/null || true && \
    rmdir /var/www/html/QloApps-develop && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    rm /tmp/qloapp.zip

# Apache configuration
RUN echo '<VirtualHost *:80>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html/>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Disable default site and enable QloApps site
RUN a2dissite 000-default.conf && a2ensite 000-default.conf

# Start script with database creation
RUN echo '#!/bin/bash\n\
service mysql start\n\
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME:-qloapp_db};"\n\
mysql -e "CREATE USER IF NOT EXISTS '"'"'${DB_USER:-qloapp_user}'"'"'@'"'"'localhost'"'"' IDENTIFIED BY '"'"'${DB_PASS:-qloapp_password}'"'"';"\n\
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME:-qloapp_db}.* TO '"'"'${DB_USER:-qloapp_user}'"'"'@'"'"'localhost'"'"';"\n\
mysql -e "FLUSH PRIVILEGES;"\n\
apache2ctl -D FOREGROUND' > /start-script.sh && chmod +x /start-script.sh

EXPOSE 80

CMD ["/start-script.sh"]
