#!/bin/bash

# Dummy placeholder script to setup Kong and Keycloak, will be adjusted later

# Create namespace
kubectl create namespace $1

# Install Helm

# Install Kong
helm repo add kong https://charts.konghq.com
helm repo update
helm install kong kong/kong -f kong-values.yaml --namespace $1

# Install Keycloak
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install keycloak bitnami/keycloak -f keycloak-values.yaml --namespace $1

# Wait for Keycloak to be ready
while [ $(kubectl get pods -l release=keycloak -o jsonpath='{.items[*].status.phase}' --namespace $1) != "Running" ]; do
  sleep 5
done

# Wait for Kong to be ready
while [ $(kubectl get pods -l release=kong -o jsonpath='{.items[*].status.phase}' --namespace $1) != "Running" ]; do
  sleep 5
done