# linux-system-internal-exploration-for-sre
A hands-on learning project for Site Reliability Engineering (SRE) focusing on Linux system internals, observability, and troubleshooting. This project creates controlled chaos scenarios to practice debugging and resolution skills.

## Overview

This project provides:
- A problematic Go microservice with built-in issues for learning
- Infrastructure as Code (Terraform) for AWS deployment
- eBPF programs for deep system observability
- Documented troubleshooting scenarios
- Load testing and chaos engineering tools

## Prerequisites

- Go 1.21+
- Docker and Docker Compose
- Terraform 1.0+
- AWS CLI configured
- Linux environment with eBPF tools (bcc-tools)

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/sre-weekend-challenge
cd sre-weekend-challenge
```

2. Deploy infrastructure:
```bash
cd deployments/terraform
terraform init
terraform apply
```

3. Build and run locally:
```bash
make build
make run
```

## Project Structure

- `/deployments` - Infrastructure and container configurations
- `/internal` - Application source code
- `/scripts` - Utility scripts and eBPF programs
- `/docs` - Documentation and troubleshooting guides
- `/configs` - Configuration files

## Scenarios

1. Goroutine Leaks
2. Memory Management Issues
3. CPU Bottlenecks
4. File Descriptor Exhaustion
5. Database Connection Problems
6. Network Issues

Each scenario includes:
- Problem description
- Triggering mechanism
- Observation methods
- Resolution steps

## Documentation

Detailed documentation for each component is available in the `/docs` directory:
- [Setup Guide](docs/setup.md)
- [Troubleshooting Commands](docs/troubleshooting/commands.md)
- [eBPF Tools Guide](docs/troubleshooting/ebpf-tools.md)

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

MIT License - see LICENSE file for details