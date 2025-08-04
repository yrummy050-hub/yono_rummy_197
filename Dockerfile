FROM php:8.1-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy only composer files first for better caching
COPY --chown=www-data:www-data composer.json composer.lock* ./

# Install dependencies (no scripts)
RUN composer install --no-dev --no-scripts --no-interaction --optimize-autoloader

# Copy application files
COPY --chown=www-data:www-data . .

# Set up storage and cache directories
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Configure Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/public
RUN a2enmod rewrite headers \
    && echo 'ServerName localhost' > /etc/apache2/conf-available/servername.conf \
    && echo 'Listen 8080' > /etc/apache2/ports.conf \
    && echo '<VirtualHost *:8080>\n        ServerAdmin webmaster@localhost\n        DocumentRoot ${APACHE_DOCUMENT_ROOT}\n        <Directory "${APACHE_DOCUMENT_ROOT}">\n            AllowOverride All\n            Require all granted\n            Options Indexes FollowSymLinks\n        </Directory>\n        ErrorLog ${APACHE_LOG_DIR}/error.log\n        CustomLog ${APACHE_LOG_DIR}/access.log combined\n    </VirtualHost>' > /etc/apache2/sites-available/000-default.conf \
    && a2dissite 000-default \
    && a2ensite 000-default.conf

# Set proper permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# Expose port 8080
EXPOSE 8080

# Start Apache
CMD ["apache2-foreground"]