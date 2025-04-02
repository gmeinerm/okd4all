#!/bin/bash

LOCAL_REGISTRY='registry.ocp.mark.lan'
LOCAL_REPOSITORY='openshift/okd'
LOCAL_SECRET_JSON='auth.json'
OCP_RELEASE='4.18.0-okd-scos.6'
PRODUCT_REPO='okd'
RELEASE_NAME='scos-release'

oc adm release mirror -a ${LOCAL_SECRET_JSON}  \
     --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
     --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
     --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}

oc adm release extract -a ${LOCAL_SECRET_JSON} --command=openshift-install "${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}"
