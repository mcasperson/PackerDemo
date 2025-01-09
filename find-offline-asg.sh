#!/bin/bash

if [[ "#{Octopus.Action[Find Offline Target Group].Output.InactiveGroupColor}" == "Green" ]]
then
  set_octopusvariable "ActiveGroup" "#{AWS.ASG.Blue}"
  set_octopusvariable "InactiveGroup" "#{AWS.ASG.Green}"
  echo "Active group is Blue (#{AWS.ASG.Blue}), inactive group is Green (#{AWS.ASG.Green})"
else
  set_octopusvariable "ActiveGroup" "#{AWS.ASG.Green}"
    set_octopusvariable "InactiveGroup" "#{AWS.ASG.Blue}"
    echo "Active group is Green (#{AWS.ASG.Green}), inactive group is Blue (#{AWS.ASG.Blue})"
fi