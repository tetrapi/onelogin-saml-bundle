FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update \
  && apt-get -y install software-properties-common wget curl zip unzip git openssl gnupg tzdata \
  && rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt https://tetrapi.pt/gp/PaloAlto_SSLInspection_ForwardTrust.crt \
  && update-ca-certificates

RUN echo "UTC" > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata

RUN add-apt-repository ppa:ondrej/php \
  && apt-get update \
  && apt-get -y install php8.2-cli php8.2-curl php8.2-mbstring php8.2-zip php8.2-xml php8.2-intl \
  && rm -rf /var/lib/apt/lists/*

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php --install-dir=/usr/bin --filename=composer \
  && rm composer-setup.php \
  && composer self-update --2

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs yarn \
  && rm -rf /var/lib/apt/lists/*

RUN npm config set cafile /usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt \
  && npm config set strict-ssl false \
  && echo 'cafile "/usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt"' >> ~/.yarnrc \
  && echo 'strict-ssl false' >> ~/.yarnrc \
  && echo 'httpsCaFilePath: "/usr/local/share/ca-certificates/PaloAlto_SSLInspection_ForwardTrust.crt"' >> ~/.yarnrc.yml \
  && echo 'enableStrictSsl: false' >> ~/.yarnrc.yml

WORKDIR /var/www/onelogin-saml-bundle

COPY . /var/www/onelogin-saml-bundle/

RUN composer install --no-dev --optimize-autoloader

RUN if [ -f "package.json" ]; then npm install && npm run build; fi

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public/"]