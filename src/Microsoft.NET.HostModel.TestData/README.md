# Microsoft.NET.HostModel.TestData

This project contains binary Mach-O files that are used to test the `Microsoft.NET.HostModel` implementation of ad-hoc signing.

To produce the binary files, run `dotnet build -t:GenerateMachOBinaries` on a macOS machine with `clang` installed. The version of `clang` used for the files in the current commit is `Apple clang version 16.0.0 (clang-1600.0.26.3)`.
