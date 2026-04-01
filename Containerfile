# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="OpenLDAP w/FusionDirectory" \
        org.opencontainers.image.description="Directory server with FusionDirectory schemas" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/openldap-fusiondirectory" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-openldap-fusiondirectory/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-openldap-fusiondirectory.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ARG \
    FUSIONDIRECTORY_VERSION="fusiondirectory-1.5" \
    FUSIONDIRECTORY_REPO_URL="https://github.com/fusiondirectory/fusiondirectory" \
    FUSIONDIRECTORY_INTEGRATOR_REPO_URL="https://github.com/fusiondirectory/fusiondirectory-integrator" \
    FUSIONDIRECTORY_INTEGRATOR_VERSION="1.2" \
    FUSIONDIRECTORY_ORCHESTRATOR_REPO_URL="https://github.com/fusiondirectory/fusiondirectory-orchestrator" \
    FUSIONDIRECTORY_ORCHESTRATOR_VERSION="1.1" \
    FUSIONDIRECTORY_PLUGINS_VERSION="fusiondirectory-1.5" \
    FUSIONDIRECTORY_PLUGINS_REPO_URL="https://github.com/fusiondirectory/fusiondirectory-plugins" \
    FUSIONDIRECTORY_TOOLS_VERSION="1.2" \
    FUSIONDIRECTORY_TOOLS_REPO_URL="https://github.com/fusiondirectory/fusiondirectory-tools" \
    PHP_VERSION="php-7.4.33" \
    PHP_REPO_URL="https://github.com/php/php-src"

ENV \
    IMAGE_NAME="nfrastack/openldap-fusiondirectory" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-openldap-fusiondirectory/"

RUN echo "" && \
    OPENLDAP_FUSIONDIRECTORY_BUILD_DEPS_ALPINE=" \
                                                    git \
                                               " && \
    OPENLDAP_FUSIONDIRECTORY_RUN_DEPS_ALPINE=" \
                                               " && \
    PHP_BUILD_DEPS_ALPINE=" \
                            autoconf \
                            automake \
                            bison \
                            build-base \
                            cyrus-sasl-dev \
                            libevent-dev \
                            libtool \
                            linux-headers \
                            musl-dev \
                            openssl-dev \
                            re2c \
                          " && \
    PHP_RUN_DEPS_ALPINE=" \
                            cyrus-sasl \
                            libevent \
                            #libxml2 \
                            openssl \
                        " && \
    source /container/base/functions/container/build && \
    container_build_log image && \
    package update && \
    package upgrade && \
    package install \
                    PHP_BUILD_DEPS \
                    PHP_RUN_DEPS \
                    && \
    clone_git_repo "${PHP_REPO_URL}" "${PHP_VERSION}" /usr/src/php && \
    curl -ssL https://gitlab.alpinelinux.org/alpine/aports/-/raw/3.19-stable/community/php81/fix-lfs64.patch?ref_type=heads -o /usr/src/php/fix-lfs64.patch && \
    patch -d /usr/src/php -p1 < /usr/src/php/fix-lfs64.patch && \
    ./buildconf --force && \
    ./configure \
                --prefix=/usr/local/php \
                --disable-all \
                --disable-cgi \
                --enable-cli \
                --disable-fpm \
                --disable-phpdbg \
                --enable-posix \
                --with-ldap \
                --with-ldap-sasl=/usr/include/sasl \
                && \
    make -j "$(nproc)" && \
    make install && \
    ln -s /usr/local/php/bin/php /usr/bin/php && \
    container_build_log add "PHP" "${PHP_VERSION}" "${PHP_REPO_URL}" && \
    \
    package install \
                    OPENLDAP_FUSIONDIRECTORY_BUILD_DEPS \
                    OPENLDAP_FUSIONDIRECTORY_RUN_DEPS \
                    && \
    clone_git_repo "${FUSIONDIRECTORY_INTEGRATOR_REPO_URL}" "${FUSIONDIRECTORY_INTEGRATOR_VERSION}" && \
    mkdir -p /usr/share/php/FusionDirectory/ && \
    cp -R "${GIT_REPO_SRC_FUSIONDIRECTORY_INTEGRATOR%/}"/src/* /usr/share/php/FusionDirectory && \
    container_build_log add "FusionDirectory Integrator" "${FUSIONDIRECTORY_INTEGRATOR_VERSION}" "${FUSIONDIRECTORY_INTEGRATOR_REPO_URL}"&& \
    clone_git_repo "${FUSIONDIRECTORY_TOOLS_REPO_URL}" "${FUSIONDIRECTORY_TOOLS_VERSION}" && \
    cp -aR "${GIT_REPO_SRC_FUSIONDIRECTORY_TOOLS%/}"/bin/* /usr/local/bin && \
    cp -aR "${GIT_REPO_SRC_FUSIONDIRECTORY_TOOLS%/}"/src/FusionDirectory/Tools /usr/share/php/FusionDirectory/FusionDirectory/ && \
    container_build_log add "FusionDirectory Tools" "${FUSIONDIRECTORY_TOOLS_VERSION}" "${FUSIONDIRECTORY_TOOLS_REPO_URL}" && \
    clone_git_repo "${FUSIONDIRECTORY_REPO_URL}" "${FUSIONDIRECTORY_VERSION}" /usr/src/fusiondirectory && \
    container_build_log add "FusionDirectory Schemas" "${FUSIONDIRECTORY_VERSION}" "${FUSIONDIRECTORY_REPO_URL}" && \
    clone_git_repo "${FUSIONDIRECTORY_PLUGINS_REPO_URL}" "${FUSIONDIRECTORY_PLUGINS_VERSION}" /usr/src/fusiondirectory-plugins && \
    container_build_log add "FusionDirectory Plugins Schemas" "${FUSIONDIRECTORY_PLUGINS_VERSION}" "${FUSIONDIRECTORY_PLUGINS_REPO_URL}" && \
    clone_git_repo https://github.com/tiredofit/fusiondirectory-plugin-kopano main /usr/src/fusiondirectory-plugin-kopano && \
    cp -R /usr/src/fusiondirectory-plugin-kopano/kopano "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGINS%/}" && \
    container_build_log add "FusionDirectory Kopano Plugin Schema" "main" "https://github.com/tiredofit/fusiondirectory-plugin-kopano" && \
    clone_git_repo https://github.com/gallak/fusiondirectory-plugins-seafile master /usr/src/fusiondirectory-plugins-seafile && \
    mkdir -p "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGINS%/}"/seafile && \
    cp -R /usr/src/fusiondirectory-plugins-seafile/* "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGINS%/}"/seafile/ && \
    container_build_log add "FusionDirectory Seafile Plugin Schema" "main" "https://github.com/gallak/fusiondirectory-plugins-seafile" && \
    clone_git_repo "${FUSIONDIRECTORY_ORCHESTRATOR_REPO_URL}" "${FUSIONDIRECTORY_ORCHESTRATOR_VERSION}" /usr/src/fusiondirectory-orchestrator && \
    mkdir -p "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGINS%/}"/orchestrator/contrib/openldap && \
    cp -aR /usr/src/fusiondirectory-orchestrator/contrib/openldap/fusiondirectory-orchestrator.schema "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGINS%/}"/orchestrator/contrib/openldap/orchestrator.schema && \
    container_build_log add "FusionDirectory Orchestrator Schema" "${FUSIONDIRECTORY_ORCHESTRATOR_VERSION}" "${FUSIONDIRECTORY_ORCHESTRATOR_REPO_URL}" && \
    mkdir -p /etc/openldap/schema/fusiondirectory && \
    rm -rf /usr/src/fusiondirectory/contrib/openldap/rfc2307bis.schema && \
    cp -R \
                "${GIT_REPO_SRC_FUSIONDIRECTORY%/}"/contrib/openldap/*.schema \
                "${GIT_REPO_SRC_FUSIONDIRECTORY_PLUGINS%/}"/*/contrib/openldap/*.schema \
            /etc/openldap/schema/fusiondirectory && \
    \
    package remove \
                    OPENLDAP_FUSIONDIRECTORY_BUILD_DEPS \
                    PHP_BUILD_DEPS \
                    && \
    package cleanup

COPY rootfs /
