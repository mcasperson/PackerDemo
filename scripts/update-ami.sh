#!/bin/bash

ASG=$1
AMI=$2
VERSIONDESCRIPTION=$3

if [[ -z "${ASG}" ]]; then
  echo "Please provide the name of the Auto Scaling group as the first argument"
  exit 1
fi

if [[ -z "${AMI}" ]]; then
  echo "Please provide the ID of the new AMI as the second argument"
  exit 1
fi

if [[ -z "${VERSIONDESCRIPTION}" ]]; then
  echo "Please provide a description for the new launch template version as the third argument"
  exit 1
fi

LAUNCHTEMPLATE=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "${ASG}" \
  --query 'AutoScalingGroups[0].LaunchTemplate.LaunchTemplateId' \
  --output text)

echo "Modifying launch template ${LAUNCHTEMPLATE} for Auto Scaling group ${ASG}..."

NEWVERSION=$(aws ec2 create-launch-template-version \
    --launch-template-id "${LAUNCHTEMPLATE}" \
    --version-description "${VERSIONDESCRIPTION}" \
    --source-version 1 \
    --launch-template-data "ImageId=${AMI}")

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

