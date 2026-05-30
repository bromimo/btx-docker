FROM php:8.2-fpm

# Системные зависимости
RUN apt-get update && apt-get install -y \
    curl wget git unzip socat msmtp \
    libzip-dev libonig-dev libicu-dev libxml2-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev libwebp-dev \
    zlib1g-dev g++ \
    libmagickwand-dev imagemagick libheif-dev \
    && rm -rf /var/lib/apt/lists/*

# PHP-расширения
RUN docker-php-ext-configure intl && docker-php-ext-install intl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install mbstring zip xml mysqli pdo_mysql opcache

# imagick с поддержкой AVIF через libheif
RUN pecl install imagick && docker-php-ext-enable imagick

# Composer
RUN wget -q https://getcomposer.org/installer -O - \
    | php -- --install-dir=/usr/local/bin --filename=composer

# Sessions для Битрикса
RUN mkdir -p /var/lib/php/sessions \
    && chown -R www-data:www-data /var/lib/php/sessions \
    && chmod -R 0770 /var/lib/php/sessions

# Bitrix PHP settings
COPY php.ini /usr/local/etc/php/conf.d/bitrix.ini

# Кастомный tmp-каталог для Битрикса (некоторые модули BitrixVM-наследия используют /tmp/b)
RUN mkdir -p /tmp/b && chown -R www-data:www-data /tmp/b

WORKDIR /var/www/html

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r//' /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
