package e2e_test

import (
	"os"
	"testing"
	"time"

	"github.com/defenseunicorns/delivery_aws_iac_utils/pkg/utils"
	"github.com/gruntwork-io/terratest/modules/terraform"
	teststructure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestExamplesCompleteCommon(t *testing.T) {
	t.Parallel()

	// Set the TF_VAR_region to us-east-2 if it's not already set
	utils.SetDefaultEnvVar("TF_VAR_region", "us-east-2")

	tempFolder := teststructure.CopyTerraformFolderToTemp(t, "../..", "examples/complete")
	terraformOptions := &terraform.Options{
		TerraformDir: tempFolder,
		Upgrade:      false,
		EnvVars: map[string]string{
			"TF_VAR_region": os.Getenv("TF_VAR_region"), // This will use the existing or newly set default value
		},
		RetryableTerraformErrors: map[string]string{
			".*": "Failed to apply Terraform configuration due to an error.",
		},
		MaxRetries:         5,
		TimeBetweenRetries: 5 * time.Second,
	}

	// Defer the teardown
	defer func() {
		t.Helper()
		teststructure.RunTestStage(t, "TEARDOWN", func() {
			terraform.Destroy(t, terraformOptions)
		})
	}()

	// Set up the infra
	teststructure.RunTestStage(t, "SETUP", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	// Run assertions
	teststructure.RunTestStage(t, "TEST", func() {
		// Assertions go here
	})
}
