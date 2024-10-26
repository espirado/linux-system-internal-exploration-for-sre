# Project variables
PROJECT_NAME := linux-system-internal-exploration-for-sre
MAIN_PACKAGE_PATH := ./cmd/server
BINARY_NAME := sre-server
DOCKER_IMAGE := $(PROJECT_NAME)
DOCKER_TAG := latest

# Go parameters
GO := go
GOTEST := $(GO) test
GOVET := $(GO) vet
GOBUILD := $(GO) build
GOCLEAN := $(GO) clean
GOMOD := $(GO) mod
GOGET := $(GO) get

# Build flags
LDFLAGS := -ldflags "-w -s"

# Docker parameters
DOCKER := docker
DOCKER_COMPOSE := docker-compose

# Directories
BIN_DIR := bin
DIST_DIR := dist
TOOLS_DIR := tools

.PHONY: all build clean test lint docker-build docker-run help

# Default target
all: clean lint test build

# Build the application
build:
	@echo "Building $(BINARY_NAME)..."
	@mkdir -p $(BIN_DIR)
	$(GOBUILD) $(LDFLAGS) -o $(BIN_DIR)/$(BINARY_NAME) $(MAIN_PACKAGE_PATH)

# Run the application
run: build
	@echo "Running $(BINARY_NAME)..."
	@$(BIN_DIR)/$(BINARY_NAME)

# Clean build artifacts
clean:
	@echo "Cleaning..."
	@rm -rf $(BIN_DIR) $(DIST_DIR)
	$(GOCLEAN)

# Run tests
test:
	@echo "Running tests..."
	$(GOTEST) -v -race -cover ./...

# Run linting
lint:
	@echo "Running linters..."
	golangci-lint run

# Update Go dependencies
deps-update:
	@echo "Updating dependencies..."
	$(GOGET) -u ./...
	$(GOMOD) tidy

# Install development tools
install-tools:
	@echo "Installing development tools..."
	$(GOGET) github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	$(GOGET) golang.org/x/tools/cmd/godoc@latest
	$(GOGET) github.com/go-delve/delve/cmd/dlv@latest

# Docker targets
docker-build:
	@echo "Building Docker image..."
	$(DOCKER) build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker-run: docker-build
	@echo "Running Docker container..."
	$(DOCKER_COMPOSE) up

# System exploration targets
.PHONY: syscall-trace memory-profile cpu-profile network-trace fd-watch

syscall-trace:
	@echo "Tracing system calls..."
	@sudo bpftrace tools/bpf/syscall_trace.bt

memory-profile:
	@echo "Running memory profiling..."
	@$(BIN_DIR)/$(BINARY_NAME) -memprofile=$(DIST_DIR)/mem.prof

cpu-profile:
	@echo "Running CPU profiling..."
	@$(BIN_DIR)/$(BINARY_NAME) -cpuprofile=$(DIST_DIR)/cpu.prof

network-trace:
	@echo "Tracing network activity..."
	@sudo bpftrace tools/bpf/network_trace.bt

fd-watch:
	@echo "Watching file descriptors..."
	@sudo bpftrace tools/bpf/fd_watch.bt

# Scenario targets
.PHONY: scenario-memory scenario-cpu scenario-network scenario-fd

scenario-memory:
	@echo "Running memory leak scenario..."
	@curl -X POST http://localhost:8080/debug/scenarios/memory-leak

scenario-cpu:
	@echo "Running CPU intensive scenario..."
	@curl -X POST http://localhost:8080/debug/scenarios/cpu-burn

scenario-network:
	@echo "Running network congestion scenario..."
	@curl -X POST http://localhost:8080/debug/scenarios/network-flood

scenario-fd:
	@echo "Running file descriptor leak scenario..."
	@curl -X POST http://localhost:8080/debug/scenarios/fd-leak

# Development helpers
.PHONY: dev bench profile

dev: build
	@echo "Starting development server..."
	@$(BIN_DIR)/$(BINARY_NAME) -dev

bench:
	@echo "Running benchmarks..."
	$(GOTEST) -bench=. -benchmem ./...

profile: build
	@echo "Running with profiling enabled..."
	@$(BIN_DIR)/$(BINARY_NAME) -profile

# Help target
help:
	@echo "Available targets:"
	@echo "  make build          - Build the application"
	@echo "  make run           - Run the application"
	@echo "  make test          - Run tests"
	@echo "  make lint          - Run linters"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make docker-build  - Build Docker image"
	@echo "  make docker-run    - Run with Docker Compose"
	@echo "  make install-tools - Install development tools"
	@echo ""
	@echo "System Exploration:"
	@echo "  make syscall-trace   - Trace system calls"
	@echo "  make memory-profile  - Profile memory usage"
	@echo "  make cpu-profile    - Profile CPU usage"
	@echo "  make network-trace  - Trace network activity"
	@echo "  make fd-watch       - Watch file descriptors"
	@echo ""
	@echo "Scenarios:"
	@echo "  make scenario-memory  - Run memory leak scenario"
	@echo "  make scenario-cpu    - Run CPU intensive scenario"
	@echo "  make scenario-network - Run network congestion scenario"
	@echo "  make scenario-fd     - Run FD leak scenario"