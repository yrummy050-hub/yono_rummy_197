FROM php:8.1-apache

# Create system user to run Composer and Artisan commands
RUN useradd -G www-data,root -u 1000 -d /home/dockeruser dockeruser \
    && mkdir -p /home/dockeruser/.composer \
    && chown -R dockeruser:dockeruser /home/dockeruser

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

# Create necessary directories that might be missing but are required by Composer
RUN mkdir -p database/seeds database/factories database/migrations

# Copy composer files first to leverage Docker cache
COPY --chown=dockeruser:dockeruser composer.json composer.lock* ./

# Install PHP dependencies as non-root user
RUN if [ -f composer.lock ]; then \
        su -s /bin/bash -c "composer install --no-dev --optimize-autoloader --no-interaction --no-scripts" dockeruser; \
    else \
        su -s /bin/bash -c "composer update --no-dev --optimize-autoloader --no-interaction --no-scripts" dockeruser; \
    fi

# Copy application files
COPY --chown=dockeruser:dockeruser . .

# Set up storage and cache permissions
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && chown -R dockeruser:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Generate application key only if not set in environment
# RUN if [ -z "$APP_KEY" ]; then \
#         su -s /bin/bash -c "/usr/local/bin/php artisan key:generate --force" dockeruser; \
#     fi

# Apache configuration
RUN a2enmod rewrite
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf

# Set correct permissions for Apache
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type f -exec chmod 644 {} \; && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    chmod -R 777 storage bootstrap/cache

# Expose port 8080
EXPOSE 8080

# Configure Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN echo 'ServerName localhost' > /etc/apache2/conf-available/servername.conf && \
    echo 'Listen 8080' > /etc/apache2/ports.conf && \
    a2enmod rewrite headers && \
    a2enconf servername && \
    # Disable default site and enable our configuration
    a2dissite 000-default && \
    # Ensure the document root exists and has correct permissions
    mkdir -p ${APACHE_DOCUMENT_ROOT} && \
    chown -R www-data:www-data ${APACHE_DOCUMENT_ROOT} && \
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

# Start Apache
CMD ["apache2ctl", "-D", "FOREGROUND"]