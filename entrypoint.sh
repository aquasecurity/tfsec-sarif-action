#!/bin/bash

set -xe

# Check for a github workkspace, exit if not found
if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

# default to latest
TFSEC_VERSION="latest"

# if INPUT_TFSEC_VERSION set and not latests
if [ -n "${INPUT_TFSEC_VERSION}" && "$INPUT_TFSEC_VERSION" != "latest" ]; then
  TFSEC_VERSION="tags/${INPUT_TFSEC_VERSION}"
fi

# Pull https://api.github.com/repos/aquasecurity/tfsec/releases for the full list of releases. NOTE no trailing slash
wget --inet4-only -O - -q "$(wget -q https://api.github.com/repos/aquasecurity/tfsec/releases/${TFSEC_VERSION} -O - | grep -m 1 -o -E "https://.+?tfsec-linux-amd64" | head -n1)" > tfsec-linux-amd64
wget --inet4-only -O - -q "$(wget -q https://api.github.com/repos/aquasecurity/tfsec/releases/${TFSEC_VERSION} -O - | grep -m 1 -o -E "https://.+?tfsec_checksums.txt" | head -n1)" > tfsec.checksums

# pipe out the checksum and validate
grep tfsec-linux-amd64 tfsec.checksums > tfsec-linux-amd64.checksum
sha256sum -c tfsec-linux-amd64.checksum
install tfsec-linux-amd64 /usr/local/bin/tfsec

# if input vars file then add to arguments
if [ -n "${INPUT_TFVARS_FILE}" ]; then
  echo "Using tfvars file ${INPUT_TFVARS_FILE}"
  TFVARS_OPTION="--tfvars-file ${INPUT_TFVARS_FILE}"
fi

# if config file passed, add config to the arguments 
if [ -n "${INPUT_CONFIG_FILE}" ]; then
  echo "Using config file ${INPUT_CONFIG_FILE}"
  CONFIG_FILE_OPTION="--config-file ${INPUT_CONFIG_FILE}"
fi

# if any additional args included, add them on
if [ -n "${INPUT_TFSEC_ARGS}" ]; then
  echo "Using specified args: ${INPUT_TFSEC_ARGS}"
  TFSEC_ARGS_OPTION="${INPUT_TFSEC_ARGS}"
fi

# if set,  all dirs to be included,
if [ -n "${INPUT_FULL_REPO_SCAN}" ]; then
  echo "Forcing all directories to be scanned"
  TFSEC_ARGS_OPTION="--force-all-dirs ${TFSEC_ARGS_OPTION}"
fi


# prime the sarif file with empty results
echo {} > ${INPUT_SARIF_FILE}

tfsec --soft-fail --out=${INPUT_SARIF_FILE} --format=sarif ${TFSEC_ARGS_OPTION} ${CONFIG_FILE_OPTION} ${TFVARS_OPTION} "${INPUT_WORKING_DIRECTORY}" 

tfsec_return="${PIPESTATUS[0]}" exit_code=$?

echo ::set-output name=tfsec-return-code::"${tfsec_return}"
