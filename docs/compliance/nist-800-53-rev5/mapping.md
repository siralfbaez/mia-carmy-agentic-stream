# NIST 800-53 Rev 5 Compliance Mapping: mia-carmy-agentic-stream

This document maps the **MIA-cArmy Agentic Stream** architectural components to specific **NIST 800-53 Rev 5** security controls. This ensures that the technical implementation aligns with **Army Enterprise Cloud Management Agency (ECMA)** and **cArmy** onboarding requirements.

| Control ID | Control Name | PoC Implementation (Evidence) | STIG / cArmy Alignment |
| :--- | :--- | :--- | :--- |
| **AC-3** | Access Enforcement | **ABAC IAM Policies** in `terraform/modules/kms-cmk-encryption` utilizing `PrincipalTag` and `ResourceTag` matching. | Enforces "Least Privilege" and data isolation for **CUI** workloads. |
| **AC-6** | Least Privilege | **Non-root Docker Execution** (`USER 10001`) in `services/signal-gateway/Dockerfile` and hardened EKS pod security. | Prevents container escape and satisfies **Wiz** high-severity vulnerability remediation. |
| **IA-2** | Identification & Authentication | **mTLS + X.509 Certificates** for all service-to-service communication managed via `pkg/security/mtls_config.go`. | Zero Trust Architecture (ZTA) requirement for all **GovCloud** internal traffic. |
| **SC-8** | Transmission Confidentiality | **TLS 1.3 Encryption** enforced at the VPC Endpoint and Service Mesh level. | Protects **CUI** in transit within the cArmy Boundary Cloud Access Point (BCAP). |
| **SC-28** | Protection of Information at Rest | **KMS CMK Envelope Encryption** for EKS Secrets, RDS, and S3 buckets with mandatory 7-day rotation. | Mandates **FIPS 140-2** validated encryption for all sensitive federal data. |
| **AU-2** | Event Logging | **VPC Flow Logs & CloudWatch** integration in `terraform/modules/govcloud-vpc-no-igw`. | Provides the immutable audit trail required for DISA/DSS forensic analysis. |
| **CM-6** | Configuration Settings | **Hardened AMI (RHEL 8)** and **IMDSv2 Enforcement** in `terraform/modules/hardened-eks`. | Directly addresses **DISA STIG** requirements for server-side request forgery (SSRF) protection. |

## Verification Strategy
Compliance is verified through the **AI Compliance Agent** located in `services/compliance-monitor`, which performs automated drift detection against these controls by analyzing Terraform state files and live AWS environment tags.