# Microsoft.NET.HostModel.TestData

This project contains binary Mach-O files that are used to test the .NET host ad-hoc signing.

To produce the binary files, run make on a an arm64 macOS machine with `clang` installed in the `./MachO/src` directory. The version of `clang` used for the files in the current commit is `Apple clang version 16.0.0 (clang-1600.0.26.3)`.
