# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set non-interactive environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install only essential system dependencies
RUN apt-get update \
  && apt-get -y install software-properties-common wget curl zip unzip git openssl gnupg tzdata \
  && rm -rf /var/lib/apt/lists/*

# Add the Palo Alto SSL Inspection certificate
RUN wget -O /usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt https://tetrapi.pt/gp/PaloAlto_SSLInspection_ForwardTrust.crt \
  && update-ca-certificates

# Set the timezone
RUN echo "UTC" > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata

# Add the PHP repository and install PHP 8.2 with essential extensions
RUN add-apt-repository ppa:ondrej/php \
  && apt-get update \
  && apt-get -y install php8.2-cli php8.2-curl php8.2-mbstring php8.2-zip php8.2-xml php8.2-intl \
  && rm -rf /var/lib/apt/lists/*

# Install Composer globally
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php --install-dir=/usr/bin --filename=composer \
  && rm composer-setup.php \
  && composer self-update --2

# Install Node.js 20 and Yarn for optional frontend builds
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs yarn \
  && rm -rf /var/lib/apt/lists/*

# Configure npm and Yarn to trust the Palo Alto SSL Inspection certificate
RUN npm config set cafile /usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt \
  && npm config set strict-ssl false \
  && echo 'cafile "/usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt"' >> ~/.yarnrc \
  && echo 'strict-ssl false' >> ~/.yarnrc \
  && echo 'httpsCaFilePath: "/usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt"' >> ~/.yarnrc.yml \
  && echo 'enableStrictSsl: false' >> ~/.yarnrc.yml

# Set the working directory for the application
WORKDIR /var/www/onelogin-saml-bundle

# Copy application files
COPY . /var/www/onelogin-saml-bundle/

# Install PHP dependencies using Composer (exclude dev dependencies)
RUN composer install --no-dev --optimize-autoloader

# Optional: Build frontend assets if needed
RUN if [ -f "package.json" ]; then npm install && npm run build; fi

# Define the entry point
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public/"]