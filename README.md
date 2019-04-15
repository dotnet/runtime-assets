The purpose of the corefx-testdata repo is to store corefx test file dependencies.

Large test inputs (eg. over 1MB) should not bloat the corefx repo. Instead, they have their own dedicated repo, and the corefx build process pulls them via MyGet. The advantage of this is that their bloated history is not stored locally.

Steps to add test inputs to this repo:

1. Clone the corefx-testdata repo.

2. In the root folder of the corefx-testdata repo, locate the folder with the namespace of the tests you are working on and place your input files inside this folder in the appropriate location.

### **Example**

Let's say you are adding tests in the ````System.IO.Compression```` namespace for the GZip features. You can save your new file called example.gz inside the folder:

````corefx-testdata/System.IO.Compression.TestData/GZipTestData/````
 
 3. In the root folder of the corefx-testdata repo, locate the *.nuspec file for your namespace, then:

    a) Bump the version by one.

    b) Add a new file entry for each one of your new files, where src points to the relative path inside corefx-testdata and target points to the location inside NuGet (simply substitute the namespace folder with "content").

### **Example**

Open the file ```System.IO.Compression.TestData.nuspec```.

Locate the ````<version>```` element. If the current version is:

````xml
<version>1.0.7-prerelease</version>
````

then bump it to:

````xml
<version>1.0.8-prerelease</version>
````

Locate the ````<files>```` element and add a new entry for your example.gz file:

````xml
<file src="System.IO.Compression.TestData\GZipTestData\example.gz" target="content\GZipTestData\example.gz" />
````

4. Download nuget.exe from https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools and save it inside the corefx-testdata root folder.

5. From a command line located in the root folder of corefx-testdata, execute the nuget pack command against the nuspec file.

### **Example**

````
PS C:\your\path\to\corefx-testdata> nuget.exe pack System.IO.Compression.TestData.nuspec

    Attempting to build package from 'System.IO.Compression.TestData.nuspec'.
    Successfully created package 'C:\your\path\to\corefx-testdata\System.IO.Compression.TestData.1.0.8-prerelease.nupkg'.
````

*Notice a new \*.nupkg file was generated at the root of corefx-testdata. It will later be used to replace the original NuGet packages.*

6. Now we need to import the generated NuGet package to corefx, so at this point we will assume you have a local clone of the corefx project already compiled. Open the file ````corefx\external\test-runtime\XUnit.Runtime.depproj````, find the PackageReference element of your TestData and bump the version to the same you bumped in step 1.a.

### **Example**

````xml
<!-- Test Data -->
<PackageReference Include="System.IO.Compression.TestData" Version="1.0.8-prerelease" />
````

7. Now override the default dependencies with your newly generated dependencies. From the root folder of the corefx repo, execute:

```
PS C:\your\path\to\corefx> dotnet msbuild /p:overridepackagesource=C:\your\path\to\corefx-testdata
```

8. You can now check if the nuget package was exported correctly. Go to your current user's Nuget packages folder, usually located in ````C:\Users\yourusername\.nuget\packages````. Find the folder for your TestData and inside you will find the original dependencies plus the new ones you added.

### **Example**

Notice the new \*.gz file is located inside the "content" directory as it was indicated in the ````<file>```` element added to the \*.nuspec file in step 3.b:

````
PS C:\your\path\to\corefx> cd C:\Users\yourusername\.nuget\packages

PS C:\users\yourusername\.nuget\packages> dir System.IO.Compression.TestData

    Directory: C:\users\yourusername\.nuget\packages\System.IO.Compression.TestData

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----        3/01/2019   9:54 PM                1.0.7-prerelease
d-----        3/25/2019   3:55 PM                1.0.8-prerelease


PS C:\users\yourusername\.nuget\packages> dir .\System.IO.Compression.TestData\1.0.8-prerelease\

    Directory: C:\users\yourusername\.nuget\packages\System.IO.Compression.TestData\1.0.8-prerelease

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----        3/25/2019   3:55 PM                content
-a----        3/25/2019   3:55 PM            130 .nupkg.metadata
-a----        3/25/2019   3:55 PM       54372842 system.io.compression.testdata.1.0.8-prerelease.nupkg
-a----        3/25/2019   3:55 PM             88 system.io.compression.testdata.1.0.8-prerelease.nupkg.sha512
-a----        3/25/2019   3:55 PM           1034 system.io.compression.testdata.nuspec


PS C:\users\yourusername\.nuget\packages> dir .\System.IO.Compression.TestData\1.0.8-prerelease\content\

    Directory: C:\users\yourusername\.nuget\packages\System.IO.Compression.TestData\1.0.8-prerelease\content

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
...// many files
d-----        3/25/2019   3:55 PM                GZipTestData
...// many files


PS C:\users\yourusername\.nuget\packages> dir .\System.IO.Compression.TestData\1.0.8-prerelease\content\GZipTestData\

    Directory: C:\users\yourusername\.nuget\packages\System.IO.Compression.TestData\1.0.8-prerelease\content\GZipTestData

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
...// many files
-a----        3/25/2019  3:55 PM           1748 example.gz
...// many files

````

9. Now add can import the new nuget package to your Visual Studio project. Open the test \*.csproj file with notepad, find the SupplementalTestData element pointing to the old version of your namespace's TestData package and make it point to the new version. If the SupplementalTestData does not exist, add one.

### **Example**

We are going to add our new tests to ````corefx\src\System.IO.Compression\tests\System.IO.Compression.Tests.csproj````. The SupplementalTestData element was at the end of the file, and it will now look like this:

````xml
  <ItemGroup>
    <SupplementalTestData Include="$(PackagesDir)system.io.compression.testdata\1.0.8-prerelease\content\**\*.*">
      <Link>%(RecursiveDir)%(Filename)%(Extension)</Link>
    </SupplementalTestData>
  </ItemGroup>
````

*Notice that it's adding all the folders inside content.*

10. You can now consume your new input \*.gz file when running your unit test locally.

11. Make sure to send a pull request with your corefx-testdata changes first, wait for the nuget dependency to be generated officially, and then you can submit your pull request for your new test changes in corefx.

- Here is a PR example of the changes needed in corefx-testdata: https://github.com/dotnet/corefx-testdata/pull/23
- Here is a PR example of the changes needed in corefx: https://github.com/dotnet/corefx/pull/28487/files
