#Create an EKS Cluster
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2
#Update the Kubeconfig
aws eks --region us-east-1 update-kubeconfig --name my-cluster
#Verify and copy the context name
kubectl config current-context
kubectl config view
#Delete the EKS Cluster
eksctl delete cluster --name my-cluster --region us-east-1
# ensure you are connected to your K8s cluster
kubectl get namespace
kubectl get storageclass
#Apply YAML configurations
kubectl apply -f pvc.yaml
kubectl apply -f pv.yaml
kubectl apply -f postgresql-deployment.yaml

#Test Database Connection
kubectl get pods
kubectl exec -it postgresql-77d75d45d5-b8sx2 -- bash