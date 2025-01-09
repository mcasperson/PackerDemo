#!/bin/bash

RULE=$1
GREENTARGETGROUP=$2
BLUETARGETGROUP=$3

RULES=$(aws elbv2 describe-rules \
  --listener-arn "#{AWS.ALB.Listener}" \
  --output json)

#echo "${RULES}"
#echo "${RULES}" > output.json
#new_octopusartifact "$PWD/output.json"

GREENWEIGHT=$(jq -r ".Rules[] | select(.RuleArn == \"${RULE}\") | .Actions[] | select(.Type == \"forward\") | .ForwardConfig | .TargetGroups[] | select(.TargetGroupArn == \"${GREENTARGETGROUP}\") | .Weight" <<< "${RULES}")
BLUEWEIGHT=$(jq -r ".Rules[] | select(.RuleArn == \"${RULE}\") | .Actions[] | select(.Type == \"forward\") | .ForwardConfig | .TargetGroups[] | select(.TargetGroupArn == \"${BLUETARGETGROUP}\") | .Weight" <<< "${RULES}")

echo "Green weight: ${GREENWEIGHT}"
echo "Blue weight: ${BLUEWEIGHT}"

if [ "${GREENWEIGHT}" != "0" ]; then
  echo "Green target group is active, blue target group is inactive"
  set_octopusvariable "ActiveGroupArn" "${GREENTARGETGROUP}"
  set_octopusvariable "ActiveGroupColor" "Green"
  set_octopusvariable "InactiveGroupArn" "${BLUETARGETGROUP}"
  set_octopusvariable "InactiveGroupColor" "Blue"
else
  echo "Blue target group is active, green target group is inactive"
  set_octopusvariable "ActiveGroupArn" "${BLUETARGETGROUP}"
  set_octopusvariable "ActiveGroupColor" "Blue"
  set_octopusvariable "InactiveGroupArn" "${GREENTARGETGROUP}"
  set_octopusvariable "InactiveGroupColor" "Green"
fi