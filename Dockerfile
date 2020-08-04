#
# Dockerfile for php-fpm/nginx/apcu/redis
#
FROM mcr.microsoft.com/oryx/php:7.4-fpm

ENV SSH_PASSWD "root:Docker!"
ENV SSH_PORT 2222
COPY sshd_config /etc/ssh/

RUN set -x \
    && echo "$SSH_PASSWD" | chpasswd

RUN apt update \
    && apt install -y redis \
    && apt install -y libnginx-mod-http-cache-purge

RUN pecl install -o -f redis \
    && rm -fr /tmp/pear \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini

#No need for APCU, since Redis Object cache is already present.
#RUN pecl install -o -f apcu \
#    && rm -fr /tmp/pear \
#    && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

COPY opcache-recommended.ini /usr/local/etc/php/conf.d/
COPY php-recommended.ini /usr/local/etc/php/conf.d/

COPY nginx/default.conf /etc/nginx/conf.d/
COPY nginx/nginx.conf /etc/nginx/

COPY php-fpm/docker.conf /usr/local/etc/php-fpm.d/
COPY php-fpm/www.conf /usr/local/etc/php-fpm.d/
COPY php-fpm/zz-docker.conf /usr/local/etc/php-fpm.d/

ENV WORDPRESS_VERSION 5.4.2
ENV WORDPRESS_SHA1 e5631f812232fbd45d3431783d3db2e0d5670d2d

RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
	tar -xzf wordpress.tar.gz -C /tmp/; \
	rm wordpress.tar.gz; \
    cp -r /tmp/wordpress/* /var/www/html/; \
	chown -R www-data:www-data /var/www/html; \
# pre-create wp-content (and single-level children) for folks who want to bind-mount themes, etc so permissions are pre-created properly instead of root:root
	mkdir -p /var/www/html/wp-content; \
	for dir in /var/www/html/wp-content/*/; do \
		dir="$(basename "${dir%/}")"; \
		mkdir -p "wp-content/$dir"; \
	done; \
	chown -R www-data:www-data wp-content; \
	chmod -R 777 wp-content

COPY content/wp-config.php /var/www/html/
RUN chown -R www-data:www-data /var/www/html/wp-config.php
    
COPY init_container.sh /bin/
RUN chmod +x /bin/init_container.sh

EXPOSE $SSH_PORT 80
ENTRYPOINT ["/bin/init_container.sh"]