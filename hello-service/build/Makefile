APP := hello-service #$(shell basename $(CURDIR))
VERSION := $(shell git describe --tags --always --dirty)
REPORTS_DIR=.reports

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
#.PHONY: bin/$(APP) bin clean start test

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Go TASKS
build:  build/bin lint audit test ## Build Go

build/bin: bin
	go build -v -installsuffix 'static' -o $@ -ldflags "-X main.Version='${VERSION}'"

check-for-updates:	## View minor/patch upgrades 
	go list -u -f '{{if (and (not (or .Main .Indirect)) .Update)}}{{.Path}}: {{.Version}} -> {{.Update.Version}}{{end}}' -m all 2> /dev/null

bin: clean
	mkdir -p build/bin

reports: clean
	mkdir -p .reports

clean: ## Clean Go
	rm -rf build/bin

test: ## Test Go
	gotestsum --  -coverprofile=.reports/outfile -tags=integration ./...

lint: ## Go Lint
	golangci-lint run ./...

audit: reports ## Lint Go Code for security issues
	gosec -fmt=json -out=$(REPORTS_DIR)/gosec.json -stdout --verbose=text  ./...

tdd: ## Watch for changes and run tests
	gotestsum --watch -- -count=1 -tags=integration ./...

cover: reports ## View test coverage
	sh run-unit-tests.sh

run: ## Run Go
	go run main.go

tools: ## Install go packages
	go install -v golang.org/x/tools/gopls@latest
	go install -v gotest.tools/gotestsum@latest
	go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install -v github.com/securego/gosec/v2/cmd/gosec@latest
	go get github.com/playwright-community/playwright-go
	go run github.com/playwright-community/playwright-go/cmd/playwright install --with-deps