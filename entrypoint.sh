#!/bin/bash

set -x

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

echo {} > ${INPUT_SARIF_FILE}

tfsec --format=sarif "${INPUT_WORKING_DIRECTORY}" > ${INPUT_SARIF_FILE}

tfsec_return="${PIPESTATUS[0]}" exit_code=$?

echo ::set-output name=tfsec-return-code::"${tfsec_return}"
