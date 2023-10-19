# tech-talk-01
Berlin Tech-Talk to deploy a Hashicorp Vault and basic frontend App locally

## Install microk8s with helm
01. cd VAULT_DEMO
02. sudo ./deploy_with_microk8s.sh

## Build Image for microk8s locally
01. sudo docker build -t localhost:32000/vaultk8s:1.1.1 .
02. sudo docker push localhost:32000/vaultk8s:1.1.1
