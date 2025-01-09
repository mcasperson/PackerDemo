#!/bin/bash

RULES=$(aws elbv2 describe-rules \
  --listener-arn "#{AWS.ALB.Listener}" \
  --output json)

#echo "${RULES}"
#echo "${RULES}" > output.json
#new_octopusartifact "$PWD/output.json"

GREENWEIGHT=$(jq -r '.Rules[] | select(.RuleArn == "#{AWS.ALB.ListenerRule}") | .Actions[] | select(.Type == "forward") | .ForwardConfig | .TargetGroups[] | select(.TargetGroupArn == "#{AWS.ALB.GreenTargetGroup}") | .Weight' <<< "${RULES}")
BLUEWEIGHT=$(jq -r '.Rules[] | select(.RuleArn == "#{AWS.ALB.ListenerRule}") | .Actions[] | select(.Type == "forward") | .ForwardConfig | .TargetGroups[] | select(.TargetGroupArn == "#{AWS.ALB.BlueTargetGroup}") | .Weight' <<< "${RULES}")

echo "Green weight: ${GREENWEIGHT}"
echo "Blue weight: ${BLUEWEIGHT}"


if [ "${GREENWEIGHT}" == "100" ]; then
  set_octopusvariable "ActiveGroupArn" "#{AWS.ALB.GreenTargetGroup}"
  set_octopusvariable "InactiveGroupArn" "#{AWS.ALB.BlueTargetGroup}"
else
  set_octopusvariable "ActiveGroupArn" "#{AWS.ALB.BlueTargetGroup}"
  set_octopusvariable "InactiveGroupArn" "#{AWS.ALB.GreenTargetGroup}"
fi