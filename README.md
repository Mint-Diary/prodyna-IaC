
# PRODYNA Infrastructure Task

## Repository Structure

The project is structured to strictly separate infrastructure provisioning from configuration management, utilizing modular approaches for both Terraform and Ansible.

```Plaintext
.
├── ansible/
│   ├── roles/
│   │   ├── core/           # Base system configuration (updates, timezone)
│   │   ├── jumphost/       # Administrative tool installations (az cli, kubectl)
│   │   └── motd/           # Custom login banner deployment (99-prodyna.sh.j2)
│   └── site.yml            # Master playbook orchestrating all roles
├── modules/
│   ├── aks/                # Azure Kubernetes Service provisioning
│   ├── jumphost/           # Linux VM, public IP, and network interface
│   ├── network/            # Virtual Network, Subnets, and NSG rules
│   ├── security/           # Key Vault and associated Private Endpoints
│   └── storage/            # Storage Account and associated Private Endpoints
├── main.tf                 # Root module invoking the infrastructure components
├── providers.tf            # Provider configuration (azurerm, local, tls)
├── variables.tf            # Global variable definitions
└── README.md               # Project documentation

```


## Deployment Instructions

### 1. Preparation

Open the Azure Cloud Shell and clone this repository to your workspace.

```Bash
git clone https://github.com/Mint-Diary/prodyna-IaC.git
cd prodyna-IaC
```
___

### 2. Infrastructure Provisioning

The Terraform deployment creates a strictly isolated Azure VNet (10.0.0.0/16). Managed Services like AKS, Key Vault, and Storage are restricted to Private Endpoints to enforce Zero Trust principles. To prevent routing conflicts with this primary VNet, the AKS cluster is provisioned with a custom Service CIDR (192.168.0.0/16).

Initialize and apply the Terraform configuration:

```Bash
terraform init
terraform apply -var="subscription_id=<YOUR_SUBSCRIPTION_ID>"

```
___

### 3. Configuration Management

Because the managed services are fully private, a dedicated Linux Jumphost serves as the single point of entry. The provided Ansible playbook dynamically configures this instance by applying system updates, deploying a custom MOTD, and installing the necessary administrative CLI tools like Azure CLI and kubectl.

Execute the playbook from the ansible directory:


```Bash
cd ansible
chmod 600 jumphost_key.pem
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "<JUMPHOST_IP>," -u adminuser --private-key ./jumphost_key.pem site.yml

```

## Validation and Testing

The scope of this project was deliberately expanded to implement a fully private network architecture because it simply made sense for a secure cloud baseline. Consequently, infrastructure validation must be performed from within the Jumphost. Please ensure you are currently located in the ansible directory so the SSH command can access the generated key file.

Connect to the Jumphost:


```Bash
ssh -i ./jumphost_key.pem adminuser@<JUMPHOST_IP>

```

Verify internal routing to the configured Private Endpoints:


```
Bash
nc -vz <STORAGE_ACCOUNT_PRIVATE_IP> 443
nc -vz <KEY_VAULT_PRIVATE_IP> 443

```

Authenticate via Azure CLI and verify cluster connectivity:



```Bash
az login --use-device-code
az aks get-credentials --resource-group RG-Demid-Krom --name aks-prodyna-dev
kubectl get nodes

```
## Conceptual Architecture & Operations

To demonstrate a comprehensive understanding of Workload Management within the deployed infrastructure, the following concepts outline how this baseline architecture handles application deployments and secret management.

### DevOps Engineer: Workload Deployment & Secret Management

* **IaC Workload Deployment (Staging/Production):** To deploy a web server like Nginx across multiple environments, I would utilize Helm as the package manager, orchestrated either via Terraform (using the Helm provider) or a GitOps controller like ArgoCD. The core Kubernetes manifests (Deployment, Service, Ingress) would be kept generic in a base Helm chart. Environment-specific configurations, such as replica counts or resource limits, would be separated into dedicated `values-staging.yaml` and `values-prod.yaml` files. This ensures the configuration remains DRY (Don't Repeat Yourself) while allowing safe, isolated environment overrides.
* **Secret Synchronization via Operator:** To securely inject a MySQL connection string from Azure Key Vault into the AKS cluster, I would deploy the Azure Key Vault Provider for Secret Store CSI Driver (or alternatively, the External Secrets Operator). By defining a `SecretProviderClass` Custom Resource, the operator dynamically fetches the secret from the Key Vault and mounts it directly into the pod's file system or synchronizes it into a native Kubernetes Secret. This completely removes the need to store sensitive payloads in the Git repository or the Terraform state file.
## Engineering Notes

Building this environment involved navigating several practical cloud constraints. Here is a brief overview of the design decisions and challenges encountered during the setup:

-   **NSG SSH Access (Wildcard vs. Dedicated IP):** The Network Security Group rule for the Jumphost uses a wildcard source prefix instead of a dedicated IP address. While a production environment would mandate strict IP whitelisting or Azure Bastion, this compromise was made specifically for the assessment. It ensures the reviewing engineers can seamlessly connect to the Jumphost to evaluate the configuration without needing to inject their own IP addresses into the Terraform state beforehand.
    
-   **Capacity Constraints:** Initial provisioning attempts failed due to Azure region capacity limitations. The virtual machine SKUs had to be actively upgraded from the standard B1s series to Standard_B2s_v2 to guarantee a reliable deployment process.
    
-   **Network Overlaps:** To enforce the private network architecture cleanly, the AKS Service CIDR had to be explicitly shifted to 192.168.0.0/16. This prevents IP space collisions with the primary VNet.
    
-   **DNS Resolution:** Dedicated Azure Private DNS Zones were kept out of scope to keep the codebase lean and focused. Therefore, a local DNS resolution workaround via the hosts file on the Jumphost is utilized to resolve the internal Private Endpoints for testing.


## Documentation Note

The technical concepts, architecture design, and deployment instructions in this project are entirely my own work. AI tooling was utilized strictly to translate my original German notes into professional English and to refine the overall formatting of this document.
