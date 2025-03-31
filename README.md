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
You can call this just like any other reusable Github Workflow, with some required input parameters. **Just make sure that there is no file or directory named `ci-scripts` in the root directory of your project,** as this worklow will sparse check out the bash script dependencies into that directory at the root of your repository!

For more information on how, [check out this page](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows).

[Click here for a reference configuration of the *Build* task.](https://github.com/BertanT/WatchDuck/blob/main/.github/workflows/build.yml)
[Click here for a reference configuration of the *Release* task.](https://github.com/BertanT/WatchDuck/blob/main/.github/workflows/build.yml)

## What's Next?
* Will extend the CI pipeline to generate Homebrew and APT package releases.
* The changelog updater will be optional, as some projects may not want to use it.
* ... let me know in the [Issues](https://github.com/BertanT/SwiftPM-Cross-Comp-CI/issues) page if you have any other ideas or suggestions!