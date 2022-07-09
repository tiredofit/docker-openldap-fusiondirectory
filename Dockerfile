FROM docker.io/tiredofit/openldap:2.6-7.2.10
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

## Set Environment Varialbes
ENV FUSIONDIRECTORY_VERSION=1.4-dev \
    FUSIONDIRECTORY_PLUGINS_VERSION=1.4-dev \
    IMAGE_NAME="tiredofit/openldap-fusiondirectory" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-openldap-fusiondirectory/"

## Install Schema2LDIF
RUN set -x && \
    apk update && \
    apk upgrade && \
    apk add git && \
    \
## Install FusionDirectory
    mkdir -p /usr/src/fusiondirectory /usr/src/fusiondirectory-plugins && \
    git clone https://gitlab.fusiondirectory.org/fusiondirectory/fd/ /usr/src/fusiondirectory && \
    cd /usr/src/fusiondirectory && \
    git checkout ${FUSIONDIRECTORY_VERSION} && \
    git clone https://gitlab.fusiondirectory.org/fusiondirectory/fd-plugins/ /usr/src/fusiondirectory-plugins && \
    cd /usr/src/fusiondirectory-plugins && \
    git checkout ${FUSIONDIRECTORY_PLUGINS_VERSION} && \
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
    \
    rm -rf /usr/src/* && \
    apk del git && \
    rm -rf /var/cache/apk/*

### Add Files
ADD install /
