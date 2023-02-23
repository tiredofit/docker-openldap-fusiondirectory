#!/command/with-contenv bash

source /assets/functions/00-container
prepare_service both
PROCESS_NAME="openldap-fusiondirectory"

FUSIONDIRECTORY_INSTALLED="/etc/openldap/slapd.d/docker-openldap-fusiondirectory-was-installed"

if [ ! -e "${FUSIONDIRECTORY_INSTALLED}" ]; then
    print_warn "First time Fusion Directory install detected"

    if [ -z "$BASE_DN" ]; then
        IFS='.' read -ra BASE_DN_TABLE <<<"$DOMAIN"
        for i in "${BASE_DN_TABLE[@]}"; do
            EXT="dc=$i,"
            BASE_DN=$BASE_DN$EXT
        done

        BASE_DN=${BASE_DN::-1}
    fi

    IFS='.' read -a domain_elems <<<"${DOMAIN}"
    SUFFIX=""
    ROOT=""

    for elem in "${domain_elems[@]}"; do
        if [ "x${SUFFIX}" = x ]; then
            SUFFIX="dc=${elem}"
            BASE_DN="${SUFFIX}"
            ROOT="${elem}"
        else
            BASE_DN="${BASE_DN},dc=${elem}"
        fi
    done

    CN_ADMIN="cn=admin,ou=aclroles,${BASE_DN}"
    CN_ADMIN_BS64="$(echo -n "${CN_ADMIN}" | base64 | tr -d '\n')"
    FUSIONDIRECTORY_ADMIN_USER=${FUSIONDIRECTORY_ADMIN_USER:-fd-admin}
    file_env "FUSIONDIRECTORY_ADMIN_PASS" "admin"
    file_env "ADMIN_PASS"
    ADMIN_PASS_ENCRYPTED="$(slappasswd -s "$ADMIN_PASS")"
    FUSIONDIRECTORY_ADMIN_PASS_ENCRYPTED="$(slappasswd -s "$FUSIONDIRECTORY_ADMIN_PASS")"
    file_env "READONLY_USER_PASS"
    READONLY_USER_PASS_ENCRYPTED="$(slappasswd -s "$READONLY_USER_PASS")"
    ORGANIZATION=${ORGANIZATION:-Example Organization}
    UID_FD_ADMIN="uid=${FUSIONDIRECTORY_ADMIN_USER},${BASE_DN}"
    UID_FD_ADMIN_BS64="$(echo -n "${UID_FD_ADMIN}" | base64 | tr -d '\n')"

    ### Install Core Fusion Directory Schemas
    silent fusiondirectory-insert-schema

    ### Step 1
    cat <<EOF >/tmp/01-fusiondirectory-base.ldif
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
userPassword: ${ADMIN_PASS_ENCRYPTED}
EOF

    silent ldapmodify -H 'ldapi:///' -D "cn=admin,${BASE_DN}" -w "${ADMIN_PASS}" -f /tmp/01-fusiondirectory-base.ldif

    # Read only user
    if var_true "${ENABLE_READONLY_USER}"; then
        print_notice "Adding read only (DSA) user"
        ldapadd -H 'ldapi:///' -D "cn=admin,${BASE_DN}" -w "${ADMIN_PASS}" -f /assets/slapd/config/bootstrap/ldif/readonly-user/readonly-user.ldif
        ldapmodify -H 'ldapi:///' -f /assets/slapd/config/bootstrap/ldif/readonly-user/readonly-user-acl.ldif
    fi

    ### Step 2
    cat <<EOF >/tmp/02-fusiondirectory-add.ldif
dn: uid=${FUSIONDIRECTORY_ADMIN_USER},${BASE_DN}
changeType: add
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
cn: System Administrator
sn: Administrator
givenName: System
uid: ${FUSIONDIRECTORY_ADMIN_USER}
userPassword: ${FUSIONDIRECTORY_ADMIN_PASS_ENCRYPTED}

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
fdTimezone: ${TIMEZONE}
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
fdShells: /bin/dash
fdShells: /bin/zsh
fdShells: /sbin/nologin
fdShells: /bin/false
fdForcePasswordDefaultHash: FALSE
fdHandleExpiredAccounts: FALSE
fdForceSSL: FALSE
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

    silent ldapadd -H 'ldapi:///' -D "cn=admin,${BASE_DN}" -w "${ADMIN_PASS}" -f /tmp/02-fusiondirectory-add.ldif

    ### Step 4
    print_notice "Adding ppolicy defaults"
    sed -i "s|<BASE_DN>|${BASE_DN}|g" /assets/slapd/config/ppolicy/01-ppolicy-config.ldif
    sed -i "s|<BASE_DN>|${BASE_DN}|g" /assets/slapd/config/ppolicy/02-ppolicy-ou.ldif
    sed -i "s|<BASE_DN>|${BASE_DN}|g" /assets/slapd/config/ppolicy/03-ppolicy-default.ldif
    silent ldapadd -Y EXTERNAL -Q -H ldapi:/// -f /assets/slapd/config/ppolicy/01-ppolicy-config.ldif
    silent ldapadd -H 'ldapi:///' -D "cn=admin,${BASE_DN}" -w "${ADMIN_PASS}" -f /assets/slapd/config/ppolicy/02-ppolicy-ou.ldif
    silent ldapadd -H 'ldapi:///' -D "cn=admin,${BASE_DN}" -w "${ADMIN_PASS}" -f /assets/slapd/config/ppolicy/03-ppolicy-default.ldif
    ###
    rm -rf /tmp/*.ldif
fi

### Insert Plugin Schemas
if [ ! -e "${FUSIONDIRECTORY_INSTALLED}" ] || var_true "${REAPPLY_PLUGIN_SCHEMAS}"; then
    ### Determine which plugins we want installed
    PLUGIN_ALIAS=${PLUGIN_ALIAS:-"FALSE"}
    PLUGIN_APPLICATIONS=${PLUGIN_APPLICATIONS:-"FALSE"}
    PLUGIN_ARCHIVE=${PLUGIN_ARCHIVE:-"FALSE"}
    PLUGIN_ARGONAUT=${PLUGIN_ARGONAUT:-"FALSE"}
    PLUGIN_AUDIT=${PLUGIN_AUDIT:-"TRUE"}
    PLUGIN_AUTOFS=${PLUGIN_AUTOFS:-"FALSE"}
    PLUGIN_AUTOFS5=${PLUGIN_AUTOFS5:-"FALSE"}
    PLUGIN_CERTIFICATES=${PLUGIN_CERTIFICATES:-"FALSE"}
    PLUGIN_COMMUNITY=${PLUGIN_COMMUNITY:-"FALSE"}
    PLUGIN_CYRUS=${PLUGIN_CYRUS:-"FALSE"}
    PLUGIN_DEBCONF=${PLUGIN_DEBCONF:-"FALSE"}
    PLUGIN_DEVELOPERS=${PLUGIN_DEVELOPERS:-"FALSE"}
    PLUGIN_DHCP=${PLUGIN_DHCP:-"FALSE"}
    PLUGIN_DNS=${PLUGIN_DNS:-"TRUE"}
    PLUGIN_DOVECOT=${PLUGIN_DOVECOT:-"FALSE"}
    PLUGIN_DSA=${PLUGIN_DSA:-"TRUE"}
    PLUGIN_DYNGROUPS=${PLUGIN_DYNGROUPS:-"TRUE"}
    PLUGIN_EJBCA=${PLUGIN_EJBCA:-"FALSE"}
    PLUGIN_FAI=${PLUGIN_FAI:-"FALSE"}
    PLUGIN_FREERADIUS=${PLUGIN_FREERADIUS:-"FALSE"}
    PLUGIN_FUSIONINVENTORY=${PLUGIN_FUSIONINVENTORY:-"FALSE"}
    PLUGIN_GPG=${PLUGIN_GPG:-"FALSE"}
    PLUGIN_IPAM=${PLUGIN_IPAM:-"FALSE"}
    PLUGIN_IPMI=${PLUGIN_IPMI:-"FALSE"}
    PLUGIN_INVITATIONS=${PLUGIN_INVITATIONS:-"FALSE"}
    PLUGIN_KERBEROS=${PLUGIN_KERBEROS:-"FALSE"}
    PLUGIN_KOPANO=${PLUGIN_KOPANO:-"FALSE"}
    PLUGIN_LDAPDUMP=${PLUGIN_LDAPDUMP:-"TRUE"}
    PLUGIN_LDAPMANAGER=${PLUGIN_LDAPMANAGER:-"TRUE"}
    PLUGIN_MAIL=${PLUGIN_MAIL:-"TRUE"}
    PLUGIN_MAILINBLACK=${PLUGIN_MAILINBLACK:-"FALSE"}
    PLUGIN_MIGRATION_MAILROUTING=${PLUGIN_MIGRATION_MAILROUTING:-"FALSE"}
    PLUGIN_MIXEDGROUPS=${PLUGIN_MIXEDGROUPS:-"TRUE"}
    PLUGIN_NAGIOS=${PLUGIN_NAGIOS:-"FALSE"}
    PLUGIN_NETGROUPS=${PLUGIN_NETGROUPS:-"FALSE"}
    PLUGIN_NEXTCLOUD=${PLUGIN_NEXTCLOUD:-"FALSE"}
    PLUGIN_NEWSLETTER=${PLUGIN_NEWSLETTER:-"FALSE"}
    PLUGIN_OPSI=${PLUGIN_OPSI:-"FALSE"}
    PLUGIN_PERSONAL=${PLUGIN_PERSONAL:-"TRUE"}
    PLUGIN_POSIX=${PLUGIN_POSIX:-"FALSE"}
    PLUGIN_POSTFIX=${PLUGIN_POSTFIX:-"FALSE"}
    PLUGIN_PPOLICY=${PLUGIN_PPOLICY:-"TRUE"}
    PLUGIN_PUBLIC_FORMS=${PLUGIN_PUBLIC_FORMS:-"FALSE"}
    PLUGIN_PUPPET=${PLUGIN_PUPPET:-"FALSE"}
    PLUGIN_PUREFTPD=${PLUGIN_PUREFTPD:-"FALSE"}
    PLUGIN_QUOTA=${PLUGIN_QUOTA:-"FALSE"}
    PLUGIN_RENATER_PARTAGE=${PLUGIN_RENATER_PARTAGE:-"FALSE"}
    PLUGIN_REPOSITORY=${PLUGIN_REPOSITORY:-"FALSE"}
    PLUGIN_SAMBA=${PLUGIN_SAMBA:-"FALSE"}
    PLUGIN_SCHAC=${PLUGIN_SCHAC:-"FALSE"}
    PLUGIN_SEAFILE=${PLUGIN_SEAFILE:-"FALSE"}
    PLUGIN_SINAPS=${PLUGIN_SINAPS:-"FALSE"}
    PLUGIN_SOGO=${PLUGIN_SOGO:-"FALSE"}
    PLUGIN_SPAMASSASSIN=${PLUGIN_SPAMASSASSIN:-"FALSE"}
    PLUGIN_SQUID=${PLUGIN_SQUID:-"FALSE"}
    PLUGIN_SSH=${PLUGIN_SSH:-"TRUE"}
    PLUGIN_SUBCONTRACTING=${PLUGIN_SUBCONTRACTING:-"FALSE"}
    PLUGIN_SUBSCRIPTIONS=${PLUGIN_SUBSCRIPTIONS:-"FALSE"}
    PLUGIN_SUDO=${PLUGIN_SUDO:-"TRUE"}
    PLUGIN_SUPANN=${PLUGIN_SUPANN:-"FALSE"}
    PLUGIN_SYMPA=${PLUGIN_SYMPA:-"FALSE"}
    PLUGIN_SYSTEMS=${PLUGIN_SYSTEMS:-"TRUE"}
    PLUGIN_USER_REMINDER=${PLUGIN_USER_REMINDER:-"FALSE"}
    PLUGIN_WEBAUTHN=${PLUGIN_WEBAUTHN:-"FALSE"}
    PLUGIN_WEBLINK=${PLUGIN_WEBLINK:-"FALSE"}
    PLUGIN_WEBSERVICE=${PLUGIN_WEBSERVICE:-"FALSE"}
    PLUGIN_ZIMBRA=${PLUGIN_ZIMBRA:-"FALSE"}

    fd_apply() {
        if var_true "${REAPPLY_PLUGIN_SCHEMAS}"; then
            RE="Re"
            A="a"
            ARG="-m"
        else
            A="A"
            ARG="-i"
        fi
        print_notice "${RE}${A}pplying Fusion Directory $@ schema"
    }

    ## Handle the core plugins
    if var_true "${REAPPLY_PLUGIN_SCHEMAS}"; then
        fd_apply core
        fusiondirectory-insert-schema -m core*.schema
        fusiondirectory-insert-schema -m ldapns.schema
        fusiondirectory-insert-schema -m template-fd.schema
    fi

    ### Import / Modify Schemas - Put Mail First
    if var_true "${PLUGIN_MAIL}"; then
        fd_apply mail
        silent fusiondirectory-insert-schema $ARG mail*.schema
    fi

    if var_true "${PLUGIN_SYSTEMS}"; then
        fd_apply systems
        silent fusiondirectory-insert-schema $ARG service*.schema
        silent fusiondirectory-insert-schema $ARG systems*.schema
        silent fusiondirectory-insert-schema $ARG dns*.schema
    fi

    if var_true "${PLUGIN_AUDIT}"; then
        fd_apply audit
        silent fusiondirectory-insert-schema $ARG audit*.schema
    fi

    if var_true "${PLUGIN_AUTOFS}"; then
        fd_apply AutoFS
        silent fusiondirectory-insert-schema $ARG autofs-*.schema
    fi

    if var_true "${PLUGIN_AUTOFS5}"; then
        fd_apply AutoFS
        silent fusiondirectory-insert-schema $ARG autofs5-*.schema
    fi

    if var_true "${PLUGIN_ALIAS}"; then
        fd_apply alias
        silent fusiondirectory-insert-schema $ARG alias*.schema
    fi

    if var_true "${PLUGIN_APPLICATIONS}"; then
        fd_apply applications
        silent fusiondirectory-insert-schema $ARG applications*.schema
    fi

    if var_true "${PLUGIN_ARGONAUT}"; then
        fd_apply argonaut
        silent fusiondirectory-insert-schema $ARG argonaut*.schema
    fi

    if var_true "${PLUGIN_CALENDAR}"; then
        fd_apply calendar
        silent fusiondirectory-insert-schema $ARG cal*.schema
    fi

    if var_true "${PLUGIN_COMMUNITY}"; then
        fd_apply community
        silent fusiondirectory-insert-schema $ARG community*.schema
    fi

    if var_true "${PLUGIN_CYRUS}"; then
        fd_apply cyrus
        silent fusiondirectory-insert-schema $ARG cyrus*.schema
    fi

    if var_true "${PLUGIN_DEBCONF}"; then
        fd_apply debconf
        silent fusiondirectory-insert-schema $ARG debconf*.schema
    fi

    if var_true "${PLUGIN_DHCP}"; then
        fd_apply DHCP
        silent fusiondirectory-insert-schema $ARG dhcp*.schema
    fi

    if var_true "${PLUGIN_DNS}"; then
        fd_apply DNS
        silent fusiondirectory-insert-schema $ARG dns*.schema
    fi

    if var_true "${PLUGIN_DOVECOT}"; then
        fd_apply dovecot
        silent fusiondirectory-insert-schema $ARG dovecot*.schema
    fi

    if var_true "${PLUGIN_DSA}"; then
        fd_apply DSA
        silent fusiondirectory-insert-schema $ARG dsa*.schema
    fi

    if var_true "${PLUGIN_EJBCA}"; then
        fd_apply ejbca
        silent fusiondirectory-insert-schema $ARG ejbca*.schema
    fi

    if var_true "${PLUGIN_FAI}"; then
        fd_apply FAI
        silent fusiondirectory-insert-schema $ARG fai*.schema
    fi

    if var_true "${PLUGIN_FREERADIUS}"; then
        fd_apply FreeRadius
        silent fusiondirectory-insert-schema $ARG freeradius*.schema
    fi

    if var_true "${PLUGIN_FUSIONINVENTORY}"; then
        fd_apply Inventory
        silent fusiondirectory-insert-schema $ARG fusioninventory*.schema
        silent fusiondirectory-insert-schema $ARG inventory*.schema
    fi

    if var_true "${PLUGIN_GPG}"; then
        fd_apply GPG
        silent fusiondirectory-insert-schema $ARG gpg*.schema
        silent fusiondirectory-insert-schema $ARG pgp*.schema
    fi

    if var_true "${PLUGIN_INVITATIONS}"; then
        fd_apply Invitations
        silent fusiondirectory-insert-schema $ARG invitations*.schema
    fi

    if var_true "${PLUGIN_IPAM}"; then
        fd_apply IPAM
        silent fusiondirectory-insert-schema $ARG ipam*.schema
    fi

    if var_true "${PLUGIN_IPMI}"; then
        fd_apply IPMI
        silent fusiondirectory-insert-schema $ARG ipmi*.schema
    fi

    if var_true "${PLUGIN_KERBEROS}"; then
        fd_apply Kerberos
        silent fusiondirectory-insert-schema $ARG kerberos*.schema
    fi

    if var_true "${PLUGIN_KOPANO}"; then
        fd_apply Kopano
        silent fusiondirectory-insert-schema $ARG kopano*.schema
    fi

    if var_true "${PLUGIN_MAILINBLACK}"; then
        fd_apply "Mail in Black"
        silent fusiondirectory-insert-schema $ARG mailinblack*.schema
    fi

    if var_true "${PLUGIN_MIGRATION_MAILROUTING}"; then
        fd_apply "Mail-Routing"
        silent fusiondirectory-insert-schema $ARG migration-mailrouting*.schema
    fi

    if var_true "${PLUGIN_NAGIOS}"; then
        fd_apply Nagios
        silent fusiondirectory-insert-schema $ARG nagios*.schema
        silent fusiondirectory-insert-schema $ARG netways*.schema
    fi

    if var_true "${PLUGIN_NETGROUPS}"; then
        fd_apply Netgroups
        silent fusiondirectory-insert-schema $ARG netgroups*.schema
    fi

    if var_true "${PLUGIN_NEWSLETTER}"; then
        fd_apply Newsletter
        silent fusiondirectory-insert-schema $ARG newsletter*.schema
    fi

    if var_true "${PLUGIN_NEXTCLOUD}"; then
        fd_apply Nextcloud
        silent fusiondirectory-insert-schema $ARG nextcloud*.schema
    fi

    if var_true "${PLUGIN_OPSI}"; then
        fd_apply OPSI
        silent fusiondirectory-insert-schema $ARG opsi*.schema
    fi

    if var_true "${PLUGIN_PPOLICY}"; then
        fd_apply ppolicy
        silent fusiondirectory-insert-schema $ARG ppolicy*.schema
    fi

    if var_true "${PLUGIN_QUOTA}"; then
        fd_apply Quota
        silent fusiondirectory-insert-schema $ARG quota*.schema
    fi

    if var_true "${PLUGIN_PUPPET}"; then
        fd_apply puppet
        silent fusiondirectory-insert-schema $ARG puppet*.schema
    fi

    if var_true "${PLUGIN_RENATER_PARTAGE}"; then
        fd_apply Repository
        silent fusiondirectory-insert-schema $ARG renater-partage*.schema
    fi

    if var_true "${PLUGIN_REPOSITORY}"; then
        fd_apply Repository
        silent fusiondirectory-insert-schema $ARG repository*.schema
    fi

    if var_true "${PLUGIN_SAMBA}"; then
        fd_apply Samba
        silent fusiondirectory-insert-schema $ARG samba*.schema
    fi

    if var_true "${PLUGIN_PERSONAL}"; then
        fd_apply Personal
        silent fusiondirectory-insert-schema $ARG personal*.schema
    fi

    if var_true "${PLUGIN_POSTFIX}"; then
        fd_apply Postfix
        silent fusiondirectory-insert-schema $ARG postfix*.schema
    fi

    if var_true "${PLUGIN_PUBLIC_FORMS}"; then
        fd_apply PublicForms
        silent fusiondirectory-insert-schema $ARG public-forms*.schema
    fi

    if var_true "${PLUGIN_PUREFTPD}"; then
        fd_apply PureFTPd
        silent fusiondirectory-insert-schema $ARG pureftpd*.schema
    fi

    if var_true "${PLUGIN_SCHAC}"; then
        fd_apply SCHAC
        silent fusiondirectory-insert-schema $ARG schac*.schema
    fi

    if var_true "${PLUGIN_SEAFILE}"; then
        fd_apply Seafile
        silent fusiondirectory-insert-schema $ARG seafile*.schema
    fi

    if var_true "${PLUGIN_SSH}"; then
        fd_apply SSH
        silent fusiondirectory-insert-schema $ARG openssh*.schema
    fi

    if var_true "${PLUGIN_SINAPS}"; then
        fd_apply Sinaps
        silent fusiondirectory-insert-schema $ARG sinaps*.schema
    fi

    if var_true "${PLUGIN_SOGO}"; then
        fd_apply SoGo
        silent fusiondirectory-insert-schema $ARG sogo*.schema
        silent fusiondirectory-insert-schema $ARG cal*.schema
    fi

    if var_true "${PLUGIN_SPAMASSASSIN}"; then
        fd_apply Spamassassin
        silent fusiondirectory-insert-schema $ARG spamassassin*.schema
    fi

    if var_true "${PLUGIN_SQUID}"; then
        fd_apply Squid
        silent fusiondirectory-insert-schema $ARG proxy*.schema
    fi

    if var_true "${PLUGIN_SUBCONTRACTING}"; then
        fd_apply Subcontracting
        silent fusiondirectory-insert-schema $ARG subcontracting*.schema
    fi

    if var_true "${PLUGIN_SUBSCRIPTIONS}"; then
        fd_apply Subscriptions
        silent fusiondirectory-insert-schema $ARG subscriptions*.schema
    fi

    if var_true "${PLUGIN_SUDO}"; then
        fd_apply sudo
        silent fusiondirectory-insert-schema $ARG sudo*.schema
    fi

    if var_true "${PLUGIN_SUPANN}"; then
        fd_apply supann
        silent fusiondirectory-insert-schema $ARG internet2*.schema
        silent fusiondirectory-insert-schema $ARG supann*.schema
    fi

    if var_true "${PLUGIN_SYMPA}"; then
        fd_apply Sympa
        silent fusiondirectory-insert-schema $ARG sympa*.schema
    fi

    if var_true "${PLUGIN_USER_REMINDER}"; then
        fd_apply reminder
        silent fusiondirectory-insert-schema $ARG user-reminder*.schema
    fi

    if var_true "${PLUGIN_WEBAUTHN}"; then
        fd_apply weblink
        silent fusiondirectory-insert-schema $ARG webauthn*.schema
    fi

    if var_true "${PLUGIN_WEBLINK}"; then
        fd_apply weblink
        silent fusiondirectory-insert-schema $ARG weblink*.schema
    fi

    if var_true "${PLUGIN_WEBSERVICE}"; then
        fd_apply webservice
        silent fusiondirectory-insert-schema $ARG webservice*.schema
    fi

    if var_true "${PLUGIN_ZIMBRA}"; then
        fd_apply weblink
        silent fusiondirectory-insert-schema $ARG zimbra*.schema
    fi

    date >> "${FUSIONDIRECTORY_INSTALLED}"
    fusiondirectory-insert-schema -l >> "${FUSIONDIRECTORY_INSTALLED}"
fi
