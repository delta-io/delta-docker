# ---------------------------------------------------------------
# Delta Lake Quickstart Docker — build and test targets
# ---------------------------------------------------------------
MAVEN_PROXY_URL ?= https://repo.1.maven.org/maven2/
PYPI_PROXY_URL ?= https://pypi.org/simple/
IMAGE_NAME ?= delta_quickstart

.PHONY: build test build-and-test clean help

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image (IMAGE_NAME=delta_quickstart)
	docker build -t $(IMAGE_NAME) -f Dockerfile --build-arg MAVEN_PROXY_URL=$(MAVEN_PROXY_URL) --build-arg PYPI_PROXY_URL=$(PYPI_PROXY_URL) .

test: ## Run integration tests against IMAGE_NAME (must be built first)
	@bash tests/test_docker.sh $(IMAGE_NAME)

build-and-test: build test ## Build the image then run all tests

clean: ## Remove the local Docker image
	docker rmi -f $(IMAGE_NAME) 2>/dev/null || true
