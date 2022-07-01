# System&period;Net test certificates

This package contains test certificates for `System.Net` library.

The `TestData` directory is considered obsolete. The certificates are encrypted with RC2 and triple des encryption. The pfx password is `testcertificate`.

The `TestDataCertificates` directory contains the same pfx certificates as in `TestData` however they are all encrypted by triple des encryption. The pfx password is `PLACEHOLDER`.

The `res` directory is necessary for running tests on Android. It contains the `network_security_config.xml` file and public keys in the PEM format exported from the data in the TestDataCertificates directory (see [Network security configuration on Android](https://developer.android.com/training/articles/security-config)).

