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
The latest AMIs were Published on 2019/10/07:

```
ap-northeast-1: ami-0943c71779148970f
ap-northeast-2: ami-042714c24ecf25e26
ap-south-1: ami-08cbb4e76dfee765f
ap-southeast-1: ami-0f65ac71a3f129066
ap-southeast-2: ami-0ff11e1be125ada2f
ca-central-1: ami-0904037074b287caa
eu-central-1: ami-0901dc2ff46fd73a2
eu-north-1: ami-0f3c9a76407b25f84
eu-west-1: ami-0581e1d8ead15c893
eu-west-2: ami-0f415b06e749438de
eu-west-3: ami-07eba3d943b8c05cd
sa-east-1: ami-0bd26fc35cde37dca
us-east-1: ami-02ddb83ff84ca592a
us-east-2: ami-04e2458136bbbbaec
us-west-1: ami-03ec171be9ffd4bdd
us-west-2: ami-0d280b33e51a94243
```

Changelog:
* CentOS 7.7 (kernel 3.10.0-1062.1.2.el7)
* Switch on [Retpoline Spectre V2 mitigation to regain lost performance](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/7.7_release_notes/new_features#enhancement_kernel)
* Chef Workstation 0.9.42 / Puppet Agent 6.10.0 / Amazon SSM Agent 2.3.714.0
* Docker 19.03.2-3.el7

----

### Previous AMIs
See [the CHANGELOG](./CHANGELOG.md)

## Contributors
* Irving Popovetsky (@irvingpop) - Maintainer
* Gavin Staniforth (@gsdevme)
* John Jelinek IV (@johnjelinek)
* Josh Sooter (@jsooter)
* Siebrand Mazeland (@siebrand)
