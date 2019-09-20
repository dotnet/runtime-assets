# CoreFx-TestData

This repository contains test assets that are binary files or too large to be checked into corefx directly. Packages are produced and uploaded to the dotnet blob feed: https://dotnetfeed.blob.core.windows.net/dotnet-core/index.json.

Uploading the packages is currently a manual step. Community members can submit PRs but the deployment needs to be done by a .NET team member as described below.

## Workflow

1. Modify the \*.csproj project file(s) and increment the version number.
2. Generate the nuget package file for your new test data using `dotnet pack`.
3. (Optional) Test that corefx can import the new nuget package file.
4. Submit a corefx-testdata PR with your new test assets and bumped version project file.
5. Upload the nuget package file to the dotnet blob feed (only .NET team members can do this). See: https://github.com/dotnet/core-eng/tree/master/Documentation/Tools/dotnet-core-push-oneoff-package
6. Submit a corefx PR with your unit test changes that consume the new nuget package. Update the test data's package version here: https://github.com/dotnet/corefx/blob/master/eng/Versions.props#L67-L74.


## Example

We are going to make the following assumptions:

- We cloned the `dotnet/corefx-testdata` GitHub repo in `D:\corefx-testdata`.
- We cloned the `dotnet/corefx` GitHub project in `D:\corefx`.
- We are working on adding a new unit test for the GZip feature from the `System.IO.Compression` namespace, and the test depends on a file called `example.gz`.
- We already compiled corefx with `build.cmd`.

#### 1. Modify the project file(s) and increment the version number.

Save `example.gz` inside `corefx-testdata\System.IO.Compression.TestData\GZipTestData`.

Edit the `corefx-testdata\System.IO.Compression.TestData\System.IO.Compression.TestData.csproj` file and bump the patch fragment of the version number.

*Note: if the version was 1.0.9, bump it to 1.0.10, not 1.1.0.*

```xml
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <PackageVersion>1.0.10</PackageVersion>
    </PropertyGroup>
</Project>
```

#### 2. Generate the nuget package file for your new test data using `dotnet pack`.

From the directory where your *.csproj file is located, run `dotnet pack` and you'll get an output like this:

```
P SD:\corefx-testdata\System.IO.Compression.TestData> dotnet pack

    Microsoft (R) Build Engine version 16.1.68-preview+g64a5b6be6d for .NET Core
    Copyright (C) Microsoft Corporation. All rights reserved.

    Restore completed in 28.78 ms for D:\corefx-testdata\System.IO.Compression.TestData\System.IO.Compression.TestData.csproj.
    C:\Program Files\dotnet\sdk\2.1.700-preview-009618\Sdks\Microsoft.NET.Sdk\targets\Microsoft.NET.RuntimeIdentifierInference.targets(143,5): message NETSDK1057: You are working with a preview version of the .NET Core SDK. You can define the SDK version via a global.json file in the current project. More at https://go.microsoft.com/fwlink/?linkid=869452 [D:\corefx-testdata\System.IO.Compression.TestData\System.IO.Compression.TestData.csproj]
    System.IO.Compression.TestData -> D:\corefx-testdata\System.IO.Compression.TestData\bin\Debug\netstandard2.0\System.IO.Compression.TestData.dll
```

*Note: Running `dotnet pack` from the root of the `corefx-testdata` project will generate the nuget packages for all the \*.csproj files.*

The generated nuget file(s) will be located in the `bin\Debug` subfolder:

`D:\corefx-testdata\System.IO.Compression.TestData\bin\Debug\System.IO.Compression.TestData.1.0.10.nupkg`


#### 3. Test that corefx can import the new nuget package file.

We need to make sure our change works by importing the generated nuget package file into our corefx project.

Open the `corefx\eng\Versions.props` file, find an xml item that ends with `<*TestDataPackageVersion>`, and begins with the namespace (without dots) for which you're adding a dependency. For our example, the element is called '<SystemIOCompressionTestDataPackageVersion>'. Bump the version to the one you used in step 1:

```xml
<!-- Test Data -->
...
<SystemIOCompressionTestDataPackageVersion>1.0.10</SystemIOCompressionTestDataPackageVersion>
...
```

**Note**: If the test data folder is being added to corefx-data for the first time, you need to add the above entry to `Versions.props`, and then edit your test project to consume it:

corefx\src\System.IO.Compression\tests\System.IO.Compression.Tests.csproj:
```xml
<ItemGroup>
    <PackageReference Include="System.IO.Compression.TestData" Version="$(SystemIOCompressionTestDataPackageVersion)" ExcludeAssets="contentFiles" GeneratePathProperty="true" />
    <None Include="$(PkgSystem_IO_Compression_TestData)\contentFiles\any\any\**\*" CopyToOutputDirectory="PreserveNewest" Visible="false" />
</ItemGroup>
```

Make sure you have a local package source defined in your nuget configuration. Open the file `corefx\NuGet.config` and make sure there's an entry that points to the location where the nupkg file was saved in step 2:

```xml
...
<packageSources>
  ...
  <add key="local" value="D:\corefx-testdata\System.IO.Compression.TestData\bin\Debug\" />
  ...
</packageSources>
...
```

Now restore the packages for your test project in corefx:

```
PS D:\corefx> .\.dotnet\dotnet.exe restore src\System.IO.Compression\tests\System.IO.Compression.Tests.csproj
  ...
  Restore completed in 253.06 ms for D:\corefx\src\Common\tests\CoreFx.Private.TestUtilities\CoreFx.Private.TestUtilities.csproj.
  Restore completed in 2.64 sec for D:\corefx\src\System.IO.Compression\tests\System.IO.Compression.Tests.csproj. 
  ...
```

 Now check if the nuget package was restored correctly. Go to your current user's nuget packages folder, usually located in `%UserProfile%\.nuget\packages`. Find the folder for your TestData and inside you should see a new folder with the new version of the package you produced:

```
PS D:\corefx> dir $Env:UserProfile\.nuget\packages\System.IO.Compression.TestData\1.0.10\

    Directory: C:\Users\yourusername\.nuget\packages\System.IO.Compression.TestData\1.0.10

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----        3/25/2019   3:55 PM                content
-a----        3/25/2019   3:55 PM            130 .nupkg.metadata
-a----        3/25/2019   3:55 PM       54372842 system.io.compression.testdata.1.0.10.nupkg
-a----        3/25/2019   3:55 PM             88 system.io.compression.testdata.1.0.10.nupkg.sha512
-a----        3/25/2019   3:55 PM           1034 system.io.compression.testdata.nuspec


PS D:\corefx> dir $Env:UserProfile\.nuget\packages\System.IO.Compression.TestData\1.0.10\content\GZipTestData\

    Directory: C:\users\yourusername\.nuget\packages\System.IO.Compression.TestData\1.0.10\content\GZipTestData

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        3/25/2019  3:55 PM           1748 example.gz
```

**Note**: If you made a mistake and need to update this version's file (in other words, you need to do steps 1-3 again), make sure to delete the directory `%UserProfile%\.nuget\packages\System.IO.Compression.TestData\1.0.10`, because it's not going to get overwritten.


#### 4. Submit a corefx-testdata PR with your new test assets and bumped version project file.

Any community member can submit corefx-data changes, but make sure to notify a .NET team member so they can help with step 6.

Your PR should include:
- The new test data file(s) like `example.gz`.
- The `*.csproj` file(s) with the bumped version.

#### 5. Upload the nuget package file to the dotnet blob feed.

**Important: Only .NET team members can do this step.**

Use this build definition to upload it:
https://github.com/dotnet/core-eng/tree/master/Documentation/Tools/dotnet-core-push-oneoff-package.

Make sure to clear the myget feed in the queue time variable section.

#### 6. Submit a corefx PR with your unit test changes that consume the new nuget package.

Make sure your PR is submitted after the nuget package is officially located to the dotnet blob feed.

Your PR should include:
- The `XUnit.Runtime.depproj` file with the bumped version.
- The `*.csproj` file(s) with the bumped version.
- All the `*.cs` unit test files consuming the new test data files.
