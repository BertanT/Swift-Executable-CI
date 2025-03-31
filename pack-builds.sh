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

# Define an array of target directories and their corresponding tarball names
declare -A targets=(
    [".build/aarch64-swift-linux-musl/release"]="linux-aarch64"
    [".build/x86_64-swift-linux-musl/release"]="linux-x86_64"
)

# Loop through the targets and package binaries
for dir in "${!targets[@]}"; do
    cd "$dir"
    tarball_name="${targets[$dir]}"
    if compgen -G "*.resources" > /dev/null; then
        tar -czf "../../../.build/tarballs/${EXEC_NAME}-${NEW_TAG}-${tarball_name}.tar.gz" ${EXEC_NAME} *.resources
    else
        tar -czf "../../../.build/tarballs/${EXEC_NAME}-${NEW_TAG}-${tarball_name}.tar.gz" ${EXEC_NAME}
    fi
    cd -
done

# Loop through every file in the tarballs directory and create a SHA 256 sum for each file
cd .build/tarballs
for file in *; do
    if [[ "${file}" != *".sha256" ]]; then
        shasum -a 256 "${file}" > "${file}.sha256"
    fi
done
cd -