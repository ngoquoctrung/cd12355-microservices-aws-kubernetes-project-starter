# Coworking Space Service Extension
The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

For this project, you are a DevOps engineer who will be collaborating with a team that is building an API for business analysts. The API provides business analysts basic analytics data on user activity in the service. The application they provide you functions as expected locally and you are expected to help build a pipeline to deploy it in Kubernetes.

## Getting Started

### Dependencies
#### Local Environment
1. Python Environment - run Python 3.6+ applications and install Python dependencies via `pip`
2. Docker CLI - build and run Docker images locally
3. `kubectl` - run commands against a Kubernetes cluster
4. `helm` - apply Helm Charts to a Kubernetes cluster

#### Remote Resources
1. AWS CodeBuild - build Docker images remotely
2. AWS ECR - host Docker images
3. Kubernetes Environment with AWS EKS - run applications in k8s
4. AWS CloudWatch - monitor activity and logs in EKS
5. GitHub - pull and clone code

### Setup

#### Ensure the AWS CLI is configured correctly.

aws sts get-caller-identity  
aws configure  
>AWS Access Key ID [None]: <New_AWS_Access_Key_ID>  
>AWS Secret Access Key [None]: <New_AWS_Secret_Access_Key>  
>Default region name [None]: <Region> (e.g., us-east-1)  
>Default output format [None]: <Format> (e.g., json)  

aws configure set aws_session_token [SESSION_TOKEN]  

#### Create an EKS Cluster
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2

#### Delete the EKS Cluster (when the project completes)
eksctl delete cluster --name my-cluster --region us-east-1

#### Update the Kubeconfig
aws eks --region us-east-1 update-kubeconfig --name my-cluster
#### Verify and copy the context name
kubectl config current-context  
kubectl config view  

#### Ensure you are connected to your K8s cluster
kubectl get namespace  
kubectl get storageclass  

#### Apply YAML configurations
kubectl apply -f pvc.yaml  
kubectl apply -f pv.yaml  
kubectl apply -f postgresql-deployment.yaml  

#### Test Database Connection
kubectl get pods  
kubectl exec -it postgresql-77d75d45d5-dgncv -- bash  
psql -U myuser -d mydatabase  
\l  
\c mydatabase  
\q # to exit  
exit # to exit  
kubectl apply -f postgresql-service.yaml  

#### List the services
kubectl get svc  

#### Set up port-forwarding to `postgresql-service`
kubectl port-forward service/postgresql-service 5433:5432 &  

#### Run Seed Files
apt update  
apt install postgresql postgresql-contrib  

export DB_PASSWORD=mypassword  
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/1_create_tables.sql  
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/2_seed_users.sql  
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/3_seed_tokens.sql  

#### Checking the tables
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433  
select *from users;  
select* from tokens;  
#### Closing the forwarded ports, this is just an FYI, you do not need to run it:
ps aux | grep 'kubectl port-forward' | grep -v grep | awk '{print $2}' | xargs -r kill  

#### Build the Analytics Application Locally

cd analytics  
pip install -r requirements.txt  

kubectl port-forward --namespace default svc/postgresql-service 5433:5432 &  

export DB_USERNAME=myuser  
export DB_PASSWORD=mypassword  
export DB_HOST=127.0.0.1  
export DB_PORT=5433  
export DB_NAME=mydatabase  

python app.py  

curl 127.0.0.1:5153/api/reports/daily_usage  
curl 127.0.0.1:5153/api/reports/user_visits  

docker build -t test-coworking-analytics .  
docker run --network="host" test-coworking-analytics  
 
echo -n 'mypassword' | base64  

kubectl apply -f deployment/configmap.yaml  
kubectl apply -f deployment/coworking.yaml  

kubectl get pods  
kubectl get svc  

curl a1878298dcdc34cf8a9f7a3d285f04d7-451711366.us-east-1.elb.amazonaws.com:5153/health_check  
curl a1878298dcdc34cf8a9f7a3d285f04d7-451711366.us-east-1.elb.amazonaws.com:5153/api/reports/daily_usage  
curl a1878298dcdc34cf8a9f7a3d285f04d7-451711366.us-east-1.elb.amazonaws.com:5153/api/reports/user_visits  

#### Setup CloudWatch Logging

aws iam attach-role-policy \
--role-name eksctl-my-cluster-nodegroup-my-nod-NodeInstanceRole-H7FBhcDn0H5V \
--policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy 

aws eks create-addon --addon-name amazon-cloudwatch-observability --cluster-name my-cluster  

curl a1878298dcdc34cf8a9f7a3d285f04d7-451711366.us-east-1.elb.amazonaws.com:5153/health_check  
curl a1878298dcdc34cf8a9f7a3d285f04d7-451711366.us-east-1.elb.amazonaws.com:5153/api/reports/daily_usage  
curl a1878298dcdc34cf8a9f7a3d285f04d7-451711366.us-east-1.elb.amazonaws.com:5153/api/reports/user_visits  

### Deliverables
### Deliverables
1. `Dockerfile`: Refer to [`Dockerfile`](Dockerfile)
2. Screenshot of AWS CodeBuild pipeline: Refer to [`screenshots/AWS_CodeBuild_pipeline.png`](screenshots/AWS_CodeBuild_pipeline.png)
3. Screenshot of AWS ECR repository for the application's repository: Refer to [`screenshots/AWS_ECR_repository.png`](screenshots/AWS_ECR_repository.png)
4. Screenshot of `kubectl get svc`: Refer to [`screenshots/kubectl_get_svc.png`](screenshots/kubectl_get_svc.png)
5. Screenshot of `kubectl get pods`: Refer to [`screenshots/kubectl_get_pods.png`](screenshots/kubectl_get_pods.png)
6. Screenshot of `kubectl describe svc <DATABASE_SERVICE_NAME>`: Refer to [`screenshots/postgresql_service.png`](screenshots/postgresql_service.png)
7. Screenshot of `kubectl describe deployment <SERVICE_NAME>`: Refer to [`screenshots/postgresql_deployment.png`](screenshots/postgresql_deployment.png) and [`screenshots/coworking_deployment.png`](screenshots/coworking_deployment.png)
8. All Kubernetes config files used for deployment (ie YAML files): Refer to: [`postgresql-deployment.yaml`](postgresql-deployment.yaml), [`postgresql-service.yaml`](postgresql-service.yaml), [`pv.yaml`](pv.yaml), [`pvc.yaml`](pvc.yaml), [`deployment/configmap.yaml`](deployment/configmap.yaml), [`deployment/coworking.yaml`](deployment/coworking.yaml)
9. Screenshot of AWS CloudWatch logs for the application - Refer to [`screenshots/AWS_CloudWatch_logs.png`](screenshots/AWS_CloudWatch_logs.png)
10. `README.md` file in your solution that serves as documentation for your user to detail how your deployment process works and how the user can deploy changes. The details should not simply rehash what you have done on a step by step basis. Instead, it should help an experienced software developer understand the technologies and tools in the build and deploy process as well as provide them insight into how they would release new builds.
Refer to this `README.md` file - `Setup`