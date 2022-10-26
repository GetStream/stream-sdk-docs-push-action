#!/bin/bash

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

CLONE_DIR=$(mktemp -d) # create a temporary directory

echo "Cloning destination git repository"
# Setup git
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

# Clone the repository with the single branch as $TARGET_BRANCH to the temporary directory
git clone --single-branch --branch "$TARGET_BRANCH" "https://$GIT_USERNAME:$STREAM_DOCS_GH_TOKEN@github.com/$DESTINATION_GITHUB_USERNAME/$DESTINATION_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

SDKs=$(find ./"$SOURCE_DIRECTORY"/docs -maxdepth 1 -mindepth 1 -type d | awk -F'/' '{print $4}')

echo "Deleting all contents of SDKs in target git repository and copying current over"
for sdk in "${SDKs[@]}"
do
    find "$CLONE_DIR"/docs/"$PRODUCT_DIRECTORY" -maxdepth 1 -mindepth 1 -type f -iname "*${sdk/ /}*" -exec bash "$ACTION_PATH"/find_match_handler.sh "${sdk/ /}" {} \;
    find "$CLONE_DIR"/docs/"$PRODUCT_DIRECTORY" -maxdepth 1 -mindepth 1 -type d -iname "*${sdk/ /}*" -exec bash "$ACTION_PATH"/find_match_handler.sh "${sdk/ /}" {} \;
    find "$CLONE_DIR"/docs/"$PRODUCT_DIRECTORY" -maxdepth 2 -mindepth 2 -type d -iname "*${sdk/ /}*" -exec bash "$ACTION_PATH"/find_match_handler.sh "${sdk/ /}" {} \;
    ls -la "$CLONE_DIR"/docs/"$PRODUCT_DIRECTORY"
    ls -la "$CLONE_DIR"/docs/"$PRODUCT_DIRECTORY"/docs
done

# Create Product directory if it doesn't exist
echo "Creating Product directory if it doesn't exist"
[ -d "$CLONE_DIR/docs/$PRODUCT_DIRECTORY" ] || mkdir "$CLONE_DIR/docs/$PRODUCT_DIRECTORY"

# Copy the documentation from the SDK to the temporary directory
echo "Copying the documentation from the SDK to the temporary directory"
cp -a "./$SOURCE_DIRECTORY/." "$CLONE_DIR/docs/$PRODUCT_DIRECTORY"

cd "$CLONE_DIR"

# Setting the commit message to be used while commiting the changes
echo "Setting the commit message to be used while commiting the changes"
ORIGIN_COMMIT="https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"
COMMIT_MESSAGE="${COMMIT_MESSAGE/\$GITHUB_REF/$GITHUB_REF}"

# Add all the files to the git repository
echo "Add all the files to the git repository"
git add .
git status

# Commit the changes
# git diff-index : to avoid the git commit failing if there are no changes to be committed
echo "Commit the changes with the message: $COMMIT_MESSAGE"
git diff-index --quiet HEAD || git commit -m "$COMMIT_MESSAGE"

# Push the changes
# --set-upstream: sets default branch when pushing to a branch that does not exist
echo "Pushing the changes"
git push "https://$GIT_USERNAME:$STREAM_DOCS_GH_TOKEN@github.com/$DESTINATION_GITHUB_USERNAME/$DESTINATION_REPOSITORY_NAME.git" --set-upstream "$TARGET_BRANCH"
