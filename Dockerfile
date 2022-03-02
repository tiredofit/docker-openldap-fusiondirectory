FROM tiredofit/openldap:7.1.16
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

## Set Environment Varialbes
ENV FUSIONDIRECTORY_VERSION=1.3 \
    SCHEMA2LDIF_VERSION=1.3

## Install Schema2LDIF
RUN set -x && \
    apk update && \
    apk upgrade && \
    apk add git && \
    curl https://repos.fusiondirectory.org/sources/schema2ldif/schema2ldif-${SCHEMA2LDIF_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr && \
    rm -rf /usr/CHANGELOG && \
    rm -rf /usr/LICENSE && \
    \
## Install FusionDirectory
    mkdir -p /usr/src/fusiondirectory /usr/src/fusiondirectory-plugins && \
    curl https://repos.fusiondirectory.org/sources/fusiondirectory/fusiondirectory-${FUSIONDIRECTORY_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/fusiondirectory && \
    curl https://repos.fusiondirectory.org/sources/fusiondirectory/fusiondirectory-plugins-${FUSIONDIRECTORY_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/fusiondirectory-plugins && \
    \
    ## Install Extra FusionDirectory Plugins
    git clone https://github.com/tiredofit/fusiondirectory-plugin-kopano /usr/src/fusiondirectory-plugin-kopano && \
    cp -R /usr/src/fusiondirectory-plugin-kopano/kopano /usr/src/fusiondirectory-plugins/ && \
    git clone https://github.com/slangdaddy/fusiondirectory-plugin-nextcloud /usr/src/fusiondirectory-plugin-nextcloud && \
    rm -rf /usr/src/fusiondirectory-plugin-nextcloud/src/DEBIAN && \
    mkdir -p /usr/src/fusiondirectory-plugins/nextcloud && \
    cp -R /usr/src/fusiondirectory-plugin-nextcloud/src/* /usr/src/fusiondirectory-plugins/nextcloud/ && \
    git clone https://github.com/gallak/fusiondirectory-plugins-seafile /usr/src/fusiondirectory-plugins-seafile && \
    rm -rf /usr/src/fusiondirectory-plugins-seafile/README.md && \
    mkdir -p /usr/src/fusiondirectory-plugins/seafile && \
    cp -R /usr/src/fusiondirectory-plugins-seafile/* /usr/src/fusiondirectory-plugins/seafile/ && \
    \
### Cleanup
    mkdir -p /etc/openldap/schema/fusiondirectory && \
    rm -rf /usr/src/fusiondirectory/contrib/openldap/rfc2307bis.schema && \
    cp /usr/src/fusiondirectory/contrib/bin/fusiondirectory-insert-schema /usr/sbin && \
    cp -R /usr/src/fusiondirectory/contrib/openldap/*.schema /etc/openldap/schema/fusiondirectory && \
    cp -R /usr/src/fusiondirectory-plugins/*/contrib/openldap/*.schema /etc/openldap/schema/fusiondirectory && \
    \
    sed -i -e "s|/etc/ldap/schema|/etc/openldap/schema|g" /usr/sbin/fusiondirectory-insert-schema && \
    chmod +x /usr/sbin/fusiondirectory-insert-schema && \
    chmod +x /assets/custom-scripts/*.sh && \
    \
    rm -rf /usr/src/* && \
    apk del git && \
    rm -rf /var/cache/apk/*

### Add Files
ADD install /
