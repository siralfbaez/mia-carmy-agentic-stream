# terraform/modules/govcloud-vpc-no-igw/main.tf

resource "aws_vpc" "carmy_main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name           = "mia-carmy-hardened-vpc"
    Classification = "CUI" # Controlled Unclassified Information
    Compliance     = "NIST-800-53-Rev5"
  }
}

# STIG Requirement: Enable Flow Logs for Auditing
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = var.flow_log_role_arn
  log_destination = var.s3_compliance_bucket_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.carmy_main.id
}

# Private Subnets Only (No IGW allowed in strict cArmy BCAP zones)
resource "aws_subnet" "private_app_zone" {
  vpc_id            = aws_vpc.carmy_main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "mia-private-app-subnet"
    # cArmy typically requires specific tagging for routing
    "kubernetes.io/role/internal-elb" = "1" 
  }
}

# VPC Endpoints (Interface Endpoints) for AWS Services
# This allows the Agent to talk to AWS services without hitting the public web
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.carmy_main.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
}
