# action-save-test-results
Saves unit test results to S3

Example:
```
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - id: upload-results
        name: Upload Results
        uses: speareducation/action-save-test-results
        env:
          AWS_REGION: us-east-1
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        with:
          s3Bucket: spear-core-test-coverage
          sourceDir: .ci-results
          projectKey: ${{ steps.build-vars.outputs.projectKey }}
          releaseTag: ${{ github.ref_name }}
```

