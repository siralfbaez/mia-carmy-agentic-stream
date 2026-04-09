resource "aws_iam_policy" "carmy_abac_s3_access" {
  name        = "MIA-cArmy-ABAC-S3-Policy"
  description = "Enforces tag-based access for GovCloud S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "arn:aws-us-gov:s3:::mia-carmy-*"
        # The "Magic" of ABAC:
        # User tag "Project" must match Bucket tag "Project"
        Condition = {
          "StringEquals": {
            "aws:ResourceTag/Project": "$${aws:PrincipalTag/Project}",
            "aws:ResourceTag/Classification": "$${aws:PrincipalTag/Classification}"
          }
        }
      },
      {
        # NIST 800-53 SC-28: Enforce Encryption at Rest
        Effect = "Deny"
        Action = "s3:PutObject"
        Resource = "arn:aws-us-gov:s3:::mia-carmy-*"
        Condition = {
          "StringNotEquals": {
            "s3:x-amz-server-side-encryption": "aws:kms"
          }
        }
      }
    ]
  })
}
