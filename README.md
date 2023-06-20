# About

Open Telemetry Spike: AWS X-Ray Integration with Local Kubernetes Cluster (k3d)

This project demonstrates the integration of AWS X-Ray with a local Kubernetes cluster using OpenTelemetry. It utilizes the `aws-otel-collector` to collect traces and metrics from the `hello-service` application and send them to AWS X-Ray.

## Prerequisites - Laptop Setup

1. [Mac Setup][mac_setup]
2. [Windows Setup][win_setup]


## Getting Started
Follow these steps to set up and run the project:

1. Create a Local Kubernetes Cluster: Use the command `local-dev/assist.sh setup` to create a local Kubernetes cluster using k3d.

2. Create Secrets: Execute the commands to create a secret containing AWS credentials required for accessing AWS services.
    * Directly using ``kubectl create secret generic aws-credentials --from-file="$HOME/.aws/credentials"` 
    * With warppers script
        ```sh
        scripts/wrapper.sh run create_secrets_in_cluster_from_aws_credential_file
        scripts/wrapper.sh run view_aws_credentials_from_cluster
        scripts/wrapper.sh run check_aws_token_expiration_time
        scripts/wrapper.sh run delete_aws_credentials_from_cluster
        ```

3. Bootstrap the Cluster: Apply the bootstrap resources to the local Kubernetes cluster using the command `kubectl apply -k bootstrap`.

4. Retrieve Pod and Container Information: Run the command `bootstrap/debug.sh default` to obtain information about the pods, containers, and their associated ports.

5. Build, Push, and Deploy the hello-service: Navigate to the `cd hello-service` directory and execute the following commands sequentially:
   - `.ci-cd/build.sh` to build the hello-service container image.
   - `.ci-cd/push.sh` to push the built image to the local registry.
   - `.ci-cd/deploy.sh` to deploy the hello-service to the local Kubernetes cluster.

6. Access the hello-service: Use the commands `http http://hello.local.gd` and `http http://hello.local.gd/otel` to access the hello-service and verify the integration with AWS X-Ray.

7. Visit the AWS X-Ray Console: Navigate to the AWS X-Ray console to view the traces and metrics collected from the hello-service. Ensure that the AWS region is set to `us-west-2` and the time range is set to `Last 5 minutes` as specified `bootstrap/aws-otel-collector/config.yaml`.

Please refer to the provided readme file for detailed instructions and additional information about the project setup, configuration, and usage.

## Details 

OpenTelemetry is a standardized framework for collecting and sending data to an Observability back-end.

It is a standardized set of SDKs, APIs, and tools designed for collecting, transforming, and sending data to an Observability back-end. This vendor-agnostic framework promotes interoperability and consistency across different observability solutions.

Now, let's categorize the components of OpenTelemetry:

SDKs:
- `go.opentelemetry.io/otel v1.16.0`: Core OpenTelemetry SDK in Go.
- `go.opentelemetry.io/otel/sdk v1.16.0`: OpenTelemetry SDK implementation in Go.

APIs:
- `go.opentelemetry.io/otel/trace v1.16.0`: APIs for working with trace data.
- `go.opentelemetry.io/otel/exporters/otlp/otlptrace v1.16.0`: API for exporting trace data in OTLP format.
- `go.opentelemetry.io/contrib/propagators/aws v1.17.0`: API for AWS X-Ray and Trace Context propagators.

Tools:
- `go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc v1.16.0`: OTLP gRPC exporter for trace data.
- `google.golang.org/grpc v1.55.0`: Go implementation of gRPC for communication.
- `public.ecr.aws/aws-observability/aws-otel-collector:latest`: AWS Distro for OpenTelemetry (ADOT) collector container image.

The SDKs provide the core functionality and implementation of OpenTelemetry. APIs define the contracts and interfaces for working with different aspects of observability data. Tools include exporters and communication mechanisms that enable exporting and transmitting data to external systems.

Together, these SDKs, APIs, and tools form a comprehensive framework for collecting, transforming, and sending data to Observability back-ends, ensuring consistency and interoperability across various observability solutions.

### AWS Distro for OpenTelemetry (ADOT) Deployment Modes

Refrence: https://aws-otel.github.io/docs/getting-started/adot-eks-add-on/installation

The ADOT Collector can be deployed in one of four modes: Deployment, DaemonSet, StatefulSet, and Sidecar. Here's a summary of each mode:

1. Deployment Mode:
   - Provides control over the Collector as a standalone application.
   - Allows easy scaling, version rollback, pausing, and management like any other application.
   - Suitable for scenarios where more control and flexibility are required.

2. DaemonSet Mode:
   - Runs the Collector as an agent on every Kubernetes node.
   - Each node has its own Collector instance to monitor the pods within it.
   - Useful when you want to monitor all pods running on each node.

3. StatefulSet Mode:
   - Offers predictable names for Collector instances.
   - Pod names in the StatefulSet are derived from the StatefulSet name and the ordinal of the pod.
   - Supports rescheduling and sticky identity (e.g., volumes) for failed Collector pods.
   - Allows configuring the target allocator for even delegation of scraping jobs.

4. Sidecar Mode:
   - Operates at the container level within the same pod as the application.
   - No new pod is created, keeping the cluster clean and manageable.
   - Enables fast and reliable offloading of telemetry data from the application.
   - Can be used to implement different collection and export strategies for specific applications.
   - Requires adding the annotation `sidecar.opentelemetry.io/inject: "true"` to the pod spec or namespace.

Each deployment mode serves different use cases and offers unique benefits in terms of management, scalability, monitoring, and offloading telemetry data. Choose the mode that best suits your requirements and deployment scenarios.

Spike uses the Deployment mode to deploy the ADOT Collector as a standalone application.

## Quick Strater Guide

1. Run the command `bootstrap/aws-otel-collector/local/otel-docker-runner.sh` to strat aws-otel-collector in a docker container.
1. Run the command `go run hello-service/main.go` to strat go lang hello-service.
1. Run the command `http http://hello.local.gd` and `http http://hello.local.gd/otel` to access the hello-service.
1. Visit the AWS X-Ray Console: Navigate to the AWS X-Ray console to view the traces and metrics collected from the hello-service. Ensure that the AWS region is set to `us-west-2` and the time range is set to `Last 5 minutes` as specified `bootstrap/aws-otel-collector/config.yaml`.

[win_setup]: https://github.com/rajasoun/win10x-onboard
[mac_setup]: https://github.com/rajasoun/mac-onboard