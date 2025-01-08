#!/bin/bash
chmod +x packer/packer
packer/packer init ubuntu-webserver.pkr.hcl
packer/packer validate "-var=vpc=#{AWS.Parameter.VPCID}" "-var=subnet=#{AWS.Parameter.SubnetID}" ubuntu-webserver.pkr.hcl
packer/packer build -color=false "-var=vpc=#{AWS.Parameter.VPCID}" "-var=subnet=#{AWS.Parameter.SubnetID}" ubuntu-webserver.pkr.hcl