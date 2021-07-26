# Amazon EKS Cluster
This repository contains source code to provision an EKS cluster in AWS using Terraform. 

## Prerequisites
* AWS account
* AWS profile configured with CLI on local machine
* [Terraform](https://www.terraform.io/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Project Structure

```
├── README.md
├── eks
|  ├── cluster.tf
|  ├── cluster_role.tf
|  ├── cluster_sg.tf
|  ├── node_group.tf
|  ├── node_group_role.tf
|  ├── node_sg.tf
|  └── vars.tf
├── main.tf
├── provider.tf
├── raw-manifests
|  ├── aws-auth.yaml
|  ├── pod.yaml
|  └── service.yaml
├── variables.tf
└── vpc
   ├── control_plane_sg.tf
   ├── data_plane_sg.tf
   ├── nat_gw.tf
   ├── output.tf
   ├── public_sg.tf
   ├── vars.tf
   └── vpc.tf
```

## Remote Backend State Configuration
To configure remote backend state for your infrastructure, create an S3 bucket and DynamoDB table before running *terraform init*. In the case that you want to use local state persistence, update the *provider.tf* accordingly and don't bother with creating an S3 bucket and DynamoDB table.

### Create S3 Bucket for State Backend
```aws s3api create-bucket --bucket <bucket-name> --region <region> --create-bucket-configuration LocationConstraint=<region>```

### Create DynamoDB table for State Locking
```aws dynamodb create-table --table-name <table-name> --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1```

## Provision Infrastructure
Review the *main.tf* to update the node size configurations (i.e. desired, maximum, and minimum). When you're ready, run the following commands:
1. `terraform init` - Initialize the project, setup the state persistence (whether local or remote) and download the API plugins.
2. `terraform plan` - Print the plan of the desired state without changing the state.
3. `terraform apply` - Print the desired state of infrastructure changes with the option to execute the plan and provision. 

## Connect To Cluster
Using the same AWS account profile that provisioned the infrastructure, you can connect to your cluster by updating your local kube config with the following command:
`aws eks --region <aws-region> update-kubeconfig --name <cluster-name>`

## Map IAM Users & Roles to EKS Cluster
If you want to map additional IAM users or roles to your Kubernetes cluster, you will have to update the `aws-auth` *ConfigMap* by adding the respective ARN and a Kubernetes username value to the mapRole or mapUser property as an array item. 

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::<account-id>:role/<cluster-name>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::<account-id>:role/ops-role
      username: ops-role
  mapUsers: |
    - userarn: arn:aws:iam::<account-id>:user/developer-user
      username: developer-user
```

When you are done with modifications to the aws-auth ConfigMap, you can run `kubectl apply -f auth-auth.yaml`. An example of this manifest file exists in the raw-manifests directory.

For a more in-depth explanation on this, you can read [this post](https://medium.com/swlh/secure-an-amazon-eks-cluster-with-iam-rbac-b78be0cd95c9).

## Deploy Application
To deploy a simple application to you cluster, redirect to the directory called raw-manifests and apply the *pod.yaml* and *service.yaml* manifest files to create a Pod and expose the application with a LoadBalancer Service. 
1. `kubectl apply -f service.yaml`
2. `kubectl apply -f pod.yaml`