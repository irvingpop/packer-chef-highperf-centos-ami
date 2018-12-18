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
The latest AMIs were Published on 2018/10/31:

```
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
