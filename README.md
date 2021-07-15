[![GitHub All Releases](https://img.shields.io/github/downloads/tfsec/tfsec-sarif-action/total)](https://github.com/tfsec/tfsec-sarif-action/releases)
# tfsec-sarif-action

## Description

This Github Action will run the tfsec sarif check then add the report to the repo for upload.

Example usage

```yaml
name: tfsec
on:
  push:
    branches:
      - main
  pull_request:
jobs:
  tfsec:
    name: tfsec sarif report
    runs-on: ubuntu-latest

    steps:
      - name: Clone repo
        uses: actions/checkout@master

      - name: tfsec
        uses: tfsec/tfsec-sarif-action@master
        with:
          sarif_file: tfsec.sarif          

      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v1
        with:
          # Path to SARIF file relative to the root of the repository
          sarif_file: tfsec.sarif         
```

The `tfsec/tfsec-sarif-action` optionally takes a `config_file` argument to specify the path to a `tfsec` config file that you wish to be run in during the action.
