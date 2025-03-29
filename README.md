# SwiftPM-Cross-Comp-CI
An extensive GitHub Workflow CI pipeline to cross-compile, test, hash, release executable Swift Binaries for macOS and Linux.
Originally built for the [WatchDuck](https://github.com/BertanT/WatchDuck) project, I am relesing it as a reusable template for other projects!

This CI pipeline is specifically intended for cross-platfrom SwiftPM projects with executable products inteded to run on both macOS and Linux!
 
**The current version requires the host to have a `CHANGELOG.MD` file following the [Keep a Changelog](https://keepachangelog.com) format.**

## Features
* Cross compiles macOS and Linux binaries on a macOS Action Runner
* Customizable Swift Toolchain and Static Linux SDK versions.
* Statically links Linux Binaries
* Created universal binary for macOS
* Follows the [Keep a Changelog](https://keepachangelog.com) format to automatically generate release notes and updates the Changelog links with new releases
* Creates release tarballs, project bundles included!
* Creates sha256 hash files along the release artifacts, also adding them descriptibely to the release notes

## How to use
You can call this just like any other reusable Github Workflow. For more information on how, [check out this page](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows).

For a reference configuration, [take a look at the WatchDuck workflow configuration!](https://github.com/BertanT/WatchDuck/blob/main/.cross-comp-ci/.github/workflows/build-release.yml)

## What's Next?
* Will extend the CI pipeline to generate Homebrew and APT package releases.
* The changelog updater will be optional, as some projects may not want to use it.
* ... let me know in the [Issues](http://github.com/BertanT/SwiftPM-Cross-Comp-CI/Issues/) page if you have any other ideas or suggestions!