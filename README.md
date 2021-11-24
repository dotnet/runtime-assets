# Runtime-Assets

This repository contains assets that are binary files or too large to be checked in directly. Packages are uploaded to the default transport channel's feed.

## Workflow

1. Submit a PR with the new assets.
2. After the PR is merged, an internal build publishes assets to the Build Assets Registry and an auto PR will be opened in the subscribing repositories.

- Optional step: Local testing.

## Example

Let's assume we are adding a new unit test for the GZip feature from the `System.IO.Compression` namespace, and the test depends on a file called `example.gz`.

### 1. Submit a PR to runtime-assets with the new files.

### 2. Post-merge

After the PR is merged an internal build will publish the packages to a public feed and update the Build Assets Registry. Subscribers to this repository will receive an auto PR update with the updated package version.
### Optional step: local testing

Testing your assets in your local machine is an optional step you can perform before submitting your PR.
Local testing is usually not necessary due to the nature of this repository, which mostly only deals with static files.
Feel free to skip this section.

a) Save `example.gz` inside `runtime-assets\src\System.IO.Compression.TestData\GZipTestData`.

b) Run `build.cmd --pack` from the `runtime-assets\` root folder.

c) Verify that your package was generated with the new test data.

  I.  Go to `runtime-assets\artifacts\packages\Debug\NonShipping`.
  II.  Temporarily rename `System.IO.Compression.TestData.7.0.0-dev.nupkg` to the extension `*.nupkg.zip`.
  III.  Open it with your preferred Zip app.
  IV.  Inside the zip, navigate to `contentFiles\any\any\GZipTestData` and verify that the new `example.gz` file can be found there.
  V.  Close the Zip window, and revert the name to `*.nupkg`.

d)  Go to your `runtime` folder.

e)  Edit `Nuget.config` located in the root folder, and inside the `<packageSources>` section, add a new key that points to the temporary folder as a source: `<add key="tmp" value="D:\runtime-assets\artifacts\packages\Debug\NonShipping" />` (make sure to adjust the root path to your repo folder).

f) Go to `runtime\src\libraries\System.IO.Compression\tests` and run `dotnet build` or `dotnet restore`. This will force consuming the new nupkg and will place it in your local `.nuget` cache (usually, it's `C:\Users\%USERNAME%\.nuget`).

g) At the time of writing this guide, the .NET version tracked in the `main` branch of the `runtime` repo was 7.0. So for this example, assume the version number is `7.0.0`. Navigate to your local `.nuget` folder, go to `.nuget\System.IO.Compression.TestData` and verify that the folder `7.0.0-dev` is there, and that `7.0.0-dev\contentFiles\any\any\GZipTestData\example.gz` is there.

h) Run your new unit test that depends on that file, it should be able to find the file.

i) If you need to update the package with additional files, make sure to delete the folder `.nuget\System.IO.Compression.TestData\7.0.0-dev\`, then repeat steps **b** through **h**.
