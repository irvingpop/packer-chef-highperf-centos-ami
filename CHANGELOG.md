
## Previous AMIs
Published on 2018/12/18:

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

Published on 2018/10/31:

```
ca-central-1: ami-082b857c6ad643ad5
eu-central-1: ami-0cb5372cf96c049b5
eu-west-1: ami-0a1a03058ad1dd657
eu-west-2: ami-06e54a9d35305fe03
eu-west-3: ami-01e2c6ae2055c7ad7
sa-east-1: ami-04be093d34af1162f
us-east-1: ami-0dd362a0723a5824f
us-east-2: ami-0bd1af97fd2616315
us-west-1: ami-0de1be25a7e1e65a5
us-west-2: ami-05c8e42d85f60b86b
```

Changelog:
* Latest security and bugfix updates for all the things
* Still on CentOS 7.5, as 7.6 is still in beta

----

Published on 2018/08/17:

```
ca-central-1: ami-0c45a1323d0bef4a3
eu-central-1: ami-06eb7a21cab41309f
eu-west-1: ami-0b8ef990b4f6cc2f1
eu-west-2: ami-0f7061cd93c1719d9
eu-west-3: ami-0bbbe61cd746a7a40
sa-east-1: ami-003b10b29322f17ee
us-east-1: ami-0d9c743093b303d3d
us-east-2: ami-0e3549bf81da3a5cc
us-west-1: ami-0a29da21b480d9a6a
us-west-2: ami-0bdec459b8954e39b
```

Changelog:
* Latest security and bugfix updates for all the things
* Ship new version of awscli: [https://access.redhat.com/errata/RHBA-2018:1991]
* Add `sa-east-1` region to publishing
* Add a few more sysadmin convenience packages: lsof, mlocate, nload

----

Published on 2018/07/02:

```
ca-central-1: ami-a361e3c7
eu-central-1: ami-f2a59d19
eu-west-1: ami-d7dfca3d
eu-west-2: ami-65886002
eu-west-3: ami-22c3735f
us-east-1: ami-4789af38
us-east-2: ami-56162e33
us-west-1: ami-c541a0a6
us-west-2: ami-e315419b
```

Changelog:
* Latest CentOS security and bugfix updates
* Switch from ChefDK to Chef Workstation
* Fix issue with awscli: [https://access.redhat.com/errata/RHBA-2018:1991]

----

Published on 2018/05/10:

```
ca-central-1: ami-68ad2d0c
eu-central-1: ami-93496578
eu-west-1: ami-6c96a115
eu-west-2: ami-91b954f6
eu-west-3: ami-24843559
us-east-1: ami-5036bf2f
us-east-2: ami-28e9d44d
us-west-1: ami-7df7e91d
us-west-2: ami-24d6a65c
```

Changelog:
* Update to CentOS 7.5
* Return back to using the stock kernel
* Stop using `net.ifnames=0` as it appears to cause networking issues on M5/C5 instances
* docker-ce 18.03.1 and docker-compose 1.21.2
* ChefDK 2.5.3

----
Published on 2018/03/21:

```
ca-central-1: ami-e7db5d83
eu-central-1: ami-cdb8e826
eu-west-1: ami-a6c692df
eu-west-2: ami-a82bcdcf
eu-west-3: ami-983c8ae5
us-east-1: ami-b5c413c8
us-east-2: ami-dd4071b8
us-west-1: ami-f9eafd99
us-west-2: ami-0131ad79
```

Changelog:
* Publishing to more EU regions as well as Canada
* kernel 4.9.86
* docker-ce 17.12.1 and docker-compose 1.18.0
* cloud-init 0.7.9
* ChefDK 2.5.3

----

Published on 2018/01/20:

```
eu-west-1: ami-bfff65c6
eu-west-2: ami-409c8724
us-east-1: ami-23aa8159
us-east-2: ami-8ec5efeb
us-west-1: ami-634d4003
us-west-2: ami-10fa4768
```

Changelog:
* Update to the 4.9.77 kernel to protect against Meltdown/Spectre
* docker-ce 17.12.0 and docker-compose 1.18.0

----

Published on 2017/12/21:

```
eu-west-1: ami-3135b748
eu-west-2: ami-e6e2fb82
us-east-1: ami-4583f83f
us-east-2: ami-9ddcf4f8
us-west-1: ami-0f90976f
us-west-2: ami-5378d52b
```

Changelog:
* Enable `centos-release-xen` which switches to a much more modern Linux 4.9 (LTS) kernel
  * Docker now leverages the latest and greatest `overlay2` filesytem and features
* Switch from NTP to chronyd
* `docker-compose` now in `/usr/bin` because Redhat stubbornly excludes `/usr/local/bin` from root's PATH
* docker-ce 17.0.9.1 and docker-compose 1.18.0

----

Published on 2017/11/29:

```
eu-west-1: ami-b62193cf
eu-west-2: ami-a17866c5
us-east-1: ami-2b4dd251
us-east-2: ami-e5755c80
us-west-1: ami-b29da6d2
us-west-2: ami-143ae36c
```

Changelog:
* CentOS 7.4 (kernel 3.10.0-693.5.2.el7)
  * switch to using a new, cleanroom-built 7.4 base image that has XFS formatted with [ftype=1](https://linuxer.pro/2017/03/what-is-d_type-and-why-docker-overlayfs-need-it/)
* ChefDK 2.4.17
* Fixing a compatibility issue with newer AWS instances like C5 (specifically the initramfs)
* Setting ulimits to a sane-by-default value for newer single-user high performance servers
* Install and start Docker CE (17.0.9) and docker-compose
* Adding nice bash completions for things like systemd

----

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

----

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

----

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

----

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

----

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

----

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

----

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

----

Published on 2016/12/22:

| Region    |     AMI      |
|-----------|--------------|
| us-east-1 | ami-6f3e2378 |
| us-west-1 | ami-31f8a951 |
| us-west-2 | ami-8c10a6ec |

Changelog:
* Update to CentOS 7.3
* Enable `Multi-queue I/O scheduling for SCSI` which brings significant performance gains to SSD storage: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/7.3_Release_Notes/technology_previews_storage.html


----

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


----

Published 2016/10/07:

| Region    |     AMI      |
|-----------|--------------|
| us-east-1 | ami-0d206e1a |
| us-west-1 | ami-c7b3faa7 |
| us-west-2 | ami-6c2ff70c |


