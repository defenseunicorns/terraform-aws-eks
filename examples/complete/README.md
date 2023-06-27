# Complete Example: EKS Cluster Deployment with new VPC & Big Bang Dependencies

This example deploys:

- A VPC with:
  - 3 public subnets with internet gateway
  - 3 private subnets with NAT gateway
- An EKS cluster with worker node group(s)
- A Bastion host in one of the private subnets
- Big Bang dependencies:
  - KMS key and IAM roles for SOPS and IRSA
  - S3 bucket for Loki
  - RDS database for Keycloak

> This example has 2 modes: "insecure" and "secure". Insecure mode uses managed nodegroups, default instance tenancy, and enables the public endpoint on the EKS cluster. Secure mode uses self-managed nodegroups, dedicated instance tenancy, and disables the public endpoint on the EKS cluster. The method of choosing which mode to use is by using either `fixtures.insecure.tfvars` or `fixtures.secure.tfvars` as an overlay on top of `fixtures.common.tfvars`.

## Deploy/Destroy

See the [examples README](../README.md) for instructions on how to deploy/destroy this example. The make targets for this example are either `test-complete-insecure` or `test-complete-secure`.

## Connect

### Insecure mode

In insecure mode, the EKS cluster has a public endpoint. You can get the kubeconfig you need to connect to the cluster with the following command:

```shell
aws eks update-kubeconfig --region <RegionYouUsed> --name <ClusterName> --kubeconfig <PathToKubeconfigYouWantToModify> --alias <AliasForTheCluster>
```
> Use `aws eks list-clusters --region <RegionYouUsed>` to get the name of the cluster.

### Secure mode

In secure mode, the EKS cluster does not have a public endpoint. To connect to it, you'll need to tunnel through the bastion host. We use `sshuttle` to do this.

For convenience, we have set up a Make target called `bastion-connect`. Running the target will run a Docker container with `sshuttle` already running and the KUBECONFIG already configured and drop you into a bash shell inside the container.

```shell
aws-vault exec <your-profile> -- make bastion-connect

SShuttle is running and KUBECONFIG has been set. Try running kubectl get nodes.
[root@f72f0495c0cd complete]$ kubectl get nodes
NAME                                          STATUS   ROLES    AGE   VERSION
ip-10-200-36-117.us-east-2.compute.internal   Ready    <none>   22h   v1.23.16-eks-48e63af
ip-10-200-41-153.us-east-2.compute.internal   Ready    <none>   22h   v1.23.16-eks-48e63af
ip-10-200-48-31.us-east-2.compute.internal    Ready    <none>   22h   v1.23.16-eks-48e63af
```

To do this manually, you're going to want to run:

> NOTE: This is not really recommended. Better to use the make target / docker container. If the container doesn't have a tool you need, open an issue [here](https://github.com/defenseunicorns/not-a-build-harness) and we'll get it added.

```shell
# Switch to the examples/complete directory
cd examples/complete

# Init Terraform
terraform init

# Set up the AWS environment. This will drop you into a new shell with the env vars you need.
aws-vault exec <your-profile>

# Make sure you have the env vars you need
env | grep AWS
AWS_VAULT=<redacted>
AWS_DEFAULT_REGION=<redacted>
AWS_REGION=<redacted>
AWS_ACCESS_KEY_ID=<redacted>
AWS_SECRET_ACCESS_KEY=<redacted>
AWS_SESSION_TOKEN=<redacted>
AWS_SECURITY_TOKEN=<redacted>
AWS_SESSION_EXPIRATION=<redacted>

# Run sshuttle in the background. Don't forget to kill the background process when you are done. Use 'ps' to get the PID, then use 'kill -15 <PID>' to kill it.
# There's a ton of stuff here. Here's the breakdown:
# sshpass: pass the bastion's SSH password noninteractively
# -D: Run sshuttle in daemon (background) mode. Don't use '-D' if you'd rather run it in the foreground in a separate terminal window.
# -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null: Don't check the bastion's host key
# -o ProxyCommand="...": Tell SSH to use AWS SSM
sshuttle -D -e 'sshpass -p "my-password" ssh -q -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="aws ssm --region $(terraform output -raw bastion_region) start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p"' --dns --disable-ipv6 -vr ec2-user@$(terraform output -raw bastion_instance_id) $(terraform output -raw vpc_cidr)

# Set up the KUBECONFIG
aws eks --region $(terraform output -raw bastion_region) update-kubeconfig --name $(terraform output -raw eks_cluster_name)

# Test it out
kubectl get nodes
```
