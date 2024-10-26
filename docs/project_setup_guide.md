# Linux System Internals Exploration for SRE - Project Setup Guide

## Core Project Configuration

This guide explains the core configuration files and their purposes for our SRE exploration project.

### 1. Go Module Configuration (`go.mod`)

```go
module github.com/yourusername/linux-system-internal-exploration-for-sre

go 1.21
```

#### Key Dependencies

1. **HTTP and Routing**
   - `github.com/gorilla/mux v1.8.1`
   - Purpose: HTTP routing and middleware handling

2. **Database Drivers**
   - `github.com/lib/pq v1.10.9` (PostgreSQL)
   - `github.com/redis/go-redis/v9 v9.3.0` (Redis)
   - Purpose: Database connectivity and caching operations

3. **Observability Stack**
   - `github.com/prometheus/client_golang v1.17.0`
   - `go.opentelemetry.io/otel v1.21.0`
   - `go.opentelemetry.io/otel/exporters/otlp/otlptrace v1.21.0`
   - Purpose: Metrics, monitoring, and distributed tracing

4. **Logging and Error Handling**
   - `github.com/sirupsen/logrus v1.9.3`
   - Purpose: Structured logging

5. **Configuration Management**
   - `github.com/spf13/viper v1.18.2`
   - Purpose: Application configuration handling

6. **System Metrics**
   - `github.com/shirou/gopsutil/v3 v3.23.11`
   - Purpose: System and process metrics collection

7. **Testing**
   - `github.com/stretchr/testify v1.8.4`
   - Purpose: Testing assertions and mocking

### 2. Makefile Structure

#### Build Commands

```makefile
# Basic build commands
make build      # Compile the application
make run        # Run the built binary
make test       # Run test suite with race detection
make clean      # Clean build artifacts
```

#### Development Tools

```makefile
make lint           # Run code linting
make deps-update    # Update dependencies
make install-tools  # Install development tools
```

#### System Exploration Commands

```makefile
make syscall-trace    # Trace system calls using eBPF
make memory-profile   # Run memory profiling
make cpu-profile      # Run CPU profiling
make network-trace    # Trace network activity
make fd-watch         # Monitor file descriptors
```

#### Scenario Execution

```makefile
make scenario-memory    # Trigger memory leak scenario
make scenario-cpu       # Trigger CPU intensive scenario
make scenario-network   # Trigger network issues
make scenario-fd        # Trigger file descriptor leaks
```

#### Docker Operations

```makefile
make docker-build    # Build Docker image
make docker-run      # Run with Docker Compose
```

### 3. Makefile Design Goals

1. **Development Efficiency**
   - Quick build and test cycles
   - Easy dependency management
   - Automated tool installation

2. **System Exploration**
   - Direct access to tracing tools
   - Profile generation
   - Scenario execution

3. **Container Support**
   - Docker image building
   - Container orchestration
   - Development environment consistency

4. **Learning Support**
   - Pre-configured scenarios
   - Monitoring tools integration
   - Documentation generation

### 4. Project Variables

```makefile
PROJECT_NAME := linux-system-internal-exploration-for-sre
MAIN_PACKAGE_PATH := ./cmd/server
BINARY_NAME := sre-server
DOCKER_IMAGE := $(PROJECT_NAME)
DOCKER_TAG := latest
```

### 5. Directory Structure

```bash
linux-system-internal-exploration-for-sre/
├── cmd/
│   └── server/           # Main application entry point
├── internal/
│   ├── app/             # Application logic
│   ├── pkg/             # Reusable packages
│   └── scenarios/       # SRE learning scenarios
├── tools/
│   └── bpf/             # eBPF programs
├── scripts/             # Utility scripts
├── bin/                 # Compiled binaries
└── dist/                # Distribution artifacts
```

### 6. Scenario Targets

Each scenario target is designed to:
1. Trigger specific system behavior
2. Enable monitoring and observation
3. Provide learning opportunities
4. Document resolution steps

Example scenario execution:
```bash
# Memory leak scenario
make scenario-memory

# Expected output:
# Running memory leak scenario...
# Endpoint: POST http://localhost:8080/debug/scenarios/memory-leak
```

### 7. Development Workflow

1. **Initial Setup**
   ```bash
   git clone <repository>
   make install-tools
   make deps-update
   ```

2. **Development Cycle**
   ```bash
   make dev        # Start development server
   make test      # Run tests
   make lint      # Check code quality
   ```

3. **System Exploration**
   ```bash
   make syscall-trace    # Observe system calls
   make memory-profile   # Check memory usage
   ```

4. **Scenario Testing**
   ```bash
   make scenario-memory  # Run memory scenario
   make scenario-cpu     # Run CPU scenario
   ```

### 8. Best Practices

1. **Development**
   - Always run `make lint` before commits
   - Use `make test` with race detection
   - Keep scenarios isolated

2. **System Exploration**
   - Use provided tools for observation
   - Document findings
   - Follow troubleshooting guides

3. **Containerization**
   - Test in containers
   - Verify resource limits
   - Check for container-specific issues

### 9. Troubleshooting

Common issues and solutions:
1. Permission issues with eBPF tools
   ```bash
   sudo setcap cap_sys_admin+ep ./bin/sre-server
   ```

2. Resource limits in containers
   ```bash
   docker stats  # Monitor container resources
   ```

3. Profile analysis
   ```bash
   go tool pprof ./bin/sre-server cpu.prof
   ```

Remember to check the project's main README.md for the most up-to-date information and additional documentation in the `/docs` directory.