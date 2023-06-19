# Open Telemetry Spike 

aws-otel-collector is used to collect traces and metrics from the hello-service and send them to AWS X-Ray 

1. Create Local k8s cluster using k3d using the command `local-dev/assist.sh  setup`
1. Create secrets using the command `kubectl create secret generic aws-credentials --from-file="$HOME/.aws/credentials"`
1. Bootstrap the local k8s cluster using the command `kubectl apply -k bootstrap`
1. Run the command `bootstrap/debug.sh default` to get pod, container and port(s) information
1. Buld, Push and Deploy the hello-service to the local cluster using the commands 
    ```
    cd hello-service
    .ci-cd/build.sh && .ci-cd/push.sh && .ci-cd/deploy.sh
    ```
1. Access the hello-service using the command `http http://hello.local.gd` and `http http://hello.local.gd/otel` 


## TODO:

1. Make it work with jaeger. Visit `http://jaeger.local.gd/`