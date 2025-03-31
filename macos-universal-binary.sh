#!/bin/bash
#################################################################################################################################
# macos-universal-binary.sh
# Created on 03/27/2025
#
# Copyright (C) 2025 Mehmet Bertan Tarakcioglu, Under the MIT License
#
# This file was originally created as part of the WatchDuck project CI Pipeline.
#################################################################################################################################

# This script is meant to run on a GitHub macOS Action Runner as part of the SwiftPM-Cross-Comp-CI workflows!
# It assumes to be part of the workflow and may fail if it is being run by itself.

# This script combines macOS build binaries and generates a singel universal binary in its own build directory.

# Exit bash script on error
set -e

# Create a new directory to contain the universal binary build
mkdir -p ".build/macos-universal/release"

# Create universal binary
lipo -create ".build/arm64-apple-macosx/release/${EXEC_NAME}" ".build/x86_64-apple-macosx/release/${EXEC_NAME}" \
    -output ".build/macos-universal/release/${EXEC_NAME}"

# Copy the universal binary and its bundle to its new home!
cp -r ".build/arm64-apple-macosx/release/"*.bundle ".build/macos-universal/release"