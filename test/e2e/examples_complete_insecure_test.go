package e2e_test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	teststructure "github.com/gruntwork-io/terratest/modules/test-structure"

	"github.com/defenseunicorns/terraform-aws-uds-eks/test/e2e/utils"
)

func TestExamplesCompleteInsecure(t *testing.T) {
	t.Parallel()
	tempFolder := teststructure.CopyTerraformFolderToTemp(t, "../..", "examples/complete")
	terraformOptions := &terraform.Options{
		TerraformDir: tempFolder,
		Upgrade:      false,
		VarFiles: []string{
			"fixtures.common.tfvars",
			"fixtures.insecure.tfvars",
		},
		RetryableTerraformErrors: map[string]string{
			".*empty output.*": "bug in aws_s3_bucket_logging, intermittent error",
			".*timeout while waiting for state to become 'ACTIVE'.*": "Sometimes the EKS cluster takes a long time to create",
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
		utils.ValidateEFSFunctionality(t, tempFolder)
		utils.DownloadZarfInitPackage(t)
		utils.ConfigureKubeconfig(t, tempFolder)
		utils.ValidateZarfInit(t, tempFolder)
	})
}
