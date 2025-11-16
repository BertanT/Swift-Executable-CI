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

# This script will install Swiftly and set up the correct version of Swift requested by the repository workflow variables.

# Exit bash script on error
set -eo pipefail

# Install Swiftly
curl -O https://download.swift.org/swiftly/darwin/swiftly.pkg
installer -pkg swiftly.pkg -target CurrentUserHomeDirectory
~/.swiftly/bin/swiftly init --assume-yes --skip-install --quiet-shell-followup
source ~/.swiftly/env.sh

echo "SWIFTLY_HOME_DIR="${SWIFTLY_HOME_DIR}"" >>"${GITHUB_ENV}"
echo "SWIFTLY_BIN_DIR="${SWIFTLY_BIN_DIR}"" >>"${GITHUB_ENV}"
echo "${SWIFTLY_BIN_DIR}" >>"${GITHUB_PATH}"

hash -r

# Install the requested version of Swift
swiftly install "${SWIFT_TOOLCHAIN_VERSION}"
swiftly use --global-default "${SWIFT_TOOLCHAIN_VERSION}"