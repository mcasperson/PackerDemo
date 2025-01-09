#!/bin/bash

if [ "#{Octopus.Action[Find Offline Target Group].Output.InactiveGroupColor}" == "Green" ]
then
  LAUNCHTEMPLATE="#{AWS.ASG.Green}"
else
  LAUNCHTEMPLATE="#{AWS.ASG.Blue}"
fi

aws ec2 create-launch-template-version \
    --launch-template-id "${LAUNCHTEMPLATE}" \
    --version-description "#{Octopus.Release.Number}" \
    --source-version 1 \
    --launch-template-data "ImageId=#{AWS.AMI.ID}"

aws autoscaling start-instance-refresh --auto-scaling-group-name some-name