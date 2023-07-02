# Getting Started 

 Commands demonstrate how to set up a Kubernetes deployment, expose it using an ingress resource, and perform a test request. 

# Using kubectl with kustomization

## Setup

To begin, execute the following commands to set up the deployment and ingress resource:

```sh
kubectl apply -k welcome-service
```

## Test

After the setup is complete, you can test the deployment by making an HTTP request to the specified URL. Use the http command-line tool and provide the appropriate request method and URL. 

```sh
http http://welcome.local.gd
```

## Teardown

Execute the following commands for teardown:

```sh
kubectl delete -k welcome-service
```

# Using kubectl (without kustomization)
## Setup

To begin, execute the following commands to set up the deployment and ingress resource:

```sh
# Create a deployment using the NGINX image
kubectl create deployment welcome --image=nginx:latest --port=80
# Expose the deployment as a service
kubectl expose deployment welcome
# Create an ingress resource for the domain "welcome.local.gd"
kubectl create ingress welcome-local-gd --class=nginx  --rule="welcome.local.gd/*=welcome:80"
```

## Test

After the setup is complete, you can test the deployment by making an HTTP request to the specified URL. Use the http command-line tool and provide the appropriate request method and URL. 

```sh
http http://welcome.local.gd
```


## Teardown

Execute the following commands for teardown:

```sh
# Delete the deployment
kubectl delete deployment welcome 
# Delete the service
kubectl delete service welcome
# Delete the ingress resource
kubectl delete ingress welcome-local-gd 
```