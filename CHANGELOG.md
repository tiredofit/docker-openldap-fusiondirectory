## 2.6-7.4.1 2023-03-30 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:2.6-7.4.1


## 2.6-1.4-7.3.2 2023-03-16 <dave at tiredofit dot ca>

   ### Added
      - Pin to docker.io/tiredofit/openldap:2.6-7.3.2


## 2.6-1.4-7.3.1 2023-02-23 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:2.6-7.3.1


## 2.6-1.4-7.3.0 2023-02-22 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:2.6-7.3.0
      - Modernize Image


## 2.6-1.4-7.1.41 2023-02-21 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:2.6-7.2.19
      - Stop pulling from mainline 1.4-dev branches instead use
      - Fusiondirectory b246399ff2d3dc74565c9f3897e4a3544e0c51d1
      - Fusiondirectory Plugins b0078c722634cbd42fe2b0231eb8d40c6d87df3e
      - Due to removal of key tools that we just aren't ready to modify quite yet (fusiondirectory-insert schema)


## 7.1.40 2022-12-20 <dave at tiredofit dot ca>

   ### Changed
      - Fix for nextcloud schema not being inserted on startup (Credit to Marsu31@github)


## 7.1.39 2022-11-04 <dave at tiredofit dot ca>

   ### Added
      - tiredofit/openldap:2.6-7.2.16
      - Switch ADD to COPY in Dockerfile


## 7.1.38 2022-08-08 <dave at tiredofit dot ca>

   ### Added
      - tiredofit/openldap:2.6-7.2.16


## 7.1.37 2022-07-14 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:2.6-7.2.12


## 7.1.36 2022-07-14 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:2.6-7.2.11


## 7.1.35 2022-07-09 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/docker-openldap-2.6-7.2.10


## 7.1.34 2022-07-05 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:2.6-7.2.9


## 7.1.33 2022-05-24 <dave at tiredofit dot ca>

   ### Changed
      - Stop installing Schema2LDIF again, it's already installed in upstream


## 7.1.32 2022-05-24 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:2.6-7.2.8


## 7.1.31 2022-05-15 <dave at tiredofit dot ca>

   ### Changed
      - Bugfix


## 7.1.30 2022-05-15 <dave at tiredofit dot ca>

   ### Changed
      - Change location where schema2LDIF is loaded from


## 7.1.29 2022-05-15 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:2.6-7.2.7


## 7.1.28 2022-03-01 <dave at tiredofit dot ca>

   ### Added
      - Use new tiredofit/openldap branch mechanism


## 7.1.27 2022-03-01 <dave at tiredofit dot ca>

   ### Changed
      - Make +x bit on the /assets/custom scripts


## 7.1.26 2022-02-10 <dave at tiredofit dot ca>

   ### Changed
      - Update to support upstream image changes


## 7.1.25 2022-02-05 <dave at tiredofit dot ca>

   ### Changed
      - Fix for installation failing with 1.4 due to deprecated attributes for Cas and HTTP AUth


## 7.1.24 2021-12-20 <dave at tiredofit dot ca>

   ### Changed
      - tiredofit/openldap:2.4-7.1.24


## 7.1.23 2021-12-20 <dave at tiredofit dot ca>

   ### Added
      - Update to alpine 3.15
      - Keep maintaining OpenLDAP 2.4 / Fusiondirectory 1.4 beta branch
      - Pin to tiredofit/openldap/2.4-7.1.23


## 7.1.5 2021-10-16 <dave at tiredofit dot ca>

   ### Added
      - Added mailinblack plugin


## 7.1.4 2021-09-10 <dave at tiredofit dot ca>

   ### Added
      - Pin to tiredofit/openldap:7.1.21


## 7.1.3 2021-09-04 <dave at tiredofit dot ca>

   ### Added
      - Use tiredofit/openldap:7.1.20 as base image


## 7.1.2 2021-05-12 <dave at tiredofit dot ca>

   ### Changed
      - Many script error repairs
      - Shellcheck fixes on quoting variables


## 7.1.1 2021-05-11 <dave at tiredofit dot ca>

   ### Changed
      - Fix for Install schema script


## 7.1.0 2021-05-10 <dave at tiredofit dot ca>

   ### Added
      - FusionDirectory 1.4-dev schemas


## 7.0.4 2021-05-08 <dave at tiredofit dot ca>

   ### Added
      - Track tiredofit/openldap version 7.1.16


## 7.0.3 2020-09-19 <dave at tiredofit dot ca>

   ### Changed
      - Check for REAPPLY_PLUGIN_SCHEMAS when finding custom scripts


## 7.0.2 2020-06-26 <dave at tiredofit dot ca>

   ### Added
      - Match version number to tiredofit/openldap release

   ### Changed
      - Alter ppolicy routines


## 6.7.0 2020-06-20 <dave at tiredofit dot ca>

   ### Added
      - Add support for Kopano plugin
      - Add support for Nextcloud plugin
      - Add support for Seafile Plugin


## 6.6.0 2020-06-15 <dave at tiredofit dot ca>

   ### Added
      - Update to support tiredofit/alpine 5.x base image


## 6.5.0 2020-01-14 <sagreal@github>

   ### Added
      - Add support for Sinaps Plugin
      - Add Secrets Support
 
   ### Changed
      - Fix AutoFS Plugin
      - Fix Nagios Plugin
      - Fix Renater Partage Plugin


## 6.4.1 2020-01-02 <dave at tiredofit dot ca>

   ### Changed
      - Fixed reverted commit to fix BASE_DN being improperly set whenusing subdomains


## 6.4.0 2020-01-02 <dave at tiredofit dot ca>

   ### Added
      - Changes to support new tiredofit/alpine and tiredofit/openldap bases


## 6.3 2019-05-06 <dave at tiredofit dot ca>

* FusionDirectory 1.3.0

## 6.2 2018-12-27 <dave at tiredofit dot ca>

* Match base tiredofit/openldap
* FusionDirectory 1.2.3

## 6.1 2018-12-03 <dave at tiredofit dot ca>

* Match Base

## 6.0.2 2018-09-17 <dave at tiredofit dot ca>

* Update Schemas to Fusiondirectory 1.2.2
* Switch to FusionDirectory Git instance

## 6.0.1 2018-08-27 <dave at tiredofit dot ca>

* Base upgrade for tiredofit/openldap

## 6.0 2018-07-20 <dave at tiredofit dot ca>

* Rebase from new tiredofit/openldap image based on Alpine
* Added Individual Schema Application
* Added Reapplication of Schemas 

## 5.3 2018-06-12 <dave at tiredofit dot ca>

* Update Schema to FD 1.2.1

## 5.2 2018-01-13 <dave at tiredofit dot ca>

* Rebase - CI

## 5.1 2017-10-19 <dave at tiredofit dot ca>

* Cron Backup Fix in Baseimage, enough to warrant new image

## 5.0 2017-07-03 <dave at tiredofit dot ca>

* FD 1.2 and adding schema for sudo and ssh

## 4.1 2017-06-26 <dave at tiredofit dot ca>

* Memberof Fixes and Skip init script for ppolicy.

## 4.0 2017-06-15 <dave at tiredofit dot ca>

* Final Base 4.0 w/ FD 1.1.1 - FD PPolicy, Personal, Mail, Audit

## 3.2 2017-04-04 <dave at tiredofit dot ca>

* FD 1.1.1

## 3.1 2017-04-04 <dave at tiredofit dot ca>

* FD 1.1

## 3.1 2017-04-04 <dave at tiredofit dot ca>

* Cleanup
* FD 1.0.20

## 3.0 2017-03-21 <dave at tiredofit dot ca>

* Rebasing off Docker/openldap 3.0

## 2.0 2017-02-14 <dave at tiredofit dot ca>

* Rebase with Zabbix
* Fusion Directory 1.0.19
 - fusiondirectory-schema
 - fusiondirectory-plugin-alias-schema
 - fusiondirectory-plugin-argonaut-schema
 - fusiondirectory-plugin-applications-schema
 - fusiondirectory-plugin-audit-schema
 - fusiondirectory-plugin-autofs-schema
 - fusiondirectory-plugin-certificates-schema
 - fusiondirectory-plugin-dovecot-schema
 - fusiondirectory-plugin-dsa-schema
 - fusiondirectory-plugin-gpg-schema
 - fusiondirectory-plugin-mail-schema
 - fusiondirectory-plugin-personal-schema
 - fusiondirectory-plugin-postfix-schema
 - fusiondirectory-plugin-ppolicy-schema
 - fusiondirectory-plugin-quota-schema
 - fusiondirectory-plugin-ssh-schema
 - fusiondirectory-plugin-sudo-schema
 - fusiondirectory-plugin-systems-schema
 - fusiondirectory-plugin-weblink-schema
 - fusiondirectory-plugin-webservice-schema
## 1.0 2017-01-03 <dave at tiredofit dot ca>

* Initial Build 
* Fusion Directory 1.0.17
* Fusion Directory Schema's Included
  -  fusiondirectory-schema
  -  fusiondirectory-plugin-argonaut-schema
  -  fusiondirectory-plugin-autofs-schema
  -  fusiondirectory-plugin-gpg-schema
  -  fusiondirectory-plugin-mail-schema
  -  fusiondirectory-plugin-postfix-schema
  -  fusiondirectory-plugin-ssh-schema
  -  fusiondirectory-plugin-sudo-schema
  -  fusiondirectory-plugin-weblink-schema
  -  fusiondirectory-plugin-webservice-schema
