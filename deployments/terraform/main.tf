# deployments/terraform/main.tf

provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "sre_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.sre_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.sre_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sre_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "instance" {
  name        = "${var.project_name}-sg"
  description = "Security group for SRE learning instance"
  vpc_id      = aws_vpc.sre_vpc.id

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  # Application Port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  # Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# EC2 Instance
resource "aws_instance" "sre_instance" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instance.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
    encrypted   = true
    tags = {
      Name = "${var.project_name}-root-volume"
    }
  }

  # Enable detailed monitoring
  monitoring = true

  # Add instance profile for SystemsManager
  iam_instance_profile = aws_iam_instance_profile.systems_manager.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  # Enforce IMDSv2
  }

  user_data = <<-EOF
              #!/bin/bash
              # System Configuration
              echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf
              echo "net.ipv4.tcp_max_syn_backlog = 65535" >> /etc/sysctl.conf
              echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
              echo "net.ipv4.tcp_max_tw_buckets = 2000000" >> /etc/sysctl.conf
              echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
              sysctl -p

              # Install essential tools
              apt-get update && apt-get upgrade -y
              apt-get install -y \
                git \
                build-essential \
                linux-headers-$(uname -r) \
                bpfcc-tools \
                python3-bpfcc \
                libbpfcc-dev \
                docker.io \
                docker-compose \
                stress-ng \
                sysstat \
                iotop \
                htop \
                tcpdump \
                strace \
                perf-tools-unstable

              # Setup monitoring
              mkdir -p /opt/monitoring/scripts
              
              # Create performance monitoring script
              cat <<'PERF_SCRIPT' > /opt/monitoring/scripts/collect_metrics.sh
              #!/bin/bash
              
              while true; do
                  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
                  
                  # CPU stats
                  mpstat 1 1 >> /var/log/cpu_stats.log
                  
                  # Memory stats
                  free -m >> /var/log/memory_stats.log
                  
                  # Disk I/O
                  iostat -x 1 1 >> /var/log/io_stats.log
                  
                  # Network stats
                  ss -s >> /var/log/network_stats.log
                  
                  sleep 60
              done
              PERF_SCRIPT
              
              chmod +x /opt/monitoring/scripts/collect_metrics.sh
              
              # Create systemd service for monitoring
              cat <<'SERVICE' > /etc/systemd/system/performance-monitoring.service
              [Unit]
              Description=System Performance Monitoring
              After=network.target
              
              [Service]
              Type=simple
              ExecStart=/opt/monitoring/scripts/collect_metrics.sh
              Restart=always
              
              [Install]
              WantedBy=multi-user.target
              SERVICE
              
              # Start monitoring service
              systemctl daemon-reload
              systemctl enable performance-monitoring
              systemctl start performance-monitoring

              # Setup log rotation
              cat <<'LOGROTATE' > /etc/logrotate.d/performance-stats
              /var/log/cpu_stats.log
              /var/log/memory_stats.log
              /var/log/io_stats.log
              /var/log/network_stats.log {
                  rotate 7
                  daily
                  compress
                  missingok
                  notifempty
              }
              LOGROTATE

              EOF

  tags = {
    Name        = "${var.project_name}-instance"
    Environment = var.environment
    Monitor     = "true"
    Project     = "sre-learning"
  }

  lifecycle {
    create_before_destroy = true
  }
}