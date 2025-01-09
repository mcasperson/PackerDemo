#!/bin/bash

RULE=$1
OFFLINEGROUP=$2
ONLINEGROUP=$3

# https://stackoverflow.com/questions/61074411/modify-aws-alb-traffic-distribution-using-aws-cli
MODIFYRULE=$(aws elbv2 modify-rule \
  --rule-arn "${RULE}" \
  --actions \
    "[{
        \"Type\": \"forward\",
        \"Order\": 1,
        \"ForwardConfig\": {
          \"TargetGroups\": [
              {\"TargetGroupArn\": \"${OFFLINEGROUP}\", \"Weight\": 0 },
              {\"TargetGroupArn\": \"${ONLINEGROUP}\", \"Weight\": 100 }
          ]
        }
     }]")

echo "Updated listener rules for ${RULE} to set weight to 0 for ${OFFLINEGROUP} and 100 for ${ONLINEGROUP}."

write_verbose "${MODIFYRULE}"