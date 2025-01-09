#!/bin/bash

INACTIVECOLOR=$1
GREENASG=$2
BLUEASG=$3

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