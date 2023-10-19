#!/bin/bash

KUBECTL="microk8s.kubectl"

microk8s.helm3 uninstall meetup -n meetup  || true
microk8s.kubectl delete ns meetup  || true
echo  "\n\n\n\n🚀 meetup Namespace was deleted!" 
