#!/bin/bash
cd packer
chmod +x packer
./packer validate ubuntu-webserver.hcl
./packer build "-var=vpc=#{AWS.Network.VPCID}" "-var=subnet=#{AWS.Network.SubnetID}" ubuntu-webserver.hcl