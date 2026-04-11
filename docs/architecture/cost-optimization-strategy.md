# MIA-cArmy Cost Optimization & Governance Strategy

This document outlines the architectural decisions and automated mechanisms used to optimize cloud spend within the **AWS GovCloud** environment, specifically targeting **cArmy/ECMA** budgetary constraints.

## 1. Compute Optimization Strategy

| Strategy | Implementation Detail | Estimated Savings |
| :--- | :--- | :--- |
| **Savings Plans** | 1-Year Compute Savings Plan for baseline **EKS Control Plane** and core **Nervous System** services. | **25% - 30%** |
| **Spot Instances** | Utilized for the `ingestion-transformer` and `signal-gateway` (stateless workloads) with automated drain handling. | **60% - 90%** |
| **Karpenter Scaling** | Right-sizing node groups based on real-time pod resource requests (CPU/RAM) rather than static ASGs. | **15% - 20%** |
| **Graviton Migration** | Transitioning Go-based microservices to **AWS Graviton (ARM64)** instances for superior price-performance. | **20%** |

## 2. Storage & Data Lifecycle (NIST 800-53 SI-12)

To manage **CUI (Controlled Unclassified Information)** data costs, we implement automated S3 Lifecycle policies:

* **S3 Intelligent-Tiering:** Default for all raw ingestion buckets to automate transitions between Frequent and Infrequent access.
* **Glacier Instant Retrieval:** For audit logs and **STIG-compliance** reports that must be retained for 1 year but are rarely accessed.
* **VPC Endpoint Optimization:** Using **S3 Gateway Endpoints** to eliminate Data Transfer Out (DTO) costs within the private VPC.

## 3. Cost-Aware Architecture Logic (The "Nervous System" Integration)

The `services/compliance-monitor` includes a **Cost-Drift Agent** that performs the following:

1.  **Tag-Based Allocation:** Enforces that every resource has a `Project` and `Classification` tag (refer to `tagging-standard.md`) to ensure 100% cost transparency in **AWS Cost Explorer**.
2.  **Orphaned Resource Cleanup:** Automatically identifies and terminates unattached EBS volumes or Elastic IPs older than 24 hours.
3.  **Wiz/Cost Correlation:** Identifies if a "High Severity" security fix (like moving from Public to Private) will impact the monthly spend, providing an automated "Cost Impact Report" before applying Terraform changes.

## 4. Key Performance Indicators (KPIs)
* **Unit Cost per Signal:** Tracking the AWS spend divided by the number of signals processed through the Gateway.
* **Percentage of Waste:** Target < 5% unallocated or idle resource spend.