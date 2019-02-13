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
The latest AMIs were Published on 2019/02/13:

```
ap-northeast-1: ami-02c58f1040d612a45
ap-northeast-2: ami-0c3e242e39ef33638
ap-south-1: ami-0d121b70d4f2a7c07
ap-southeast-1: ami-0d4af852545da36f7
ap-southeast-2: ami-0fa6aa803dc7f6191
ca-central-1: ami-0dfd14de667c4e8c9
eu-central-1: ami-0ba5a0a4a8e5d70c1
eu-north-1: ami-00d82e36d4cf13239
eu-west-1: ami-0355255a4ed05d5af
eu-west-2: ami-0dd3bbb85610696bb
eu-west-3: ami-0cb3a832f7fa08045
sa-east-1: ami-0c7108774ddaedbaf
us-east-1: ami-062a84bcfcb87a1ab
us-east-2: ami-05e444eb3b5bb499f
us-west-1: ami-0719ffe132cd3bc6c
us-west-2: ami-05178c5d62c39cb82
```

Changelog:
* Update for Docker/runc vulnerability
* kernel 3.10.0-957.5.1.el7

----

### Previous AMIs
See [the CHANGELOG](./CHANGELOG.md)

## Contributors
* Irving Popovetsky (@irvingpop)
* Gavin Staniforth (@gsdevme)
* John Jelinek IV (@johnjelinek)
* Josh Sooter (@jsooter)
* Siebrand Mazeland (@siebrand)
