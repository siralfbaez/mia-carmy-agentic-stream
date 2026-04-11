# terraform/modules/s3-glacier-compliance/main.tf

resource "aws_s3_bucket" "carmy_data_lake" {
  bucket = "mia-carmy-compliance-data-${var.environment}"

  tags = {
    Project        = "AgenticStream"
    Classification = "CUI"
    Compliance     = "NIST-800-53-SI-12"
  }
}

# 1. NIST 800-53 AC-3: Block Public Access (The "Wiz" Remediation)
resource "aws_s3_account_public_access_block" "hardened_boundary" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. NIST 800-53 SC-28: Enforce KMS Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "carmy_s3_encryption" {
  bucket = aws_s3_bucket.carmy_data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# 3. Cost Optimization Logic: Lifecycle Management
resource "aws_s3_bucket_lifecycle_configuration" "carmy_cost_lifecycle" {
  bucket = aws_s3_bucket.carmy_data_lake.id

  rule {
    id     = "archive-old-cui-data"
    status = "Enabled"

    # Move to Intelligent-Tiering after 30 days for automated cost-saving
    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    # Move to Glacier Instant Retrieval after 90 days (Compliance Archive)
    # NIST 800-53 AU-11: Audit Record Retention
    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }
  }
}