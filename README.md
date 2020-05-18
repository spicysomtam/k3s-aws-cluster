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

Adapted from my [rancher install on aws via terraform](https://github.com/spicysomtam/rancher-k3s-aws-tf).

# Single load balancer

The k3s master nodes are designed to run pod workloads, similar to agent/worker nodes. Thus the load balancer directs HTTP and HTTPS traffic to all the masters and agents.

The kubernetes api is only available on masters so the port for this (6443) is only directed at master nodes.

K3s by default uses the [treafik ingress](https://docs.traefik.io/providers/kubernetes-ingress/). You will need to setup k8s annotations for this to work; treafik works on inspecting the target dns name, and then forwarding this to the correct k8s service. Thus you only need one Layer 4 cloud load balancer even if you are hosting multiple dns names/deployments in k3s. Also the single load balancer handles the k8s api. All of this is attractive as implementing multiple cloud load balancers adds to the cost of operating the stack not to mention adding complexity.

A load balancer is required even if you deploy a single master node cluster; the issue here is that the k3s certificate is set to the private IP of the host, rather than the public IP, and you will need to use `--insecure-skip-tls-verify` with `kubectl` on your client, which turns off TLS and thus is not secure. I am sure there is a work around for this.

# Terraform

## Settings

Adapt the `variables.tf`, or override them when performing the `terraform plan`.

## Prequisites

The EC2 key pair you want to use is already defined in aws. If not, it can be defined in the EC2 console under `Network & Security`.

## AWS credentials

I have refrained from hard coding these in the terraform as its bad practice. These should be defined in the shell by [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html), etc.

## Installs into default vpc

To keep things simple, the deploys are deployed into the default vpc. If you require a specific vpc, consider adapting vpc.tf, and adding a variable for it.

## Kube config

You will need to ssh to one of the nodes, `sudo` to root, and then copy `~/.kube/config`. Remember when sshing to the nodes, login as user `ubuntu`.

## Deploying multiple clusters via the prefix

If you are going to do this, its worth using `terraform workspaces` for each prefix, so you can track the state for each cluster.