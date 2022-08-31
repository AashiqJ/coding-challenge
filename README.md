# IBM Cloud Engineer coding challenge

### 1. Develop a basic application exposing 2 simple REST API endpoints (POST, GET)
  - POST - store some persistent data
  - GET - retrieve data

For this I have created a python application which uses flask to listen for POST and GET calls.
When a POST call is made to this application with a header "Number" it will add it to a list of number and when a GET call is made it returns the addition of all the numbers in the list.

```curl --location --request POST 'https://ibm-test.example.com' --header 'Number: 5' ```

``` curl --location --request GET 'https://ibm-test.example.com' ```

### 2. Implement automation that deploys and makes available the REST API endpoints on a Kubernetes environment (eg: CI/CD)

For the CI/CD part I decided to go with pipeline in AzureDevops. In the azure-pipelines.yml, we can see that the steps included are to build a docker image and push it to the Azure container registry and Deploy it to Kubernetes using the manifest file in azure_devops folder.

### 3.  Implement automation that provisions all infrastructure elements that are used to run the solution

The Infrastructure automation is done through terraform. The terrform template in the infra folder will create a Resource Group, VNet and a public AKS.
To deploy the infra use the following steps:

* Initiate the provider.
    ```
    terraform init
    ```
* Run below command to start deploying. After about 5-10 minutes your cluster should be up and running.
    ```
    terraform apply
    ```
* After Terraform is complete, go ahead and get the credentials for the cluster.
    ```
    az aks get-credentials -n <clusterName> -g <clusterResourceGroup> -f kubeconfig
    ```
* Connect to the cluster.
    ```
    export KUBECONFIG=./kubeconfig
    kubectl get all --all-namespaces
    ```

Once the cluster is Deployed then we will require Nginx ingress controller to access the application, this example uses Helm 3 for installing NGINX Ingress:
* Create the namespace for the Ingress Controller.
    ```
    kubectl create namespace nginx-ingress
    ```
* Add the ingress-nginx repo to Helm and update.
    ```
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    ```
* Before installing, we need the public IP we created and the resource group name. You can get those values from Terraform.
    ```
    IP=$(terraform output ingress-ip) && echo $IP
    RG=$(terraform output main-resource-group) && echo $RG
    ```
* Run the Helm install command after creating above variables. To pickup the Public IP resource in the resource group, we the add the two last lines to the install command.
    ```
    helm install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace nginx-ingress \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.service.type=LoadBalancer \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP=$IP \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$RG
    ```

Follow these steps to install Cert-manager along with a cert-issuer to enable TLS.
https://www.howtogeek.com/devops/how-to-install-kubernetes-cert-manager-and-configure-lets-encrypt/

Also, we need a small vm which will be used a self-hosted agent for building and pushing deployments to AKS.

Once we get the external IP of the Nginx-ingress loadbalancer we can add a DNS record to access the application from Q1.