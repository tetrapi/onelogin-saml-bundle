FROM php:8.2-cli

# Set environment variables
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/composer \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    wget \
    libzip-dev \
    libpq-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Add Palo Alto SSL Inspection certificate
RUN wget -O PaloAlto_SSLInspection_ForwardTrust.crt https://tetrapi.pt/gp/PaloAlto_SSLInspection_ForwardTrust.crt
RUN cp PaloAlto_SSLInspection_ForwardTrust.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Set timezone (as an optional step)
RUN echo "UTC" >> /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configure npm to trust the Palo Alto SSL Inspection certificate
RUN npm config set cafile /usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt
RUN npm config set strict-ssl false
RUN echo 'cafile "/usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt"' >> ~/.yarnrc
RUN echo 'strict-ssl false' >> ~/.yarnrc
RUN echo 'httpsCaFilePath: "/usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt"' >> ~/.yarnrc.yml
RUN echo 'enableStrictSsl: false' >> ~/.yarnrc.yml

# Create and set the working directory
WORKDIR /app

# Copy application files
COPY . .

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Build arguments for the version (passed via GitLab CI)
ARG CICDVERSION
ENV APP_VERSION=$CICDVERSION

# Entry point for the container (adjust as needed)
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public/"]
