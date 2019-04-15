# CoreFx-TestData

This repository contains test assets which are too large to be checked into corefx directly. Packages are produced and uploaded to the dotnet blob feed (https://dotnetfeed.blob.core.windows.net/dotnet-core/index.json).

## Workflow
1. Run `dotnet pack` in the repo root.
2. Select the nupkg to upload under `$(RepoRoot)\$(ProjectDir)\bin\`
3. Use this build definition to upload the package to the dotnet blob feed: https://github.com/dotnet/core-eng/tree/master/Documentation/Tools/dotnet-core-push-oneoff-package. Make sure to clear the myget feed in the queue time variable section.
4. Consume the package in corefx.
