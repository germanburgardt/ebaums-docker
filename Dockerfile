FROM php:5.6-apache

# Install gd, iconv, mbstring, mcrypt, mysql, soap, sockets, zip, and zlib extensions
# see example at https://hub.docker.com/_/php/

RUN apt-get update && apt-get install -y libmemcached-dev \
        libbz2-dev \
        git\
        libfreetype6-dev \
        libgd-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng16-16 \
        libxml2-dev \
        zlib1g-dev \
        memcached\
        libgeoip-dev \ 
        geoip-bin \ 
        geoip-database \
        #php5-mysql \
    #&& docker-php-ext-enable memcached-2.2.0 \
    #&& docker-php-ext-enable memcached-2.2.0 \
    && docker-php-ext-install iconv mbstring mcrypt soap sockets zip \
    && docker-php-ext-configure gd --enable-gd-native-ttf --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-configure mysql --with-mysql=mysqlnd \
    && docker-php-ext-install mysql\
    && /etc/init.d/memcached start \
    && docker-php-ext-install pdo_mysql
     
# Add a PHP config file. The file was copied from a php53 dotdeb package and
# lightly modified (mostly for improving debugging). This may not be the best
# idea.phpize
COPY ./5.6/cli/php.ini /usr/local/etc/php/

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

#COPY ./index.html /var/www/html/

RUN pecl channel-update pear.php.net
RUN pecl install memcached-2.2.0
RUN pecl install memcache-2.2.7
RUN pecl install mongo-1.5.8
RUN pecl install geoip




RUN docker-php-ext-enable memcached
RUN docker-php-ext-enable memcache
RUN docker-php-ext-enable mongo
RUN docker-php-ext-enable geoip
RUN docker-php-ext-enable mysql
RUN docker-php-ext-enable pdo_mysql
# enable mod_rewrite
RUN a2enmod rewrite

RUN /etc/init.d/memcached start

RUN mkdir /var/log/emuse

RUN touch /var/log/emuse/ebw-error.log

RUN chown -R www-data:www-data /var/log/emuse



# Get the Real World example app
#RUN git clone http://gitlab.sfo.viumbe.com/ebaumsworld.git /ebw_src

# make the webroot a volume
VOLUME /home

# In images building upon this image, copy the src/ directory to the webserver
# root and correct the owner.
ONBUILD COPY src/ /home
ONBUILD RUN chown -R www-data:www-data /var/www/html

ADD ./zend/ /usr/lib64/php/zend/

ADD ./ebaumsworld/ /var/www/


# support jwilder/nginx-proxy resp. docker-gen
# You may wan to overwrite VIRTUAL_HOST and UPSTREAM_NAME in your Docker file.
EXPOSE 80
ENV VIRTUAL_HOST site.local
ENV UPSTREAM_NAME web-site
ENV DOCKERHOST 192.168.0.49

# Put something like this into your Dockerfile if you want to add more files.
# Note that you need to correctly set the owner otherwise PHP will not be able
# to edit the file system.
## copy src-extra
#COPY src-extra/ /var/www/html/extra/
#RUN chown -R www-data:www-data /var/www/html/extra

# Entrypoint file tries to fix permissions, again
#COPY entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]

#EOF
