package stigchecker

import (
	"encoding/json"
	"fmt"
	"log"
)

// WizFinding represents the schema typically exported by Wiz or Tenable
type WizFinding struct {
	ID          string `json:"id"`
	ResourceID  string `json:"resource_id"`
	FindingType string `json:"finding_type"`
	Severity    string `json:"severity"`
	NISTControl string `json:"nist_control"`
}

// RemediationPlan defines the automated action to take
type RemediationPlan struct {
	Action      string `json:"action"`
	Impact      string `json:"impact"`
	Automated   bool   `json:"automated"`
}

// ProcessFinding analyzes the vulnerability and maps it to a STIG remediation
func ProcessFinding(findingData []byte) (RemediationPlan, error) {
	var finding WizFinding
	if err := json.Unmarshal(findingData, &finding); err != nil {
		return RemediationPlan{}, err
	}

	log.Printf("[SECURITY-ALARM] Finding %s detected on %s (Severity: %s)",
		finding.ID, finding.ResourceID, finding.Severity)

	// Remediation Logic specifically for the Vantor JD Requirements
	switch finding.FindingType {
	case "IMDSv1_ENABLED":
		return RemediationPlan{
			Action:    "ENFORCE_IMDSV2: Updating Launch Template http_tokens to 'required'.",
			Impact:    "Low - Restart of EKS worker nodes may be required.",
			Automated: true,
		}, nil

	case "S3_PUBLIC_READ_ENABLED":
		return RemediationPlan{
			Action:    "BLOCK_PUBLIC_ACCESS: Applying S3 Account-level Public Access Block.",
			Impact:    "None - Blocks unauthorized external data egress.",
			Automated: true,
		}, nil

	case "UNENCRYPTED_EBS_VOLUME":
		return RemediationPlan{
			Action:    "ENFORCE_AES256: Re-provisioning volume with KMS CMK encryption.",
			Impact:    "High - Requires data migration/snapshotting.",
			Automated: false, // Manual intervention required for data integrity
		}, nil

	default:
		return RemediationPlan{
			Action:    "MANUAL_REVIEW: Escalating to Cloud Security Architect.",
			Automated: false,
		}, nil
	}
}