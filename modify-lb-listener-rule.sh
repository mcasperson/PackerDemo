#!/bin/bash

MODIFYRULE=$(aws elbv2 modify-rule \
  --rule-arn "#{AWS.ALB.ListenerRule}" \
  --actions "Type=forward,TargetGroupArn=#{Octopus.Action[Find Offline Target Group].Output.ActiveGroupArn},ForwardConfig={TargetGroups={Weight=0}}" "Type=forward,TargetGroupArn=#{Octopus.Action[Find Offline Target Group].Output.InactiveGroupArn},ForwardConfig={TargetGroups={Weight=100}}")

echo "Updated listener rules for #{AWS.ALB.ListenerRule} to set weight to 0 for #{Octopus.Action[Find Offline Target Group].Output.ActiveGroupArn} and 100 for #{Octopus.Action[Find Offline Target Group].Output.InactiveGroupArn}"

write_verbose "${MODIFYRULE}"