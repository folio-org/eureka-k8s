#!/bin/bash

# Sample usage: ./setup.sh my-namespace
# This script will install Kong and Keycloak in the specified namespace
# Author: Kitfox team, part of the FOLIO project's contributor community

# Global variables for the script
current_dir=$(pwd)

# List of values for Kong secret creation, please adjust accordingly to your needs
KONG_ADMIN_USER=$(echo 'kong_admin' | base64)
KONG_PASSWORD=$(echo 'kong_password_123!' | base64)
KONG_PG_DATABASE=$(echo 'kong' | base64)
KONG_PG_HOST=$(echo 'specify_postgresql_host' | base64)
KONG_PG_PASSWORD=$(echo 'specify_postgresql_password' | base64)
KONG_PG_PORT=$(echo '5432' | base64)
KONG_PG_USER=$(echo 'specify_postgresql_user' | base64)
KONG_URL=$(echo 'http://kong:8001' | base64)

#List of values for Keycloak secret creation, please adjust accordingly to your needs
KC_DB_PASSWORD=$(echo 'specify_keycloak_db_password' | base64)
KC_DB_URL_DATABASE=$(echo 'keycloak' | base64)
KC_DB_URL_HOST=$(echo 'specify_postgresql_host' | base64)
KC_DB_URL_PORT=$(echo '5432' | base64)
KC_DB_USERNAME=$(echo 'specify_postgresql_user' | base64)
KC_FOLIO_BE_ADMIN_CLIENT_SECRET=$(echo 'folio_be_admin_client_secret' | base64)
KC_HTTPS_KEY_STORE_PASSWORD=$(echo 'https_key_store_password' | base64)
KEYCLOAK_ADMIN_PASSWORD=$(echo 'specify_keycloak_admin_password' | base64)
KEYCLOAK_ADMIN_USER=$(echo 'keycloak_admin' | base64)


# Create namespace
STATUS=$(kubectl create namespace $1)
if [ $? -eq 0 ]; then
  echo "Namespace $1 created successfully"
else
  echo "Namespace $1 already exists"
fi

# Create secret for Kong
kubectl create secret generic kong-credentials \
  --from-literal=KONG_ADMIN_USER=$KONG_ADMIN_USER \
  --from-literal=KONG_PASSWORD=$KONG_PASSWORD \
  --from-literal=KONG_PG_DATABASE=$KONG_PG_DATABASE \
  --from-literal=KONG_PG_HOST=$KONG_PG_HOST \
  --from-literal=KONG_PG_PASSWORD=$KONG_PG_PASSWORD \
  --from-literal=KONG_PG_PORT=$KONG_PG_PORT \
  --from-literal=KONG_PG_USER=$KONG_PG_USER \
  --from-literal=KONG_URL=$KONG_URL \
  --namespace $1

# Create secret for Keycloak
kubectl create secret generic keycloak-credentials \
  --from-literal=KC_DB_PASSWORD=$KC_DB_PASSWORD \
  --from-literal=KC_DB_URL_DATABASE=$KC_DB_URL_DATABASE \
  --from-literal=KC_DB_URL_HOST=$KC_DB_URL_HOST \
  --from-literal=KC_DB_URL_PORT=$KC_DB_URL_PORT \
  --from-literal=KC_DB_USERNAME=$KC_DB_USERNAME \
  --from-literal=KC_FOLIO_BE_ADMIN_CLIENT_SECRET=$KC_FOLIO_BE_ADMIN_CLIENT_SECRET \
  --from-literal=KC_HTTPS_KEY_STORE_PASSWORD=$KC_HTTPS_KEY_STORE_PASSWORD \
  --from-literal=KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD \
  --from-literal=KEYCLOAK_ADMIN_USER=$KEYCLOAK_ADMIN_USER \
  --namespace $1

# Add bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install Kong
helm install kong-$1 bitnami/kong -f $current_dir/kong/values.yaml --version 12.0.11 --namespace $1

# Install Keycloak
helm install keycloak-$1 bitnami/keycloak -f $current_dir/keycloak/values.yaml --version 21.0.4 --namespace $1

# Wait for Keycloak to be ready
while [ $(kubectl get pods -l release=keycloak-$1 -o jsonpath='{.items[*].status.phase}' --namespace $1) != "Running" ]; 
do
  sleep 5
done

# Wait for Kong to be ready
while [ $(kubectl get pods -l release=kong-$1 -o jsonpath='{.items[*].status.phase}' --namespace $1) != "Running" ]; 
do
  sleep 5
done