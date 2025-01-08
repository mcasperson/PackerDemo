#!/bin/bash
cd packer
packer validate ubuntu-webserver.hcl
packer build ubuntu-webserver.hcl "-var=vpc=#{AWS.Network.VPCID}" "-var=subnet=#{AWS.Network.SubnetID}"