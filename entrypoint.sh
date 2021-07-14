#!/bin/bash

set -x

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

VERSION="latest"
if [ "$INPUT_TFSEC_VERSION" != "latest" ]; then
  VERSION="tags/${INPUT_TFSEC_VERSION}"
fi

# Download the required tfsec version
wget -O - -q "$(wget -q https://api.github.com/repos/aquasecurity/tfsec/releases/${VERSION} -O - | grep -o -E "https://.+?tfsec-linux-amd64" | head -n1)" >tfsec
install tfsec /usr/local/bin/tfsec

if [ -n "${INPUT_TFVARS_FILE}" ]; then
  echo "::debug::Using tfvars file ${INPUT_TFVARS_FILE}"
  TFVARS_OPTION="--tfvars-file ${INPUT_TFVARS_FILE}"
fi

if [ -n "${INPUT_CONFIG_FILE}" ]; then
  echo "::debug::Using config file ${INPUT_CONFIG_FILE}"
  CONFIG_FILE_OPTION="--config-file ${INPUT_CONFIG_FILE}"
fi

echo {} >${INPUT_SARIF_FILE}

tfsec --format=sarif "${INPUT_WORKING_DIRECTORY}" ${CONFIG_FILE_OPTION} ${TFVARS_OPTION} >${INPUT_SARIF_FILE}

tfsec_return="${PIPESTATUS[0]}" exit_code=$?

echo ::set-output name=tfsec-return-code::"${tfsec_return}"
