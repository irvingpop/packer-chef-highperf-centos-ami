# High Performance CentOS 7 AMI

The stock RHEL and CentOS AMIs are highly unoptimized and typically out of date.  This project aims to create a high-performance CentOS 7 image that is unencumbered of product codes or other restrictions. It now also includes a recent Linux kernel and Docker.

In informal testing (building Chef server clusters) we've been able to cut deploy times by 50%.

These images are built by Chef's Customer Success team for the benefit of our customers.  For that reason, all images include the latest ChefDK :)

Credit to the DCOS team, this project is based on their [CentOS 7 cloud image](https://github.com/dcos/dcos/tree/master/cloud_images/centos7)


# Usage

## Building your own image

Simply set your `AWS_*` environment variables and run packer.  The easiest way to do this is to set up your profiles via `aws configure` and then export the correct `AWS_PROFILE` variable.
```
export AWS_PROFILE='myprofile'
packer build packer.json
```

## Consuming existing AMIs

### From Terraform
```
data "aws_ami" "centos" {
  most_recent = true
  owners = ["446539779517"] # Chef success

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-*"]
  }
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"
}
```

### Latest AMIs
The latest AMIs were Published on 2019/04/01:

```
ap-northeast-1: ami-09d14a7a7ec87c08e
ap-northeast-2: ami-059f1410383ac0827
ap-south-1: ami-07e6022a390d8691e
ap-southeast-1: ami-03a67695da4a878fa
ap-southeast-2: ami-0376d1e5bc0f69727
ca-central-1: ami-0e4694815e692db5d
eu-central-1: ami-09012d97374487072
eu-north-1: ami-0b5a6e05f6cf39474
eu-west-1: ami-06375d906efb64b71
eu-west-2: ami-02dbba09f5ba1a146
eu-west-3: ami-0e9a816bc5d766581
sa-east-1: ami-00b6b4794bad10c8b
us-east-1: ami-09304f90bec869f82
us-east-2: ami-0388099dd805a15d3
us-west-1: ami-0670cc109c38976c6
us-west-2: ami-01713c945c2ed35c9
```

Changelog:
* Reapply patch to cloud-init where the IPv6 default gateway doesn't appear
* Security and bug-fix updates
* Kernel 3.10.0-957.10.1.el7 (CentOS 7.6)
* Chef Workstation 0.2.53
* Docker 18.09.4-3.el7 / containerd.io 1.2.5-3.1.el7

----

### Previous AMIs
See [the CHANGELOG](./CHANGELOG.md)

## Contributors
* Irving Popovetsky (@irvingpop)
* Gavin Staniforth (@gsdevme)
* John Jelinek IV (@johnjelinek)
* Josh Sooter (@jsooter)
* Siebrand Mazeland (@siebrand)
