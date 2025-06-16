#!/bin/bash
#################################################################################################################################
# run-swiftlint.sh
# Created on 06/16/2025
#
# Copyright (C) 2025 Mehmet Bertan Tarakcioglu, Under the MIT License
#
# This file was originally created as part of the WatchDuck project CI Pipeline.
#################################################################################################################################

# This script is meant to run on a GitHub macOS Action Runner as part of the SwiftPM-Cross-Comp-CI workflows!
# It assumes to be part of the workflow and may fail if it is being run by itself.

# Exit bash script on error
set -eo pipefail

# List dependencies and check if swiftlint is one
if swift package plugin --list | grep -q "\‘swiftlint\’ (plugin \‘SwiftLintCommandPlugin\’ in package \‘SwiftLintPlugins\’)"; then
    swift package plugin --allow-writing-to-package-directory swiftlint lint --progress
else
    echo "Warning: The SwiftLint build tool plugin was not found in your project. Skipping..."
fi
