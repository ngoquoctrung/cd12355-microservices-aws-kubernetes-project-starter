aws sts get-caller-identity

aws configure
    AWS Access Key ID [None]: <New_AWS_Access_Key_ID>
    AWS Secret Access Key [None]: <New_AWS_Secret_Access_Key>
    Default region name [None]: <Region> (e.g., us-west-2)
    Default output format [None]: <Format> (e.g., json)

aws configure set aws_session_token [SESSION_TOKEN]

#Create an EKS Cluster
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2

#Delete the EKS Cluster
eksctl delete cluster --name my-cluster --region us-east-1

#Update the Kubeconfig
aws eks --region us-east-1 update-kubeconfig --name my-cluster
#Verify and copy the context name
kubectl config current-context
kubectl config view

# ensure you are connected to your K8s cluster
kubectl get namespace
kubectl get storageclass
#Apply YAML configurations
kubectl apply -f pvc.yaml
kubectl apply -f pv.yaml
kubectl apply -f postgresql-deployment.yaml

kubectl get pvc
#kubectl delete pvc postgresql-pvc
kubectl get pv
#kubectl delete pv my-manual-pv
kubectl get Service
#kubectl delete Service postgresql-service

#Set up database
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-postgres bitnami/postgresql

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default my-postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
echo $POSTGRES_PASSWORD

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql-service -o jsonpath="{.data.postgres-password}" | base64 -d)
echo $POSTGRES_PASSWORD

#Test Database Connection
kubectl get pods
kubectl exec -it postgresql-77d75d45d5-vx7l8 -- bash

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

apt update
apt install postgresql postgresql-contrib

export DB_PASSWORD=mypassword
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/1_create_tables.sql
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/2_seed_users.sql
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/3_seed_tokens.sql

#Run the following command to open up the psql terminal:
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433
select *from users;
select* from tokens;
#Closing the forwarded ports, this is just an FYI, you do not need to run it:
ps aux | grep 'kubectl port-forward' | grep -v grep | awk '{print $2}' | xargs -r kill

#Build the Analytics Application Locally

cd analytics
pip install -r requirements.txt

#kubectl port-forward --namespace default svc/postgresql-service 5433:5432 &
kubectl port-forward --namespace default svc/postgresql-service 5133:5432 &

export DB_PASSWORD=${POSTGRES_PASSWORD}
echo $DB_PASSWORD
export DB_HOST=127.0.0.1
export DB_PORT=5433
export DB_NAME=mydatabase

python app.py

curl 127.0.0.1:5153/api/reports/daily_usage
curl 127.0.0.1:5153/api/reports/user_visits

docker build -t test-coworking-analytics .
docker run -p 5153:5153 test-coworking-analytics

curl a8c6ccec2672f48e48e90523965da177-98993898.us-east-1.elb.amazonaws.com:5153/api/reports/daily_usage
curl a8c6ccec2672f48e48e90523965da177-98993898.us-east-1.elb.amazonaws.com:5153/api/reports/user_visits