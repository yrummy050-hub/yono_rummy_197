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
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath zip intl

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Create required directories with proper permissions
RUN mkdir -p database/seeds database/factories database/migrations \
    && mkdir -p storage/framework/{sessions,views,cache} \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# Copy application files
COPY --chown=www-data:www-data . .

# Install dependencies (skip scripts during install)
RUN composer install --no-scripts --no-interaction --optimize-autoloader --no-dev

# Run package discovery and optimization after all files are in place
RUN php artisan package:discover --no-interaction

# Configure Apache for Render
ENV APACHE_DOCUMENT_ROOT=/var/www/public
ENV PORT=8080

# Configure Apache
RUN a2enmod rewrite headers \
    && echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername \
    && echo "Listen ${PORT}" > /etc/apache2/ports.conf \
    && echo '# Virtual Host configuration' > /etc/apache2/sites-available/000-default.conf \
    && echo '<VirtualHost *:${PORT}>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    DocumentRoot ${APACHE_DOCUMENT_ROOT}' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    <Directory "${APACHE_DOCUMENT_ROOT}">' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        Options -Indexes +FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf \
    && echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf \
    && echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf \
    && echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf \
    && a2dissite 000-default \
    && a2ensite 000-default.conf

# Set proper permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# Generate application key if not set
RUN if [ -z "$APP_KEY" ]; then \
        php artisan key:generate --force; \
    fi

# Clear all caches
RUN php artisan config:clear \
    && php artisan cache:clear \
    && php artisan view:clear \
    && php artisan route:clear

# Expose the port the app runs on
EXPOSE ${PORT}

# Start Apache in the foreground
CMD ["apache2-foreground"]