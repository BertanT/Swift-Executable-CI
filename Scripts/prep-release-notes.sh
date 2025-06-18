#!/bin/bash
#################################################################################################################################
# update-changelog.sh
# Created on 06/12/2025
#
# Copyright (C) 2025 Mehmet Bertan Tarakcioglu, Under the MIT License
#
# This file was originally created as part of the WatchDuck project CI Pipeline.
##################################################################################################################################

# This script is meant to run on a GitHub macOS Action Runner as part of the Swift-Executable-CI workflows!
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
    echo "Warning: No CHANGELOG file found. Skipping changelog update."
    exit 0
fi

# Check the changelog title
if ! grep -q "# Changelog" "$CHANGELOG_FILE" && ! grep -q "# Change Log" "$CHANGELOG_FILE" && ! head -n 5 "$CHANGELOG_FILE" | grep -q -i "changelog"; then
    echo "Warning: The changelog doesn't appear to follow the Keep a Changelog format. It should have a # Changelog file at the top in markdown format. Skipping changelog update."
    exit 0
fi

# Check the link reference for the unreleased title section
if ! grep -q "\[unreleased\]:" "$CHANGELOG_FILE"; then
    echo "Warning: The changelog doesn't have an [unreleased] link reference section. Skipping changelog update."
    exit 0
fi

# Check that there is exactly one Unreleased section
UNRELEASED_COUNT=$(grep -c "## \[Unreleased\]" "$CHANGELOG_FILE" || true)
if [ "$UNRELEASED_COUNT" -eq 0 ]; then
    echo "Warning: No '## [Unreleased]' section found in the changelog. Skipping changelog update."
    exit 0
elif [ "$UNRELEASED_COUNT" -gt 1 ]; then
    echo "Warning: Multiple '## [Unreleased]' sections found in the changelog. Skipping changelog update."
    exit 0
fi

# Check that all release dates follow the YYYY-MM-DD format
INVALID_DATES=$(grep -E "^## \[[^]]+\] - " "$CHANGELOG_FILE" | grep -v -E "^## \[Unreleased\]" | grep -v -E "^## \[[^]]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$" || true)
if [ -n "$INVALID_DATES" ]; then
    echo "Error: Found release entries with invalid date format. Keep a Changelog requires YYYY-MM-DD format. Skipping changelog update."
    echo "Invalid entries:"
    echo "$INVALID_DATES"
    exit 0
fi

# Check for duplicate release entries
DUPLICATE_RELEASES=$(grep -E "^## \[[^]]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$" "$CHANGELOG_FILE" | sort | uniq -d || true)
if [ -n "$DUPLICATE_RELEASES" ]; then
    echo "Warning: Found duplicate release entries in the changelog. Each release should be unique. Skipping changelog update."
    echo "Duplicate entries:"
    echo "$DUPLICATE_RELEASES"
    exit 0
fi

# Check for empty tag titles (e.g., ## [] - YYYY-MM-DD)
EMPTY_TAGS=$(grep -E "^## \[\s*\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$" "$CHANGELOG_FILE" || true)
if [ -n "$EMPTY_TAGS" ]; then
    echo "Warning: Found empty tag titles in the changelog. Tag titles must not be empty. Skipping changelog update."
    echo "Empty tag entries:"
    echo "$EMPTY_TAGS"
    exit 0
fi

# Check that all release title have link references at the bottom
RELEASE_TAGS=$(grep -E "^## \[[^]]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$" "$CHANGELOG_FILE" | grep -v "Unreleased" | grep -o -E "\[[^]]+\]" | sed 's/\[//;s/\]//' || true)
LINK_REFS=$(grep -E "^\[[^]]+\]:" "$CHANGELOG_FILE" | grep -o -E "\[[^]]+\]" | sed 's/\[//;s/\]//' || true)
MISSING_LINKS=()

for tag in $RELEASE_TAGS; do
    if ! echo "$LINK_REFS" | grep -q "^${tag}$"; then
        MISSING_LINKS+=("$tag")
    fi
done

if [ ${#MISSING_LINKS[@]} -gt 0 ]; then
    echo "Warning: Found release titles without link references. Skipping changelog update."
    echo "Titles without links:"
    for tag in "${MISSING_LINKS[@]}"; do
        echo "  - $tag"
    done
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

# Add a new 'Unreleased' section before the first release title
sed -i '' '1,/^## \[[^]]*\] - [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/s/^## \[/## [Unreleased]\n\n## [/' "$CHANGELOG_FILE"

# Replace the 'Unreleased' link to compare with the new tag
sed -i '' "s|\[unreleased\]: .*|[unreleased]: ${REPO_URL}/compare/${NEW_TAG}...HEAD|I" "$CHANGELOG_FILE"

# Only add a comparison link if this isn't the first tag
echo -e "\n${released_tag}" >> "$CHANGELOG_FILE"

# Extract release notes from the changelog and put them into a temporary markdown file
awk "/## \\[${NEW_TAG}\\]/{flag=1;next} /## \\[/&&flag{flag=0} flag" "$CHANGELOG_FILE" | sed '/^\[.*\]: /d' >> "release-notes-${GITHUB_RUN_ID}.md"