## 7.0.1 2020-06-25 <dave at tiredofit dot ca>

   ### Changed
      - Removed functionality for READONLY user, (Use the FusionDirectory DSA Plugin instead)


## 7.0.0 2020-06-25 <dave at tiredofit dot ca>

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
