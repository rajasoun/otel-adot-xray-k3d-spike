APP := hello-service
VERSION := latest
REPORTS_DIR := .reports

# APP:=hello-service #$(shell basename $(CURDIR))
# VERSION:=latest #$(shell git describe --tags --always --dirty)
# REPORTS_DIR:=.reports

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
#.PHONY: bin/$(APP) bin clean start test

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Go TASKS
build-docker: ## Build Docker image
	docker build -t $(APP):$(VERSION) ${APP}

tag-docker: ## Tag Docker image
	docker tag $(APP):$(VERSION) registry.dev.local.gd:5001/$(APP):$(VERSION)

push-docker: ## Push Docker image
	docker push registry.dev.local.gd:5001/$(APP):$(VERSION)

deploy-to-kubernetes: ## Deploy to Kubernetes
	kubectl apply -k ${APP}/k8s

remove-from-kubernetes: ## Remove from Kubernetes
	kubectl delete -k ${APP}/k8s

remove-docker: ## Remove Docker image
	docker image prune -f
	docker rmi $(APP):$(VERSION)


build-push-deploy: build-docker tag-docker push-docker deploy-to-kubernetes ## Build, tag, push and deploy to Kubernetes

clean: remove-from-kubernetes remove-docker ## Remove from Kubernetes and remove Docker image
