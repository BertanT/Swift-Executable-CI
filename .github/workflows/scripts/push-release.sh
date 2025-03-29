#!/bin/bash
#################################################################################################################################
# build-release.sh
# Created on 03/27/2025
#
# Copyright (C) 2025 Mehmet Bertan Tarakcioglu, Under the MIT License
#
# This file was originally created as part of the WatchDuck project CI Pipeline.
#################################################################################################################################

# This script is meant to run on a GitHub macOS Action Runner as part of the SwiftPM-Cross-Comp-CI workflows!
# It assumes to be part of the workflow and may fail if it is being run by itself.

# Just before creating a new release, this script will push the changes to the changelog to the repo.
# It wil then create the new tag and also push it.

# Exit bash script on error
set -e

# Commit and push the updated changelog
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add CHANGELOG.md 
git commit -m "Update changelog for release ${NEW_TAG}"
git push --atomic origin "HEAD:${TARGET_BRANCH}"

# Create and push the new tag
git tag "${NEW_TAG}"
git push --atomic origin "${NEW_TAG}"