#!/bin/bash

LOCAL_REGISTRY='registry.okd.mark.lan'
LOCAL_REPOSITORY='openshift/okd'
LOCAL_SECRET_JSON='auth.json'
OCP_RELEASE='4.15.0-0.okd-2024-03-10-010116'
PRODUCT_REPO='openshift'
RELEASE_NAME='okd'

oc adm release mirror -a ${LOCAL_SECRET_JSON}  \
     --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
     --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
     --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}

oc adm release extract -a ${LOCAL_SECRET_JSON} --command=openshift-install "${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}"
