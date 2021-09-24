#!/usr/bin/env bash

set -x

if [ -n "$GITHUB_WORKSPACE" ]; then
  cd "$GITHUB_WORKSPACE" || exit
fi

VERSION="latest"
if [ "$INPUT_TFSEC_VERSION" != "latest" ]; then
  echo "::debug::Using tfsec version $INPUT_TFSEC_VERSION"
  VERSION="tags/$INPUT_TFSEC_VERSION"
fi

# Download the required tfsec version
wget -O - -q "$(wget -O - -q "https://api.github.com/repos/aquasecurity/tfsec/releases/$VERSION" | jq '.assets[] | select (.name == "tfsec-linux-amd64") | .browser_download_url')" > tfsec
install tfsec /usr/local/bin/tfsec

if [ -n "$INPUT_TFVARS_FILE" ]; then
  echo "::debug::Using tfvars file $INPUT_TFVARS_FILE"
  TFVARS_OPTION="--tfvars-file $INPUT_TFVARS_FILE"
fi

if [ -n "$INPUT_CONFIG_FILE" ]; then
  echo "::debug::Using config file $INPUT_CONFIG_FILE"
  CONFIG_FILE_OPTION="--config-file $INPUT_CONFIG_FILE"
fi

if [ -n "$INPUT_TFSEC_ARGS" ]; then
  echo "::debug::Using specified args: $INPUT_TFSEC_ARGS"
  TFSEC_ARGS_OPTION="$INPUT_TFSEC_ARGS"
fi

echo {} > "$INPUT_SARIF_FILE"

tfsec --format=sarif "$INPUT_WORKING_DIRECTORY" "$CONFIG_FILE_OPTION" "$TFVARS_OPTION" "$TFSEC_ARGS_OPTION" > "$INPUT_SARIF_FILE"

tfsec_return="${PIPESTATUS[0]}" exit_code=$?

echo ::set-output name=tfsec-return-code::"$tfsec_return"
echo ::set-output name=tfsec-exit-code::"$exit_code"
