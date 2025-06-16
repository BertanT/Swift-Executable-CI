#!/bin/bash
#################################################################################################################################
# update-changelog.sh
# Created on 06/12/2025
#
# Copyright (C) 2025 Mehmet Bertan Tarakcioglu, Under the MIT License
#
# This file was originally created as part of the WatchDuck project CI Pipeline.
#############################################################################################################################################################################################################

# This script is meant to run on a GitHub macOS Action Runner as part of the SwiftPM-Cross-Comp-CI workflows!
# It assumes to be part of the workflow and may fail if it is being run by itself.

# This script updates the changelog for the new release, replacing the 'Unreleased' section with the new tag
# and linking to the corresponding comparison URL on GitHub.

# WARNING: For this to work, the changelog must follow the Keep a Changelog format with an 'Unreleased' section!

# Exit bash script on error
set -eo pipefail

# Find the changelog file and store its name in a variable
CHANGELOG_FILE=$(find . -maxdepth 1 -type f -iname "changelog*" | head -1)

# Check if a CHANGELOG file exists
if [ -z "$CHANGELOG_FILE" ]; then
    echo "No CHANGELOG file found."
    exit 0
fi

# Check if any tags exist
if git tag -l | grep -q .; then
    # Get previous tag if it exists
    PREV_TAG=$(git describe --abbrev=0 --tags HEAD^)
    
    # Create a URL to link to the new tag title in the changelog
    compare_url="${REPO_URL}/compare/${PREV_TAG}...${NEW_TAG}"
    
    # Create the new markdown tag title with the correct comparison link
    released_tag="[${NEW_TAG}]: ${compare_url}"

else
    # If this is the first tag, link to the release URL instead
    release_url="${REPO_URL}/tag/${NEW_TAG}"
    released_tag="[${NEW_TAG}]: ${release_url}"
fi

# Replace 'Unreleased' with the new tag and add a date
sed -i '' "s/## \[Unreleased\]/## [${NEW_TAG}] - $(date +'%Y-%m-%d')/g" "$CHANGELOG_FILE"

# Add a new 'Unreleased' section
sed -i '' $'s/## \\[/## [Unreleased]\\\n\\\n## [/' "$CHANGELOG_FILE"

# Replace the 'Unreleased' link to compare with the new tag
sed -i '' "s|\[unreleased\]: .*|[unreleased]: ${REPO_URL}/compare/${NEW_TAG}...HEAD|I" "$CHANGELOG_FILE"

# Only add a comparison link if this isn't the first tag
echo -e "\n${released_tag}" >> "$CHANGELOG_FILE"

# Extract release notes from the changelog and put them into a temporary markdown file
echo -e "## Release Notes" > "release-notes-${GITHUB_RUN_ID}.md"
awk "/## \\[${NEW_TAG}\\]/{flag=1;next} /## \\[/&&flag{flag=0} flag" "$CHANGELOG_FILE" | sed '/^\[.*\]: /d' >> "release-notes-${GITHUB_RUN_ID}.md"