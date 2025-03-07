oc adm upgrade --allow-explicit-upgrade --to-image quay.io/okd/scos-release@sha256:0de353901f9ab5ecb14c2583d16d24561df23d1bf46fe03f218f2ffb8f134096

sleep 60

oc scale --replicas=0 deployments/cluster-version-operator -n openshift-cluster-version

oc -n openshift-kube-apiserver-operator patch deployment kube-apiserver-operator --type='json' -p='[
    {"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "quay.io/okd/scos-content@sha256:37d6b6c13d864deb7ea925acf2b2cb34305333f92ce64e7906d3f973a8071642"},
    {"op": "replace", "path": "/spec/template/spec/containers/0/env/0/value", "value": "quay.io/okd/scos-content@sha256:5c9128668752a9b891a24a9ec36e0724d975d6d49e6e4e2d516b5ba80ae2fb23"},
    {"op": "replace", "path": "/spec/template/spec/containers/0/env/1/value", "value": "quay.io/okd/scos-content@sha256:37d6b6c13d864deb7ea925acf2b2cb34305333f92ce64e7906d3f973a8071642"},
    {"op": "replace", "path": "/spec/template/spec/containers/0/env/2/value", "value": "1.29.6"}
]'

sleep 180

oc wait clusteroperators kube-apiserver --for=condition=Progressing=false --timeout=600s

oc scale --replicas=1 deployments/cluster-version-operator -n openshift-cluster-version
