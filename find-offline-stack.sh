#!/bin/bash

aws elbv2 describe-rules \
  --listener-arn "#{AWS.ALB.Listener}" \
  --output json