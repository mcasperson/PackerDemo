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

echo "Refreshing instances in Auto Scaling group ${ASG}..."

write_verbose "${REFRESH}"

# Function to check the health status of instances in the Auto Scaling group
check_instance_health() {
  local instance_ids
  instance_ids=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "${ASG}" \
    --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
    --output text)

  for instance_id in ${instance_ids}; do
    local health_status
    health_status=$(aws ec2 describe-instance-status \
      --instance-ids "${instance_id}" \
      --query 'InstanceStatuses[0].InstanceStatus.Status' \
      --output text)

    if [[ "${health_status}" != "ok" ]]; then
      return 1
    fi
  done

  return 0
}

# Wait for all instances to be healthy
for i in {1..10}; do
  if check_instance_health
  then
    echo "All instances in Auto Scaling group ${ASG} are healthy!"
    break
  fi
  echo "Waiting for all instances in Auto Scaling group ${ASG} to be healthy..."
  sleep 12
done