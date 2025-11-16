#!/bin/bash
#################################################################################################################################
# build-release.sh
# Created on 03/27/2025
#
# Copyright (C) 2025 Mehmet Bertan Tarakcioglu, Under the MIT License
#
# This file was originally created as part of the WatchDuck project CI Pipeline.
#################################################################################################################################

# This script is meant to run on a GitHub macOS Action Runner as part of the Swift-Executable-CI workflows!
# It assumes to be part of the workflow and may fail if it is being run by itself.

# Just before creating a new release, this script will push the changes to the changelog to the repo.
# It wil then create the new tag and also push it.

# Exit bash script on error
set -eo pipefail

# Set up git credentials as the GitHub Actions Bot
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

# Try and find a changelog file in the repo
CHANGELOG_FILE=$(find . -maxdepth 1 -type f -iname "changelog*" | head -1)
MATCH_COUNT=$(echo "${CHANGELOG_FILE}" | wc -l | xargs)

# Make sure there is only one
if [[ "${MATCH_COUNT}" -lt 1 ]]; then
    echo "Warning: No CHANGELOG file found! Skipping commit."
elif [[ "${MATCH_COUNT}" -gt 1 ]]; then
    echo "Warning: More than one CHANGELOG file found! Skipping commit."
else
    git add "${CHANGELOG_FILE}"
    # Make sure the changelog file actually has changes to commit...
    if ! git diff --cached --quiet; then
        # Use the API here so the commit and push is signed by GitHub
        gh api --method PUT /repos/"${REPO_PATH}"/contents/"${CHANGELOG_FILE}" \
          --field message="Update changelog for release ${NEW_TAG}" \
          --field content="$( base64 -w 0 "${CHANGELOG_FILE}" )" \
          --field encoding="base64" \
          --field branch="${TARGET_BRANCH}" \
          --field sha="$( git rev-parse "${TARGET_BRANCH}":"${CHANGELOG_FILE}" )"
    else
        echo "Warning: No changes found in the CHANGELOG file! Skipping commit."
    fi
fi

# Create and push the new tag
git tag "${NEW_TAG}"
git push --atomic origin "${NEW_TAG}"
