# Swift-Executable-CI
An extensive GitHub Workflow CI pipeline to cross-compile, lint, validate, hash, and release binary artifacts for Swift Packages with executable targets for macOS and Linux.

Originally built for the [WatchDuck](https://github.com/BertanT/WatchDuck) project, I am releasing it as a reusable workflow for everyone!

## 🌈 Features
* Automatic builds on pushes to `main`, pull requests, and manual trigger.
* Seamless release workflow with customizable release tags.
* Cross-compiles macOS and Linux binaries on a macOS Action Runner.
* Statically links Linux binaries and creates universal binaries for macOS.
* Creates tarballs for the builds along with a SHA256 hash file for each.
* Runs SwiftLint on your project if its pre-build plugin is set up in your project.
* Follows the [Keep a Changelog](https://keepachangelog.com) format to automatically generate release notes and update the Changelog links with new releases.
* Customizable Swift Toolchain and Static Linux SDK versions.

## 🐣 Quick Setup
* Create a file at `.github/workflows/build.yml` in your repository, including the parent directories. Copy the contents of the [build-template.yml](build-template.yml) file from this repository into the file you created.
* Similarly, create another file at `.github/workflows/release.yml` in your repository, and copy the contents of the [release-template.yml](release-template.yml) file from this repository into the file you created.
* Go to your repository's settings, click on the *"Secrets and variables"* tab, then click on *"Actions"* underneath. On this page, click on the "Variables" tab, and create the following required *Repository Variables* with the specified values:
    * **`EXEC_NAME`:** This should be the exact name of the executable target you wish the CI to build, specified in your `Package.swift` file.
    * **`SWIFT_TOOLCHAIN_VERSION`:** The version of Swift that will be used to build your project. This should be the full version number, such as `6.1.2`.
    * **`LINUX_SDK_URL`:** The release URL of the Swift *Static Linux SDK* that will be used to build your project. The version of the linked SDK **must match the** `SWIFT_TOOLCHAIN_VERSION`. For Swift 6.1.2, this is `https://download.swift.org/swift-6.1.2-release/static-sdk/swift-6.1.2-RELEASE/swift-6.1.2-RELEASE_static-linux-0.0.1.artifactbundle.tar.gz`
    * **`LINUX_SDK_CHECKSUM`:** The SHA256 checksum for the *Static Linux SDK* that you linked in the previous step. For Swift 6.1.2, this is `df0b40b9b582598e7e3d70c82ab503fd6fbfdff71fd17e7f1ab37115a0665b3b`
* Optionally, add the following *Repository Variables* as needed:
    * **`BUILD_RUN_SWIFTLINT`:** Optional. By default, the build workflow will try to run SwiftLint if it has been set up in your project. If you wish to disable this and override the enabled state when manually triggering the workflow, add this variable and set it to `false` (case sensitive).
    * **`RELEASE_RUN_SWIFTLINT`:** Optional. Same functionality as `BUILD_RUN_SWIFTLINT`, but for the release workflow!
    * **`UPDATE_CHANGELOG`:** Optional. By default, the release workflow will try to auto-generate release notes and update your Changelog file, if you have one. Any file named `Changelog`, case insensitive, with any extension will work. **The only supported format is from [Keep a Changelog](https://keepachangelog.com).** If you have a Changelog file but do not follow this format, please disable it to avoid potential issues, despite the CI explicitly checking for correct formatting before modifying files. If you wish to disable this and override the enabled state when manually triggering the workflow, add this variable and set it to `false` (case sensitive).
* Go to your repository settings, click on the *"Actions"* tab, then click on *"General"* underneath. Scroll down to the *"Workflow permissions"* section, and select the *"Read and write permissions"* option. This is required for the CI to be able to create releases and update the Changelog file.

**Note:** If you are using SwiftLint, make sure to configure your `.swiftlint.yml` file to exclude the `.build` directory of your project, since package dependencies are checked out there. This usually isn't a problem while using Xcode, but it can cause issues in the CI environmnet or the CLI.

## 🚀 Usage
Once the setup is complete using the default templates, the `build` workflow will automatically build your executable for macOS and Linux (on ARM64 and x86_64 architectures for each) whenever there is a push to the `main` branch, a pull request is opened, or a manual trigger from the *Actions* tab on your repository home page.

When you are ready to release a new version of your project, you can manually trigger the `release` workflow from the *Actions* tab in your repository home page. Click *"Release"* on the menu on the left. Then, click the *"Run Workflow"* button, provide a new, unused tag name for the release, and run!

This will create a release with a universal binary tarball for macOS, statically linked Linux binary tarballs for both ARM64 and x86_64, as well as `SHA256` hash files for each of the release artifacts. It will also automatically pull release notes from the `[Unreleased]` section of your Changelog file and update the section title with the new tag and date if you have one.

## 🚂 Going Further
Feel free to customize the workflow YAML files to fit your specific needs!

If you have any questions or need help, you can contact me via the [Discussions](https://github.com/BertanT/Swift-Executable-CI/discussions) page!

#### Here is a list of features that I plan to add in the future:
* Will extend the CI pipeline to generate Homebrew and APT package releases.
* ... let me know in the [Issues](https://github.com/BertanT/Swift-Executable-CI/issues) page or feel free to contribute to this project if you have any other ideas or suggestions!

###### Copyright 2025 Mehmet Bertan Tarakcioglu (github.com/BertanT), under the MIT License.