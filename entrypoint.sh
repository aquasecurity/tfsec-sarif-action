#!/bin/bash

set -x

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

if [ -n "${INPUT_TFVARS_FILE}" ]; then
   echo "::debug::Using tfvars file ${INPUT_TFVARS_FILE}"
   TFVARS_OPTION="--tfvars-file ${INPUT_TFVARS_FILE}"
fi

echo {} > ${INPUT_SARIF_FILE}

tfsec --format=sarif "${INPUT_WORKING_DIRECTORY}" ${TFVARS_OPTION} > ${INPUT_SARIF_FILE}

tfsec_return="${PIPESTATUS[0]}" exit_code=$?

echo ::set-output name=tfsec-return-code::"${tfsec_return}"


