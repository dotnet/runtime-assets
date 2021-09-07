# Runtime-Assets

This repository contains assets that are binary files or too large to be checked in directly. Packages are uploaded to the default transport channel's feed.

## Workflow
1. Submit a Pull Request with the new assets.
2. After the PR is merged, an internal build publishes assets to the Build Assets Registry and an auto PR will be opened in the subscribing repositories.

## Example
We are working on adding a new unit test for the GZip feature from the `System.IO.Compression` namespace, and the test depends on a file called `example.gz`.

#### 1. Submit a PR with the new assets.
Save `example.gz` inside `runtime-assets\src\System.IO.Compression.TestData\GZipTestData`.

### 2. Post-merge
After the PR is merged an internal build will publish the packages to an internal feed and update the Build Assets Registry. Subscribers to this repository will receive an auto PR update with the updated package version.
