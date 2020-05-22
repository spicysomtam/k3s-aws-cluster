# Aim

To provide a simple deployment of [k3s](https://k3s.io/) kubernetes clusters on aws installed using terraform.

Features implemented:

* Implement a prefix for resources so multiple clusters  can be deployed into an aws account.
* Specify how many masters (2 recommended), and how many agents (workers) to deploy.
* Implement a single Network Load Balancer (layer 4) for ports 80, 443 and 6443 (kubernetes api). 
* Specify the EC2 instance types for master and agents.
* Masters to use a shared RDS mysql instance.
* Ability to specify RDS instance type.
* Not have any excess baggage like rancher install, deploy apps; you can create these after a cluster is deployed via terraform (terraform modules?) or other means.
* Above features allow you to deploy clusters of many different sizes. Much flexibility. 
* You can increase the number of agent nodes and re-run `terraform apply` to deploy more workers when a cluster needs more capacity.
* Allows public and private subnets to be defined. Public is where the load balancer and bastion go; private is where the cluster is provisioned.
* Optional: can add a bastion host to allow ssh jumping from public to private subnets so you can get the k3s nodes (where you choose to have this config).

Adapted from my [rancher install on aws via terraform](https://github.com/spicysomtam/rancher-k3s-aws-tf).

# Single load balancer

The k3s master nodes are designed to run pod workloads, similar to agent/worker nodes. Thus the load balancer directs HTTP and HTTPS traffic to all the masters and agents.

The kubernetes api is only available on masters so the port for this (6443) is only directed at master nodes.

K3s by default uses the [treafik ingress](https://docs.traefik.io/providers/kubernetes-ingress/). You will need to setup k8s annotations for this to work; treafik works on inspecting the target dns name, and then forwarding this to the correct k8s service. Thus you only need one Layer 4 cloud load balancer even if you are hosting multiple dns names/deployments in k3s. Also the single load balancer handles the k8s api. All of this is attractive as implementing multiple cloud load balancers adds to the cost of operating the stack not to mention adding complexity.

A load balancer is required even if you deploy a single master node cluster; the issue here is that the k3s certificate is set to the private IP of the host, rather than the public IP, and you will need to use `--insecure-skip-tls-verify` with `kubectl` on your client, which turns off TLS and thus is not secure. I am sure there is a work around for this.

# Terraform

## Run as a module or standalone

How to run as a module. 

### Put everything in the default vpc and subnets

If you wish to use the aws account default vpc and subnets; see [example](./default-vpc/main.tf). You can include the block above the module to pass it through to the module.

### New vpc, public and private subnets, bastion host

With this, we create a new vpc, and create all the infrastructure in this. The k3s cluster lives on 3 private subnets. Load balancer lives on 3 public subnets. Bastion lives on public subnets and provides a way to access the k3s hosts remotely via ssh.

See [example](./new-vpc-priv-pub-subnets-bastion/main.tf).

## Settings

If not used as a module, adapt the `variables.tf`, or override them when performing the `terraform plan` or `terraform apply`.

## Prequisites

The EC2 key pair you want to use is already defined in aws. If not, it can be defined in the EC2 console under `Network & Security`.

## AWS credentials

I have refrained from hard coding these in the terraform as its bad practice. These should be defined in the shell by [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html), etc.

## Kube config

You will need to ssh to one of the nodes, `sudo` to root, and then copy `~/.kube/config`. Remember when sshing to the nodes, login as user `ubuntu`.

## Deploying multiple clusters via the prefix

If you are going to do this, its worth using `terraform workspaces` for each prefix, so you can track the state for each cluster.

## Bastion host

You can enable a bastion (jump) host if the k3s nodes are put on private subnets to allow you to jump to them from a public subnet. See `variables.tf`.

If you want to be really clever you could install OpenVPN and then vpn into the vpc networks.

## Getting the cluster kubeconfig

Once the cluster is built, you will need to get the kubeconfig to start using it.

Previously you would have had to ssh on to one the k3s nodes and get it from root ~/.kube/config.

Once you have it, edit the server url in the kubeconfig and replace 127.0.0.1 with the load balancer dns name.

### kubeconfig can be displayed to master0 console

There is the terraform varible `kubeconfig_on_console` to tell the kubeconfig to be displayed on the console of master0. Default is `0` meaning don't display to the console; `1` means display to the console.

Then you can use the aws cli to get the kubeconfig:
```
$ aws ec2 get-console-output --instance-id <id>  --output text --latest
=====================================================================
Cluster kubeconfig:
=====================================================================
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJWekNCL3FBREFnRUNBZ0VBTUFvR0NDcUdTTTQ5QkFNQ01DTXhJVEFmQmdOVkJBTU1HR3N6Y3kxelpYSjIKWlhJdFkyRkFNVFU1TURFM05qVTFNREFlRncweU1EQTFNakl4T1RReU16QmFGdzB6TURBMU1qQXhPVFF5TXpCYQpNQ014SVRBZkJnTlZCQU1NR0dzemN5MXpaWEoyWlhJdFkyRkFNVFU1TURFM05qVTFNREJaTUJNR0J5cUdTTTQ5CkFnRUdDQ3FHU000OUF3RUhBMElBQkUreGx2a3p0emRvRE1SdkVIZEhzUkpKc2RTZHVjQnRwbndLYituYUNzeXYKRVZvQlFVL1p5ZGl0bUR5QUxWbnhtbUUxam0vVnREOXpBczNkeVlySll1YWpJekFoTUE0R0ExVWREd0VCL3dRRQpBd0lDcERBUEJnTlZIUk1CQWY4RUJUQURBUUgvTUFvR0NDcUdTTTQ5QkFNQ0EwZ0FNRVVDSVFEVTFVVVFZT216CjJubGlSY0dSQndaYTNXZFQyUVVpY1BGaDNrK0xyTm5WR1FJZ0h5cThKYXZ5ZVBMZU05THNwcUdEbGVQaXZ0Z2oKaXJSYlRmb3BxMDZVdENZPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://127.0.0.1:6443
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: default
  user:
    password: 3cb5bc0247fbf81267a1053ea8eefed4
    username: admin
=====================================================================
```
