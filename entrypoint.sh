#!/bin/bash

set -x

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi


tfsec --format=sarif "${INPUT_WORKING_DIRECTORY}" > ${INPUT_SARIF_FILE}

tfsec_return="${PIPESTATUS[0]}" exit_code=$?

echo ::set-output name=tfsec-return-code::"${tfsec_return}"

# echo "Input branch is ${INPUT_BRANCH}"

# sh -c "git remote add origin ${INPUT_BRANCH} || git fetch --unshallow origin"

# sh -c "git config --global user.name '${GITHUB_ACTOR}' \
#       && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com' \
#       && git add .sarif/tfsec.sarif && git commit -m 'Updating tfsec.sarif file' --allow-empty \
#       && git push -u origin HEAD:${INPUT_BRANCH} --force"

