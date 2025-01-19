#!/bin/bash

# Sample usage: ./setup.sh my-namespace
# This script will install Kong and Keycloak in the specified namespace
# Author: Kitfox team, part of the FOLIO project's contributor community

# Global  static variables for the script
current_dir=$(pwd)
KONG_CHART_VERSION=12.0.11
KEYCLOAK_CHART_VERSION=21.0.4

# List of values for Kong secret creation, please adjust accordingly to your needs
KONG_ADMIN_USER='kong_admin'
KONG_PASSWORD='kong_password_123!'
KONG_PG_DATABASE='kong'
KONG_PG_HOST='specify_postgresql_host'
KONG_PG_PASSWORD='specify_postgresql_password'
KONG_PG_PORT='5432'
KONG_PG_USER='specify_postgresql_user'
KONG_URL='http://kong:8001'

# List of values for Keycloak secret creation, please adjust accordingly to your needs
KC_DB_PASSWORD='specify_keycloak_db_password'
KC_DB_URL_DATABASE='keycloak'
KC_DB_URL_HOST='specify_postgresql_host'
KC_DB_URL_PORT='5432'
KC_DB_USERNAME='specify_postgresql_user'
KC_FOLIO_BE_ADMIN_CLIENT_SECRET='folio_be_admin_client_secret'
KC_HTTPS_KEY_STORE_PASSWORD='https_key_store_password'
KEYCLOAK_ADMIN_PASSWORD='specify_keycloak_admin_password'
KEYCLOAK_ADMIN_USER='keycloak_admin'


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
helm install kong bitnami/kong -f $current_dir/kong/values.yaml --version $KONG_CHART_VERSION --namespace $1

# Install Keycloak
helm install keycloak bitnami/keycloak -f $current_dir/keycloak/values.yaml --version $KEYCLOAK_CHART_VERSION --namespace $1

# Wait for Keycloak to be ready
while [ "$(kubectl get pods -l release=keycloak -o jsonpath='{.items[*].status.phase}' --namespace $1)" != "Running" ]; 
do
  sleep 5
done

echo "Keycloak pod is ready in namespace $1"

# Wait for Kong to be ready
while [ "$(kubectl get pods -l release=kong -o jsonpath='{.items[*].status.phase}' --namespace $1)" != "Running" ]; 
do
  sleep 5
done

echo "Kong pod is ready in namespace $1"