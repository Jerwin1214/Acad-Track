# Use official PHP image with Apache
FROM php:8.2-apache

# System deps and PHP extensions
RUN apt-get update && apt-get install -y \
    git zip unzip libpq-dev libzip-dev libpng-dev libonig-dev libxml2-dev && \
    docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl bcmath gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Copy project files
COPY . /var/www/html/

# Set working directory
WORKDIR /var/www/html

# Install Composer (copy from official composer image)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install dependencies and prepare app
RUN composer install --no-interaction --prefer-dist --optimize-autoloader && \
    php artisan key:generate || true && \
    php artisan storage:link || true

# Expose port 80 and start Apache
EXPOSE 80
CMD ["apache2-foreground"]
