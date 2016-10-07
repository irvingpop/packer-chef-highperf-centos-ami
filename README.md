# High Performance CentOS 7 AMI

The stock RHEL and CentOS AMIs are highly unoptimized and typically out of date.  This project aims to create a high-performance CentOS 7 image that is unencumbered of product codes or other restrictions.

In informal testing (building Chef server clusters) we've been able to cut deploy times by 50%.

These images are built by Chef's Customer Success team for the benifit of our customers.  For that reason, all images include the latest ChefDK :)

Credit to the DCOS team, this project is based on their [CentOS 7 cloud image](https://github.com/dcos/dcos/tree/master/cloud_images/centos7)


# Usage

## Building your own image
run `packer build packer.json`

## Consuming existing AMIs

The latest AMIs were published on 2016/10/07:

| Region    |     AMI      |
|-----------|--------------|
| us-east-1 | ami-0d206e1a |
| us-west-1 | ami-c7b3faa7 |
| us-west-2 | ami-6c2ff70c |
