#!/bin/bash

echo "🤘 Deploying..."

#00. Install microK8s
sudo snap install microk8s --channel=1.24/stable --classic

KUBECTL="microk8s.kubectl"
STORAGE_CLASS=microk8s-hostpath

#01. Prepare Microk8s docker registry, stoarge, ingress
microk8s.enable registry storage helm3 dns dashboard ingress

#02. Set URI in hosts file to use the ingress
if grep -q "127.0.0.1 meetup.com" /etc/hosts; then
    echo "Hosts entries are already existing"
else
    echo "127.0.0.1 meetup.com" >> /etc/hosts
    echo "127.0.0.1 meetup-vault.com" >> /etc/hosts
fi

"${KUBECTL}" create ns meetup \
|| true

while [ $("${KUBECTL}" -n kube-system get pods -l k8s-app=kube-dns -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]; do echo "waiting for pod" && sleep 1; done

RELEASE_NAMESPACE="meetup"
RELEASE_NAME="meetup"

echo -e "\n\n🤘 Deploying ${RELEASE_NAME} in namespace ${RELEASE_NAMESPACE}"
microk8s.helm3 upgrade "${RELEASE_NAME}" . -i --namespace "${RELEASE_NAMESPACE}" \
    -f values.yaml \

if [ $? != 0 ]; then
    echo "Helm command failed!"
    exit;
fi

echo "\n🚀 Run sudo microk8s.kubectl get pods"

echo "\n🚀 ACCESS Meetup Service : https://meetup.com/ => ACCEPT SELF SIGNED CERTIFICATE!!!"
echo "\n🚀 ACCESS Meetup Service : https://meetup-vault.com/ => ACCEPT SELF SIGNED CERTIFICATE!!!"
