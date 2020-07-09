#!/usr/bin/env bash

REPO_SLUG=$(basename $(git config --get remote.origin.url) | cut -d'.' -f1)
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
S3_BUCKET="s3://$INPUT_S3_BUCKET"
S3_BRANCH_PATH="$S3_BUCKET/$REPO_SLUG/$COMMIT_BRANCH"

[ -d "$INPUT_TARGETDIR/databases" ] && rm -rf "$INPUT_TARGETDIR/databases"
git log -1 > "$INPUT_TARGETDIR/git-status.txt"

echo "$S3_BRANCH_PATH/$COMMIT_HASH" > "$INPUT_TARGETDIR/s3-path.txt"
echo "Uploading to $S3_BRANCH_PATH/$COMMIT_HASH"
aws s3 sync --only-show-errors --delete --acl=public-read "./$INPUT_TARGETDIR" "$S3_BRANCH_PATH/$COMMIT_HASH" && \

# releases/sandbox/gl-123        -> releases/sandbox/gl-123/latest
# releases/production/2020-01-01 -> releases/production/latest
# releases/staging/2020-01-01    -> releases/staging/latest
[[ "$COMMIT_BRANCH" =~ ^releases/(staging|production) ]] \
    && LATEST_PATH="$(dirname "$S3_BRANCH_PATH")/latest" \
    || LATEST_PATH="$S3_BRANCH_PATH/latest"

echo "Updating $LATEST_PATH"
aws s3 sync --only-show-errors --delete --acl=public-read "$S3_BRANCH_PATH/$COMMIT_HASH" "$LATEST_PATH"

exit $?
