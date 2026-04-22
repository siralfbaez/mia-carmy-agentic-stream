BINARY_NAME=signal-gateway
DOCKER_IMAGE=mia-carmy-gateway:latest

.PHONY: all build test docker-build clean

all: build test

build:
	go build -o bin/$(BINARY_NAME) services/signal-gateway/cmd/main.go

test:
	go test ./...

docker-build:
	docker build -t $(DOCKER_IMAGE) -f services/signal-gateway/Dockerfile .

tf-init:
	cd terraform/environments/gov-dev && terraform init

# NIST Compliance Check (Mock)
compliance-check:
	go run services/compliance-monitor/internal/stig-checker/remediator.go
