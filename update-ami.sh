#!/bin/bash

if [ "#{Octopus.Action[Find Offline Target Group].Output.InactiveGroupColor}" == "Green" ]
then
  ASG="#{AWS.ASG.Green}"
else
  ASG="#{AWS.ASG.Blue}"
fi

LAUNCHTEMPLATE=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "${ASG}" \
  --query 'AutoScalingGroups[0].LaunchTemplate.LaunchTemplateId' \
  --output text)

NEWVERSION=$(aws ec2 create-launch-template-version \
    --launch-template-id "${LAUNCHTEMPLATE}" \
    --version-description "#{Octopus.Release.Number}" \
    --source-version 1 \
    --launch-template-data "ImageId=#{AWS.AMI.ID}")

write_verbose "${NEWVERSION}"

NEWVERSIONNUMBER=$(jq -r '.LaunchTemplateVersion.VersionNumber' <<< "${NEWVERSION}")

MODIFYTEMPLATE=$(aws ec2 modify-launch-template \
    --launch-template-id "${LAUNCHTEMPLATE}" \
    --default-version "${NEWVERSIONNUMBER}")

write_verbose "${MODIFYTEMPLATE}"

REFRESH=$(aws autoscaling start-instance-refresh --auto-scaling-group-name "${ASG}")

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