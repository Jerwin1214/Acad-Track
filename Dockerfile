# Use official PHP image with Apache
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git zip unzip libpq-dev libzip-dev libpng-dev libonig-dev libxml2-dev && \
    docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl bcmath gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory to Laravel app
WORKDIR /var/www/html

# Copy all files to the container
COPY . /var/www/html

# Set correct Apache document root to Laravel's /public directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Update Apache configuration to use the new document root
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install dependencies and generate Laravel key
RUN composer install --no-interaction --prefer-dist --optimize-autoloader && \
    php artisan key:generate && \
    php artisan storage:link || true

EXPOSE 80
CMD ["apache2-foreground"]
