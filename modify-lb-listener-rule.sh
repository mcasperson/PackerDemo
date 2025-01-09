#!/bin/bash

# https://stackoverflow.com/questions/61074411/modify-aws-alb-traffic-distribution-using-aws-cli
MODIFYRULE=$(aws elbv2 modify-rule \
  --rule-arn "#{AWS.ALB.ListenerRule}" \
  --default-actions \
    '[{
        "Type": "forward",
        "Order": 1,
        "ForwardConfig": {
          "TargetGroups": [
              {"TargetGroupArn": "#{Octopus.Action[Find Offline Target Group].Output.ActiveGroupArn}", "Weight": 0 },
              {"TargetGroupArn": "#{Octopus.Action[Find Offline Target Group].Output.InactiveGroupArn}", "Weight": 100 }
          ]
        }
     }]'

echo "Updated listener rules for #{AWS.ALB.ListenerRule} to set weight to 0 for #{Octopus.Action[Find Offline Target Group].Output.ActiveGroupArn} and 100 for #{Octopus.Action[Find Offline Target Group].Output.InactiveGroupArn}"

write_verbose "${MODIFYRULE}"