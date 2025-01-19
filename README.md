
# Eureka-K8s

Step-by-step guide for deploying Eureka base components (Keycloak, Kong, etc.)

---

## Prerequisites

1. PostgreSQL is available on the cluster/namespace or accessible within the network.
2. Kong and Keycloak databases are created.
3. Users in Kong and Keycloak databases are provisioned.

---

## Steps to Follow

1. Clone the repository:
   ```bash
   git clone https://github.com/folio-org/eureka-k8s.git
   ```

2. Navigate to the directory and make the setup script executable:
   ```bash
   cd eureka-k8s/ && chmod +x setup.sh
   ```

3. Adjust the `values.yaml` files for Kong and Keycloak according to your needs:
   - Pay special attention to the ingress configuration.
   - If you're deploying on the cloud, add the required annotations.
   - If not, keep ingress in a disabled state.

4. Update all required variables in the `setup.sh` file:
   - Provide Kong and Keycloak secrets.
   - Ensure database credentials match those provisioned in **Prerequisites** #3.

5. Execute the script:
   ```bash
   ./setup YourNamespaceName
   ```

---

## Example Image

![Example Deployment](https://github.com/user-attachments/assets/5d8ead13-7949-42de-90f1-6fdf60640f2f)
