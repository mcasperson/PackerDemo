#!/bin/bash

RULES=$(aws elbv2 describe-rules \
  --listener-arn "#{AWS.ALB.Listener}" \
  --output json)

echo "${RULES}"

GREENWEIGHT=$(jq -r '.Rules[] | select(.RuleArn == "#{AWS.ALB.Rule}") | .Actions[] | select(.Type == "forward") | .ForwardConfig | .TargetGroups[] | select(.TargetGroupArn == "#{AWS.ALB.GreenTargetGroup}" | .Weight)' <<< "${RULES}")
BLUEWEIGHT=$(jq -r '.Rules[] | select(.RuleArn == "#{AWS.ALB.Rule}") | .Actions[] | select(.Type == "forward") | .ForwardConfig | .TargetGroups[] | select(.TargetGroupArn == "#{AWS.ALB.BlueTargetGroup}" | .Weight)' <<< "${RULES}")

echo "Green weight: ${GREENWEIGHT}"
echo "Blue weight: ${BLUEWEIGHT}"