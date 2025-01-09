#!/bin/bash

color=$(($RANDOM % 8))
html_colors=("red" "blue" "green" "yellow" "purple" "orange" "pink" "brown")

chmod +x packer/packer
packer/packer init ubuntu-webserver.pkr.hcl
packer/packer validate "-var=vpc=#{AWS.Parameter.VPCID}" "-var=subnet=#{AWS.Parameter.SubnetIdAz1}" ubuntu-webserver.pkr.hcl
packer/packer build -color=false "-var=color=${html_colors[$color]}" "-var=vpc=#{AWS.Parameter.VPCID}" "-var=subnet=#{AWS.Parameter.SubnetIdAz1}" ubuntu-webserver.pkr.hcl