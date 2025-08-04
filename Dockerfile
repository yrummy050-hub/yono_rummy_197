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
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    mkdir -p storage/framework/{sessions,views,cache} && \
    mkdir -p bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Copy application files
COPY --chown=www-data:www-data . .

# Install Composer dependencies and generate application key
USER www-data
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts && \
    if [ -z "$APP_KEY" ]; then \
        php artisan key:generate --force; \
    fi

# Switch back to root for Apache configuration
USER root

# Configure Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN echo 'ServerName localhost' > /etc/apache2/conf-available/servername.conf && \
    echo 'Listen 8080' > /etc/apache2/ports.conf && \
    a2enmod rewrite headers && \
    a2enconf servername && \
    # Disable default site and enable our configuration
    a2dissite 000-default && \
    # Configure document root in Apache
    echo '<VirtualHost *:8080>\n\
    DocumentRoot ${APACHE_DOCUMENT_ROOT}\n\
    <Directory "${APACHE_DOCUMENT_ROOT}">\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf && \
    # Enable the site
    a2ensite 000-default.conf

# Expose port 8080
EXPOSE 8080

# Set up storage and cache permissions
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Start Apache
CMD ["apache2-foreground"]