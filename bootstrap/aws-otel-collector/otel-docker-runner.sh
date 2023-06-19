#!/usr/bin/env bash 

docker run --rm -p 4317:4317 -p 55680:55680 -p 8889:8888 \
    -e AWS_REGION=us-west-2 \
    -e AWS_PROFILE=lcp-sandbox \
    -v ~/.aws:/root/.aws \
    -v "${PWD}/examples/docker/config.yaml":/otel-local-config.yaml \
    --name awscollector public.ecr.aws/aws-observability/aws-otel-collector:latest \
    --config otel-local-config.yaml; \
    --health-cmd='/healthcheck' \
    --health-interval=5s 