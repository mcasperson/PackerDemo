#!/bin/bash

ASG=$1

LAUNCHTEMPLATE=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "${ASG}" \
  --query 'AutoScalingGroups[0].LaunchTemplate.LaunchTemplateId' \
  --output text)

echo "Modifying launch template ${LAUNCHTEMPLATE} for Auto Scaling group ${ASG}..."

NEWVERSION=$(aws ec2 create-launch-template-version \
    --launch-template-id "${LAUNCHTEMPLATE}" \
    --version-description "#{Octopus.Release.Number}" \
    --source-version 1 \
    --launch-template-data "ImageId=#{AWS.AMI.ID}")

NEWVERSIONNUMBER=$(jq -r '.LaunchTemplateVersion.VersionNumber' <<< "${NEWVERSION}")

echo "Set AMI for launch template ${LAUNCHTEMPLATE} to #{AWS.AMI.ID}, generating new version ${NEWVERSIONNUMBER}..."

write_verbose "${NEWVERSION}"

MODIFYTEMPLATE=$(aws ec2 modify-launch-template \
    --launch-template-id "${LAUNCHTEMPLATE}" \
    --default-version "${NEWVERSIONNUMBER}")

echo "Set default version for launch template ${LAUNCHTEMPLATE} to ${NEWVERSIONNUMBER}..."

write_verbose "${MODIFYTEMPLATE}"

UPDATELAUNCHTEMPLATEVERSION=$(aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name "${ASG}" \
  --launch-template "LaunchTemplateId=${LAUNCHTEMPLATE},Version=${NEWVERSIONNUMBER}")

echo "Updated the ASG launch template version to ${NEWVERSIONNUMBER}..."

write_verbose "${UPDATELAUNCHTEMPLATEVERSION}"

