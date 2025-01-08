#!/bin/bash
chmod +x packer/packer
packer/packer init ubuntu-webserver.pkr.hcl
packer/packer validate -color=false "-var=vpc=#{AWS.Network.VPCID}" "-var=subnet=#{AWS.Network.SubnetID}" ubuntu-webserver.pkr.hcl
packer/packer build -color=false "-var=vpc=#{AWS.Network.VPCID}" "-var=subnet=#{AWS.Network.SubnetID}" ubuntu-webserver.pkr.hcl