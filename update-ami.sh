#!/bin/bash

ASG="#{Octopus.Action[Find Offline Target ASG].Output.InactiveGroup}"

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

REFRESH=$(aws autoscaling start-instance-refresh --auto-scaling-group-name "${ASG}")

if [[ $? -ne 0 ]];
then
  echo "Failed to start instance refresh for Auto Scaling group ${ASG}"
  exit 1
fi

REFRESHTOKEN=$(jq -r '.InstanceRefreshId' <<< "${REFRESH}")

echo "Refreshing instances in Auto Scaling group ${ASG}..."

write_verbose "${REFRESH}"

# Wait for all instances to be healthy
for i in {1..10}; do
  REFRESHSTATUS=$(aws autoscaling describe-instance-refreshes --auto-scaling-group-name "${ASG}" --instance-refresh-ids "${REFRESHTOKEN}")
  STATUS=$(jq -r '.InstanceRefreshes[0].Status' <<< "${REFRESHSTATUS}")

  write_verbose "${REFRESHSTATUS}"

  if [[ "${STATUS}" == "Successful" ]];
  then
    echo "Instance refresh succeeded"
    break
  elif [[ "${STATUS}" == "Failed" ]];
  then
    echo "Instance refresh failed!"
    exit 1
  fi
  echo "Waiting for Auto Scaling group ${ASG} refresh to complete..."
  sleep 12
done