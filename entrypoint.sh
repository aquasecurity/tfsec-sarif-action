#!/bin/bash

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

mkdir -p .sarif

tfsec --format=sarif "${INPUT_WORKING_DIRECTORY}" >> .sarif/tfsec.sarif

tfsec_return="${PIPESTATUS[0]}" exit_code=$?

echo ::set-output name=tfsec-return-code::"${tfsec_return}"

sh -c "git config --global user.name '${GITHUB_ACTOR}' \
      && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com' \
      && git add -A && git commit -m '$*' --allow-empty \
      && git push -u origin HEAD"

exit $exit_code