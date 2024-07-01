# Ensure the AWS CLI is configured correctly.

aws sts get-caller-identity  
aws configure  
>AWS Access Key ID [None]: <New_AWS_Access_Key_ID>  
>AWS Secret Access Key [None]: <New_AWS_Secret_Access_Key>  
>Default region name [None]: <Region> (e.g., us-east-1)  
>Default output format [None]: <Format> (e.g., json)  

aws configure set aws_session_token [SESSION_TOKEN]  

# Create an EKS Cluster
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2

# Delete the EKS Cluster (when the project completes)
eksctl delete cluster --name my-cluster --region us-east-1

# Update the Kubeconfig
aws eks --region us-east-1 update-kubeconfig --name my-cluster
# Verify and copy the context name
kubectl config current-context  
kubectl config view  

# Ensure you are connected to your K8s cluster
kubectl get namespace  
kubectl get storageclass  

# Apply YAML configurations
kubectl apply -f pvc.yaml  
kubectl apply -f pv.yaml  
kubectl apply -f postgresql-deployment.yaml  

# Test Database Connection
kubectl get pods  
kubectl exec -it postgresql-77d75d45d5-nl7jw -- bash  
psql -U myuser -d mydatabase  
\l  
\c mydatabase  
\q # to exit  
exit # to exit  
kubectl apply -f postgresql-service.yaml  

# List the services
kubectl get svc  

# Set up port-forwarding to `postgresql-service`
kubectl port-forward service/postgresql-service 5433:5432 &  

# Run Seed Files
apt update  
apt install postgresql postgresql-contrib  

export DB_PASSWORD=mypassword  
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/1_create_tables.sql  
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/2_seed_users.sql  
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/3_seed_tokens.sql  

# Checking the tables
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433  
select *from users;  
select* from tokens;  
# Closing the forwarded ports, this is just an FYI, you do not need to run it:
ps aux | grep 'kubectl port-forward' | grep -v grep | awk '{print $2}' | xargs -r kill  

# Build the Analytics Application Locally

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

kubectl get svc  
echo -n 'mypassword' | base64  

kubectl apply -f deployment/configmap.yaml  
kubectl apply -f deployment/coworking.yaml  

curl acc00e48dfb304e3791e5c4dffa6e5eb-455415038.us-east-1.elb.amazonaws.com:5153/health_check  
curl acc00e48dfb304e3791e5c4dffa6e5eb-455415038.us-east-1.elb.amazonaws.com:5153/api/reports/daily_usage  
curl acc00e48dfb304e3791e5c4dffa6e5eb-455415038.us-east-1.elb.amazonaws.com:5153/api/reports/user_visits  

# Setup CloudWatch Logging

aws iam attach-role-policy \  
--role-name eksctl-my-cluster-nodegroup-my-nod-NodeInstanceRole-HFIlNqBK6dli \  
--policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  

aws eks create-addon --addon-name amazon-cloudwatch-observability --cluster-name my-cluster  

curl acc00e48dfb304e3791e5c4dffa6e5eb-455415038.us-east-1.elb.amazonaws.com:5153/health_check  
curl acc00e48dfb304e3791e5c4dffa6e5eb-455415038.us-east-1.elb.amazonaws.com:5153/api/reports/daily_usage  
curl acc00e48dfb304e3791e5c4dffa6e5eb-455415038.us-east-1.elb.amazonaws.com:5153/api/reports/user_visits  