FROM docker.io/tiredofit/openldap:2.6-7.4.1
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG FUSIONDIRECTORY_VERSION
ARG FUSIONDIRECTORY_PLUGINS_VERSION

ENV FUSIONDIRECTORY_VERSION=b246399ff2d3dc74565c9f3897e4a3544e0c51d1 \
    FUSIONDIRECTORY_REPO_URL=https://github.com/fusiondirectory/fusiondirectory \
    FUSIONDIRECTORY_PLUGINS_VERSION=b0078c722634cbd42fe2b0231eb8d40c6d87df3e \
    FUSIONDIRECTORY_PLUGINS_REPO_URL=https://github.com/fusiondirectory/fusiondirectory-plugins \
    IMAGE_NAME="tiredofit/openldap-fusiondirectory" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-openldap-fusiondirectory/"

RUN source /assets/functions/00-container && \
    set -x && \
    package update && \
    package upgrade && \
    package install git && \
    \
    ## Fetch Install FusionDirectory
    clone_git_repo "${FUSIONDIRECTORY_REPO_URL}" "${FUSIONDIRECTORY_VERSION}" /usr/src/fusiondirectory && \
    clone_git_repo "${FUSIONDIRECTORY_PLUGINS_REPO_URL}" "${FUSIONDIRECTORY_PLUGINS_VERSION}" /usr/src/fusiondirectory-plugins && \
    \
    ## Fetch Install Extra FusionDirectory Plugins
    clone_git_repo https://github.com/tiredofit/fusiondirectory-plugin-kopano main /usr/src/fusiondirectory-plugin-kopano && \
    cp -R /usr/src/fusiondirectory-plugin-kopano/kopano /usr/src/fusiondirectory-plugins/ && \
    clone_git_repo https://github.com/slangdaddy/fusiondirectory-plugin-nextcloud master /usr/src/fusiondirectory-plugin-nextcloud && \
    rm -rf /usr/src/fusiondirectory-plugin-nextcloud/src/DEBIAN && \
    mkdir -p /usr/src/fusiondirectory-plugins/nextcloud && \
    cp -R /usr/src/fusiondirectory-plugin-nextcloud/src/* /usr/src/fusiondirectory-plugins/nextcloud/ && \
    clone_git_repo https://github.com/gallak/fusiondirectory-plugins-seafile master /usr/src/fusiondirectory-plugins-seafile && \
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
    package remove git && \
    package cleanup

### Add Files
COPY install /
