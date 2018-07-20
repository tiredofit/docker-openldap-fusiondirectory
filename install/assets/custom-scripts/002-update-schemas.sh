#!/usr/bin/with-contenv bash

FUSIONDIRECTORY_INSTALLED="/etc/openldap/slapd.d/docker-openldap-fusiondirectory-was-installed" 

if [ "$DEBUG_MODE" = "TRUE" ] || [ "$DEBUG_MODE" = "true" ];  then
  set -x
fi

silent() {
  if [ "$DEBUG_MODE" = "TRUE" ] || [ "$DEBUG_MODE" = "true" ];  then
    "$@"
  else
    "$@" > /dev/null 2>&1
  fi
}

if [ -e "$FUSIONDIRECTORY_INSTALLED" ]; then
	  if [ -f /assets/fusiondirectory-custom/ ] ; then
	    mkdir -p /tmp/schema
	    mv /etc/openldap/schema/fusiondirectory/* /tmp/schema
	  
        for f in $(find /assets/fusiondirectory-custom/ -name \*.schema -type f); do
	        echo "** [openldap-fusiondirectory] Found Custom Schema: ${f}"
	        cp -R ${f} /etc/openldap/schema/fusiondirectory
        done
	    
	    cd /etc/ldap/schema/fusiondirectory
	    echo "** [openldap-fusiondirectory] Attempting to Install new Schemas"
	    silent fusiondirectory-insert-schema -i *.schema
	    silent fusiondirectory-insert-schema -m *.schema
	    cd /tmp
	    rm -rf /etc/openldap/schema/fusiondirectory/*
	    mv /tmp/schema/* /etc/openldap/schema/fusiondirectory/*
	  fi
fi
