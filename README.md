# Mia cArmy Agentic Stream ⚡

Root CA: Offline, highly protected (simulated).

Intermediate CA: Used to sign service certificates.

Service Certificates: Each pod in EKS gets a unique identity.


# MIA cArmy Tagging & ABAC Standard

This document defines the mandatory tagging schema for the **Agentic Data Nervous System**. These tags are used by the IAM ABAC policies to enforce **NIST 800-53 AC-3** (Access Enforcement) across AWS GovCloud resources.

## 1. Core Tagging Matrix

| Entity | Key | Value (Example) | Purpose |
| :--- | :--- | :--- | :--- |
| **S3 Bucket** | `Project` | `AgenticStream` | Ensures data isolation between mission workloads. |
| **S3 Bucket** | `Classification` | `CUI` | Identifies Controlled Unclassified Information per ECMA standards. |
| **EKS Pod** | `Project` | `AgenticStream` | Identity matching for service-to-service data access. |
| **IAM User** | `Classification` | `CUI` | Determines the "Clearance" level for manual data retrieval. |

## 2. Enforcement Logic
All resources must be tagged at creation. The Terraform `aws_iam_policy.carmy_abac_s3_access` uses these attributes to dynamically permit or deny `s3:PutObject` and `s3:GetObject` operations without requiring individual IAM Role updates.

## 3. Compliance Mapping
* **NIST 800-53 AC-3:** Access Enforcement via Attribute-Based Access Control.
* **NIST 800-53 SC-28:** Protection of Information at Rest (combined with KMS encryption).



```mermaid
graph TD
    subgraph AWS_GovCloud [AWS GovCloud - cArmy Landing Zone]
        subgraph Public_Zone [Boundary Cloud Access Point - BCAP]
            VPCE[VPC Endpoints / PrivateLink]
        end

        subgraph Private_VPC [Hardened VPC - No IGW]
            direction TB
            subgraph EKS_Cluster [Hardened EKS Cluster]
                subgraph App_Namespace [Namespace: Agentic-Stream]
                    SG[Signal Gateway - RHEL 8 STIG]
                    IT[Ingestion Transformer]
                    AA[AI Compliance Agent]
                    SG -- "mTLS (Strict)" --> IT
                end
            end

            subgraph Data_Layer [Data & Storage]
                S3[(S3 Bucket - CUI Classified)]
                KMS[KMS - CMK Encryption]
            end

            IT -- "ABAC Verified Access" --> S3
            S3 -. "Encrypted by" .-> KMS
            AA -- "Scans / Remediates" --> SG
        end
    end

    User((Alf - Architect)) -- "VPN / AWS CLI" --> VPCE
    VPCE --> EKS_Cluster

    classDef hardened fill:#f96,stroke:#333,stroke-width:2px;
    class SG,IT,AA,EKS_Cluster hardened;

``` 

---





