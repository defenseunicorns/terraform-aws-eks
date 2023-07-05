package e2e_test

import (
	utils "e2e_test/test/utils"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	teststructure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestExamplesCompleteInsecure(t *testing.T) {
	t.Parallel()
	newTestDir := "../tmptest/insecure" // Create a fresh seperate temp directory
	os.MkdirAll(newTestDir, os.ModePerm)
	tempFolder := teststructure.CopyTerraformFolderToTemp(t, newTestDir, "examples/complete")
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
		utils.ConfigureKubeconfig(t, tempFolder)
		utils.ValidateEFSFunctionality(t, tempFolder)
		// utils.DownloadZarfInitPackage(t)
		// utils.ValidateZarfInit(t, tempFolder)
	})
}
