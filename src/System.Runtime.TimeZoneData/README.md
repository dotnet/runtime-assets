This is a copy of the text files from the [IANA timezone database](https://www.iana.org/time-zones) To update to the most recent versions change
```xml
    <TimeZoneDataVersion>2020d</TimeZoneDataVersion>
```
To the [latest version](https://data.iana.org/time-zones/tzdb/version) and run `dotnet build /t:UpdateData`

To check if the included version is up to date run `dotnet build /t:CheckVersion`