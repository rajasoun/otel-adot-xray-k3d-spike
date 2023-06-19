# About

Open Telemetry Spike: AWS X-Ray Integration with Local Kubernetes Cluster (k3d)

This project demonstrates the integration of AWS X-Ray with a local Kubernetes cluster using OpenTelemetry. It utilizes the `aws-otel-collector` to collect traces and metrics from the `hello-service` application and send them to AWS X-Ray.

## Prerequisites


## Getting Started
Follow these steps to set up and run the project:

1. Create a Local Kubernetes Cluster: Use the command `local-dev/assist.sh setup` to create a local Kubernetes cluster using k3d.

2. Create Secrets: Execute the command `kubectl create secret generic aws-credentials --from-file="$HOME/.aws/credentials"` to create a secret containing AWS credentials required for accessing AWS services.

3. Bootstrap the Cluster: Apply the bootstrap resources to the local Kubernetes cluster using the command `kubectl apply -k bootstrap`.

4. Retrieve Pod and Container Information: Run the command `bootstrap/debug.sh default` to obtain information about the pods, containers, and their associated ports.

5. Build, Push, and Deploy the hello-service: Navigate to the `cd hello-service` directory and execute the following commands sequentially:
   - `.ci-cd/build.sh` to build the hello-service container image.
   - `.ci-cd/push.sh` to push the built image to the local registry.
   - `.ci-cd/deploy.sh` to deploy the hello-service to the local Kubernetes cluster.

6. Access the hello-service: Use the commands `http http://hello.local.gd` and `http http://hello.local.gd/otel` to access the hello-service and verify the integration with AWS X-Ray.

Please refer to the provided readme file for detailed instructions and additional information about the project setup, configuration, and usage.