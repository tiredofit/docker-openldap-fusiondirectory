#!/bin/sh

kubectl create secret generic openldap-certs --from-file=certs/
