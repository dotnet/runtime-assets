namespace Microsoft.NET.HostModel.TestData;

public class MachObjects
{
    static readonly string[] s_dataFileNames = ["a.out", "a.unsigned.out", "a.signed.out" ];

    public static List<(string Name, Stream Data)> GetAll()
    {
        List<(string Name, Stream Data)> dataStreams = new(s_dataFileNames.Length);
        foreach (string name in s_dataFileNames)
        {
            Stream stream = typeof(MachObjects).Assembly.GetManifestResourceStream($"Microsoft.NET.HostModel.TestData.data.{name}")
                ?? throw new InvalidOperationException($"Resource '{name}' not found.");
            dataStreams.Add((name, stream));
        }
        return dataStreams;
    }
}
