# Aim

To provide a straightforward deployment of rancher [k3s](https://k3s.io/) light weight kubernetes clusters on aws using terraform. In essence build yourself a simple k3s based cluster. If you don't know what k3s is, its a super light weight but full featured kubernetes; this means more performance (memory/cpu) for your apps.

Features implemented:

* Implement a prefix for resources so multiple clusters  can be deployed into an aws account.
* Specify how many masters (2 recommended), and how many agents (workers) to deploy.
* Implement a single Network Load Balancer (layer 4) for ports 80, 443 and 6443 (kubernetes api). 
* Specify the EC2 instance types for master and agents.
* Masters to use a shared RDS mysql instance.
* Ability to specify RDS instance type.
* Ability to choose between mysql community (default) and aurora mysql. With aurora you specify the number of instances (default 2; 1 reader and 1 writer). Aurora allows a high performant and resilient db for production deployments.
* Not have any excess baggage like rancher install, deploy apps; you can create these after a cluster is deployed via terraform (terraform modules?) or other means.
* Above features allow you to deploy clusters of many different sizes. Much flexibility. 
* You can increase the number of agent nodes and re-run `terraform apply` to deploy more workers when a cluster needs more capacity.
* Allows public and private subnets to be defined. Public is where the load balancer and bastion go; private is where the cluster is provisioned.
* Optional: can add a bastion host to allow ssh jumping from public to private subnets so you can get the k3s nodes (where you choose to have this config).
* Ability to turn off port 6443 (kubernetes api) on the load balancer (see below for details).
* Able to attach additional security groups to masters and agents. This means you can provide additional access to these nodes outside the module. For example if you define an additional load balancer and want to open up some additional ports for it.

Adapted from my [rancher install on aws via terraform](https://github.com/spicysomtam/rancher-k3s-aws-tf), which I decided to keep as is as a simple/poc deploy.

# Single load balancer for kubernetes api and ingress

K3s by default uses the [traefik ingress controller](https://docs.traefik.io/providers/kubernetes-ingress/). There are a number of ingress controllers available for kubernetes (k8s) besides traefik; nginx (ingress-nginx and nginx-ingress), haproxy, etc. They all work the same and use the k8s ingress resource type. Ingress controllers work by inspecting the target dns name, and then forwarding this to the correct k8s service. Thus you only need one Layer 4 (TCP) cloud load balancer even if you are hosting multiple dns names/deployments in k8s. Also the single load balancer handles the k8s api. All of this is attractive as implementing multiple cloud load balancers adds to cost and complexity.

The k3s master nodes are designed to run pod workloads, similar to worker nodes. Thus the load balancer directs HTTP and HTTPS traffic to all the masters and workers.

The kubernetes api is only available on masters so the port for this (6443) is only directed at master nodes.

Originally when I created this deployment (June 2020), traefik worked perfectly as an ingress controller across multiple masters and workers. However this has broken over time, and can only assume traefik originally worked as a daemonset, and in more recently releases changed over to a deployment. Since this has broken, I decided to disable traefik ingress and switch to ingress-nginx, which can easily be deployed as a daemonset from the official helm3 chart. Reasons for using ingress-nginx over traefik:
* ingress-nginx is more popular, more understood, and a standard kubernetes component.
* traefik v1.7 shipped with k3s has a messy daemonset deployment (can't be deployed via a helm chart, although can now be done via traefik 2.x, but this functionality in the helm chart has just been released and traefik 2.x is not general availability/stable at this time).
* ingress-nginx has a more stable feature set while traefik feature set is in flux and I can't guarentee it will change greatly (it has already broke my deployment once so why should I stick with it?)
* ingress-nginx is unlikely to remove its existing functionality; traefik is less predictable.

Its worth discussing Ingress controllers in general (including ingress-nginx):
* Ingress controllers are meant to manage the whole ingress sequence; don't attempt to mix functionality of the cloud load balancer with the ingress controller! Typically examples include installing TLS certificates on the load balancer, which leads to all sorts of issues; the ingress controller is intended to manage TLS for you!
* As mentioned in the first point: ingress manages TLS for you. There is some complexity here of managing certificate authority generated certs (eg Godaddy, Digicert, etc). To simplify this, you might want to install cert-manager, and then let cert-manager manage certs via Letsencrypt, etc. Letsencypt certs are free and cert-manager can manage the renewals of these. 

# Terraform

## Run as a module or standalone

How to run as a module. 

### Put everything in the default vpc and subnets

If you wish to use the aws account default vpc and subnets; see [example](./default-vpc/main.tf). You can include the block above the module to pass it through to the module.

### New vpc public and private subnets and bastion host

With this, we create a new vpc, and create all the infrastructure in this. The k3s cluster lives on 3 private subnets. Load balancer lives on 3 public subnets. Bastion lives on public subnets and provides a way to access the k3s hosts remotely via ssh.

See [example](./new-vpc-priv-pub-subnets-bastion/main.tf).

### No k8s api on external load balancer and enabled on an internal load balancer

See section [Disable kubernetes api on load balancer](#Disable-kubernetes-api-on-load-balancer) for details. This is the same as stack 
[New vpc public and private subnets and bastion host](#New-vpc-public-and-private-subnets-and-bastion-host) with a internal load balancer added that just exposes the k8s api internally. See [example](./no-api-on-ext-lb-plus-int-lb-for-api/main.tf).
## Settings

If not used as a module, adapt the `variables.tf`, or override them when performing the `terraform plan` or `terraform apply`.

## Prequisites

The EC2 key pair you want to use is already defined in aws. If not, it can be defined in the EC2 console under `Network & Security`.

## AWS credentials

I have refrained from hard coding these in the terraform as its bad practice. These should be defined in the shell by [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html), etc.

## Deploying multiple clusters via the prefix

If you are going to do this, its worth using `terraform workspaces` for each prefix, so you can track the state for each cluster.

## Bastion host

You can enable a bastion (jump) host if the k3s nodes are put on private subnets to allow you to jump to them from a public subnet. See `variables.tf`.

If you want to be really clever you could install OpenVPN and then vpn into the vpc networks.

## Reducing number of nodes

It is wise to use `kubectl drain`  to remove a agent or master from the cluster before reducing their count via terraform.

## Masters prevented from recreation on resource changes

This can be quite dangerous; basically recreating the masters. Thus this is blocked. You should always run a terraform plan before making changes to see what the impact is.

However you are not prevented from increasing or decreasing the number of masters. Care must be take on decreasing the number; that is remove masters from the cluster using say `kubectl drain` in advance of reducing the number via terraform. That is remove the nodes cleanly.

## Worker nodes implemented as a launch configuration and auto scaling group

This makes it easier to scale workers up and down, and one of the motivators for using an autoscaling group (asg) is to allow the Cluster Autoscaler (CA) to do autoscaling for you automatically (google Kubernetes Cluster Autoscaler to learn more). The CA works on the basis of checking for pods that go into Pending state; this means there is no free resources to run the pod; in this case the CA will increase the desired number of nodes in the asg. Conversly, when load reduces (typically after 10 minutes) the CA will scale nodes down in the asg. 

I have not had any time to test the CA in k3s with AWS; I will add some notes when I get round to testing this.

## Getting the cluster kubeconfig

Once the cluster is built, you will need to get the kubeconfig to start using it.

Previously you would have had to ssh on to the k3s master0 node and get it from root ~/.kube/config, which may be a problem if you don't have a bastion host. 

Now you can get it from the Jenkins pipeline or master0 console; see the following sections.

### kubeconfig saved as a System Manager parameter so it can be obtained from the Jenkins job console output

There is a terraform variable `kubeconfig_ssm` to write the kubeconfig to a Systems Manager (ssm) parameter. The name of the ssm parameter is `<prefix>-kubeconfig`. By default the variable is `true`. The parameter is used to pass the kubeconfig from master0 back to the Jenkins job so the kubeconfig can be displayed at the end of the Jenkins job so you can easy get it. The ssm parameter is left inplace so you can get it again if required without needing to login via ssh to master0. See the Jenkinsfile in `default-vpc` folder for how this works.

With this method, the load balancer url is automatically inserted.

### kubeconfig can be displayed to master0 console

This predates the `kubeconfig_ssm`. There is the terraform varible `kubeconfig_on_console` to tell the kubeconfig to be displayed on the console of master0. Default is `false` meaning don't display to the console; `true` means display to the console.

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

Once you have the kubeconfig, edit the server url in the kubeconfig and replace 127.0.0.1 with the load balancer dns name.

## Disable kubernetes api on load balancer

There may be situations where the kubernetes api should not be available on the load balancer, especially if its is internet facing.

Thus I added option `api_on_lb` to turn it off. Set this to `true` (default) or `false`.

You could argue that I could also create another internal load balancer for the api, and add loads of options for this within this stack. However I think this is bloating the stack and it would be difficult to cater for the different configurations people might want. Thus you can easily create an internal load balancer outside the stack and pass references from this stack to the internal load balancer stack. 

Thus I just included an option to turn off the k8s api on the load balancer.

I would recommend using the main load balancer for service ingress and just use the internal load balancer for the k8s api; the reason is it will make you ingress simpler to configure (only need to cater for ingress on the main load balancer).

I have included an [example](no-api-on-ext-lb-plus-int-lb-for-api/main.tf).

# Jenkins pipeline

I have included a sample `Jenkinsfile` pipeline in the `default-vpc` example. You could adapt this to the other examples or your requirements. Its a minimum config deploy; I mean it has the bare minimum number of parameters required to do a deploy; you may wish to expand this if you need to specify other parameters.

## Terrform tools

As time passes, `terraform` versions change. To make this easier to manage, I have implement a `tools` section in the pipeline to allow you to manage this. Notes on this:
* Install the Jenkins `terraform` plugin and restart Jenkins.
* Navigate to Jenkins `Manage Jenkins->Global Tool Configuration` and add one or more Terraform installations. I name them based on the `<major>.<minor>` version (eg `0.15`). You can adjust the bug fix version actually installed for a given name over time as required (eg `<major>.<minor>.<bugfix>`) since they are just bug fixes and should have no functionality changes.
* You can see there is now a Jenkins choice parameter called `tf_version` which allows you to set the default and one or more versions, based on the names you defined for the Jenkins Terraform tools. With the versions you set, they need to work with the terraform code, so take care setting the versions. It might be safer just to define one version, and update it over time.
* Also be aware that you should use the same terraform version for a `create` and then the `destroy`. If you update the terraform version on a deploy that is active, you might try running a `create` on top of the existing `create` so as to update the terraform state.

# k3os

I could have used [k3os](https://github.com/rancher/k3os). However this repo predates my discovering k3os, and then I would have the issue of building a custom ami image, and then redoing all the master/worker integration. Thus I did not see any great benefit in switching k3os and decided to stay with k3s, which probably has a bigger user base than k3os.
