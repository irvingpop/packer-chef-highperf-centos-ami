# CentOS base AMI builder

These packer definitions will create minimal CentOS AMIs completely from scratch, meaning they are not built from existing AMIs.

It uses the "EBS Surrogate" packer builder to create them.

## Usage

CentOS 7:
```bash
packer build packer-base-centos7.json
```

CentOS 8:
```bash
packer build packer-base-centos8.json
```

CentOS 8 Stream:
```bash
packer build packer-base-centos8-stream.json
```


## Technical notes on how these are built


## Procedure to create an image on an additional volume on an existing instance:

- Launch a CentOS AMI, make sure it is a newer type that uses nvme disks (e.g. T3 or M5)
  - At launch time, specify attaching a secondary volume that is 8GB.  Do not set the secondary volume to delete on termination.
- Log in to your instance and become root (sudo -i)
- Update your instance, especially if it is not the latest:  yum upgrade -y
- run: curl -O https://raw.githubusercontent.com/irvingpop/packer-chef-highperf-centos7-ami/marketplace/create_base_ami.sh
- Find the volume using "lsblk". It's probaly named "nvme1n1"
- export DEVICE="/dev/nvme1n1" # export the DEVICE variable for this script
- bash -x create_base_ami.sh # start this script

Wait until the script has completed. Can can take 10 minutes or so.

When complete, convert the $DEVICE into an AMI by creating a snapshot of the
EBS volume and converting the snapshot into an AMI.  These steps can be done
with the AWS web console or using the CLI tools.

How to create an AMI of the volume?

- Detach the additional volume from the instance in the EC2 Dashboard menu
  Volumes.
- Create a snapshot of the detached volume by selecting it, and executing the
  action "Create Snapshot". Provide a useful description for the snapshot.
- Create an AMI of the created snapshot in the EC2 Dashboard menu Snapshots
  by selecting the snapshot and executing the action "Create Image". Provide
  the following values:
  - Name: Useful, short name.
  - Description: Description, more verbose, including for example the script name and repo URL used to create it.
  - Virtualisation type: Hardware-assisted vistualisation


