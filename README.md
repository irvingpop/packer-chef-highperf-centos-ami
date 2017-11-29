# High Performance CentOS 7 AMI

The stock RHEL and CentOS AMIs are highly unoptimized and typically out of date.  This project aims to create a high-performance CentOS 7 image that is unencumbered of product codes or other restrictions.

In informal testing (building Chef server clusters) we've been able to cut deploy times by 50%.

These images are built by Chef's Customer Success team for the benifit of our customers.  For that reason, all images include the latest ChefDK :)

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
The latest AMIs were published on 2017/11/29:

```
eu-west-1: ami-d04bf9a9
eu-west-2: ami-b37967d7
us-east-1: ami-6a831c10
us-east-2: ami-c27158a7
us-west-1: ami-9b9ba0fb
us-west-2: ami-c308d1bb
```

Changelog:
* CentOS 7.4 (kernel 3.10.0-693.5.2.el7)
  * switch to using a new, cleanroom-built 7.4 base image that has XFS formatted with [ftype=1](https://linuxer.pro/2017/03/what-is-d_type-and-why-docker-overlayfs-need-it/)
* ChefDK 2.4.17
* Fixing a compatibility issue with newer AWS instances like C5 (specifically the initramfs)
* Setting ulimits to a sane-by-default value for newer single-user high performance servers
* Install and start Docker CE (17.0.9) and docker-compose
* Adding nice bash completions for things like systemd

### Previous AMIs
Published on 2017/09/22:

| Region    |     AMI      |
|-----------|--------------|
| eu-west-1 | ami-6865aa11 |
| eu-west-2 | ami-23e3f047 |
| us-east-1 | ami-96f41fec |
| us-east-2 | ami-9993b1fc |
| us-west-1 | ami-993e0ff9 |
| us-west-2 | ami-9555a9ed |

Changelog:
* Based on CentOS 7.4 (kernel 3.10.0-693.2.2.el7)
* ChefDK 2.3.3

Published on 2017/08/31:

| Region    |     AMI      |
|-----------|--------------|
| eu-west-1 | ami-9b19e3e2 |
| eu-west-2 | ami-a8e4f4cc |
| us-east-1 | ami-53101b28 |
| us-east-2 | ami-88b89bed |
| us-west-1 | ami-060b3f66 |
| us-west-2 | ami-39628841 |

Changelog:
* Probably the last AMI on CentOS 7.3 before 7.4 comes out
* Security updates since the last AMI
* ChefDK 2.1.11

Published on 2017/08/01:

| Region    |     AMI      |
|-----------|--------------|
| eu-west-1 | ami-60669319 |
| eu-west-2 | ami-0f3e2f6b |
| us-east-1 | ami-c39ebab8 |
| us-east-2 | ami-37193952 |
| us-west-1 | ami-e2c5ed82 |
| us-west-2 | ami-0c4eaa74 |

Changelog:
* Security updates since the last AMI
* ChefDK 2.0.28 and Chef 13

Published on 2017/07/03:

| Region    |     AMI      |
|-----------|--------------|
| eu-west-1 | ami-9b9573e2 |
| eu-west-2 | ami-15d0c671 |
| us-east-1 | ami-6b71497d |
| us-east-2 | ami-ed0c2d88 |
| us-west-1 | ami-9e5d72fe |
| us-west-2 | ami-9f3121e6 |

Changelog:
* Add the ENA (10GbE support) network driver to make enhanced networking work with newer instances such as i3

Published on 2017/07/03:

| Region    |     AMI      |
|-----------|--------------|
| eu-west-1 | ami-2a8d6b53 |
| eu-west-2 | ami-ead2c48e |
| us-east-1 | ami-4196af57 |
| us-east-2 | ami-b40d2cd1 |
| us-west-1 | ami-885f70e8 |
| us-west-2 | ami-c50b1bbc |

Changelog:
* Add additional system performance tuning settings as recommended by the Chef Automate engineering team:
  * Disabling Transparent Huge Pages (THP)
  * Adjusting Linux VM sysctl settings
* Removing setting to disable IPv6 as it's now supported in VPCs
* Publishing to additional AWS regions (us-east-2, eu-west-1, eu-west-2)
* Rebuilding AMIs to get the latest update, of note:
  * kernel 3.10.0-514.26.1.el7 (Stack Clash vulnerability)
  * chefdk 1.5.0 (Chef 12)

Published on 2017/06/01:

| Region    |     AMI      |
|-----------|--------------|
| us-east-1 | ami-b8f9acae |
| us-west-1 | ami-a21231c2 |
| us-west-2 | ami-8ee08dee |

Changelog:
* Rebuilding AMIs to get the latest update, of note:
  * kernel 3.10.0-514.21.1.el7
  * sudo 1.8.6p7-22.el7_3
  * openssl-libs 1.0.1e-60.el7_3.1
  * chefdk 1.4.3

Published on 2017/02/16:

| Region    |     AMI      |
|-----------|--------------|
| us-east-1 | ami-a88c47be |
| us-west-1 | ami-f0481790 |
| us-west-2 | ami-6bb7310b |

Changelog:
* Rebuilding AMIs to get the latest update, of note:
  * kernel 3.10.0-514.6.1.el7
  * openssl-libs 1:1.0.1e-60.el7
  * ntp 4.2.6p5-25.el7.centos.1
  * chefdk 1.2.22

Published on 2016/12/22:

| Region    |     AMI      |
|-----------|--------------|
| us-east-1 | ami-6f3e2378 |
| us-west-1 | ami-31f8a951 |
| us-west-2 | ami-8c10a6ec |

Changelog:
* Update to CentOS 7.3
* Enable `Multi-queue I/O scheduling for SCSI` which brings significant performance gains to SSD storage: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/7.3_Release_Notes/technology_previews_storage.html


Published on 2016/10/26:

| Region    |     AMI      |
|-----------|--------------|
| us-east-1 | ami-a2f1aeb5 |
| us-west-1 | ami-4895de28 |
| us-west-2 | ami-e6963186 |

Changelog:
* Update for the "Dirty Cow" Linux kernel vulnerability
* Install awscli and aws-cfn-bootstrap
* Install and enable ntp by default


Published 2016/10/07:

| Region    |     AMI      |
|-----------|--------------|
| us-east-1 | ami-0d206e1a |
| us-west-1 | ami-c7b3faa7 |
| us-west-2 | ami-6c2ff70c |
