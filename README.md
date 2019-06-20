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
The latest AMIs were Published on 2019/06/20:

```
ap-northeast-1: ami-06a5861a21f2c1989
ap-northeast-2: ami-007773c5db92d032b
ap-south-1: ami-0db1403d77d4d0dae
ap-southeast-1: ami-0c70926a92f7d8686
ap-southeast-2: ami-07a371cb67c67d306
ca-central-1: ami-0224c451b7c827ed0
eu-central-1: ami-091502e79184cf6dc
eu-north-1: ami-0ee564268ba7f3e26
eu-west-1: ami-0905bc6e0dac6b284
eu-west-2: ami-00dfb15d8a057c8b5
eu-west-3: ami-00d486ef56f7bdec9
sa-east-1: ami-0e0f6e6c4119a358a
us-east-1: ami-0212942f6a6dab9d1
us-east-2: ami-0b8303d2d78a84ede
us-west-1: ami-04c0e22c2587597a4
us-west-2: ami-0da8aa7dcc7b39112
```

Changelog:
* Security and bug-fix updates (including RHSA-2019:1481)
* Kernel 3.10.0-957.21.3.el7 (CentOS 7.6)
* Chef Workstation 0.4.2 / Puppet Agent 5.5.14 / Amazon SSM Agent 2.3.662.0
* Docker 18.09.6-3.el7

----

### Previous AMIs
See [the CHANGELOG](./CHANGELOG.md)

## Contributors
* Irving Popovetsky (@irvingpop) - Maintainer
* Gavin Staniforth (@gsdevme)
* John Jelinek IV (@johnjelinek)
* Josh Sooter (@jsooter)
* Siebrand Mazeland (@siebrand)
