# Runtime-Assets

This repository contains assets that are binary files or too large to be checked in directly. Packages are produced and uploaded to the dotnet blob feed: https://dotnetfeed.blob.core.windows.net/dotnet-core/index.json.

Uploading the packages is currently a manual step. Community members can submit PRs but the deployment needs to be done by a .NET team member as described below.

## Workflow
1. Modify the \*.csproj project file(s) and increment the version number.
2. Submit a PR with the new assets and bumped version project file.
3. After the PR is merged, an internal build publishes assets to the Build Assets Registry and an auto PR will be opened in the subscribing repositories.

## Example
We are working on adding a new unit test for the GZip feature from the `System.IO.Compression` namespace, and the test depends on a file called `example.gz`.

#### 1. Modify the project file(s) and increment the version number.
Save `example.gz` inside `runtime-assets\System.IO.Compression.TestData\GZipTestData`.

Edit the `runtime-assets\System.IO.Compression.TestData\System.IO.Compression.TestData.csproj` file and bump the patch fragment of the version number.

*Note: if the version was 1.0.9, bump it to 1.0.10, not 1.1.0.*

```xml
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <PackageVersion>1.0.10</PackageVersion>
    </PropertyGroup>
</Project>
```

### 2. Submit a PR with the changes
After the PR is merged an internal build will publish the packages to an internal feed and update the Build Asset Registry. Subscribers to this repository will get an auto PR update with the updated package version.