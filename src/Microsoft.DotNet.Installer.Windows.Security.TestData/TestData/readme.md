## BootstrapperCore.dll

WiX binary, signed by .NET Foundation, terminates in a non-Microsoft root (DigiCert).

## dotnet_realsigned.exe

.NET host executable, signed with the .NET Authenticode certificate, trusted Microsoft root.

## dual_signed.dll

This file is dual signed with the .NET Foundation and Microsoft 3rd Party Application SHA2 certificates. 

## System.Web.Mvc.dll

SHA1 signed assembly - valid authenticode, but no longer a trusted Microsoft trusted root.

## tampered.msi

Signed MSI from .NET Runtime, edited in Orca to change the ProductName in the Properties table to invalidate the signature.


