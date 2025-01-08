#!/bin/bash
chmod +x packer/packer
packer/packer validate ubuntu-webserver.hcl
packer/packer build "-var=vpc=#{AWS.Network.VPCID}" "-var=subnet=#{AWS.Network.SubnetID}" ubuntu-webserver.pkr.hcl