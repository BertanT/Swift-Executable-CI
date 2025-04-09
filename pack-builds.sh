#!/bin/bash
#################################################################################################################################
# pack-builds.sh
# Created on 03/27/2025
#
# Copyright (C) 2025 Mehmet Bertan Tarakcioglu, Under the MIT License
#
# This file was originally created as part of the WatchDuck project CI Pipeline.
#################################################################################################################################

# This script is meant to run on a GitHub macOS Action Runner as part of the SwiftPM-Cross-Comp-CI workflows!
# It assumes to be part of the workflow and may fail if it is being run by itself.

# This script takes all the compiled binaries and packages them into tarballs, ready for release and distribution!

# Exit bash script on error
set -e

# Create a directory to store the tarballs
mkdir -p .build/tarballs

# Package macOS universal binary
cd .build/macos-universal/release
tar -czf "../../../.build/tarballs/${EXEC_NAME}-${NEW_TAG}-macos-universal.tar.gz" .
cd -

# Package Linux aarch64 binary
cd .build/aarch64-swift-linux-musl/release
tar -czf "../../../.build/tarballs/${EXEC_NAME}-${NEW_TAG}-linux-aarch64.tar.gz" ${EXEC_NAME} *.resources
cd -

# Package Linux x86_64 binary
cd .build/x86_64-swift-linux-musl/release
tar -czf "../../../.build/tarballs/${EXEC_NAME}-${NEW_TAG}-linux-x86_64.tar.gz" ${EXEC_NAME} *.resources
cd -

# Loop through every file in the tarballs directory and create a SHA 256 sum for each file
cd .build/tarballs
for file in *; do
    if [[ "${file}" != *".sha256" ]]; then
        shasum -a 256 "${file}" > "${file}.sha256"
    fi
done
cd -
