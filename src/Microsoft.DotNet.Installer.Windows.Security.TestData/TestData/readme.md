
## triple_signed.dll

This file contains 3 Microsoft AuthentiCode signatures and is used to verify CryptQueryObject implementations to
construct SignedCms objects and extract nested signatures.

## dual_signed.dll

This file is dual signed with the .NET Foundation and Microsoft 3rd Party Application SHA2 certificates. It's used to
test some of the CLI installer logic to verify trusted origanizations.

## tampered.msi

Signed MSI from .NET Runtime, edited in Orca to change the ProductName in the Properties table which should have invalidated the signature.
