package e2e_test

import (
	"testing"

	"github.com/defenseunicorns/delivery_aws_iac_utils/pkg/utils"
	"github.com/gruntwork-io/terratest/modules/terraform"
	teststructure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestExamplesCompletePlanOnly(t *testing.T) {
	t.Parallel()

	// Set the TF_VAR_region to us-east-2 if it's not already set
	utils.SetDefaultEnvVar("TF_VAR_region", "us-east-2")

	tempFolder := teststructure.CopyTerraformFolderToTemp(t, "../..", "examples/complete")
	terraformOptionsPlan := &terraform.Options{
		TerraformDir: tempFolder,
		Upgrade:      false,
		VarFiles: []string{
			"fixtures.common.tfvars",
			"fixtures.insecure.tfvars",
		},
	}
	teststructure.RunTestStage(t, "SETUP", func() {
		terraform.Init(t, terraformOptionsPlan)
		terraform.Plan(t, terraformOptionsPlan)
	})
}
