#!/bin/bash

INACTIVECOLOR=$1
GREENASG=$2
BLUEASG=$3

if [[ -z "${INACTIVECOLOR}" ]]
then
  echo "Please provide the color of the inactive Auto Scaling group (Green or Blue) as the first argument"
  exit 1
fi

if [[ -z "${GREENASG}" ]]
then
  echo "Please provide the name of the Green Auto Scaling group as the second argument"
  exit 1
fi

if [[ -z "${BLUEASG}" ]]
then
  echo "Please provide the name of the Blue Auto Scaling group as the third argument"
  exit 1
fi

if [[ "${INACTIVECOLOR}" == "Green" ]]
then
  set_octopusvariable "ActiveGroup" "${BLUEASG}"
  set_octopusvariable "InactiveGroup" "${GREENASG}"
  echo "Active group is Blue (${BLUEASG}), inactive group is Green (${GREENASG})"
else
  set_octopusvariable "ActiveGroup" "${GREENASG}"
    set_octopusvariable "InactiveGroup" "${BLUEASG}"
    echo "Active group is Green (${GREENASG}), inactive group is Blue (${BLUEASG})"
fi