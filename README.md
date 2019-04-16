# CoreFx-TestData

This repository contains test assets that are binary file or too large to be checked into corefx directly. Packages are produced and uploaded to the dotnet blob feed (https://dotnetfeed.blob.core.windows.net/dotnet-core/index.json).

Uploading the packages is currently a manual step. Community members can submit PRs but the deployment needs to be done by a .NET team member as described below.

## Workflow
1. Make changes in the respective project and increments its version (usually just the patch fragment)
2. Run `dotnet pack` on the project and find the produced nuget package in the project's bin folder.
3. Use this build definition to upload the package to the dotnet blob feed: https://github.com/dotnet/core-eng/tree/master/Documentation/Tools/dotnet-core-push-oneoff-package. Make sure to clear the myget feed in the queue time variable section.
4. Consume the updated package in corefx by incrementing the `PackageReference` version attribute: https://github.com/dotnet/corefx/blob/8d79b6117e9d584eebb8b6933bba83dd514010ca/external/test-runtime/XUnit.Runtime.depproj#L47-L54
