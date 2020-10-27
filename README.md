# tfsec-sarif-action

## Description

This Github Action will run the tfsec sarif check then add the report to the repo for upload.

Example usage

```yaml
name: tfsec
on: [pull_request]
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
          github_token: ${{ secrets.github_token }}
          
```