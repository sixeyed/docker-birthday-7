#!/bin/bash

# required parameters in ENV:
# AZURE_SP_NAME
# AZURE_SP_TENANT
# AZURE_SP_PASSWORD
# AZURE_SP_APP_ID
# AZURE_RESOURCE_GROUP
# AZURE_REGION
# AKS_CLUSTER_NAME
# AKS_KUBERNETES_VERSION
# AKS_NODE_COUNT
# AKS_NODE_SIZE

# login
az login --service-principal -u $AZURE_SP_NAME -p $AZURE_SP_PASSWORD --tenant $AZURE_SP_TENANT > /dev/null

# create RG if needed:
az group show --name $AZURE_RESOURCE_GROUP > /dev/null
if [ $? != 0 ]; then
	echo "Creating new resource group: $AZURE_RESOURCE_GROUP"
	az group create --name $AZURE_RESOURCE_GROUP --location $AZURE_REGION > /dev/null
else
	echo "Using existing resource group: $AZURE_RESOURCE_GROUP"
fi

# create cluster if not exists:
az aks show --resource-group $AZURE_RESOURCE_GROUP --name $AKS_CLUSTER_NAME > /dev/null
if [ $? != 0 ]; then
    echo "Creating AKS cluster: $AKS_CLUSTER_NAME"
    az aks create --resource-group $AZURE_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --node-count $AKS_NODE_COUNT --node-vm-size $AKS_NODE_SIZE --kubernetes-version $AKS_KUBERNETES_VERSION --generate-ssh-keys --network-plugin azure --vnet-subnet-id $SUBNET_ID --docker-bridge-address 172.17.0.1/16 --dns-service-ip 10.2.0.10 --service-cidr 10.2.0.0/24
        
    # get creds for Kubectl
    az aks get-credentials --resource-group $AZURE_RESOURCE_GROUP --name $AKS_CLUSTER_NAME
       
    echo 'Installing ACI connector for Windows'
    helm install https://github.com/virtual-kubelet/azure-aci/raw/master/charts/virtual-kubelet-aci-for-aks.tgz 
      --generate-name --set nodeOsType=Windows \
      --set nodeName=virtual-kubelet-aci-connector-for-windows \
      --set image.name=virtual-kubelet --set image.tag=1.2.1 \
      --set providers.azure.vnet.enabled=false
    
    echo 'Installing ACI connector for Linux'
    helm install https://github.com/virtual-kubelet/azure-aci/raw/master/charts/virtual-kubelet-aci-for-aks.tgz \
      --generate-name --set nodeOsType=Linux \
      --set nodeName=virtual-kubelet-aci-connector-for-linux \
      --set image.name=virtual-kubelet --set image.tag=1.2.1 \
      --set providers.azure.vnet.enabled=false 

    echo 'Configuring RBAC for Kubernetes dashboard'
    kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
else
	echo "Cluster: $AKS_CLUSTER_NAME already exists, no changes made - resource group: $AZURE_RESOURCE_GROUP"
fi