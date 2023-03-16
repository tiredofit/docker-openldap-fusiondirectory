# github.com/tiredofit/docker-openldap-fusiondirectory

[![GitHub release](https://img.shields.io/github/v/tag/tiredofit/docker-openldap-fusiondirectory?style=flat-square)](https://github.com/tiredofit/docker-openldap-fusiondirectory/releases/latest)
[![Build Status](https://img.shields.io/github/actions/workflow/status/tiredofit/docker-openldap-fusiondirectorymain.yml?branch=2.6-1.4&style=flat-square)](https://github.com/tiredofit/docker-openldap-fusiondirectory.git/actions)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/openldap-fusiondirectory.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/openldap-fusiondirectory/)
[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/openldap-fusiondirectory.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/openldap-fusiondirectory/)
[![Become a sponsor](https://img.shields.io/badge/sponsor-tiredofit-181717.svg?logo=github&style=flat-square)](https://github.com/sponsors/tiredofit)
[![Paypal Donate](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square)](https://www.paypal.me/tiredofit)


## About

This will build a Docker image for an [OpenLDAP Server](https://sourceforge.net/projects/openldap-fusiondirectory/) with [Fusion Directory](https://www.fusiondirectory.org) Schema's Included. It includes all the functions in the [OpenLDAP Image](https://github.com/tiredofit/docker-openldap) such as Multi-Master Replication, TLS, and other features.

## Maintainer

- [Dave Conroy](https://github.com/tiredofit/)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
  - [Build from Source](#build-from-source)
  - [Prebuilt Images](#prebuilt-images)
  - [Multi Architecture](#multi-architecture)
- [Configuration](#configuration)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
  - [Environment Variables](#environment-variables)
- [Schema Installation](#schema-installation)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support](#support)
  - [Usage](#usage)
  - [Bugfixes](#bugfixes)
  - [Feature Requests](#feature-requests)
  - [Updates](#updates)
- [License](#license)
- [References](#references)

# Dependencies

- To build this image you must have the [OpenLDAP Image](https://github.com/tiredofit/docker-openldap) built and available. To utilize, you must also have the [Fusion Directory Image](https://github.com/tiredofit/docker-fusiondirectory) image built and available.

## Installation
### Build from Source
Clone this repository and build the image with `docker build -t (imagename) .`

### Prebuilt Images
Builds of the image are available on [Docker Hub](https://hub.docker.com/r/tiredofit/openldap-fusiondirectory)

```bash
docker pull docker.io/tiredofdit/openldap-fusiondirectory:(imagetag)
```
Builds of the image are also available on the [Github Container Registry](https://github.com/tiredofit/docker-openldap-fusiondirectory/pkgs/container/docker-openldap-fusiondirectory) 
 
```
docker pull ghcr.io/tiredofit/docker-openldap-fusiondirectory:(imagetag)
``` 

Builds of the image are also available on the [Github Container Registry](https://github.com/tiredofit/docker-tiredofdit/pkgs/container/docker-tiredofdit) 
 
```
docker pull ghcr.io/tiredofit/docker-tiredofdit:(imagetag)
``` 

The following image tags are available along with their tagged release based on what's written in the [Changelog](CHANGELOG.md):

| Version | OpenLDAP Version | Container OS | Tag        |
| ------- | ---------------- | ------------ | ---------- |
| `1.4.x` | 2.6.x            | Alpine       | `:latest`  |
| `1.4.x` | 2.6.x            | Alpine       | `:2.6-1.4` |
| `1.4.x` | 2.4.x            | Alpine       | `:2.4-1.4` |
| `1.3.x` | 2.4.x            | Alpine       | `:2.4-1.3` |

### Multi Architecture
Images are built primarily for `amd64` architecture, and may also include builds for `arm/v6`, `arm/v7`, `arm64` and others. These variants are all unsupported. Consider [sponsoring](https://github.com/sponsors/tiredofit) my work so that I can work with various hardware. To see if this image supports multiple architecures, type `docker manifest (image):(tag)`

## Configuration

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this image.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.
* Make [networking ports](#networking) available for public access if necessary
__NOTE__: Please allow up to 2 minutes for the application to start for the first time if you are generating self signed TLS certificates.

### Persistent Storage

* Please see [OpenLDAP Image](https://github.com/tiredofit/docker-openldap) for Data Volume Configuration.

There is an additional data volume exposed:

| Directory                         | Description                                                 |
| --------------------------------- | ----------------------------------------------------------- |
| `/assets/fusiondirectory-custom/` | Place Schema files here to be imported into FusionDirectory |

### Environment Variables

This image relies on an [Alpine Linux](https://hub.docker.com/r/tiredofit/alpine) base image that relies on an [init system](https://github.com/just-containers/s6-overlay) for added capabilities. Outgoing SMTP capabilities are handlded via `msmtp`. Individual container performance monitoring is performed by [zabbix-agent](https://zabbix.org). Additional tools include: `bash`,`curl`,`less`,`logrotate`,`nano`.

Be sure to view the following repositories to understand all the customizable options:

| Image                                                     | Description                            |
| --------------------------------------------------------- | -------------------------------------- |
| [OS Base](https://github.com/tiredofit/docker-alpine/)    | Customized Image based on Alpine Linux |
| [OpenLDAP](https://github.com/tiredofit/docker-openldap/) | OpenLDAP based on Alpine Linux         |


| Variable                     | Description               | Default                |
| ---------------------------- | ------------------------- | ---------------------- |
| `FUSIONDIRECTORY_ADMIN_USER` | Default FD Admin User     | `admin`                |
| `FUSIONDIRECTORY_ADMIN_PASS` | Default FD Admin Password | `admin`                |
| `ORGANIZATION`               | Organization Name         | `Example Organization` |

## Schema Installation
Depending on your choices, the following schemas are available for installation. You must have these also enabled on the FusionDirectory application image to make use of it. If you would like to reapply the schemas set `REAPPLY_PLUGIN_SCHEMAS` to `TRUE`.

| Variable                 | Description                              | Default |
| ------------------------ | ---------------------------------------- | ------- |
| `REAPPLY_PLUGIN_SCHEMAS` | Reapply Plugin Schemas `TRUE` or `FALSE` | `FALSE` |
| `PLUGIN_ALIAS`           | Mail Aliases                             | `FALSE` |
| `PLUGIN_APPLICATIONS`    | Applications                             | `FALSE` |
| `PLUGIN_ARGONAUT`        | Argonaut                                 | `FALSE` |
| `PLUGIN_AUDIT`           | Audit Trail                              | `TRUE`  |
| `PLUGIN_AUTOFS`          | AutoFS                                   | `FALSE` |
| `PLUGIN_CERTIFICATES`    | Manage Certificates                      | `FALSE` |
| `PLUGIN_COMMUNITY`       | Community Plugin                         | `FALSE` |
| `PLUGIN_CYRUS`           | Cyrus IMAP                               | `FALSE` |
| `PLUGIN_DEBCONF`         | Argonaut Debconf                         | `FALSE` |
| `PLUGIN_DEVELOPERS`      | Developers Plugin                        | `FALSE` |
| `PLUGIN_DHCP`            | Manage DHCP                              | `FALSE` |
| `PLUGIN_DNS`             | Manage DNS                               | `TRUE`  |
| `PLUGIN_DOVECOT`         | Dovecot IMAP                             | `FALSE` |
| `PLUGIN_DSA`             | System Accounts                          | `TRUE`  |
| `PLUGIN_EJBCA`           | Unknown                                  | `FALSE` |
| `PLUGIN_FAI`             | Unknown                                  | `FALSE` |
| `PLUGIN_FREERADIUS`      | FreeRadius Management                    | `FALSE` |
| `PLUGIN_FUSIONINVENTORY` | Inventory Plugin                         | `FALSE` |
| `PLUGIN_GPG`             | Manage GPG Keys                          | `FALSE` |
| `PLUGIN_IPMI`            | IPMI Management                          | `FALSE` |
| `PLUGIN_KOPANO`          | Kopano                                   | `FALSE` |
| `PLUGIN_MAIL`            | Mail Attributes                          | `TRUE`  |
| `PLUGIN_MAILINBLACK`     | MailinBlack                              | `FALSE` |
| `PLUGIN_MIXEDGROUPS`     | Unix/LDAP Groups                         | `FALSE` |
| `PLUGIN_NAGIOS`          | Nagios Monitoring                        | `FALSE` |
| `PLUGIN_NETGROUPS`       | NIS                                      | `FALSE` |
| `PLUGIN_NEXTCLOUD`       | Nextcloud                                | `FALSE` |
| `PLUGIN_NEWSLETTER`      | Manage Newsletters                       | `FALSE` |
| `PLUGIN_OPSI`            | Inventory                                | `FALSE` |
| `PLUGIN_PERSONAL`        | Personal Details                         | `TRUE`  |
| `PLUGIN_POSIX`           | Posix Groups                             | `FALSE` |
| `PLUGIN_POSTFIX`         | Postfix SMTP                             | `FALSE` |
| `PLUGIN_PPOLICY`         | Password Policy                          | `TRUE`  |
| `PLUGIN_PUPPET`          | Puppet CI                                | `FALSE` |
| `PLUGIN_PUREFTPD`        | FTP Server                               | `FALSE` |
| `PLUGIN_QUOTA`           | Manage Quotas                            | `FALSE` |
| `PLUGIN_RENATER_PARTAGE` | Unknown                                  | `FALSE` |
| `PLUGIN_REPOSITORY`      | Argonaut Deployment Registry             | `FALSE` |
| `PLUGIN_SAMBA`           | File Sharing                             | `FALSE` |
| `PLUGIN_SEAFILE`         | Seafile                                  | `FALSE` |
| `PLUGIN_SOGO`            | Groupware                                | `FALSE` |
| `PLUGIN_SPAMASSASSIN`    | Anti Spam                                | `FALSE` |
| `PLUGIN_SQUID`           | Proxy                                    | `FALSE` |
| `PLUGIN_SSH`             | Manage SSH Keys                          | `TRUE`  |
| `PLUGIN_SUBCONTRACTING`  | Unknown                                  | `FALSE` |
| `PLUGIN_SUDO`            | Manage SUDO on Hosts                     | `FALSE` |
| `PLUGIN_SUPANN`          | SUPANN                                   | `FALSE` |
| `PLUGIN_SYMPA`           | Sympa Mailing List                       | `FALSE` |
| `PLUGIN_SYSTEMS`         | Systems Management                       | `TRUE`  |
| `PLUGIN_USER_REMINDER`   | Password Expiry                          | `FALSE` |
| `PLUGIN_WEBLINK`         | Display Weblink                          | `FALSE` |


### Networking

* Please see [OpenLDAP Image](https://github.com/tiredofit/docker-openldap) for Networking Configuration

## Maintenance

### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

``bash
docker exec -it (whatever your container name is) bash
``
## Support

These images were built to serve a specific need in a production environment and gradually have had more functionality added based on requests from the community.
### Usage
- The [Discussions board](../../discussions) is a great place for working with the community on tips and tricks of using this image.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) for personalized support
### Bugfixes
- Please, submit a [Bug Report](issues/new) if something isn't working as expected. I'll do my best to issue a fix in short order.

### Feature Requests
- Feel free to submit a feature request, however there is no guarantee that it will be added, or at what timeline.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) regarding development of features.

### Updates
- Best effort to track upstream changes, More priority if I am actively using the image in a production environment.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) for up to date releases.

## License
MIT. See [LICENSE](LICENSE) for more details.

## References

* https://fusiondirectory.org
* https://openldap.org
