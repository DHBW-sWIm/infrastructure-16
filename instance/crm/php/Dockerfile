FROM php:7.2-apache
ARG SWIM_CRM_CLONE_GIT_REPO_URL
RUN apt-get update && apt-get install -y git mysql-client
RUN cd /var/www/html/ && git clone "${SWIM_CRM_CLONE_GIT_REPO_URL}"
RUN mkdir /db_backup
RUN cd /db_backup && git clone --single-branch --branch db_backup "${SWIM_CRM_CLONE_GIT_REPO_URL}"
RUN docker-php-ext-install pdo pdo_mysql mysqli
RUN a2enmod rewrite
#Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=. --filename=composer
RUN mv composer /usr/local/bin/
COPY run_crm.sh /run_crm.sh
RUN chmod +x "/run_crm.sh"
ENTRYPOINT "/run_crm.sh"
