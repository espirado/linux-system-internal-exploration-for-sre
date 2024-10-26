# deployments/terraform/iam.tf

# IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Custom policy for our SRE learning requirements
resource "aws_iam_policy" "sre_learning_policy" {
  name        = "${var.project_name}-custom-policy"
  description = "Custom policy for SRE learning environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/${var.project_name}*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-custom-policy"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Systems Manager policy attachment
resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch policy attachment
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach our custom policy
resource "aws_iam_role_policy_attachment" "sre_learning" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.sre_learning_policy.arn
}

# Instance profile
resource "aws_iam_instance_profile" "systems_manager" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "${var.project_name}-instance-profile"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}