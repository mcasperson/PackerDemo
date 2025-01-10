#!/bin/bash

RULE=$1
GREENTARGETGROUP=$2
BLUETARGETGROUP=$3

echoerror() { echo "$@" 1>&2; }

if [[ -z "${RULE}" ]]; then
  echoerror "Please provide the ARN of the listener rule as the first argument"
  exit 1
fi

if [[ -z "${GREENTARGETGROUP}" ]]; then
  echoerror "Please provide the ARN of the green target group as the second argument"
  exit 1
fi

if [[ -z "${BLUETARGETGROUP}" ]]; then
  echoerror "Please provide the ARN of the blue target group as the third argument"
  exit 1
fi

RULES=$(aws elbv2 describe-rules \
  --listener-arn "#{AWS.ALB.Listener}" \
  --output json)

write_verbose "${RULES}"

GREENWEIGHT=$(jq -r ".Rules[] | select(.RuleArn == \"${RULE}\") | .Actions[] | select(.Type == \"forward\") | .ForwardConfig | .TargetGroups[] | select(.TargetGroupArn == \"${GREENTARGETGROUP}\") | .Weight" <<< "${RULES}")
BLUEWEIGHT=$(jq -r ".Rules[] | select(.RuleArn == \"${RULE}\") | .Actions[] | select(.Type == \"forward\") | .ForwardConfig | .TargetGroups[] | select(.TargetGroupArn == \"${BLUETARGETGROUP}\") | .Weight" <<< "${RULES}")

if [[ -z "${GREENWEIGHT}" ]]; then
  echo "Failed to find the target group ${GREENTARGETGROUP} in the listener rule ${RULE}"
  echo "Double check that the target group exists and has been associated with the load balancer"
  exit 1
fi

if [[ -z "${BLUEWEIGHT}" ]]; then
  echo "Failed to find the target group ${BLUETARGETGROUP} in the listener rule ${RULE}"
  echo "Double check that the target group exists and has been associated with the load balancer"
  exit 1
fi

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