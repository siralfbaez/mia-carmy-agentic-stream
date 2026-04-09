# terraform/modules/hardened-eks/main.tf

# KMS Key for EKS Envelope Encryption (NIST 800-53 SC-28: Protection of Information at Rest)
resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS underlying secret encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true # Mandatory for DISA STIG compliance
}

resource "aws_eks_cluster" "carmy_cluster" {
  name     = "mia-carmy-agentic-cluster"
  role_arn = var.eks_cluster_role_arn

  # NIST 800-53 AC-3: Access Enforcement (Private Endpoint Only)
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false # No public access to the K8s API
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }

  # Enable logging for auditing (NIST 800-53 AU-2)
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# Hardened Node Group
resource "aws_eks_node_group" "hardened_nodes" {
  cluster_name    = aws_eks_cluster.carmy_cluster.name
  node_group_name = "hardened-worker-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = ["m5.large"]

  # Enforce IMDSv2 and Disk Encryption (STIG/CIS requirement)
  launch_template {
    name    = aws_launch_template.eks_hardened_lt.name
    version = "$Latest"
  }
}

resource "aws_launch_template" "eks_hardened_lt" {
  name_prefix   = "eks-stig-template-"
  image_id      = var.hardened_ami_id # This should be the DISA STIG'd RHEL 8 or AL2 AMI

  metadata_options {
    http_tokens                 = "required" # IMDSv2 - Direct remediations for "Wiz" findings
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      encrypted   = true
      kms_key_id  = var.kms_key_id
    }
  }
}
