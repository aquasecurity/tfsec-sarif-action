#!/bin/bash

set -xe

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

TFSEC_VERSION="latest"
if [ "$INPUT_TFSEC_VERSION" != "latest" ]; then
  TFSEC_VERSION="/tags/${INPUT_TFSEC_VERSION}"
fi

# Pull https://api.github.com/repos/aquasecurity/tfsec/releases for the full list of releases. NOTE no trailing slash
wget -O - -q "$(wget -q https://api.github.com/repos/aquasecurity/tfsec/releases${TFSEC_VERSION} -O - | grep -m 1 -o -E "https://.+?tfsec-linux-amd64" | head -n1)" > tfsec-linux-amd64
wget -O - -q "$(wget -q https://api.github.com/repos/aquasecurity/tfsec/releases${TFSEC_VERSION} -O - | grep -m 1 -o -E "https://.+?tfsec_checksums.txt" | head -n1)" > tfsec.checksums

grep tfsec-linux-amd64 tfsec.checksums > tfsec-linux-amd64.checksum
sha256sum -c tfsec-linux-amd64.checksum
install tfsec-linux-amd64 /usr/local/bin/tfsec

if [ -n "${INPUT_TFVARS_FILE}" ]; then
  echo "::debug::Using tfvars file ${INPUT_TFVARS_FILE}"
  TFVARS_OPTION="--tfvars-file ${INPUT_TFVARS_FILE}"
fi

if [ -n "${INPUT_CONFIG_FILE}" ]; then
  echo "::debug::Using config file ${INPUT_CONFIG_FILE}"
  CONFIG_FILE_OPTION="--config-file ${INPUT_CONFIG_FILE}"
fi

if [ -n "${INPUT_TFSEC_ARGS}" ]; then
  echo "::debug::Using specified args: ${INPUT_TFSEC_ARGS}"
  TFSEC_ARGS_OPTION="${INPUT_TFSEC_ARGS}"
fi

if [ -n "${INPUT_FULL_REPO_SCAN}" ]; then
  echo "::debug:: Forcing all directories to be scanned"
  TFSEC_ARGS_OPTION="--force-all-dirs ${TFSEC_ARGS_OPTION}"
fi

echo {} > ${INPUT_SARIF_FILE}

tfsec --soft-fail --out=${INPUT_SARIF_FILE} --format=sarif ${TFSEC_ARGS_OPTION} ${CONFIG_FILE_OPTION} ${TFVARS_OPTION} "${INPUT_WORKING_DIRECTORY}" 

tfsec_return="${PIPESTATUS[0]}" exit_code=$?

echo ::set-output name=tfsec-return-code::"${tfsec_return}"
