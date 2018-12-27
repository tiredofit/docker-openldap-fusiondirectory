FROM tiredofit/openldap:latest
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

## Set Environment Varialbes
ENV FUSIONDIRECTORY_VERSION=1.2.3 \
    SCHEMA2LDIF_VERSION=1.3
    
## Install Schema2LDIF
RUN curl https://gitlab.fusiondirectory.org/fusiondirectory/schema2ldif/-/archive/${SCHEMA2LDIF_VERSION}/schema2ldif-${SCHEMA2LDIF_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr && \
    rm -rf /usr/CHANGELOG && \
    rm -rf /usr/LICENSE && \
    \
## Install FusionDirectory
    mkdir -p /usr/src/fusiondirectory /usr/src/fusiondirectory-plugins && \
    curl https://gitlab.fusiondirectory.org/fusiondirectory/fd/-/archive/fusiondirectory-${FUSIONDIRECTORY_VERSION}/fd-fusiondirectory-${FUSIONDIRECTORY_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/fusiondirectory && \
    curl https://gitlab.fusiondirectory.org/fusiondirectory/fd-plugins/-/archive/fusiondirectory-${FUSIONDIRECTORY_VERSION}/fd-plugins-fusiondirectory-${FUSIONDIRECTORY_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/fusiondirectory-plugins && \
    \
### Cleanup
    \
    mkdir -p /etc/openldap/schema/fusiondirectory && \
    rm -rf /usr/src/fusiondirectory/contrib/openldap/rfc2307bis.schema && \
    cp /usr/src/fusiondirectory/contrib/bin/fusiondirectory-insert-schema /usr/sbin && \
    cp -R /usr/src/fusiondirectory/contrib/openldap/*.schema /etc/openldap/schema/fusiondirectory && \
    cp -R /usr/src/fusiondirectory-plugins/*/contrib/openldap/*.schema /etc/openldap/schema/fusiondirectory && \
    \
    sed -i -e "s|/etc/ldap/schema|/etc/openldap/schema|g" /usr/sbin/fusiondirectory-insert-schema && \
    chmod +x /usr/sbin/fusiondirectory-insert-schema && \
    \
    rm -rf /usr/src/*

### Add Files
   ADD install /
