#!/command/with-contenv bash

source /assets/functions/00-container
prepare_service both

PROCESS_NAME="openldap-fusiondirectory"

FUSIONDIRECTORY_INSTALLED="/etc/openldap/slapd.d/docker-openldap-fusiondirectory-was-installed"

if [ -e "$FUSIONDIRECTORY_INSTALLED" ]; then
	if [ -d /assets/fusiondirectory-custom/ ] ; then
		if var_true "${REAPPLY_PLUGIN_SCHEMAS}" ; then
			mkdir -p /tmp/schema
			mv /etc/openldap/schema/fusiondirectory/* /tmp/schema

			for custom_schema in $(find /assets/fusiondirectory-custom/ -name \*.schema -type f) ; do
				print_notice "Found Custom Schema: ${custom_schema}"
				cp -R "${custom_schema}" /etc/openldap/schema/fusiondirectory
			done

			cd /etc/openldap/schema/fusiondirectory
			print_notice "Attempting to Install new Schemas"
			silent fusiondirectory-insert-schema -i *.schema
			silent fusiondirectory-insert-schema -m *.schema
			cd /tmp
			rm -rf /etc/openldap/schema/fusiondirectory/*
			mv /tmp/schema/* /etc/openldap/schema/fusiondirectory/
		fi
	fi
fi
