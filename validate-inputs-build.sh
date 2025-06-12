#!/bin/bash
#################################################################################################################################
# validate-inputs-build.sh
# Created on 03/28/2025
#
# Copyright (C) 2025 Mehmet Bertan Tarakcioglu, Under the MIT License
#
# This file was originally created as part of the WatchDuck project CI Pipeline.
#################################################################################################################################

# !!!!!!!!!! Only use this for the build workflow !!!!!!!!!!

# This script is meant to run on a GitHub macOS Action Runner as part of the SwiftPM-Cross-Comp-CI workflows!
# It assumes to be part of the workflow and may fail if it is being run by itself.

# This script validates and sanitizes the inputs for the workflow to harden against malicious input.

# Exit on error and disallow unset variables
set -euo pipefail

if [[ -z "${SWIFT_TOOLCHAIN_VERSION:-}" || -z "${LINUX_SDK_URL:-}" ]]; then
  echo "Missing Swift toolchain or SDK URL"
  exit 1
fi

# Check for URL safety
if [[ ! "${LINUX_SDK_URL}" =~ ^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$ ]]; then
  echo "Invalid SDK URL"
  exit 1
fi

# Extract domain and enforce swift.org
DOMAIN=$(echo "${LINUX_SDK_URL}" | awk -F/ '{print $3}')

if [[ "${DOMAIN}" != "swift.org" && ! "${DOMAIN}" =~ \.swift\.org$ ]]; then
  echo "Untrusted domain: ${DOMAIN}"
  exit 1
fi

# Validate Swift version in SDK URL
SDK_VERSION_PATTERN=$(printf '%s' "${SWIFT_TOOLCHAIN_VERSION}" | sed 's/[.]/\\./g')
if ! echo "${LINUX_SDK_URL}" | grep -q -E "${SDK_VERSION_PATTERN}"; then
  echo "The Swift version in the Linux Statick SDK does not match the provided Swift toolchain version for Swift Setup!"
  exit 1
fi
