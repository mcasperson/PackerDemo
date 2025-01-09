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

if [ "${GREENWEIGHT}" != "0" ]; then
  echo "Green target group is active, blue target group is inactive"
  set_octopusvariable "ActiveGroupArn" "#{AWS.ALB.GreenTargetGroup}"
  set_octopusvariable "ActiveGroupColor" "Green"
  set_octopusvariable "InactiveGroupArn" "#{AWS.ALB.BlueTargetGroup}"
  set_octopusvariable "InactiveGroupColor" "Blue"
else
  echo "Blue target group is active, green target group is inactive"
  set_octopusvariable "ActiveGroupArn" "#{AWS.ALB.BlueTargetGroup}"
  set_octopusvariable "ActiveGroupColor" "Blue"
  set_octopusvariable "InactiveGroupArn" "#{AWS.ALB.GreenTargetGroup}"
  set_octopusvariable "InactiveGroupColor" "Green"
fi