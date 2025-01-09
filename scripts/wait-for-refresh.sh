#!/bin/bash

ASG=$1

for i in {1..30}; do
  EXISTINGREFRESHES=$(aws autoscaling describe-instance-refreshes --auto-scaling-group-name "${ASG}")
  NOTSUCCESSFUL=$(jq '.InstanceRefreshes[] | select(.Status == "Pending" or .Status == "InProgress" or .Status == "Cancelling" or .Status == "RollbackInProgress" or .Status == "Baking")' <<< "${EXISTINGREFRESHES}")
  if [[ -z "${NOTSUCCESSFUL}" ]];
  then
    break
  fi
    echo "Waiting for existing Auto Scaling group ${ASG} refresh to complete..."
    sleep 12
done

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
for i in {1..30}; do
  REFRESHSTATUS=$(aws autoscaling describe-instance-refreshes --auto-scaling-group-name "${ASG}" --instance-refresh-ids "${REFRESHTOKEN}")
  STATUS=$(jq -r '.InstanceRefreshes[0].Status' <<< "${REFRESHSTATUS}")
  PERCENTCOMPLETE=$(jq -r '.InstanceRefreshes[0].PercentageComplete' <<< "${REFRESHSTATUS}")

  write_verbose "${REFRESHSTATUS}"

  if [[ "${STATUS}" == "Successful" ]]
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