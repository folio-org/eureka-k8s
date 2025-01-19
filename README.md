# eureka-k8s
step-by-step guide for deploying Eureka base (keycloak, kong etc.) components
Prerequisites:
1. Postgresql is availabe on cluster\namespace or network
2. Kong\Keycloak DBs created
3. Users in Kong\Keycloak DBs provisioned
Steps to follow:
1. git clone https://github.com/folio-org/eureka-k8s.git
2. cd eureka-k8s/ && chmod +x setup.sh
3. Adjust kong\keycloak value.yaml files according to your needs (Please pay attention to ingress part, if you're on cloud please use annotations, if not, keep it in disabled state)
4. Update all required variables in setup.sh file (Kong\Keycloak secrets, mostly DB related, please use the same creds fron prerequisites #3)
5. Execute script via ./setup YourNamespaceName