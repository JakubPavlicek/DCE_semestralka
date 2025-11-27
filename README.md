## Docker Compose + Terraform + Ansible

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)

### Setup Docker Compose 

Use the .devcontainer folder to open the project in VS Code in a container.

Access the frontend: http://localhost:8080

### Setup Terraform + Ansible

Use the .devcontainer folder to open the project in VS Code in a container.

Change directory to `terraform`:
```shell
cd terraform
```

Create `terraform.tfvars` file with the following content and fill in the missing values:
```hcl
opennebula_username = "<orion login>"
opennebula_token    = "<opennebula token>"
vm_ssh_pubkey = "<public key - use 'ppk' command in dev. container terminal>"
vm_count = 1
vm_image_name = "Ubuntu Minimal 24.04"
vm_image_url = "https://marketplace.opennebula.io//appliance/44077b30-f431-013c-b66a-7875a4a4f528/download/0"
```

Run Terraform:
```shell
terraform init
terraform apply -auto-approve
```

Access the frontend at the generated VM's IP address.

### Implementation

#### Backend

Backend is implemented using Flask. \
See source code in: `python/backend/backend.py`

REST API endpoints:
- `/health` - returns 200 OK if the backend is up and running
- `/movies` - returns a list of movies
- `/movies/<movie_id>` - returns a movie with the given ID
- `/find/<movie_name>` - returns a movie with the given name

#### Frontend

Frontend is implemented using Flask and it uses template rendering to render the HTML pages. \
See source code in: `python/frontend/frontend.py` and templates in: `python/frontend/templates`

The pages:
- `movies.html`
- `movie.html`
- `find.html`

#### Docker Compose

The Dockerfile for frontend is located in: `.devcontainer/Dockerfile.frontend` \
The Dockerfile for backend is located in: `.devcontainer/Dockerfile.backend`

The Docker Compose file is located in: `.devcontainer/docker-compose.yml` which contains both frontend and backend services.

#### Terraform

It uses OpenNebula provider to create a VM instance. \
It uses `inventory.template` file to generate the Ansible host inventory dynamically. \
It uses `ansible-provisioner` resource to run Ansible playbook on the newly created infrastructure.

#### Ansible

It installs Docker and Docker Compose on the VM instance.

Roles:
- `docker` - to install Docker
- `backend-and-frontend` - to start the frontend and backend services using Docker Compose 

## Kubernetes

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

### Docker Images

Docker Images are built using GitHub Actions and published to GitHub Container Registry.

### Setup

Start minikube:
```shell
minikube start --driver=docker
```

Enable ingress addon:
```shell
minikube addons enable ingress
```

Change directory to `k8s`:
```shell
cd k8s
```

Create `dce` namespace, ingress, frontend and backend deployments/services:
```shell
kubectl apply -f dce-namespace.yaml
kubectl apply -f ingress.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
```

Wait for the frontend and backend to be ready:
```shell
kubectl get pods -n dce
```

Run this to make Ingress addon work in minikube:
```shell
sudo minikube tunnel
```

Access the frontend: http://localhost:80

### Implementation

The Kubernetes manifests are located in: `k8s`