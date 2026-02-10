fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Upload metadata to App Store Connect

### ios build

```sh
[bundle exec] fastlane ios build
```

Build release archive

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Upload build to App Store Connect

### ios set_age_rating

```sh
[bundle exec] fastlane ios set_age_rating
```

Set age rating to 4+ (all content ratings NONE)

### ios prepare_submission

```sh
[bundle exec] fastlane ios prepare_submission
```

Set pricing to Free and upload copyright

### ios swap_build

```sh
[bundle exec] fastlane ios swap_build
```

Switch build on app store version to Build 2 (iPhone-only)

### ios cancel_review

```sh
[bundle exec] fastlane ios cancel_review
```

Cancel App Store review submission

### ios release

```sh
[bundle exec] fastlane ios release
```

Full pipeline: build, upload, metadata

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
