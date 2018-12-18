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
The latest AMIs were Published on 2018/12/18:

```
ap-northeast-1: ami-0aff6cdef7409384b
ap-northeast-2: ami-0a7519a39caa763cf
ap-south-1: ami-0f1f2cbb6520121ec
ap-southeast-1: ami-01862851f72e48829
ap-southeast-2: ami-082d22722632a1a88
ca-central-1: ami-084099074cfe03d29
eu-central-1: ami-0e117581e9563af5f
eu-north-1: ami-028a5202d82e84b02
eu-west-1: ami-0ddc23402bfc1713e
eu-west-2: ami-06796d787b224578d
eu-west-3: ami-088f9757dcb904145
sa-east-1: ami-01a7e80ff07b90d5b
us-east-1: ami-0046f7d33d7b63774
us-east-2: ami-0df204de73ba574c6
us-west-1: ami-072c8477f2f447a65
us-west-2: ami-04a8ea2e6cac7c58a
```

Changelog:
* CentOS 7.6 and all the things updated
* All build scripts are now modularized, thanks to Siebrand Mazeland (@siebrand)!
* Fixing a number of networking issues:
  * Leaving the `ifup-eth0` file caused systemd to consider the network.service to be in a failed state
  * IPv6 machines didn't receive a default route if NetworkManager is removed
* Completely revamped base image creator

----

### Previous AMIs
See [the CHANGELOG]](./CHANGELOG.md)

## Contributors
* Irving Popovetsky (@irvingpop)
* Gavin Staniforth (@gsdevme)
* John Jelinek IV (@johnjelinek)
* Josh Sooter (@jsooter)
* Siebrand Mazeland (@siebrand)
