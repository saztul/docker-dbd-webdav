FROM ubuntu:xenial

MAINTAINER Lutz Selke <ls@hfci.de>

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    MYSQL_AUTH_SERVER=127.0.0.1 \
    MYSQL_AUTH_DB=dav_auth \
    MYSQL_AUTH_USER=root \
    MYSQL_AUTH_PASSWORD="" \
    MYSQL_AUTH_PW_QUERY='SELECT ENCRYPT(password) FROM sessions WHERE user = %s' \
    MYSQL_AUTH_NAME='WEBDAV Server'

# Apache 2
RUN apt-get -y update && \
    apt-get -y install \
        mysql-client-5.7 \
        apache2 \
        libaprutil1-dbd-mysql

ADD ./dav-server.conf /etc/apache2/sites-available/dav-server.conf

# Apache vhost config
RUN mkdir -p /davserver/log && \
    mkdir -p /davserver/data/ && \
    chown -R www-data:www-data /davserver && \
    a2dissite 000-default default-ssl && \
    a2ensite dav-server && \
    a2dismod mpm_event && \
    a2enmod dbd authz_dbd authn_dbd mpm_prefork \
        alias auth_digest authn_core authn_file \
        authz_core authz_user dav dav_fs setenvif && \
    update-rc.d -f apache2 remove

EXPOSE 80

VOLUME '/davserver/log/'
VOLUME '/davserver/data/'

CMD ["/usr/sbin/apachectl", "-d", "/etc/apache2", "-e", "info", "-D", "FOREGROUND"]

