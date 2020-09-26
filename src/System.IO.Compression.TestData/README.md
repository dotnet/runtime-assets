Code like the following may be used to generate compressed files for test data, using the files in UncompressedTestFiles as the raw input.
```C#
using System;
using System.IO;
using System.IO.Compression;

Compress("BrotliTestData", ".br", (fs, cl) => new BrotliStream(fs, cl));
Compress("DeflateTestData", "", (fs, cl) => new DeflateStream(fs, cl));
Compress("GZipTestData", ".gz", (fs, cl) => new GZipStream(fs, cl));
Compress("ZLibTestData", ".zl", (fs, cl) => new ZLibStream(fs, cl));

static void Compress(string directoryName, string suffix, Func<FileStream, CompressionLevel, Stream> createStream)
{
    const string RootPath = @"D:\repos\runtime-assets\src\System.IO.Compression.TestData\";

    int type = 0;
    foreach (string path in Directory.EnumerateFiles(Path.Combine(RootPath, @"UncompressedTestFiles"), "*", SearchOption.AllDirectories))
    {
        using FileStream source = File.OpenRead(path);
        using FileStream fs = File.Create(path.Replace("UncompressedTestFiles", directoryName) + suffix);
        using var cs = createStream(fs, (CompressionLevel)(type++ % 3)); // exact CompressionLevel selected doesn't matter
        source.CopyTo(cs);
    }
}
```
