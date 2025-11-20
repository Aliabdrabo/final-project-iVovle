
## Cloud DevOps Project Documentation

Project Overview

This project demonstrates a full Cloud DevOps pipeline for the iVolve application. It integrates modern DevOps practices to automate building, deploying, and monitoring the application.

- Containerization: Docker.
- Container Orchestration: Kubernetes (EKS).
- Infrastructure as Code (IaC): Terraform.
- CI/CD Pipeline: GitHub Actions.
- Application Deployment Management: ArgoCD & Kustomize.
- Security & Monitoring: Trivy scans for containers.

The workflow automates building, scanning, pushing images, and deploying updated applications to the Kubernetes cluster




## 🌐 Infrastructure Overview

<img width="1536" height="1024" alt="Image" src="https://github.com/user-attachments/assets/bb6bfb5e-a17d-49be-8116-bc78619d8ef3" />
The infrastructure is built using **Terraform** and AWS resources:

1. **VPC (Virtual Private Cloud)**
   - CIDR block: `10.0.0.0/16`
   - Public and private subnets across **two Availability Zones** for high availability.
   - DNS support and hostnames enabled.
 <img width="1508" height="231" alt="Image" src="https://github.com/user-attachments/assets/0e033db2-8cba-449c-ad3c-5485ed0043e6" />

2. **Subnets**
   - **Public Subnets**: For NAT Gateway, Internet Gateway, and public-facing resources.
   - **Private Subnets**: For EKS worker nodes and private resources.
<img width="1598" height="358" alt="Image" src="https://github.com/user-attachments/assets/59f0e6b2-f0c4-4eae-8756-1b0e25fec37d" />

3. **Internet Gateway (IGW)**
   - Allows public access to resources in public subnets.
<img width="1592" height="242" alt="Screenshot 2025-11-18 215131" src="https://github.com/user-attachments/assets/f1fef273-f390-4ea4-aa64-a636038d5293" />

4. **NAT Gateway**
   - Deployed in public subnets to provide internet access to private subnets.
<img width="1605" height="248" alt="Screenshot 2025-11-18 215116" src="https://github.com/user-attachments/assets/fb88883c-586e-4a07-a622-fd499d3d3239" />

5. **Route Tables**
   - Public route table: Routes `0.0.0.0/0` traffic through IGW.
   - Private route table: Routes `0.0.0.0/0` traffic through NAT Gateway.

6. **VPC Endpoints**
   - ECR API endpoint for private communication between EKS nodes and ECR.
   - Private DNS enabled.

7. **EKS Cluster**
   - Managed Kubernetes cluster using **Amazon EKS**.
   - **Two worker nodes**, deployed in separate private subnets.
   - Worker nodes type: `t3.micro` (Free Tier eligible for testing).
<img width="1897" height="937" alt="Screenshot 2025-11-18 215018" src="https://github.com/user-attachments/assets/23c90d5f-afa5-4e13-9c85-93134f364b93" />

8. **IAM Roles**
   - Roles for EKS cluster and worker nodes to allow AWS resources access.
<img width="1266" height="101" alt="Screenshot 2025-11-18 215553" src="https://github.com/user-attachments/assets/dfd25ca5-f920-410b-be1b-df960bf578ad" />

9. **ECR Repository**
   - For storing Docker images for deployment in the cluster.
<img width="1582" height="241" alt="Screenshot 2025-11-18 215143" src="https://github.com/user-attachments/assets/dee32b35-e1fb-4d2e-aa6b-b963c965354e" />

<img width="1541" height="330" alt="Screenshot 2025-11-18 215202" src="https://github.com/user-attachments/assets/67e7c27b-61f0-4eb1-8f21-5bdb6e19d582" />

<img width="1552" height="437" alt="Screenshot 2025-11-18 215213" src="https://github.com/user-attachments/assets/1843e09d-21ed-47c7-82ae-708b9e350cbc" />


## ⚙️ Terraform Modules

- `modules/vpc` → VPC, subnets, route tables, NAT, IGW  
- `modules/eks` → EKS cluster and node groups  
- `modules/roles` → IAM roles for cluster and nodes  
- `modules/ecr` → ECR repository  
- `modules/endpoints` → VPC endpoints  



## 🛠️ Variables

The following variables are used across modules:

```hcl
variable "project_name"       # Project name
variable "aws_region"         # AWS region (e.g., eu-central-1)
variable "availability_zones" # List of AZs for subnets
variable "cidr_block"         # VPC CIDR block
variable "public_cidr_blocks" # Public subnets CIDR
variable "private_cidr_blocks"# Private subnets CIDR
variable "default_route"      # Default route (usually 0.0.0.0/0)
```


---

## 🛠️ Setup & Deployment

Follow these steps to deploy the infrastructure:

### 1. Configure AWS Credentials
Make sure your AWS CLI is configured:
```bash
 vim ~/.aws/credentials
```
 put your aws credentials in the file 


### 2.Initialize Terraform
Download provider plugins and initialize your Terraform workspace:
```bash
terraform init
```
### 3. Validate Terraform Configuration
Check your Terraform files for any syntax or configuration issues:
```bash
terraform validate
```


### 4. Apply Terraform to Deploy
Create the infrastructure on AWS:
```bash
terraform apply -auto-approve
```

#### This will create:

- VPC, public and private subnets

- Internet Gateway and NAT Gateway

- Route Tables and associations

- EKS cluster with two worker nodes

- ECR repository

- VPC Endpoints

<img width="1641" height="890" alt="Image" src="https://github.com/user-attachments/assets/0ecaa105-f13c-4163-8e3f-6093fe403f8d" />

## 🐳 Docker & Build Tools

The application was containerized using Docker to ensure consistency across development and deployment environments. The workflow included:

1. Build & Dependencies

- Install required Python packages using in the Dockerfile:
    ```bash
    pip install -r requirements.txt
    ```

    Ensured all dependencies are defined in requirements.txt for reproducibility.

2. Dockerfile Creation

-  Created a Dockerfile defining the environment for the application.

   Set up the working directory, copied the application code, installed dependencies, and exposed the necessary ports.

3. Docker Image Build & Push

- Build the Docker image :
    ```bash
    docker build -t <image_name>:<tag> .
    ```

    Tagged and pushed the image to the AWS ECR repository:
    ```bash
    docker tag <image_name>:<tag> <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repo_name>:<tag>
    docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repo_name>:<tag>
    ```

This setup allows the application to run consistently across all environments, simplifies deployment, and integrates directly with Kubernetes via EKS.

## ☸️ Kubernetes Deployment
1. Namespace
- Created a dedicated namespace for isolating the application resources.

2. Deployment 
- Defined a Deployment manifest to manage the application's pods.
- Ensures desired replicas of the application are always running.
- Supports rolling updates for zero-downtime deployments.

3. Service (LoadBalancer)

- Configured a Service of type LoadBalancer to expose the application externally.

- Automatically provisions an external AWS ELB to distribute traffic across pods.

4. Scalability & Management

- Supports scaling of pods by adjusting replicas in the Deployment.

- All Kubernetes resources are version-controlled using YAML manifests.

This setup ensures the application is highly available, load-balanced, and isolated within its own namespace on the cluster.



## 🔄 CI/CD Workflow

The project uses a fully automated DevOps workflow to build, test, and deploy the application to AWS EKS. The workflow is implemented using GitHub Actions and integrates Docker, Terraform, and Kubernetes.

**Workflow Stages**
1. Code Commit & Push
- Any code change pushed to the repository triggers the workflow automatically.
- Ensures every commit goes through the CI/CD pipeline. 

2. Build Stage
- Builds a Docker image for the application using the Dockerfile.

3. Scan & Test Stage
- Performs security scans and tests using Trivy on the Docker image.
- Ensures vulnerabilities are detected before deployment.

4. Push to ECR
- Pushes the Docker image to AWS Elastic Container Registry (ECR).
- Tags images using GitHub run numbers for traceability.

5. Clone Manifests Repo
Clone the manifests repository and check the folder structure:
```bash
.
├── argocd
│   ├── application.yaml
│   └── argocd-application.yaml
└── manifests
    ├── base
    │   ├── application.yaml
    │   ├── deployment.yaml
    │   ├── kustomization.yaml      
    │   ├── lb.yaml                 
    │   └── ns.yaml                 
    └── overlays
        └── prod
            ├── image-patch.yaml    # Patch for Deployment image
            ├── kustomization.yaml  # Overlay kustomization
            ├── lb-patch.yaml       # LoadBalancer patch
            ├── ns-patch.yaml       # Namespace patch
            └── replicas-patch.yaml # Patch for replicas
```
- update the image-patch.yaml  with the new image 

6. Notifications 

- Slack notifications can be triggered to inform the team about pipeline success or failure.

**Workflow Benefits**

- Fully automated build-test-deploy cycle.

- Secure and reproducible Docker images.

- Scalable and fault-tolerant EKS deployment.

- Easy rollback and version tracking through image tags.



<img width="1898" height="407" alt="Image" src="https://github.com/user-attachments/assets/bb0096cf-2b8d-4c1c-b87d-0da0c711dc49" />




## 7. Deploy with ArgoCD

Follow these steps to deploy your application using ArgoCD:

1. Install ArgoCD (if not installed)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
<img width="1641" height="900" alt="Image" src="https://github.com/user-attachments/assets/ad002a16-edff-4a1c-9db7-ab2708933dcc" />

2. Access ArgoCD UI via LoadBalancer
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc argocd-server -n argocd
```

3. Open to Brwoser
```bash 
https://<EXTERNAL-IP>
```
4. Use the admin Username 
- Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Create an ArgoCD Application**
this will:
- Track the manifests repo.
- Deploy the resources defined in the manifests/base and overlays (e.g., prod).
- Automatically sync the changes.

<img width="1920" height="1031" alt="Image" src="https://github.com/user-attachments/assets/9a4e6de4-de19-49cd-9596-e595a84a35b0" />


----


**Validate your object on the cluster**
- check that all the pods is has Running state
- check that the lb is there and has external ip 
```bash
kubectl get ns
kubectl get all -n argocd
kubectl get deployments -n ivolve
kubectl get po -n ivolve 
kubectl get svc -n ivolve
```
<img width="1641" height="187" alt="Image" src="https://github.com/user-attachments/assets/c944feb2-3311-4e98-8097-ed7b4b1b7c61" />

### access your application 


<img width="1920" height="1080" alt="Image" src="https://github.com/user-attachments/assets/6b45860b-2385-4b7c-a9cc-9c41887b936c" />

---

## flow of the project

<img width="1796" height="655" alt="Image" src="https://github.com/user-attachments/assets/4e41969f-3976-4a7a-8a28-100a04daaf34" />
