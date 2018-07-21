#!/usr/bin/with-contenv bash

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

FUSIONDIRECTORY_INSTALLED="/etc/openldap/slapd.d/docker-openldap-fusiondirectory-was-installed" 

if [ ! -e ${FUSIONDIRECTORY_INSTALLED} ]; then
	echo "** [openldap-fusiondirectory] First time Fusion Directory install detected"


	if [ -z "$BASE_DN" ]; then
	    IFS='.' read -ra BASE_DN_TABLE <<< "$DOMAIN"
	    for i in "${BASE_DN_TABLE[@]}"; do
	      EXT="dc=$i,"
	      BASE_DN=$BASE_DN$EXT
	    done

	    BASE_DN=${BASE_DN::-1}
	  fi

	IFS='.' read -a domain_elems <<< "${DOMAIN}"
	SUFFIX=""
	ROOT=""

	for elem in "${domain_elems[@]}" ; do
	    if [ "x${SUFFIX}" = x ] ; then
	        SUFFIX="dc=${elem}"
	        ROOT="${elem}"
	    else
	        BASE_DN="${SUFFIX},dc=${elem}"
	    fi
	done

	CN_ADMIN="cn=admin,ou=aclroles,${BASE_DN}"
	CN_ADMIN_BS64=$(echo -n ${CN_ADMIN} | base64 | tr -d '\n')
	FUSIONDIRECTORY_ADMIN_USER=${FUSIONDIRECTORY_ADMIN_USER:-fd-admin}
	FUSIONDIRECTORY_ADMIN_PASS=${FUSIONDIRECTORY_ADMIN_PASS:-"admin"}
	ORGANIZATION=${ORGANIZATION:-Example Organization}
	UID_FD_ADMIN="uid=${FUSIONDIRECTORY_ADMIN_USER},${BASE_DN}"
	UID_FD_ADMIN_BS64=$(echo -n ${UID_FD_ADMIN} | base64 | tr -d '\n')

	### Step 1
	if [ "$ENABLE_READONLY_USER" = "TRUE" ] || [ "$ENABLE_READONLY_USER" = "true" ];  then
	    cat <<EOF >> /tmp/01-fusiondirectory-delete.ldif
dn: cn=${READONLY_USER_USER},${BASE_DN}
changetype: delete

EOF
	fi

	cat <<EOF >> /tmp/01-fusiondirectory-delete.ldif
dn: cn=admin,${BASE_DN}
changetype: delete

dn: ${BASE_DN}
changetype: delete

EOF

	silent ldapmodify -H 'ldapi:///' -D "cn=admin,$BASE_DN" -w $ADMIN_PASS -f /tmp/01-fusiondirectory-delete.ldif
	
	### Install Core Fusion Directory Schemas
	silent fusiondirectory-insert-schema

    ### Step 2
	cat <<EOF > /tmp/02-fusiondirectory-base.ldif
dn: ${BASE_DN}
changeType: add
o: ${ORGANIZATION}
dc: ${ROOT}
ou: ${ROOT}
description: ${ROOT}
objectClass: top
objectClass: dcObject
objectClass: organization
objectClass: gosaDepartment
objectClass: gosaAcl
gosaAclEntry: 0:subtree:${CN_ADMIN_BS64}:${UID_FD_ADMIN_BS64}

dn: cn=admin,${BASE_DN}
changeType: add
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword: ${ADMIN_PASS}

EOF

	if [ "$ENABLE_READONLY_USER" = "TRUE" ] || [ "$ENABLE_READONLY_USER" = "true" ];  then
    	cat <<EOF >> /tmp/02-fusiondirectory-base.ldif

dn: cn=${READONLY_USER_USER},${BASE_DN}
changeType: add
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: cn=${READONLY_USER_USER}
description: LDAP read only user
userPassword: ${READONLY_USER_PASS}
EOF
	fi
    
	silent ldapmodify -H 'ldapi:///' -D "cn=admin,${BASE_DN}" -w $ADMIN_PASS -f /tmp/02-fusiondirectory-base.ldif

    ### Step 3
	cat <<EOF > /tmp/03-fusiondirectory-add.ldif
dn: uid=${FUSIONDIRECTORY_ADMIN_USER},${BASE_DN}
changeType: add
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
cn: System Administrator
sn: Administrator
givenName: System
uid: ${FUSIONDIRECTORY_ADMIN_USER}
userPassword: ${FUSIONDIRECTORY_ADMIN_PASS}

dn: ou=aclroles,${BASE_DN}
changeType: add
objectClass: organizationalUnit
ou: aclroles

dn: cn=admin,ou=aclroles,${BASE_DN}
changeType: add
objectClass: top
objectClass: gosaRole
cn: admin
description: Gives all rights on all objects
gosaAclTemplate: 0:all;cmdrw

dn: cn=manager,ou=aclroles,${BASE_DN}
changeType: add
cn: manager
description: Give all rights on users in the given branch
objectClass: top
objectClass: gosaRole
gosaAclTemplate: 0:user/password;cmdrw,user/user;cmdrw,user/posixAccount;cmdrw

dn: cn=editowninfos,ou=aclroles,${BASE_DN}
changeType: add
cn: editowninfos
description: Allow users to edit their own information (main tab and posix use
  only on base)
objectClass: top
objectClass: gosaRole
gosaAclTemplate: 0:user/posixAccount;srw,user/user;srw

dn: ou=fusiondirectory,${BASE_DN}
changeType: add
objectClass: organizationalUnit
ou: fusiondirectory

dn: ou=tokens,ou=fusiondirectory,${BASE_DN}
changeType: add
objectClass: organizationalUnit
ou: tokens

dn: cn=config,ou=fusiondirectory,${BASE_DN}
changeType: add
fdTheme: default
fdTimezone: `cat /etc/timezone`
fusionConfigMd5: 7fd38d273a2f2e14c749467f4c38a650
fdSchemaCheck: TRUE
fdPasswordDefaultHash: ssha
fdListSummary: TRUE
fdModificationDetectionAttribute: entryCSN
fdLogging: TRUE
fdLdapSizeLimit: 200
fdLoginAttribute: uid
fdWarnSSL: TRUE
fdSessionLifeTime: 1800
fdEnableSnapshots: TRUE
fdSnapshotBase: ou=snapshots,${BASE_DN}
fdSslKeyPath: /etc/ssl/private/fd.key
fdSslCertPath: /etc/ssl/certs/fd.cert
fdSslCaCertPath: /etc/ssl/certs/ca.cert
fdCasServerCaCertPath: /etc/ssl/certs/ca.cert
fdCasHost: localhost
fdCasPort: 443
fdCasContext: /cas
fdAccountPrimaryAttribute: uid
fdCnPattern: %givenName% %sn%
fdStrictNamingRules: TRUE
fdMinId: 100
fdUidNumberBase: 1100
fdGidNumberBase: 1100
fdUserRDN: ou=people
fdGroupRDN: ou=groups
fdAclRoleRDN: ou=aclroles
fdIdAllocationMethod: traditional
fdDebugLevel: 0
fdShells: /bin/ash
fdShells: /bin/bash
fdShells: /bin/csh
fdShells: /bin/sh
fdShells: /bin/ksh
fdShells: /bin/tcsh
fdShells: /bin/dash
fdShells: /bin/zsh
fdShells: /sbin/nologin
fdShells: /bin/false
fdForcePasswordDefaultHash: FALSE
fdHandleExpiredAccounts: FALSE
fdForceSSL: FALSE
fdHttpAuthActivated: FALSE
fdCasActivated: FALSE
fdRestrictRoleMembers: FALSE
fdDisplayErrors: FALSE
fdLdapStats: FALSE
fdDisplayHookOutput: FALSE
fdAclTabOnObjects: FALSE
cn: config
fdOGroupRDN: ou=groups
fdForceSaslPasswordAsk: FALSE
fdDashboardNumberOfDigit: 3
fdDashboardPrefix: PC
fdDashboardExpiredAccountsDays: 15
objectClass: fusionDirectoryConf
objectClass: fusionDirectoryPluginsConf
objectClass: fdDashboardPluginConf
objectClass: fdPasswordRecoveryConf
fdPasswordRecoveryActivated: FALSE
fdPasswordRecoveryEmail: to.be@chang.ed
fdPasswordRecoveryValidity: 10
fdPasswordRecoverySalt: SomethingSecretAndVeryLong
fdPasswordRecoveryUseAlternate: FALSE
fdPasswordRecoveryMailSubject: [FusionDirectory] Password recovery link
fdPasswordRecoveryMailBody:: SGVsbG8sCgpIZXJlIGFyZSB5b3VyIGluZm9ybWF0aW9ucyA6I
 AogLSBMb2dpbiA6ICVzCiAtIExpbmsgOiAlcwoKVGhpcyBsaW5rIGlzIG9ubHkgdmFsaWQgZm9yID
 EwIG1pbnV0ZXMu
fdPasswordRecoveryMail2Subject: [FusionDirectory] Password recovery successful
fdPasswordRecoveryMail2Body:: SGVsbG8sCgpZb3VyIHBhc3N3b3JkIGhhcyBiZWVuIGNoYW5n
 ZWQuCllvdXIgbG9naW4gaXMgc3RpbGwgJXMu

dn: ou=locks,ou=fusiondirectory,${BASE_DN}
changeType: add
objectClass: organizationalUnit
ou: locks

dn: ou=snapshots,${BASE_DN}
changeType: add
objectClass: organizationalUnit
ou: snapshots
EOF

	silent ldapmodify -H 'ldapi:///' -D "cn=admin,${BASE_DN}" -w $ADMIN_PASS -f /tmp/03-fusiondirectory-add.ldif

### Step 4
	cat <<EOF > /tmp/04-fusiondirectory-ppolicy.ldif
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: ppolicy

dn: olcOverlay=ppolicy,olcDatabase={1}${BACKEND},cn=config
objectClass: olcConfig
objectClass: olcOverlayConfig
objectClass: olcPpolicyConfig
olcOverlay: ppolicy
olcPPolicyDefault: cn=default,ou=ppolicies,${BASE_DN}
olcPPolicyUseLockout: TRUE
olcPPolicyHashCleartext: TRUE
EOF

	silent ldapmodify -H 'ldapi:///' -D "cn=admin,${BASE_DN}" -w $ADMIN_PASS -f /tmp/04-fusiondirectory-ppolicy.ldif
    rm -rf /tmp/*.ldif
fi

### Insert Plugin Schemas
if [ ! -e ${FUSIONDIRECTORY_INSTALLED} ] || [ "$REAPPLY_PLUGIN_SCHEMAS" = "TRUE" ] || [ "$REAPPLY_PLUGIN_SCHEMAS" = "true" ];  then
  ### Determine which plugins we want installed 
  PLUGIN_ALIAS=${PLUGIN_ALIAS:-"FALSE"}
  PLUGIN_APPLICATIONS=${PLUGIN_APPLICATIONS:-"FALSE"}
  PLUGIN_ARGONAUT=${PLUGIN_ARGONAUT:-"FALSE"}
  PLUGIN_AUDIT=${PLUGIN_AUDIT:-"TRUE"}
  PLUGIN_AUTOFS=${PLUGIN_AUTOFS:-"FALSE"}
  PLUGIN_CERTIFICATES=${PLUGIN_CERTIFICATES:-"FALSE"}
  PLUGIN_COMMUNITY=${PLUGIN_COMMUNITY:-"FALSE"}
  PLUGIN_CYRUS=${PLUGIN_CYRUS:-"FALSE"}
  PLUGIN_DEBCONF=${PLUGIN_DEBCONF:-"FALSE"}
  PLUGIN_DEVELOPERS=${PLUGIN_DEVELOPERS:-"FALSE"}
  PLUGIN_DHCP=${PLUGIN_DHCP:-"FALSE"}
  PLUGIN_DNS=${PLUGIN_DNS:-"FALSE"}
  PLUGIN_DOVECOT=${PLUGIN_DOVECOT:-"FALSE"}
  PLUGIN_DSA=${PLUGIN_DSA:-"TRUE"}
  PLUGIN_EJBCA=${PLUGIN_EJBCA:-"FALSE"}
  PLUGIN_FAI=${PLUGIN_FAI:-"FALSE"}
  PLUGIN_FREERADIUS=${PLUGIN_FREERADIUS:-"FALSE"}
  PLUGIN_FUSIONINVENTORY=${PLUGIN_FUSIONINVENTORY:-"FALSE"}
  PLUGIN_GPG=${PLUGIN_GPG:-"FALSE"}
  PLUGIN_IPMI=${PLUGIN_IPMI:-"FALSE"}
  PLUGIN_LDAPDUMP=${PLUGIN_LDAPDUMP:-"TRUE"}
  PLUGIN_LDAPMANAGER=${PLUGIN_LDAPMANAGER:-"TRUE"}
  PLUGIN_MAIL=${PLUGIN_MAIL:-"TRUE"}
  PLUGIN_MIXEDGROUPS=${PLUGIN_MIXEDGROUPS:-"TRUE"}
  PLUGIN_NAGIOS=${PLUGIN_NAGIOS:-"FALSE"}
  PLUGIN_NETGROUPS=${PLUGIN_NETGROUPS:-"FALSE"}
  PLUGIN_NEWSLETTER=${PLUGIN_NEWSLETTER:-"FALSE"}
  PLUGIN_OPSI=${PLUGIN_OPSI:-"FALSE"}
  PLUGIN_PERSONAL=${PLUGIN_PERSONAL:-"TRUE"}
  PLUGIN_POSIX=${PLUGIN_POSIX:-"FALSE"}
  PLUGIN_POSTFIX=${PLUGIN_POSTFIX:-"FALSE"}
  PLUGIN_PPOLICY=${PLUGIN_PPOLICY:-"TRUE"}
  PLUGIN_PUPPET=${PLUGIN_PUPPET:-"FALSE"}
  PLUGIN_PUREFTPD=${PLUGIN_PUREFTPD:-"FALSE"}
  PLUGIN_QUOTA=${PLUGIN_QUOTA:-"FALSE"}
  PLUGIN_RENATER_PARTAGE=${PLUGIN_RENATER_PARTAGE:-"FALSE"}
  PLUGIN_REPOSITORY=${PLUGIN_REPOSITORY:-"FALSE"}
  PLUGIN_SAMBA=${PLUGIN_SAMBA:-"FALSE"}
  PLUGIN_SOGO=${PLUGIN_SOGO:-"FALSE"}
  PLUGIN_SPAMASSASSIN=${PLUGIN_SPAMASSASSIN:-"FALSE"}
  PLUGIN_SQUID=${PLUGIN_SQUID:-"FALSE"}
  PLUGIN_SSH=${PLUGIN_SSH:-"TRUE"}
  PLUGIN_SUBCONTRACTING=${PLUGIN_SUBCONTRACTING:-"FALSE"}
  PLUGIN_SUDO=${PLUGIN_SUDO:-"TRUE"}
  PLUGIN_SUPANN=${PLUGIN_SUPANN:-"FALSE"}
  PLUGIN_SYMPA=${PLUGIN_SYMPA:-"FALSE"}
  PLUGIN_SYSTEMS=${PLUGIN_SYSTEMS:-"TRUE"}
  PLUGIN_USER_REMINDER=${PLUGIN_USER_REMINDER:-"FALSE"}
  PLUGIN_WEBLINK=${PLUGIN_WEBLINK:-"FALSE"}
  PLUGIN_WEBSERVICE=${PLUGIN_WEBSERVICE:-"FALSE"}

fd_apply() {
  if [ "$REAPPLY_PLUGIN_SCHEMAS" = "TRUE" ] || [ "$REAPPLY_PLUGIN_SCHEMAS" = "true" ];  then
    RE="Re"
    A="a"
    ARG="-m"
  else 
  	A="A"
  	ARG="-i"
  fi
  echo "** [openldap-fusiondirectory] ${RE}${A}pplying Fudion Directory "$@" schema"
}

## Handle the core plugins
  if [ "$REAPPLY_PLUGIN_SCHEMAS" = "TRUE" ] || [ "$REAPPLY_PLUGIN_SCHEMAS" = "true" ];  then
  	fd_apply core
  	fusiondirectory-insert-schema -m core*.schema
  	fusiondirectory-insert-schema -m ldapns.schema
  	fusiondirectory-insert-schema -m template-fd.schema
  fi

### Import / Modify Schemas - Put Mail First
  if [[ "$PLUGIN_MAIL" != "FALSE" ]] && [[ "$PLUGIN_MAIL" != "false" ]];  then
    fd_apply mail
    silent fusiondirectory-insert-schema $ARG mail*.schema
  fi
  
  if [[ "$PLUGIN_SYSTEMS" != "FALSE" ]] && [[ "$PLUGIN_SYSTEMS" != "false" ]];  then
    fd_apply systems
    silent fusiondirectory-insert-schema $ARG service*.schema
    silent fusiondirectory-insert-schema $ARG systems*.schema
  fi
  if [[ "$PLUGIN_AUDIT" != "FALSE" ]] && [[ "$PLUGIN_AUDIT" != "false" ]];  then
    fd_apply audit
    silent fusiondirectory-insert-schema $ARG audit*.schema
  fi

  if [[ "$PLUGIN_ALIAS" != "FALSE" ]] && [[ "$PLUGIN_ALIAS" != "false" ]];  then
    fd_apply alias
    silent fusiondirectory-insert-schema $ARG alias*.schema
  fi
  
  if [[ "$PLUGIN_APPLICATIONS" != "FALSE" ]] && [[ "$PLUGIN_APPLICATIONS" != "false" ]];  then
    fd_apply applications
    silent fusiondirectory-insert-schema $ARG applications*.schema
  fi

  if [[ "$PLUGIN_ARGONAUT" != "FALSE" ]] && [[ "$PLUGIN_ARGONAUT" != "false" ]];  then
    fd_apply argonaut
    silent fusiondirectory-insert-schema $ARG argonaut*.schema
  fi
  
  if [[ "$PLUGIN_COMMUNITY" != "FALSE" ]] && [[ "$PLUGIN_COMMUNITY" != "false" ]];  then
  	fd_apply community
    silent fusiondirectory-insert-schema $ARG community*.schema
  fi

  if [[ "$PLUGIN_CYRUS" != "FALSE" ]] && [[ "$PLUGIN_CYRUS" != "false" ]];  then
    fd_apply cyrus
    silent fusiondirectory-insert-schema $ARG cyrus*.schema
  fi

  if [[ "$PLUGIN_DEBCONF" != "FALSE" ]] && [[ "$PLUGIN_DEBCONF" != "false" ]];  then
    fd_apply debconf
    silent fusiondirectory-insert-schema $ARG debconf*.schema
  fi

  if [[ "$PLUGIN_DHCP" != "FALSE" ]] && [[ "$PLUGIN_DHCP" != "false" ]];  then
    fd_apply DHCP
    silent fusiondirectory-insert-schema $ARG dhcp*.schema
  fi

  if [[ "$PLUGIN_DNS" != "FALSE" ]] && [[ "$PLUGIN_DNS" != "false" ]];  then
    fd_apply DNS
    silent fusiondirectory-insert-schema $ARG dns*.schema
  fi

  if [[ "$PLUGIN_DOVECOT" != "FALSE" ]] && [[ "$PLUGIN_DOVECOT" != "false" ]];  then
    fd_apply dovecot
    silent fusiondirectory-insert-schema $ARG dovecot*.schema
  fi

  if [[ "$PLUGIN_DSA" != "FALSE" ]] && [[ "$PLUGIN_DSA" != "false" ]];  then
    fd_apply DSA
    silent fusiondirectory-insert-schema $ARG dsa*.schema
  fi

  if [[ "$PLUGIN_EJBCA" != "FALSE" ]] && [[ "$PLUGIN_EJBCA" != "false" ]];  then
    fd_apply ejbca
    silent fusiondirectory-insert-schema $ARG ejbca*.schema
  fi

  if [[ "$PLUGIN_FAI" != "FALSE" ]] && [[ "$PLUGIN_FAI" != "false" ]];  then
    fd_apply FAI
    silent fusiondirectory-insert-schema $ARG fai*.schema
  fi

  if [[ "$PLUGIN_FREERADIUS" != "FALSE" ]] && [[ "$PLUGIN_FREERADIUS" != "false" ]];  then
    fd_apply FreeRadius
    silent fusiondirectory-insert-schema $ARG freeradius*.schema
  fi

  if [[ "$PLUGIN_FUSIONINVENTORY" != "FALSE" ]] && [[ "$PLUGIN_FUSIONINVENTORY" != "false" ]];  then
    fd_apply Inventory
    silent fusiondirectory-insert-schema $ARG fusioninventory*.schema
    silent fusiondirectory-insert-schema $ARG inventory*.schema
  fi

  if [[ "$PLUGIN_GPG" != "FALSE" ]] && [[ "$PLUGIN_GPG" != "false" ]];  then
    fd_apply GPG
    silent fusiondirectory-insert-schema $ARG gpg*.schema
    silent fusiondirectory-insert-schema $ARG pgp*.schema
  fi

  if [[ "$PLUGIN_IPMI" != "FALSE" ]] && [[ "$PLUGIN_IPMI" != "false" ]];  then
    fd_apply IPMI
    silent fusiondirectory-insert-schema $ARG ipmi*.schema
  fi

  if [[ "$PLUGIN_NAGIOS" != "FALSE" ]] && [[ "$PLUGIN_MIXEDGROUPS" != "false" ]];  then
    fd_apply Nagios
    silent fusiondirectory-insert-schema $ARG nagios*.schema
    silent fusiondirectory-insert-schema $ARG netways*.schema
  fi

  if [[ "$PLUGIN_NETGROUPS" != "FALSE" ]] && [[ "$PLUGIN_NETGROUPS" != "false" ]];  then
    fd_apply Netgroups
    silent fusiondirectory-insert-schema $ARG netgroups*.schema
  fi

  if [[ "$PLUGIN_NEWSLETTER" != "FALSE" ]] && [[ "$PLUGIN_NEWSLETTER" != "false" ]];  then
    fd_apply Newsletter
    silent fusiondirectory-insert-schema $ARG newsletter*.schema
  fi

  if [[ "$PLUGIN_OPSI" != "FALSE" ]] && [[ "$PLUGIN_OPSI" != "false" ]];  then
    fd_apply OPSI
    silent fusiondirectory-insert-schema $ARG opsi*.schema
  fi

  if [[ "$PLUGIN_PPOLICY" != "FALSE" ]] && [[ "$PLUGIN_PPOLICY" != "false" ]];  then
    fd_apply ppolicy
    silent fusiondirectory-insert-schema $ARG ppolicy*.schema
  fi

  if [[ "$PLUGIN_QUOTA" != "FALSE" ]] && [[ "$PLUGIN_QUOTA" != "false" ]];  then
    fd_apply Quota
    silent fusiondirectory-insert-schema $ARG quota*.schema
  fi

  if [[ "$PLUGIN_PUPPET" != "FALSE" ]] && [[ "$PLUGIN_PUPPET" != "false" ]];  then
    fd_apply puppet
    silent fusiondirectory-insert-schema $ARG puppet*.schema
  fi

  if [[ "$PLUGIN_REPOSITORY" != "FALSE" ]] && [[ "$PLUGIN_REPOSITORY" != "false" ]];  then
    fd_apply Repository
    silent fusiondirectory-insert-schema $ARG repository*.schema
  fi

  if [[ "$PLUGIN_SAMBA" != "FALSE" ]] && [[ "$PLUGIN_SAMBA" != "false" ]];  then
    fd_apply Samba
    silent fusiondirectory-insert-schema $ARG samba*.schema
  fi
  
  if [[ "$PLUGIN_PERSONAL" != "FALSE" ]] && [[ "$PLUGIN_PERSONAL" != "false" ]];  then
    fd_apply Personal
    silent fusiondirectory-insert-schema $ARG personal*.schema
  fi

  if [[ "$PLUGIN_POSTFIX" != "FALSE" ]] && [[ "$PLUGIN_POSTFIX" != "false" ]];  then
    fd_apply Postfix
    silent fusiondirectory-insert-schema $ARG postfix*.schema
  fi

  if [[ "$PLUGIN_PUREFTPD" != "FALSE" ]] && [[ "$PLUGIN_PUREFTPD" != "false" ]];  then
    fd_apply PureFTPd
    silent fusiondirectory-insert-schema $ARG pureftpd*.schema
  fi

  if [[ "$PLUGIN_SSH" != "FALSE" ]] && [[ "$PLUGIN_SSH" != "false" ]];  then
    fd_apply SSH
    silent fusiondirectory-insert-schema $ARG openssh*.schema
  fi

  if [[ "$PLUGIN_SOGO" != "FALSE" ]] && [[ "$PLUGIN_SOGO" != "false" ]];  then
    fd_apply SoGo
    silent fusiondirectory-insert-schema $ARG sogo*.schema
    silent fusiondirectory-insert-schema $ARG cal*.schema
  fi

  if [[ "$PLUGIN_SPAMASSASSIN" != "FALSE" ]] && [[ "$PLUGIN_SPAMASSASSIN" != "false" ]];  then
    fd_apply Spamassassin
    silent fusiondirectory-insert-schema $ARG spamassassin*.schema
  fi

  if [[ "$PLUGIN_SQUID" != "FALSE" ]] && [[ "$PLUGIN_SQUID" != "false" ]];  then
    fd_apply Squid
    silent fusiondirectory-insert-schema $ARG proxy*.schema
  fi

  if [[ "$PLUGIN_SUBCONTRACTING" != "FALSE" ]] && [[ "$PLUGIN_SUBCONTRACTING" != "false" ]];  then
    fd_apply Subcontracting
    silent fusiondirectory-insert-schema $ARG subcontracting*.schema
  fi

  if [[ "$PLUGIN_SUDO" != "FALSE" ]] && [[ "$PLUGIN_SUDO" != "false" ]];  then
    fd_apply sudo
    silent fusiondirectory-insert-schema $ARG sudo*.schema
  fi

  if [[ "$PLUGIN_SUPANN" != "FALSE" ]] && [[ "$PLUGIN_SUPANN" != "false" ]];  then
    fd_apply supann
    silent fusiondirectory-insert-schema $ARG internet2*.schema
    silent fusiondirectory-insert-schema $ARG supann*.schema
  fi

  if [[ "$PLUGIN_SYMPA" != "FALSE" ]] && [[ "$PLUGIN_SYMPA" != "false" ]];  then
    fd_apply Sympa
    silent fusiondirectory-insert-schema $ARG sympa*.schema
  fi

  if [[ "$PLUGIN_USER_REMINDER" != "FALSE" ]] && [[ "$PLUGIN_USER_REMINDER" != "false" ]];  then
    fd_apply reminder
    silent fusiondirectory-insert-schema $ARG user-reminder*.schema
  fi

  if [[ "$PLUGIN_WEBLINK" != "FALSE" ]] && [[ "$PLUGIN_WEBLINK" != "false" ]];  then
  	fd_apply weblink
    silent fusiondirectory-insert-schema $ARG weblink*.schema
  fi

    fd_apply webservice
  if [[ "$PLUGIN_WEBSERVICE" != "FALSE" ]] && [[ "$PLUGIN_WEBSERVICE" != "false" ]];  then
    silent fusiondirectory-insert-schema $ARG webservice*.schema
  fi

echo `date` >> $FUSIONDIRECTORY_INSTALLED 
echo `fusiondirectory-insert-schema -l` >>$FUSIONDIRECTORY_INSTALLED
fi
